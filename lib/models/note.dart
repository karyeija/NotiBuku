class Note {
  final int? id;
  final String title;
  final String content;
  final String createdAt;
  final String? color;
  final String? titleTextColor; // Title color
  final String? contentTextColor; // content text  color
  final String? titleFontFamily; // Title font
  final String? contentFontFamily; // Content font
  final double? titleFontSize; // 🔥 NEW: Title size
  final double? contentFontSize; // 🔥 NEW: Content size

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
    this.titleFontSize, // 🔥 NEW
    this.contentFontSize, // 🔥 NEW
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'content': content,
      'createdAt': createdAt,
      if (id != null) 'id': id,
      if (color != null) 'color': color,
      if (titleTextColor != null) 'titleTextColor': titleTextColor,
      if (contentTextColor != null) 'contentTextColor': contentTextColor,
      if (titleFontFamily != null) 'titleFontFamily': titleFontFamily,
      if (contentFontFamily != null) 'contentFontFamily': contentFontFamily,
      if (titleFontSize != null) 'titleFontSize': titleFontSize,
      if (contentFontSize != null) 'contentFontSize': contentFontSize,
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
    );
  }
}
