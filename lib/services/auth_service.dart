// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users?email=$email'));
      
      if (response.statusCode == 200) {
        final List<dynamic> users = json.decode(response.body);
        
        if (users.isNotEmpty) {
          final user = users.first;
          if (user['password'] == password) {
            return {'success': true, 'user': user};
          } else {
            return {'success': false, 'message': 'Invalid password'};
          }
        } else {
          return {'success': false, 'message': 'User not found'};
        }
      }
      return {'success': false, 'message': 'Server error'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> signup(String email, String password, String name) async {
    try {
      // Check if user already exists
      final checkResponse = await http.get(Uri.parse('$baseUrl/users?email=$email'));
      
      if (checkResponse.statusCode == 200) {
        final List<dynamic> existingUsers = json.decode(checkResponse.body);
        
        if (existingUsers.isNotEmpty) {
          return {'success': false, 'message': 'Email already exists'};
        }

        // Get ALL users to find the highest ID
        final allUsersResponse = await http.get(Uri.parse('$baseUrl/users'));
        if (allUsersResponse.statusCode == 200) {
          final List<dynamic> allUsers = json.decode(allUsersResponse.body);
          
          // Calculate next ID
          int nextId = 1;
          if (allUsers.isNotEmpty) {
            // Extract all IDs and find the maximum
            List<int> ids = [];
            for (var user in allUsers) {
              if (user['id'] is int) {
                ids.add(user['id']);
              } else if (user['id'] is String) {
                int? parsedId = int.tryParse(user['id']);
                if (parsedId != null) {
                  ids.add(parsedId);
                }
              }
            }
            
            if (ids.isNotEmpty) {
              nextId = ids.reduce((max, current) => current > max ? current : max) + 1;
            }
          }

          print('🆔 Creating user with ID: $nextId');

          // Create new user
          final newUser = {
            'id': nextId,
            'email': email,
            'password': password,
            'name': name,
            'createdAt': DateTime.now().toIso8601String(),
          };

          final response = await http.post(
            Uri.parse('$baseUrl/users'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(newUser),
          );

          if (response.statusCode == 201) {
            final createdUser = json.decode(response.body);
            print('✅ User created successfully with ID: ${createdUser['id']}');
            return {'success': true, 'user': createdUser};
          } else {
            print('❌ Failed to create user. Status: ${response.statusCode}');
            return {'success': false, 'message': 'Failed to create user'};
          }
        }
      }
      return {'success': false, 'message': 'Server error'};
    } catch (e) {
      print('❌ Signup error: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}