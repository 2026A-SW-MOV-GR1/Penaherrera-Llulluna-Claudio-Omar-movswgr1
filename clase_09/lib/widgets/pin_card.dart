import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pin_model.dart';
import '../utils/constants.dart';

class PinCard extends StatelessWidget {
  final PinModel pin;
  final VoidCallback onTap;
  final VoidCallback? onOptions;
  final VoidCallback? onLongPress;

  const PinCard({
    super.key,
    required this.pin,
    required this.onTap,
    this.onOptions,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Hero(
                tag: 'pin-${pin.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: pin.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.grayButton,
                      child: const AspectRatio(aspectRatio: 1),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
              if (pin.isSaved)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.pinterestRed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 12),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4, right: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    pin.title.isNotEmpty ? pin.title : pin.author,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (onOptions != null)
                  GestureDetector(
                    onTap: onOptions,
                    child: const Icon(Icons.more_horiz, color: AppColors.textPrimary, size: 16),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
