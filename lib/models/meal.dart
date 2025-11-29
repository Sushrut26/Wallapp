class Meal {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final String category; // breakfast, lunch, dinner, snack
  final DateTime plannedDate;
  final bool isCooked;
  final int rating; // 1-5 stars
  final String? notes;

  Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.category,
    required this.plannedDate,
    this.isCooked = false,
    this.rating = 0,
    this.notes,
  });

  Meal copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? ingredients,
    String? category,
    DateTime? plannedDate,
    bool? isCooked,
    int? rating,
    String? notes,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      category: category ?? this.category,
      plannedDate: plannedDate ?? this.plannedDate,
      isCooked: isCooked ?? this.isCooked,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'category': category,
      'plannedDate': plannedDate.toIso8601String(),
      'isCooked': isCooked,
      'rating': rating,
      'notes': notes,
    };
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      ingredients: List<String>.from(json['ingredients']),
      category: json['category'],
      plannedDate: DateTime.parse(json['plannedDate']),
      isCooked: json['isCooked'] ?? false,
      rating: json['rating'] ?? 0,
      notes: json['notes'],
    );
  }
}
