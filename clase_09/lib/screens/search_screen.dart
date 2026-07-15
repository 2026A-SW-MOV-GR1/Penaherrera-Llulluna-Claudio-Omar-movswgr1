import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/pin_provider.dart';
import '../models/pin_model.dart';
import '../models/board_model.dart';
import '../utils/constants.dart';
import '../widgets/pin_card.dart';
import '../widgets/board_card.dart';
import 'pin_detail_screen.dart';
import 'board_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pinProvider = context.watch<PinProvider>();
    final searchResults = pinProvider.searchPins(_searchQuery);
    final boards = pinProvider.boards;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Barra de Búsqueda
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.grayButton,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, color: AppColors.textSecondary),
                    hintText: 'Busca en Pinterest',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    border: InputBorder.none,
                    suffixIcon: Icon(Icons.camera_alt, color: AppColors.textPrimary),
                  ),
                ),
              ),
            ),

            Expanded(
              child: _searchQuery.isEmpty
                  ? _buildMainContent(boards, pinProvider.pins, pinProvider)
                  : _buildSearchResults(searchResults),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(List<BoardModel> boards, List<PinModel> pins, PinProvider pinProvider) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Banner Superior
        _buildBanner(),

        // Indicadores tipo carrusel
        _buildCarouselIndicators(),

        const Padding(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          child: Text(
            'Explora tableros destacados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        // Tableros Destacados (Horizontal)
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: AppSizes.paddingMedium),
            itemCount: boards.length,
            itemBuilder: (context, index) {
              final board = boards[index];
              return Container(
                width: 150,
                margin: const EdgeInsets.only(right: 12),
                child: BoardCard(
                  board: board,
                  pins: pinProvider.getPinsByBoard(board),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BoardDetailScreen(board: board),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),

        const Padding(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          child: Text(
            'Ideas para ti',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        // Grid de Ideas para ti
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingSmall),
          child: MasonryGridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemCount: pins.length > 10 ? 10 : pins.length,
            itemBuilder: (context, index) {
              final pin = pins[index];
              return PinCard(
                pin: pin,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PinDetailScreen(pin: pin),
                    ),
                  );
                },
                onOptions: () {},
                onLongPress: () {},
              );
            },
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSearchResults(List<PinModel> results) {
    if (results.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron resultados',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingSmall),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: results.length,
        itemBuilder: (context, index) {
          final pin = results[index];
          return PinCard(
            pin: pin,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PinDetailScreen(pin: pin),
                ),
              );
            },
            onOptions: () {},
            onLongPress: () {},
          );
        },
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 200,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: 'https://images.unsplash.com/photo-1556910103-1c02745aae4d',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Secretos culinarios',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Diseña tu propio libro de recetas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselIndicators() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == 0 ? Colors.white : AppColors.grayButton,
            ),
          );
        }),
      ),
    );
  }
}
