class BoardModel {
  final String id;
  final String name;
  final String description;
  final List<String> pinIds;
  final DateTime createdAt;
  final int totalPins;

  BoardModel({
    required this.id,
    required this.name,
    required this.description,
    required this.pinIds,
    required this.createdAt,
    required this.totalPins,
  });

  // Método opcional para facilitar la copia con cambios
  BoardModel copyWith({
    String? name,
    String? description,
    List<String>? pinIds,
    int? totalPins,
  }) {
    return BoardModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      pinIds: pinIds ?? this.pinIds,
      createdAt: createdAt,
      totalPins: totalPins ?? this.totalPins,
    );
  }
}
