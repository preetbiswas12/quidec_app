import 'package:flutter/material.dart';
import '../services/index.dart';
import '../models/index.dart';
import 'chat_detail_screen.dart';

class ChatHomeScreen extends StatefulWidget {
  final User currentUser;

  const ChatHomeScreen({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  late WebSocketService _wsService;
  late ApiService _apiService;
  late NotificationService _notificationService;
  late StorageService _storageService;

  List<Friend> _friends = [];
  bool _isLoading = true;
  String? _selectedFriend;

  @override
  void initState() {
    super.initState();
    _wsService = WebSocketService();
    _apiService = ApiService();
    _notificationService = NotificationService();
    _storageService = StorageService();
    
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _notificationService.initialize();
      await _wsService.connect('wss://quidec-server.onrender.com');
      _wsService.authenticate(widget.currentUser.username);
      
      _wsService.messages.listen((message) {
        _handleWebSocketMessage(message);
      });

      await _loadFriends();
    } catch (e) {
      print('Error initializing services: $e');
    }
  }

  Future<void> _loadFriends() async {
    try {
      final friends = await _apiService.getFriends(widget.currentUser.username);
      setState(() {
        _friends = friends;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading friends: $e');
      setState(() => _isLoading = false);
    }
  }

  void _handleWebSocketMessage(Map<String, dynamic> message) {
    final type = message['type'];
    
    switch (type) {
      case 'message':
        _notificationService.showMessageNotification(
          sender: message['from'] ?? 'Unknown',
          message: message['content'] ?? '',
          messageId: message['messageId'] ?? '',
        );
        break;
      case 'incoming-request':
        _notificationService.showFriendRequestNotification(
          sender: message['from'] ?? 'Unknown',
        );
        break;
      case 'user-status':
        _updateFriendStatus(message['username'], message['online']);
        break;
    }
  }

  void _updateFriendStatus(String username, bool online) {
    setState(() {
      final index = _friends.indexWhere((f) => f.username == username);
      if (index != -1) {
        _friends[index] = Friend(
          username: _friends[index].username,
          online: online,
          lastSeen: _friends[index].lastSeen,
          unreadCount: _friends[index].unreadCount,
          lastMessage: _friends[index].lastMessage,
          lastMessageTime: _friends[index].lastMessageTime,
        );
      }
    });
  }

  Future<void> _logout() async {
    _wsService.disconnect();
    await _storageService.clearUser();
    await _storageService.clearToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF111122),
        elevation: 0,
        title: Text(
          'Quidec',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Color(0xFF4A89FF)),
            onPressed: () async {
              await _logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Container(
        color: Color(0xFF0a0a14),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF234C6A),
                  ),
                ),
              )
            : _friends.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Color(0xFF7A8FA0),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No friends yet',
                          style: TextStyle(
                            color: Color(0xFFA0A0B0),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _friends.length,
                    itemBuilder: (context, index) {
                      final friend = _friends[index];
                      return FriendListItem(
                        friend: friend,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatDetailScreen(
                                currentUser: widget.currentUser,
                                friend: friend,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
      ),
    );
  }

  @override
  void dispose() {
    _wsService.disconnect();
    super.dispose();
  }
}

class FriendListItem extends StatelessWidget {
  final Friend friend;
  final VoidCallback onTap;

  const FriendListItem({
    Key? key,
    required this.friend,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFF1a1a2e),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF234C6A),
                      Color(0xFF1F3F54),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Center(
                  child: Text(
                    friend.username[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              // Friend Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          friend.username,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (friend.unreadCount > 0)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF4ade80),
                                  Color(0xFF22c55e),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${friend.unreadCount}',
                              style: TextStyle(
                                color: Color(0xFF0a0a14),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            friend.lastMessage ?? 'No messages yet',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFF9AA0B0),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: friend.online
                                ? Color(0xFF4ade80)
                                : Color(0xFF7A8FA0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
