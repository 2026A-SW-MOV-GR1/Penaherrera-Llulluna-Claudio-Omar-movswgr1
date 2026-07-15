class PinModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final String author;
  final int likes;
  final bool isSaved;
  final bool isLiked;

  PinModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.author,
    this.likes = 0,
    this.isSaved = false,
    this.isLiked = false,
  });

  PinModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? imageUrl,
    String? author,
    int? likes,
    bool? isSaved,
    bool? isLiked,
  }) {
    return PinModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      author: author ?? this.author,
      likes: likes ?? this.likes,
      isSaved: isSaved ?? this.isSaved,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
