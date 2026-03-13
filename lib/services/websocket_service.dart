import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:async';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  late WebSocketChannel _channel;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  
  String? _currentUser;
  bool _isConnected = false;

  factory WebSocketService() {
    return _instance;
  }

  WebSocketService._internal();

  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  bool get isConnected => _isConnected;

  Future<void> connect(String serverUrl) async {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(serverUrl),
      );
      _isConnected = true;
      
      _channel.stream.listen(
        (dynamic message) {
          try {
            final data = jsonDecode(message);
            _messageController.add(data);
          } catch (e) {
            print('Error parsing WebSocket message: $e');
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          _isConnected = false;
        },
        onDone: () {
          print('WebSocket connection closed');
          _isConnected = false;
        },
      );
    } catch (e) {
      print('WebSocket connection error: $e');
      _isConnected = false;
    }
  }

  void authenticate(String username) {
    _currentUser = username;
    send({
      'type': 'auth',
      'username': username,
    });
  }

  void sendMessage(String to, String content) {
    send({
      'type': 'message',
      'from': _currentUser,
      'to': to,
      'content': content,
    });
  }

  void sendFriendRequest(String to) {
    send({
      'type': 'friend-request',
      'from': _currentUser,
      'to': to,
    });
  }

  void respondFriendRequest(String from, bool accept) {
    send({
      'type': 'friend-response',
      'from': _currentUser,
      'to': from,
      'accept': accept,
    });
  }

  void markMessageAsRead(String messageId, String readBy) {
    send({
      'type': 'mark-read',
      'messageId': messageId,
      'to': readBy,
    });
  }

  void getFriendsList() {
    send({
      'type': 'get-friends',
    });
  }

  void getChatHistory(String withUser) {
    send({
      'type': 'get-chat-history',
      'with': withUser,
    });
  }

  void getPendingRequests() {
    send({
      'type': 'get-pending',
    });
  }

  void send(Map<String, dynamic> message) {
    if (_isConnected) {
      try {
        _channel.sink.add(jsonEncode(message));
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  void disconnect() {
    _messageController.close();
    _channel.sink.close();
    _isConnected = false;
  }
}
