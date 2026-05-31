import 'package:flutter/material.dart';
import 'package:himnario_ici/screens/detalle_himno.dart';
import 'package:himnario_ici/widgets/himno_avatar.dart';
import '../models/himno.dart';
import '../services/database_helper.dart';

class PantallaFavoritos extends StatelessWidget {
  const PantallaFavoritos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. TÍTULO GIGANTE "MIS FAVORITOS"
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 25, right: 20, bottom: 10),
                child: Text(
                  "Favoritos",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1.2,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),

            // 2. LISTA DE FAVORITOS
            FutureBuilder<List<Himno>>(
              future: DatabaseHelper().getFavoritos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final favoritos = snapshot.data ?? [];

                if (favoritos.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 64,
                            color: Colors.grey.withOpacity(0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Aún no tienes favoritos",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.only(bottom: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _buildItem(context, favoritos[i]),
                      childCount: favoritos.length,
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

  // 🎨 Item personalizado para mantener la estética
  Widget _buildItem(BuildContext context, Himno himno) {
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
            style: const TextStyle(
              fontWeight: FontWeight.w600, 
              fontSize: 15
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios, 
            size: 14, 
            color: Colors.grey
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetalleHimno(himno: himno),
              ),
            );
          },
        ),
      ),
    );
  }
}