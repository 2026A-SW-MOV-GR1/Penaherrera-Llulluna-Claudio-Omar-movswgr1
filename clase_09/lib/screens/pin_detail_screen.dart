import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/pin_model.dart';
import '../providers/pin_provider.dart';
import '../utils/constants.dart';
import '../widgets/pin_card.dart';

class PinDetailScreen extends StatelessWidget {
  final PinModel pin;

  const PinDetailScreen({super.key, required this.pin});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el provider para tener actualizaciones de likes/saved en tiempo real
    final pinProvider = context.watch<PinProvider>();
    final currentPin = pinProvider.findById(pin.id);
    final relatedPins = pinProvider.getRelatedPins(currentPin.category, currentPin.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Imagen y Botones Superiores
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.6,
            backgroundColor: AppColors.background,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  child: IconButton(
                    icon: const Icon(Icons.more_horiz, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'pin-${currentPin.id}',
                child: CachedNetworkImage(
                  imageUrl: currentPin.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: AppColors.cardBackground),
                ),
              ),
            ),
          ),

          // Información del Pin
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fila de Autor y Botón Guardar
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.grayButton,
                        child: Text(
                          currentPin.author[0],
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentPin.author,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const Text(
                              'Seguidores',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.read<PinProvider>().toggleSavePin(currentPin.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(currentPin.isSaved ? 'Eliminado de tus pines' : 'Pin guardado'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentPin.isSaved ? AppColors.grayButton : AppColors.pinterestRed,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          currentPin.isSaved ? 'Guardado' : 'Guardar',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Título y Descripción
                  if (currentPin.title.isNotEmpty)
                    Text(
                      currentPin.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (currentPin.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        currentPin.description,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),

                  // Botones de Interacción (Like, Comentar, Compartir)
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.read<PinProvider>().toggleLikePin(currentPin.id),
                        child: Row(
                          children: [
                            Icon(
                              currentPin.isLiked ? Icons.favorite : Icons.favorite_border,
                              color: currentPin.isLiked ? AppColors.pinterestRed : Colors.white,
                              size: 28,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${currentPin.likes}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.comment_outlined, size: 28),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined, size: 28),
                        onPressed: () {
                          Share.share('Mira este pin en Pinterest: ${currentPin.imageUrl}');
                        },
                      ),
                    ],
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: AppColors.softBorder),
                  ),

                  // Sección "Más para explorar"
                  const Text(
                    'Más para explorar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Grid de Pines Relacionados
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemBuilder: (context, index) {
                final relatedPin = relatedPins[index];
                return PinCard(
                  pin: relatedPin,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PinDetailScreen(pin: relatedPin),
                      ),
                    );
                  },
                  onOptions: () {},
                  onLongPress: () {},
                );
              },
              childCount: relatedPins.length,
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 50),
          ),
        ],
      ),
    );
  }
}
