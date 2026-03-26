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
  final bool? isCompleted; // NEW: For To-Do completion status

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
    this.isCompleted = false, //  Default false for new todos
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'is_completed': isCompleted == true ? 1 : 0, //  Store as 0/1
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
    return map;
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      createdAt: map['createdAt'] as String? ?? '',
      color: map['color'] as String?,
      titleTextColor: map['titleTextColor'] as String?,
      contentTextColor: map['contentTextColor'] as String?,
      titleFontFamily: map['titleFontFamily'] as String?,
      contentFontFamily: map['contentFontFamily'] as String?,
      titleFontSize: map['titleFontSize']?.toDouble(),
      contentFontSize: map['contentFontSize']?.toDouble(),
      category: map['category'] as String?,
      isCompleted:
          (map['is_completed'] as int?) == 1, // Convert 1→true, else false
    );
  }
}
