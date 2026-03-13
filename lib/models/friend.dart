class Friend {
  final String username;
  final bool online;
  final DateTime lastSeen;
  final int unreadCount;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  Friend({
    required this.username,
    this.online = false,
    required this.lastSeen,
    this.unreadCount = 0,
    this.lastMessage,
    this.lastMessageTime,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      username: json['username'] ?? '',
      online: json['online'] ?? false,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'].toString())
          : DateTime.now(),
      unreadCount: json['unreadCount'] ?? 0,
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'online': online,
      'lastSeen': lastSeen.toIso8601String(),
      'unreadCount': unreadCount,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
    };
  }
}
