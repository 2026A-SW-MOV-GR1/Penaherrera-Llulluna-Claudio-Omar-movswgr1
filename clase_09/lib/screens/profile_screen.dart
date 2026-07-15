import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/pin_provider.dart';
import '../utils/constants.dart';
import '../widgets/pin_card.dart';
import '../widgets/board_card.dart';
import 'pin_detail_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pinProvider = context.watch<PinProvider>();
    final savedPins = pinProvider.savedPins;
    final boards = pinProvider.boards;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            const SizedBox(height: 40),
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Usuario',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Text(
              '@usuario • 120 seguidores',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            const TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: [
                Tab(text: 'Tableros'),
                Tab(text: 'Guardados'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Tableros
                  GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: boards.length,
                    itemBuilder: (context, index) {
                      return BoardCard(
                        board: boards[index],
                        pins: pinProvider.getPinsByBoard(boards[index]),
                        onTap: () {},
                      );
                    },
                  ),
                  // Guardados (Aquí aparecen las fotos guardadas)
                  savedPins.isEmpty
                      ? const Center(child: Text('No has guardado nada aún', style: TextStyle(color: Colors.white)))
                      : MasonryGridView.count(
                          padding: const EdgeInsets.all(16),
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          itemCount: savedPins.length,
                          itemBuilder: (context, index) {
                            return PinCard(
                              pin: savedPins[index],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (c) => PinDetailScreen(pin: savedPins[index])),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
