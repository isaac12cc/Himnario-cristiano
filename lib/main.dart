import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'services/settings_controller.dart';
import 'models/himno.dart';

//import de screens
import 'screens/favoritos.dart';
import 'screens/configuracion.dart';
import 'screens/detalle_himno.dart';
import 'screens/lista_himnos.dart';
import 'screens/herramientas.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Himnario Cristiano',
          

          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8DAA92),
            brightness: settingsController.isDarkMode
                ? Brightness.dark
                : Brightness.light,
            surface: settingsController.isDarkMode ? null : Colors.white,
            ),

            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF8DAA91),
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
            ),

             pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          home: const PantallaPrincipal(),
        );
      },
    );
  }
}

class HimnoSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildListaBusqueda();

  @override
  Widget buildSuggestions(BuildContext context) => _buildListaBusqueda();

  Widget _buildListaBusqueda() {
    if (query.isEmpty) return const Center(child: Text("Escribe el nombre o número"));

    return FutureBuilder<List<Himno>>(
      future: DatabaseHelper().buscarHimnos(query),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final resultados = snapshot.data!;
        return ListView.builder(
          itemCount: resultados.length,
          itemBuilder: (context, i) {
            return ListTile(
              leading: CircleAvatar(child: Text(resultados[i].numero.toString())),
              title: Text(resultados[i].titulo),
              onTap: () {
                close(context, null); 
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DetalleHimno(himno: resultados[i])),
                );
              },
            );
          },
        );
      },
    );
  }
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indiceActual = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: settingsController.isDarkMode
              ? const Color(0xFF121212)
              : const Color(0xFFF1F3F1),

         
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _indiceActual = index;
              });
            },
            children: const [
              ListaHimnos(),
              PantallaFavoritos(),
              PantallaHerramientas(),
              PantallaConfiguracion(),
            ],
          ),

          bottomNavigationBar: NavigationBar(
            selectedIndex: _indiceActual,
            onDestinationSelected: (int index) {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
              );
            },
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
              NavigationDestination(icon: Icon(Icons.favorite), label: 'Favoritos'),
              NavigationDestination(icon: Icon(Icons.format_list_bulleted_rounded), label: 'Listas'),
              NavigationDestination(icon: Icon(Icons.settings), label: 'Ajustes'),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
