class Task {
  int? id;

  String title;

  String description;

  Task({this.id, required this.title, required this.description});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] is int ? map['id'] as int : int.tryParse(map['id']?.toString() ?? ''),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
    );
  }
}

