import 'dart:math';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:fftea/fftea.dart';

class AfinadorService {
  final FlutterAudioCapture _audioCapture = FlutterAudioCapture();
  
  // Este es el "puente" que enviará los datos a tu pantalla
  Function(double frecuencia, String nota, double desviacion)? onData;

  // Configuración técnica
  final int sampleRate = 44100;
  final int bufferSize = 4096;

  void iniciar() async {
    try {
      await _audioCapture.init();
      await _audioCapture.start(
        _audioCallback, 
        _errorCallback, 
        sampleRate: sampleRate, 
        bufferSize: bufferSize
      );
    } catch (e) {
      print("Error al iniciar captura de audio: $e");
    }
  }

  void _audioCallback(dynamic obj) {
  // 1. Convertimos la entrada a una lista de dobles
  final List<double> audioData = List<double>.from(obj);
  
  // 2. En fftea, realFft es a menudo un método de extensión sobre List<double>
  // o requiere que el objeto FFT sea llamado así:
  final fft = FFT(audioData.length);
  
  // 3. Probamos la sintaxis que la librería espera según tu error:
  final freqData = fft.realFft(audioData); 
  
  int maxIdx = 0;
  double maxMag = 0;

  // 4. Buscamos la magnitud (la fuerza de la nota)
  // freqData es una lista de números complejos
  for (int i = 0; i < freqData.length; i++) {
    double mag = freqData[i].abs().x; 
    
    if (mag > maxMag) {
      maxMag = mag;
      maxIdx = i;
    }
  }

  double frecuenciaHz = maxIdx * sampleRate / audioData.length;

  if (frecuenciaHz > 20 && frecuenciaHz < 2000) {
    _determinarNota(frecuenciaHz);
  }
}

  void _determinarNota(double freq) {
    // Fórmula matemática: n = 12 * log2(f / 440) + 69
    // Esto nos da el número de nota MIDI
    double n = 12 * (log(freq / 440) / log(2)) + 69;
    int notaIndex = n.round();
    
    // La desviación (cents) nos dice qué tan lejos estamos de la nota perfecta
    double desviacion = (n - notaIndex) * 100;

    const nombresNotas = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];
    String notaFinal = nombresNotas[notaIndex % 12];

    // Enviamos los datos a la pantalla si el callback está configurado
    if (onData != null) {
      onData!(freq, notaFinal, desviacion);
    }
  }

  void _errorCallback(dynamic obj) {
    print("Error de audio: $obj");
  }

  Future<void> detener() async {
    await _audioCapture.stop();
  }
}