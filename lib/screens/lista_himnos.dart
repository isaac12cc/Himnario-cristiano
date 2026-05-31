import 'package:flutter/material.dart';
import 'package:himnario_ici/main.dart';
import 'package:himnario_ici/models/himno.dart';
import 'package:himnario_ici/routes/app_routes.dart';
import 'package:himnario_ici/screens/detalle_himno.dart';
import 'package:himnario_ici/services/database_helper.dart';
import 'package:himnario_ici/widgets/himno_avatar.dart';

class ListaHimnos extends StatefulWidget {
  const ListaHimnos({super.key});

  @override
  State<ListaHimnos> createState() => _ListaHimnosState();
}

class _ListaHimnosState extends State<ListaHimnos>
    with AutomaticKeepAliveClientMixin {
  final Map<String, int> clasificaciones = {
    "Coros": 1,
    "Himnos": 2,
    "Coros Juvenil": 3,
    "Himnos Juvenil": 4,
    "Himnario Infantil": 5,
  };

  String seleccion = "Coros";
  late Future<List<Himno>> _futureHimnos;

  @override
  void initState() {
    super.initState();
    _cargarHimnos();
  }

  void _cargarHimnos() {
    _futureHimnos = DatabaseHelper()
        .getHimnos(idHimnarioFilter: clasificaciones[seleccion]);
  }

  void _cambiarSeleccion(String nuevoValor) {
    setState(() {
      seleccion = nuevoValor;
      _cargarHimnos();
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      // Usamos el color de fondo definido en tu main o uno suave
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. TÍTULO GIGANTE
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 25, right: 20),
                child: Text(
                  "Himnario",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1.2,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),

            // 2. BUSCADOR ESTILO PILL
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: GestureDetector(
                  onTap: () => showSearch(
                    context: context,
                    delegate: HimnoSearchDelegate(),
                  ),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white10
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 15),
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 10),
                        Text(
                          "Buscar",
                          style: TextStyle(color: Colors.grey, fontSize: 17),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. SELECTOR DE CATEGORÍA
            SliverToBoxAdapter(
              child: _buildSelector(context),
            ),

            // 4. LISTA DE HIMNOS
            FutureBuilder<List<Himno>>(
              future: _futureHimnos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final himnos = snapshot.data ?? [];
                if (himnos.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text("No hay registros")),
                  );
                }

                // CORRECCIÓN AQUÍ: SliverPadding usa 'sliver:', no 'child:'
                return SliverPadding(
                  padding: const EdgeInsets.only(bottom: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _buildItem(himnos[i]),
                      childCount: himnos.length,
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

  Widget _buildSelector(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Categoría",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          DropdownButton<String>(
            value: seleccion,
            underline: const SizedBox(),
            onChanged: (value) {
              if (value != null) _cambiarSeleccion(value);
            },
            items: clasificaciones.keys.map((nombre) {
              return DropdownMenuItem(
                value: nombre,
                child: Text(nombre),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(Himno himno) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          leading: HimnoAvatar(himno: himno),
          title: Text(
            himno.titulo,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          onTap: () {
            Navigator.push(
              context,
              AppRoutes.fadeSlide(DetalleHimno(himno: himno)),
            );
          },
        ),
      ),
    );
  }
}