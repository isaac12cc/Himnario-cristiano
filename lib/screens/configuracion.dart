import 'package:flutter/material.dart';
import 'package:himnario_ici/services/settings_controller.dart';

class PantallaConfiguracion extends StatelessWidget {
  const PantallaConfiguracion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: settingsController,
          builder: (context, _) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. TÍTULO GIGANTE "AJUSTES"
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, top: 25, right: 20, bottom: 20),
                    child: Text(
                      "Ajustes",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1.2,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),

                // 2. SECCIÓN DE LECTURA
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "LECTURA",
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            color: Colors.grey[600],
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        // Tarjeta para agrupar opciones (estilo iOS/Material3 moderno)
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                          ),
                          child: Column(
                            children: [
                              // CONTROL DEL TAMAÑO DE LETRA
                              ListTile(
                                title: const Text("Tamaño de la letra"),
                                subtitle: Text("${settingsController.fontSize.toInt()} px"),
                                trailing: SizedBox(
                                  width: 120,
                                  child: Slider(
                                    value: settingsController.fontSize,
                                    min: 14,
                                    max: 40,
                                    activeColor: const Color(0xFF8DAA91),
                                    onChanged: (double value) {
                                      settingsController.updateFontSize(value);
                                    },
                                  ),
                                ),
                              ),
                              const Divider(height: 1, indent: 16, endIndent: 16),
                              
                              // CONTROL DEL MODO OSCURO
                              SwitchListTile(
                                title: const Text("Modo Nocturno"),
                                secondary: const Icon(Icons.dark_mode_outlined),
                                activeColor: const Color(0xFF8DAA91),
                                value: settingsController.isDarkMode,
                                onChanged: (bool value) {
                                  settingsController.toggleDarkMode(value);
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // SECCIÓN DE INFORMACIÓN (Opcional, para rellenar)
                        Text(
                          "APP",
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                          ),
                          child: const ListTile(
                            title: Text("Versión"),
                            trailing: Text("1.0.0", style: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}