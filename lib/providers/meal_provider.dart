import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/meal.dart';
import '../services/llm_service.dart';

class MealProvider extends ChangeNotifier {
  List<Meal> _meals = [];
  final LLMService _llmService = LLMService();
  bool _isGenerating = false;

  List<Meal> get meals => _meals;
  bool get isGenerating => _isGenerating;

  MealProvider() {
    _loadMeals();
  }

  List<Meal> getMealsForDate(DateTime date) {
    return _meals.where((meal) {
      return meal.plannedDate.year == date.year &&
          meal.plannedDate.month == date.month &&
          meal.plannedDate.day == date.day;
    }).toList();
  }

  List<Meal> getMealHistory({int limit = 20}) {
    final sorted = List<Meal>.from(_meals)
      ..sort((a, b) => b.plannedDate.compareTo(a.plannedDate));
    return sorted.take(limit).toList();
  }

  Future<void> _loadMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final mealsJson = prefs.getString('meals');
    if (mealsJson != null) {
      final List<dynamic> decoded = json.decode(mealsJson);
      _meals = decoded.map((item) => Meal.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final mealsJson = json.encode(_meals.map((meal) => meal.toJson()).toList());
    await prefs.setString('meals', mealsJson);
  }

  Future<void> addMeal({
    required String name,
    required String description,
    required List<String> ingredients,
    required String category,
    required DateTime plannedDate,
  }) async {
    final meal = Meal(
      id: const Uuid().v4(),
      name: name,
      description: description,
      ingredients: ingredients,
      category: category,
      plannedDate: plannedDate,
    );
    _meals.add(meal);
    await _saveMeals();
    notifyListeners();
  }

  Future<void> updateMeal({
    required String id,
    String? name,
    String? description,
    List<String>? ingredients,
    String? category,
    DateTime? plannedDate,
    bool? isCooked,
    int? rating,
    String? notes,
  }) async {
    final index = _meals.indexWhere((meal) => meal.id == id);
    if (index != -1) {
      _meals[index] = _meals[index].copyWith(
        name: name,
        description: description,
        ingredients: ingredients,
        category: category,
        plannedDate: plannedDate,
        isCooked: isCooked,
        rating: rating,
        notes: notes,
      );
      await _saveMeals();
      notifyListeners();
    }
  }

  Future<void> deleteMeal(String id) async {
    _meals.removeWhere((meal) => meal.id == id);
    await _saveMeals();
    notifyListeners();
  }

  Future<String?> generateMealSuggestion({
    required String category,
    String? preferences,
  }) async {
    _isGenerating = true;
    notifyListeners();

    try {
      final history = getMealHistory(limit: 10);
      final suggestion = await _llmService.generateMealSuggestion(
        category: category,
        mealHistory: history,
        preferences: preferences,
      );
      _isGenerating = false;
      notifyListeners();
      return suggestion;
    } catch (e) {
      _isGenerating = false;
      notifyListeners();
      return null;
    }
  }
}
