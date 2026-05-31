import 'package:flutter/material.dart';
import 'package:himnario_ici/models/himno.dart';
import 'package:himnario_ici/services/database_helper.dart';
import 'package:himnario_ici/services/settings_controller.dart';
import 'package:himnario_ici/widgets/himno_avatar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class DetalleHimno extends StatefulWidget {
  final Himno himno;

  const DetalleHimno({super.key, required this.himno});

  @override
  State<DetalleHimno> createState() => _DetalleHimnoState();
}

class _DetalleHimnoState extends State<DetalleHimno> {
  late int esFavorito;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    esFavorito = widget.himno.favorito;
  }

  // --- NUEVA FUNCIÓN: DETERMINAR NOMBRE POR CATEGORÍA ---
  String _getEtiquetaTipo() {
    // Según los IDs que manejas en tu base de datos
    switch (widget.himno.idHimnario) {
      case 1:
        return "coro";
      case 2:
        return "himno";
      case 3:
        return "Coro Juvenil";
      case 4:
        return "Himno Juvenil";
      case 5:
        return "Himno Infantil";
      default:
        return "canto";
    }
  }

  // FUNCIÓN PARA GENERAR TEXTO (MODIFICADA)
  String generarTexto() {
    final etiqueta = _getEtiquetaTipo();
    return "📖 $etiqueta ${widget.himno.numero}: ${widget.himno.titulo}\n\n${widget.himno.contenido}\n\n🙏 Compartido desde Himnario ICI";
  }

  void toggleFavorito() async {
    int nuevoEstado = esFavorito == 1 ? 0 : 1;

    await _dbHelper.actualizarFavorito(widget.himno.id, nuevoEstado).then((_) {
      setState(() {
        esFavorito = nuevoEstado;
        widget.himno.favorito = nuevoEstado;
      });

      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(nuevoEstado == 1 ? "Añadido a favoritos" : "Eliminado de favoritos"),
          duration: const Duration(seconds: 1),
        ),
      );
    }).catchError((e) {
      print("Error: $e");
    });
  }

  void _mostrarSelectorDeListas() async {
    final listas = await _dbHelper.getListas();
    final isDark = settingsController.isDarkMode;

    if (!mounted) return;

    if (listas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No tienes listas creadas. Ve a > Listas > +"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                "Guardar en lista",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: listas.length,
                  itemBuilder: (context, index) {
                    final lista = listas[index];
                    return ListTile(
                      leading: const Icon(Icons.folder_open_rounded, color: Color(0xFF8DAA91)),
                      title: Text(
                        lista['nombre'],
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      ),
                      onTap: () async {
                        await _dbHelper.agregarHimnoALista(lista['id'], widget.himno.id);
                        if (!mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Añadido a '${lista['nombre']}'"),
                            backgroundColor: const Color(0xFF8DAA91),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void copiarHimno() {
    final texto = generarTexto();
    Clipboard.setData(ClipboardData(text: texto));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Contenido copiado al portapapeles")),
    );
  }

  void compartirHimno() {
    final texto = generarTexto();
    Share.share(texto);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (context, _) {
        final colorIcono = settingsController.isDarkMode ? Colors.white : Colors.black;
        // Obtenemos la etiqueta dinámica para el AppBar
        final etiquetaActual = _getEtiquetaTipo();

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              "$etiquetaActual ${widget.himno.numero}", // <--- MODIFICADO AQUÍ
              style: TextStyle(
                color: colorIcono,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: colorIcono,
                size: 22,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.playlist_add_rounded, color: colorIcono),
                onPressed: _mostrarSelectorDeListas,
                tooltip: "Añadir a lista",
              ),
              IconButton(
                icon: Icon(
                  esFavorito == 1 ? Icons.favorite : Icons.favorite_border_rounded,
                ),
                color: esFavorito == 1 ? Colors.redAccent : colorIcono,
                onPressed: toggleFavorito,
              ),
              IconButton(
                icon: Icon(Icons.share_outlined, color: colorIcono),
                onPressed: compartirHimno,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: HimnoAvatar(
                    himno: widget.himno,
                    radius: 50,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.himno.titulo.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: settingsController.isDarkMode
                            ? Colors.white
                            : const Color(0xFF434040),
                      ),
                ),
                const SizedBox(height: 25),
                Text(
                  widget.himno.contenido,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: settingsController.fontSize,
                    color: settingsController.isDarkMode
                        ? Colors.white70
                        : const Color(0xFF434040),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}