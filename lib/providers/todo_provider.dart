import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/todo_item.dart';

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
    final prefs = await SharedPreferences.getInstance();
    final todosJson = prefs.getString('todos');
    if (todosJson != null) {
      final List<dynamic> decoded = json.decode(todosJson);
      _todos = decoded.map((item) => TodoItem.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = json.encode(_todos.map((todo) => todo.toJson()).toList());
    await prefs.setString('todos', todosJson);
  }

  Future<void> addTodo({
    required String title,
    required String description,
    required String familyMember,
  }) async {
    final todo = TodoItem(
      id: const Uuid().v4(),
      title: title,
      description: description,
      familyMember: familyMember,
      createdAt: DateTime.now(),
    );
    _todos.add(todo);
    await _saveTodos();
    notifyListeners();
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

  Future<void> updateTodo({
    required String id,
    String? title,
    String? description,
    String? familyMember,
  }) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        title: title,
        description: description,
        familyMember: familyMember,
      );
      await _saveTodos();
      notifyListeners();
    }
  }
}
