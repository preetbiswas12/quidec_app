import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/index.dart';
import '../models/index.dart';

class ChatDetailScreen extends StatefulWidget {
  final User currentUser;
  final Friend friend;

  const ChatDetailScreen({
    Key? key,
    required this.currentUser,
    required this.friend,
  }) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late WebSocketService _wsService;
  late ApiService _apiService;
  late NotificationService _notificationService;

  final _messageController = TextEditingController();
  List<Message> _messages = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _wsService = WebSocketService();
    _apiService = ApiService();
    _notificationService = NotificationService();
    
    _loadMessages();
    _setupWebSocketListener();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _apiService.getMessages(
        widget.currentUser.username,
        widget.friend.username,
      );
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      
      // Auto-scroll to bottom and mark messages as read
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollToBottom();
        _markVisibleMessagesAsRead();
      });
    } catch (e) {
      print('Error loading messages: $e');
      setState(() => _isLoading = false);
    }
  }

  void _setupWebSocketListener() {
    _wsService.messages.listen((message) {
      final type = message['type'];
      
      if (type == 'message' &&
          (message['from'] == widget.friend.username ||
              message['to'] == widget.friend.username)) {
        setState(() {
          _messages.add(Message.fromJson(message));
        });
        
        // Show notification only if not from current user
        if (message['from'] == widget.friend.username) {
          _notificationService.showMessageNotification(
            sender: message['from'] ?? 'Unknown',
            message: message['content'] ?? '',
            messageId: message['messageId'] ?? '',
          );
        }
        
        _scrollToBottom();
        _markVisibleMessagesAsRead();
      } else if (type == 'read-receipt') {
        // Update message read status
        final messageId = message['messageId'];
        final index = _messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          setState(() {
            _messages[index] = Message(
              id: _messages[index].id,
              from: _messages[index].from,
              to: _messages[index].to,
              content: _messages[index].content,
              timestamp: _messages[index].timestamp,
              read: true,
              readAt: DateTime.parse(message['readAt'] ?? DateTime.now().toIso8601String()),
              readBy: message['readBy'],
            );
          });
        }
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _markVisibleMessagesAsRead() {
    for (final message in _messages) {
      if (message.from == widget.friend.username && !message.read) {
        _apiService.markMessageAsRead(
          message.id,
          widget.currentUser.username,
        );
        _wsService.markMessageAsRead(
          message.id,
          widget.currentUser.username,
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final content = _messageController.text;
    _messageController.clear();

    try {
      await _apiService.sendMessage(
        widget.currentUser.username,
        widget.friend.username,
        content,
      );

      _wsService.sendMessage(widget.friend.username, content);

      setState(() {
        _messages.add(Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          from: widget.currentUser.username,
          to: widget.friend.username,
          content: content,
          timestamp: DateTime.now(),
          read: false,
        ));
      });

      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message')),
      );
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('dd/MM/yyyy').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF111122),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.friend.username,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              widget.friend.online ? 'Online' : 'Offline',
              style: TextStyle(
                color: widget.friend.online
                    ? Color(0xFF4ade80)
                    : Color(0xFF7A8FA0),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Color(0xFF0a0a14),
        child: Column(
          children: [
            // Messages List
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF234C6A),
                        ),
                      ),
                    )
                  : _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_outline,
                                size: 64,
                                color: Color(0xFF7A8FA0),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No messages yet',
                                style: TextStyle(
                                  color: Color(0xFFA0A0B0),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isOwn =
                                message.from == widget.currentUser.username;
                            
                            return MessageBubble(
                              message: message,
                              isOwn: isOwn,
                              formatTime: _formatTime,
                            );
                          },
                        ),
            ),
            // Message Input
            Container(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Color(0xFF111122),
                border: Border(
                  top: BorderSide(
                    color: Color(0xFF1a1a2e),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(color: Colors.white),
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        hintStyle: TextStyle(color: Color(0xFF7A8FA0)),
                        filled: true,
                        fillColor: Color(0xFF1a1a2e),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: Color(0xFF234C6A),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: Color(0xFF234C6A),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: Color(0xFF4A89FF),
                            width: 1.5,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF234C6A),
                          Color(0xFF1F3F54),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: _sendMessage,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isOwn;
  final String Function(DateTime) formatTime;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isOwn,
    required this.formatTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: isOwn
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF234C6A),
                    Color(0xFF1F3F54),
                  ],
                )
              : null,
          color: isOwn ? null : Color(0xFF1a1a2e),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft:
                Radius.circular(isOwn ? 16 : 4),
            bottomRight:
                Radius.circular(isOwn ? 4 : 16),
          ),
        ),
        padding: EdgeInsets.fromLTRB(12, 10, 12, 8),
        child: Column(
          crossAxisAlignment:
              isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            SelectableText(
              message.content,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatTime(message.timestamp),
                  style: TextStyle(
                    color: isOwn
                        ? Colors.white70
                        : Color(0xFF9AA0B0),
                    fontSize: 11,
                  ),
                ),
                if (isOwn) ...[
                  SizedBox(width: 4),
                  Icon(
                    message.read ? Icons.done_all : Icons.done,
                    color: message.read
                        ? Color(0xFF4ade80)
                        : Colors.white54,
                    size: 14,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
