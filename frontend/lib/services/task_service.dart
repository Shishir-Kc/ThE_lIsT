import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Task {
  String id;
  String title;
  String description;
  DateTime startDate;
  DateTime endDate;
  int priority; // 1-10
  bool isCompleted;
  DateTime createdAt;
  DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.startDate,
    required this.endDate,
    this.priority = 5,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['task_name'] ?? '',
      description: json['task_description'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      priority: json['priority_level'] ?? 0,
      createdAt: DateTime.now(), // API doesn't return created_at yet
      isCompleted: json['completed'] ?? false,
      completedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
    );
  }
}

class ActivitySession {
  final DateTime start;
  final DateTime end;
  final bool completed;

  ActivitySession({
    required this.start,
    required this.end,
    required this.completed,
  });

  factory ActivitySession.fromJson(Map<String, dynamic> json) {
    return ActivitySession(
      start: DateTime.parse(json['start_date']),
      end: DateTime.parse(json['ended_at']),
      completed: json['completed'],
    );
  }
}

class TaskService extends ChangeNotifier {
  final List<Task> _tasks = [];
  final List<ActivitySession> _activitySessions = [];
  final Map<String, int> _completionHistory = {};
  
  // TODO: Move to config
  static const String _baseUrl = 'http://127.0.0.1:8000/api/v1';

  List<Task> get tasks => List.unmodifiable(_tasks);
  List<ActivitySession> get activitySessions => List.unmodifiable(_activitySessions);
  Map<String, int> get completionHistory => Map.unmodifiable(_completionHistory);

  TaskService();

  Future<void> fetchTasks() async {
    final url = Uri.parse('$_baseUrl/get/todo/');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _tasks.clear();
        _tasks.addAll(data.map((json) => Task.fromJson(json)).toList());
        notifyListeners();
      } else {
        debugPrint('Failed to fetch tasks: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
    }
  }

  Future<void> fetchActivity() async {
    final url = Uri.parse('$_baseUrl/activity/');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _activitySessions.clear();
        _activitySessions.addAll(data.map((json) => ActivitySession.fromJson(json)).toList());
        notifyListeners();
      } else {
        debugPrint('Failed to fetch activity: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching activity: $e');
    }
  }

  Future<void> addTask({
    required String title,
    String description = '',
    required DateTime startDate,
    required DateTime endDate,
    int priority = 5,
  }) async {
    final url = Uri.parse('$_baseUrl/add/todo/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'task_name': title,
          'task_description': description,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'priority_level': priority,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final newTask = Task.fromJson(data);
        _tasks.add(newTask);
        notifyListeners();
      } else {
        debugPrint('Failed to add task: ${response.statusCode}');
        // Ideally show an error to the user
      }
    } catch (e) {
      debugPrint('Error adding task: $e');
    }
  }

  Future<void> setTaskCompletion(String id, bool completed) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      if (task.isCompleted == completed) return; // No change

      final url = Uri.parse('$_baseUrl/update/todo/');
      final now = DateTime.now();

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': id,
            'ended_at': now.toIso8601String(),
            'completed': completed,
          }),
        );

        if (response.statusCode == 200) {
           if (completed) {
            // Completing
            task.isCompleted = true;
            task.completedAt = now;
            _incrementHistory(task.completedAt!);
          } else {
            // Un-completing
            if (task.completedAt != null) {
              _decrementHistory(task.completedAt!);
            }
            task.isCompleted = false;
            task.completedAt = null;
          }
           notifyListeners();
        } else {
          debugPrint('Failed to update task: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Error updating task: $e');
      }
    }
  }

  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      setTaskCompletion(id, !task.isCompleted);
    }
  }

  void _incrementHistory(DateTime date) {
    final key = _formatDate(date);
    _completionHistory[key] = (_completionHistory[key] ?? 0) + 1;
  }

  void _decrementHistory(DateTime date) {
    final key = _formatDate(date);
    if (_completionHistory.containsKey(key)) {
      _completionHistory[key] = (_completionHistory[key]! - 1);
      if (_completionHistory[key]! <= 0) {
        _completionHistory.remove(key);
      }
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
  
  // Helper for stats
  int get completionsToday {
    return _completionHistory[_formatDate(DateTime.now())] ?? 0;
  }

  void reorderActiveTask(String draggedId, String targetId) {
    if (draggedId == targetId) return;

    // Get all active tasks sorted by priority (descending)
    final activeTasks = _tasks.where((t) => !t.isCompleted).toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));

    final draggedIndex = activeTasks.indexWhere((t) => t.id == draggedId);
    final targetIndex = activeTasks.indexWhere((t) => t.id == targetId);

    if (draggedIndex == -1 || targetIndex == -1) return;

    // Capture the existing priority distribution
    final priorities = activeTasks.map((t) => t.priority).toList();

    // Move the task in the list
    final taskToMove = activeTasks.removeAt(draggedIndex);
    activeTasks.insert(targetIndex, taskToMove);

    // Re-assign priorities based on new positions
    for (int i = 0; i < activeTasks.length; i++) {
        final task = activeTasks[i];
        final newPriority = priorities[i];
        
        if (task.priority != newPriority) {
            task.priority = newPriority;
            _updatePriorityBackend(task.id, newPriority);
        }
    }

    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    final url = Uri.parse('$_baseUrl/delete/todo/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}),
      );

      if (response.statusCode == 200) {
        _tasks.removeWhere((t) => t.id == id);
        notifyListeners();
      } else {
        debugPrint('Failed to delete task $id: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error deleting task $id: $e');
    }
  }

  Future<void> _updatePriorityBackend(String id, int priority) async {
    final url = Uri.parse('$_baseUrl/todo/update/priority/');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': id,
          'priority_level': priority,
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('Failed to update priority for task $id: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating priority for task $id: $e');
    }
  }
}
