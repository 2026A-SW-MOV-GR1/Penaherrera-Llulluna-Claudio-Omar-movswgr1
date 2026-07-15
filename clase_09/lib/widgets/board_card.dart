import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/board_model.dart';
import '../models/pin_model.dart';
import '../utils/constants.dart';

class BoardCard extends StatelessWidget {
  final BoardModel board;
  final List<PinModel> pins;
  final VoidCallback onTap;

  const BoardCard({
    super.key,
    required this.board,
    required this.pins,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collage de imágenes
          AspectRatio(
            aspectRatio: 1.2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Row(
                children: [
                  // Imagen grande
                  Expanded(
                    flex: 2,
                    child: _buildBoardImage(pins.isNotEmpty ? pins[0].imageUrl : ''),
                  ),
                  const SizedBox(width: 2),
                  // Columna de imágenes pequeñas
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Expanded(
                          child: _buildBoardImage(pins.length > 1 ? pins[1].imageUrl : ''),
                        ),
                        const SizedBox(height: 2),
                        Expanded(
                          child: _buildBoardImage(pins.length > 2 ? pins[2].imageUrl : ''),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  board.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${board.totalPins} pines · 1 sem',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardImage(String url) {
    return Container(
      color: AppColors.grayButton,
      child: url.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: AppColors.cardBackground),
            )
          : null,
    );
  }
}
