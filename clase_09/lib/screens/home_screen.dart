import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../providers/pin_provider.dart';
import '../models/pin_model.dart';
import '../utils/constants.dart';
import '../widgets/pin_card.dart';
import 'pin_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'Todos';

  void _showPinMenu(BuildContext context, PinModel pin) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Opciones de Pin',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.push_pin, color: Colors.white),
                title: const Text('Fijar'),
                onTap: () {
                  context.read<PinProvider>().toggleSavePin(pin.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(pin.isSaved ? 'Quitado de tus pines' : 'Pin guardado')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.white),
                title: const Text('Compartir'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Compartiendo pin...')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite, color: AppColors.pinterestRed),
                title: const Text('Me gusta'),
                onTap: () {
                  context.read<PinProvider>().toggleLikePin(pin.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Te gusta este pin')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.visibility_off, color: Colors.white),
                title: const Text('Ocultar'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pin ocultado')),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinProvider = context.watch<PinProvider>();
    final filteredPins = pinProvider.getPinsByCategory(_selectedCategory);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/0/08/Pinterest-logo.png',
            height: 24,
          ),
        ),
        title: const Text(
          'Pinterest',
          style: TextStyle(
            color: AppColors.pinterestRed,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Categorías horizontales
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: AppStrings.categories.take(7).map((category) {
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Grid de Pines
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemCount: filteredPins.length,
                itemBuilder: (context, index) {
                  final pin = filteredPins[index];
                  return PinCard(
                    pin: pin,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PinDetailScreen(pin: pin),
                      ),
                    ),
                    onLongPress: () => _showPinMenu(context, pin),
                    onOptions: () => _showPinMenu(context, pin),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 100), // Espacio para la barra inferior flotante
        ],
      ),
    );
  }
}
