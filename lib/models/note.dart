class Note {
  final int? id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({this.id, required this.title, required this.content, required this.createdAt, required this.updatedAt});

  Map<String, dynamic> toMap() => {'id': id, 'title': title, 'content': content, 'created_at': createdAt.toIso8601String(), 'updated_at': updatedAt.toIso8601String()};

  factory Note.fromMap(Map<String, dynamic> map) => Note(id: map['id'] as int?, title: map['title'] as String, content: map['content'] as String? ?? '', createdAt: DateTime.parse(map['created_at'] as String), updatedAt: DateTime.parse(map['updated_at'] as String));

  Note copyWith({String? title, String? content}) => Note(id: id, title: title ?? this.title, content: content ?? this.content, createdAt: createdAt, updatedAt: DateTime.now());
}
