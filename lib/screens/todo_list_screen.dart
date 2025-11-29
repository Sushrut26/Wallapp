import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo_item.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildMemberSelector(),
          Expanded(
            child: Consumer<TodoProvider>(
              builder: (context, provider, child) {
                final todos = provider.getTodosForMember(provider.selectedMember);

                if (todos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.checklist_rounded,
                          size: 100,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks yet',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add a new task',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return _buildTodoCard(context, todo, provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTodoDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildMemberSelector() {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: provider.familyMembers.map((member) {
              final isSelected = provider.selectedMember == member;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(member),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        provider.setSelectedMember(member);
                      }
                    },
                    selectedColor: Theme.of(context).colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildTodoCard(BuildContext context, TodoItem todo, TodoProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (value) {
            provider.toggleTodo(todo.id);
          },
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: todo.description.isNotEmpty
            ? Text(
                todo.description,
                style: TextStyle(
                  decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                ),
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          color: Colors.red,
          onPressed: () {
            _showDeleteConfirmDialog(context, todo, provider);
          },
        ),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final provider = Provider.of<TodoProvider>(context, listen: false);
    String selectedMember = provider.selectedMember;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedMember,
                decoration: const InputDecoration(
                  labelText: 'Assign to',
                  border: OutlineInputBorder(),
                ),
                items: provider.familyMembers.map((member) {
                  return DropdownMenuItem(
                    value: member,
                    child: Text(member),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedMember = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                provider.addTodo(
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  familyMember: selectedMember,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, TodoItem todo, TodoProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              provider.deleteTodo(todo.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
