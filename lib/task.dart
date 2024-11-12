class Task {
  String id;
  String name;
  bool isComplete;

  Task({required this.id, required this.name, this.isComplete = false});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isComplete': isComplete,
    };
  }

  static Task fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      name: map['name'],
      isComplete: map['isComplete'] ?? false,
    );
  }
}
