import 'package:flutter/material.dart';
import 'package:himnario_ici/services/database_helper.dart';
import 'package:himnario_ici/screens/detalle_lista_screen.dart';

// ------------NUEVA PANTALLA DE LISTAS (Gestión de Listas Personalizadas)---------------
class PantallaHerramientas extends StatefulWidget {
  const PantallaHerramientas({super.key});

  @override
  State<PantallaHerramientas> createState() => _PantallaHerramientasState();
}

class _PantallaHerramientasState extends State<PantallaHerramientas> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> _listasFuture;

  @override
  void initState() {
    super.initState();
    _refrescarListas();
  }

  void _refrescarListas() {
    setState(() {
      // Usamos getListas() que ya tienes en tu DatabaseHelper
      _listasFuture = _dbHelper.getListas(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // BOTÓN FLOTANTE DIRECTO
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoNuevaLista(context),
        backgroundColor: const Color(0xFF8DAA91),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // TÍTULO "LISTAS"
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 25, bottom: 20),
                child: Text(
                  "Listas",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1.2,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            // EL CONTENIDO DE LAS LISTAS
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _listasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        "No tienes listas creadas",
                        style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                      ),
                    ),
                  );
                }

                final listas = snapshot.data!;
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final lista = listas[index];
                        return _buildListaItem(context, lista, isDark);
                      },
                      childCount: listas.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // DISEÑO DE CADA LISTA (Reemplaza a la ToolCard)
  Widget _buildListaItem(BuildContext context, Map<String, dynamic> lista, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF8DAA91).withOpacity(0.1),
          child: const Icon(Icons.folder_rounded, color: Color(0xFF8DAA91)),
        ),
        title: Text(
          lista['nombre'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text("Toca para ver himnos"),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
          onPressed: () => _confirmarEliminacion(context, lista['id'], lista['nombre']),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleListaScreen(
                idLista: lista['id'],
                nombreLista: lista['nombre'],
              ),
            ),
          ).then((_) => _refrescarListas());
        },
      ),
    );
  }

  // MÉTODOS DE SOPORTE (DIÁLOGOS)
  void _mostrarDialogoNuevaLista(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Nueva Lista"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Ej. Culto de Jóvenes"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await _dbHelper.crearLista(controller.text.trim());
                Navigator.pop(context);
                _refrescarListas();
              }
            },
            child: const Text("Crear"),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminacion(BuildContext context, int id, String nombre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar lista?"),
        content: Text("Se borrará '$nombre'. Los himnos no se borrarán."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(
            onPressed: () async {
              await _dbHelper.eliminarLista(id);
              Navigator.pop(context);
              _refrescarListas();
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}