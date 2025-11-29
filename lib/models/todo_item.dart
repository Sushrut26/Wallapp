class TodoItem {
  final String id;
  final String title;
  final String description;
  final String familyMember;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  TodoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.familyMember,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  TodoItem copyWith({
    String? id,
    String? title,
    String? description,
    String? familyMember,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      familyMember: familyMember ?? this.familyMember,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'familyMember': familyMember,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      familyMember: json['familyMember'],
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}
