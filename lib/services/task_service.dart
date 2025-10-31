
import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskService {
  static const String baseUrl = 'http://localhost:3000';

  // Enhanced debug helper
  static dynamic _parseId(dynamic id) {
    print('🔍 Parsing ID: $id (type: ${id.runtimeType})');
    if (id is int) return id;
    if (id is String) {
      final parsed = int.tryParse(id);
      print('   String to int: $id -> $parsed');
      return parsed ?? id; 
    }
    return id;
  }

  // Debug all incoming data
  static void _debugData(String operation, dynamic data) {
    print('🐛 DEBUG $operation:');
    if (data is Map) {
      data.forEach((key, value) {
        print('   $key: $value (type: ${value.runtimeType})');
      });
    } else {
      print('   Data: $data (type: ${data.runtimeType})');
    }
  }

  // Get all tasks for a specific user
  static Future<List<dynamic>> getUserTasks(dynamic userId) async {
    try {
      _debugData('getUserTasks - userId', userId);
      final parsedUserId = _parseId(userId);
      final response = await http.get(Uri.parse('$baseUrl/tasks?userId=$parsedUserId'));
      print('📥 GET Tasks response: ${response.statusCode}');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print('❌ Error fetching tasks: $e');
      return [];
    }
  }

  // Create a new task
  static Future<Map<String, dynamic>> createTask(Map<String, dynamic> taskData) async {
    try {
      _debugData('createTask - incoming', taskData);
      
      // Get next task ID
      final allTasksResponse = await http.get(Uri.parse('$baseUrl/tasks'));
      int nextId = 1;

      if (allTasksResponse.statusCode == 200) {
        final List<dynamic> allTasks = json.decode(allTasksResponse.body);
        if (allTasks.isNotEmpty) {
          final maxId = allTasks
              .map<int>((task) {
                final id = _parseId(task['id']);
                return id is int ? id : 0;
              })
              .reduce((a, b) => a > b ? a : b);
          nextId = maxId + 1;
        }
      }

      // Ensure all types are correct
      final newTask = {
        'id': nextId,
        'userId': _parseId(taskData['userId']),
        'title': taskData['title'].toString(),
        'description': taskData['description'].toString(),
        'dueDate': taskData['dueDate'] is String ? taskData['dueDate'] : (taskData['dueDate'] as DateTime).toIso8601String(),
        'priority': taskData['priority'].toString(),
        'isCompleted': taskData['isCompleted'] ?? false,
        'createdAt': DateTime.now().toIso8601String(),
      };

      _debugData('createTask - sending', newTask);

      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newTask),
      );

      print('📡 Create response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        return {'success': true, 'task': json.decode(response.body)};
      }
      return {'success': false, 'message': 'Failed to create task. Status: ${response.statusCode}'};
    } catch (e) {
      print('❌ Create task error: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Update a task - FIXED VERSION (handles DateTime fields)
  static Future<Map<String, dynamic>> updateTask(dynamic taskId, Map<String, dynamic> taskData) async {
    try {
      _debugData('updateTask - taskId', taskId);
      _debugData('updateTask - taskData', taskData);
      
      final parsedTaskId = _parseId(taskId);
      print('🔄 Update task ID: $parsedTaskId (type: ${parsedTaskId.runtimeType})');

      // Convert DateTime fields to ISO strings if needed
      if (taskData['dueDate'] is DateTime) {
        taskData['dueDate'] = (taskData['dueDate'] as DateTime).toIso8601String();
      }
      if (taskData['createdAt'] is DateTime) {
        taskData['createdAt'] = (taskData['createdAt'] as DateTime).toIso8601String();
      }

      final response = await http.put(
        Uri.parse('$baseUrl/tasks/$parsedTaskId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(taskData),
      );

      print('📡 Update response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'task': json.decode(response.body)};
      }
      return {'success': false, 'message': 'Failed to update task. Status: ${response.statusCode}'};
    } catch (e) {
      print('❌ Update task error: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Delete a task
  static Future<Map<String, dynamic>> deleteTask(dynamic taskId) async {
    try {
      _debugData('deleteTask - taskId', taskId);
      final parsedTaskId = _parseId(taskId);
      print('🗑 Deleting task $parsedTaskId (type: ${parsedTaskId.runtimeType})');
      
      final response = await http.delete(Uri.parse('$baseUrl/tasks/$parsedTaskId'));

      print('📡 Delete response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true};
      }
      return {'success': false, 'message': 'Failed to delete task. Status: ${response.statusCode}'};
    } catch (e) {
      print('❌ Delete task error: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Toggle task completion - SIMPLE PATCH VERSION
  static Future<Map<String, dynamic>> toggleTaskCompletion(dynamic taskId, bool isCompleted) async {
    try {
      _debugData('toggleTaskCompletion - taskId', taskId);
      final parsedTaskId = _parseId(taskId);
      print('🔄 Toggling task $parsedTaskId (type: ${parsedTaskId.runtimeType}) to $isCompleted');
      
      // Use PATCH for simple field updates
      final patchData = {
        'isCompleted': isCompleted,
      };

      final response = await http.patch(
        Uri.parse('$baseUrl/tasks/$parsedTaskId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(patchData),
      );

      print('📡 Toggle response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'task': json.decode(response.body)};
      }
      return {'success': false, 'message': 'Failed to toggle task. Status: ${response.statusCode}'};
    } catch (e) {
      print('❌ Toggle error: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Get single task by ID (optional helper method)
  static Future<Map<String, dynamic>> getTaskById(dynamic taskId) async {
    try {
      _debugData('getTaskById - taskId', taskId);
      final parsedTaskId = _parseId(taskId);
      final response = await http.get(Uri.parse('$baseUrl/tasks/$parsedTaskId'));
      
      print('📥 GET Task response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return {'success': true, 'task': json.decode(response.body)};
      }
      return {'success': false, 'message': 'Task not found'};
    } catch (e) {
      print('❌ Get task error: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
