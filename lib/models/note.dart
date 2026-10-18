import 'package:notibuku/models/to_do_item.dart';

class Note {
  final int? id;
  final String title;
  final String content;
  final String createdAt;
  final String? color;
  final String? titleTextColor;
  final String? contentTextColor;
  final String? titleFontFamily;
  final String? contentFontFamily;
  final double? titleFontSize;
  final double? contentFontSize;
  final String? category;
  final bool? isCompleted;
  final bool isChecklist;
  final List<TodoItem> todoList;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.color,
    this.titleTextColor,
    this.contentTextColor,
    this.titleFontFamily,
    this.contentFontFamily,
    this.titleFontSize,
    this.contentFontSize,
    this.category,
    this.isCompleted = false,
    this.isChecklist = false,
    this.todoList = const [],
  });

  Note copyWith({
    int? id,
    String? title,
    String? content,
    String? createdAt,
    String? color,
    String? titleTextColor,
    String? contentTextColor,
    String? titleFontFamily,
    String? contentFontFamily,
    double? titleFontSize,
    double? contentFontSize,
    String? category,
    bool? isCompleted,
    bool? isChecklist,
    List<TodoItem>? todoList,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
      titleTextColor: titleTextColor ?? this.titleTextColor,
      contentTextColor: contentTextColor ?? this.contentTextColor,
      titleFontFamily: titleFontFamily ?? this.titleFontFamily,
      contentFontFamily: contentFontFamily ?? this.contentFontFamily,
      titleFontSize: titleFontSize ?? this.titleFontSize,
      contentFontSize: contentFontSize ?? this.contentFontSize,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      isChecklist: isChecklist ?? this.isChecklist,
      todoList: todoList ?? this.todoList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'is_completed': isCompleted == true ? 1 : 0,
      'isChecklist': isChecklist ? 1 : 0,
      'todoList': todoList.map((item) => item.toMap()).toList(),
      if (id != null) 'id': id,
      if (color != null) 'color': color,
      if (titleTextColor != null) 'titleTextColor': titleTextColor,
      if (contentTextColor != null) 'contentTextColor': contentTextColor,
      if (titleFontFamily != null) 'titleFontFamily': titleFontFamily,
      if (contentFontFamily != null) 'contentFontFamily': contentFontFamily,
      if (titleFontSize != null) 'titleFontSize': titleFontSize,
      if (contentFontSize != null) 'contentFontSize': contentFontSize,
      if (category != null) 'category': category,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    final List<TodoItem> list =
        (map['todoList'] as List<dynamic>?)
            ?.map(
              (item) =>
                  TodoItem.fromMap(Map<String, dynamic>.from(item as Map)),
            )
            .toList() ??
        <TodoItem>[];

    // Preserve compatibility with older saved notes.
    final rawChecklist = map['isChecklist'];

    return Note(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      createdAt: map['createdAt'] as String,
      color: map['color'] as String?,
      titleTextColor: map['titleTextColor'] as String?,
      contentTextColor: map['contentTextColor'] as String?,
      titleFontFamily: map['titleFontFamily'] as String?,
      contentFontFamily: map['contentFontFamily'] as String?,
      titleFontSize: map['titleFontSize']?.toDouble(),
      contentFontSize: map['contentFontSize']?.toDouble(),
      category: map['category'] as String?,
      isCompleted: map['is_completed'] == 1 || map['is_completed'] == true,
      isChecklist: rawChecklist == 1 || rawChecklist == true || list.isNotEmpty,
      todoList: list,
    );
  }
}
