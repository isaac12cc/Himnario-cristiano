import 'package:flutter/material.dart';
import 'package:himnario_ici/screens/detalle_himno.dart';
import 'package:himnario_ici/services/database_helper.dart';
import 'package:himnario_ici/models/himno.dart';
// Asegúrate de que esta ruta sea la correcta

class DetalleListaScreen extends StatefulWidget {
  final int idLista;
  final String nombreLista;

  const DetalleListaScreen({
    super.key,
    required this.idLista,
    required this.nombreLista,
  });

  @override
  State<DetalleListaScreen> createState() => _DetalleListaScreenState();
}

class _DetalleListaScreenState extends State<DetalleListaScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<Himno>> _himnosFuture;

  @override
  void initState() {
    super.initState();
    _refrescarHimnos();
  }

  void _refrescarHimnos() {
    setState(() {
      _himnosFuture = _dbHelper.getHimnosDeLista(widget.idLista);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nombreLista),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: FutureBuilder<List<Himno>>(
        future: _himnosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_music_outlined,
                    size: 60,
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Esta lista está vacía",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          final himnos = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            itemCount: himnos.length,
            itemBuilder: (context, index) {
              final himno = himnos[index];
              return Card(
                elevation: 0,
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8DAA91).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "${himno.numero}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8DAA91),
                      ),
                    ),
                  ),
                  title: Text(
                    himno.titulo,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent, size: 22),
                    onPressed: () => _confirmarEliminacion(himno),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalleHimno(himno: himno),
                      ),
                    ).then((_) => _refrescarHimnos()); 
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmarEliminacion(Himno himno) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Quitar himno"),
        content: Text("¿Deseas quitar '${himno.titulo}' de esta lista?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              await _dbHelper.quitarHimnoDeLista(widget.idLista, himno.id);
              if (mounted) Navigator.pop(context);
              _refrescarHimnos();
            },
            child: const Text("Quitar", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}