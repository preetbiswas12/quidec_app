import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/index.dart';

class ApiService {
  static const String baseUrl = 'https://quidec-server.onrender.com';
  // For local testing: 'http://localhost:3000'
  
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  Future<User> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  Future<User> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  Future<List<Friend>> getFriends(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/friends/$username'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final friends = (data['friends'] as List)
            .map((f) => Friend.fromJson(f))
            .toList();
        return friends;
      } else {
        throw Exception('Failed to fetch friends');
      }
    } catch (e) {
      throw Exception('Error fetching friends: $e');
    }
  }

  Future<List<Message>> getMessages(String username, String withUser) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/messages/$username/$withUser'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final messages = (data['messages'] as List)
            .map((m) => Message.fromJson(m))
            .toList();
        return messages;
      } else {
        throw Exception('Failed to fetch messages');
      }
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }

  Future<void> sendMessage(String from, String to, String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/messages/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'from': from,
          'to': to,
          'content': content,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  Future<void> markMessageAsRead(String messageId, String readBy) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/api/messages/read'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messageId': messageId,
          'readBy': readBy,
        }),
      );
    } catch (e) {
      print('Error marking message as read: $e');
    }
  }
}
