import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/todo_item.dart';
import '../utils/input_validator.dart';

class TodoProvider extends ChangeNotifier {
  List<TodoItem> _todos = [];
  final List<String> _familyMembers = ['Sushrut', 'Shilpa', 'Guest'];
  String _selectedMember = 'Sushrut';

  List<TodoItem> get todos => _todos;
  List<String> get familyMembers => _familyMembers;
  String get selectedMember => _selectedMember;

  List<TodoItem> getTodosForMember(String member) {
    return _todos.where((todo) => todo.familyMember == member).toList();
  }

  TodoProvider() {
    _loadTodos();
  }

  void setSelectedMember(String member) {
    _selectedMember = member;
    notifyListeners();
  }

  Future<void> _loadTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = prefs.getString('todos');
      if (todosJson != null && todosJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(todosJson);
        _todos = decoded
            .map((item) {
              try {
                return TodoItem.fromJson(item);
              } catch (e) {
                debugPrint('Error parsing todo item: $e');
                return null;
              }
            })
            .whereType<TodoItem>()
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading todos: $e');
      _todos = [];
    }
  }

  Future<void> _saveTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = json.encode(_todos.map((todo) => todo.toJson()).toList());
      await prefs.setString('todos', todosJson);
    } catch (e) {
      debugPrint('Error saving todos: $e');
    }
  }

  Future<bool> addTodo({
    required String title,
    required String description,
    required String familyMember,
  }) async {
    // Validate and sanitize inputs
    final titleError = InputValidator.validateTitle(title);
    if (titleError != null) {
      return false;
    }

    final descError = InputValidator.validateDescription(description);
    if (descError != null) {
      return false;
    }

    final sanitizedTitle = InputValidator.sanitize(title);
    final sanitizedDescription = InputValidator.sanitize(description);

    final todo = TodoItem(
      id: const Uuid().v4(),
      title: sanitizedTitle,
      description: sanitizedDescription,
      familyMember: familyMember,
      createdAt: DateTime.now(),
    );
    _todos.add(todo);
    await _saveTodos();
    notifyListeners();
    return true;
  }

  Future<void> toggleTodo(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        isCompleted: !_todos[index].isCompleted,
        completedAt:
            !_todos[index].isCompleted ? DateTime.now() : null,
      );
      await _saveTodos();
      notifyListeners();
    }
  }

  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((todo) => todo.id == id);
    await _saveTodos();
    notifyListeners();
  }

  Future<bool> updateTodo({
    required String id,
    String? title,
    String? description,
    String? familyMember,
  }) async {
    // Validate inputs if provided
    if (title != null) {
      final titleError = InputValidator.validateTitle(title);
      if (titleError != null) return false;
    }

    if (description != null) {
      final descError = InputValidator.validateDescription(description);
      if (descError != null) return false;
    }

    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        title: title != null ? InputValidator.sanitize(title) : null,
        description: description != null ? InputValidator.sanitize(description) : null,
        familyMember: familyMember,
      );
      await _saveTodos();
      notifyListeners();
      return true;
    }
    return false;
  }
}
