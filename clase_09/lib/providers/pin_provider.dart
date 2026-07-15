import 'package:flutter/material.dart';
import '../models/pin_model.dart';
import '../models/board_model.dart';
import '../data/sample_data.dart';

class PinProvider with ChangeNotifier {
  // Inicializamos con los datos de ejemplo
  final List<PinModel> _pins = [...SampleData.pins];
  final List<BoardModel> _boards = [...SampleData.boards];

  // Getters básicos
  List<PinModel> get pins => _pins;
  List<BoardModel> get boards => _boards;

  // Obtener un pin por ID
  PinModel findById(String id) {
    return _pins.firstWhere((pin) => pin.id == id);
  }

  // Obtener pines por categoría
  List<PinModel> getPinsByCategory(String category) {
    if (category == 'Todos') return _pins;
    return _pins.where((pin) => pin.category == category).toList();
  }

  // Buscar pines por texto (título o descripción)
  List<PinModel> searchPins(String query) {
    if (query.isEmpty) return [];
    return _pins.where((pin) => 
      pin.title.toLowerCase().contains(query.toLowerCase()) || 
      pin.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Dar/Quitar Like
  void toggleLikePin(String pinId) {
    final index = _pins.indexWhere((p) => p.id == pinId);
    if (index >= 0) {
      final pin = _pins[index];
      final isLiked = !pin.isLiked;
      final likes = isLiked ? pin.likes + 1 : pin.likes - 1;
      
      _pins[index] = pin.copyWith(
        isLiked: isLiked,
        likes: likes < 0 ? 0 : likes,
      );
      notifyListeners();
    }
  }

  // Guardar/Quitar Guardado
  void toggleSavePin(String pinId) {
    final index = _pins.indexWhere((p) => p.id == pinId);
    if (index >= 0) {
      _pins[index] = _pins[index].copyWith(isSaved: !_pins[index].isSaved);
      notifyListeners();
    }
  }

  // Obtener solo los pines guardados
  List<PinModel> get savedPins {
    return _pins.where((pin) => pin.isSaved).toList();
  }

  // Obtener pines relacionados (misma categoría, excluyendo el actual)
  List<PinModel> getRelatedPins(String category, String currentPinId) {
    return _pins.where((pin) => 
      pin.category == category && pin.id != currentPinId
    ).toList();
  }

  // Obtener pines de un tablero específico usando sus IDs
  List<PinModel> getPinsByBoard(BoardModel board) {
    return _pins.where((pin) => board.pinIds.contains(pin.id)).toList();
  }
}
