import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Asegúrate de correr 'flutter pub add shared_preferences'

class SettingsController extends ChangeNotifier {
  double _fontSize = 19.0;
  bool _isDarkMode = false;

  double get fontSize => _fontSize;
  bool get isDarkMode => _isDarkMode;

  SettingsController() {
    _cargarAjustes(); // Al crear el controlador, recuperamos lo guardado
  }

  // Recupera los datos del disco
  Future<void> _cargarAjustes() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble('fontSize') ?? 19.0;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  // Actualiza y guarda el tamaño de letra
  void updateFontSize(double newSize) async {
    _fontSize = newSize;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', newSize);
  }

  // Actualiza y guarda el modo oscuro
  void toggleDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }
}

final settingsController = SettingsController();