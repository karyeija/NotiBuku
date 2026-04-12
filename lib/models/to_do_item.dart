class TodoItem {
  final String id;
  final String text;
  final bool isCompleted;

  const TodoItem({
    required this.id,
    required this.text,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'text': text, 'isCompleted': isCompleted ? 1 : 0};
  }

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'] as String,
      text: map['text'] as String,
      isCompleted: (map['isCompleted'] as int?) == 1,
    );
  }
}
