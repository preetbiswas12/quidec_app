class Message {
  final String id;
  final String from;
  final String to;
  final String content;
  final DateTime timestamp;
  final bool read;
  final DateTime? readAt;
  final String? readBy;

  Message({
    required this.id,
    required this.from,
    required this.to,
    required this.content,
    required this.timestamp,
    this.read = false,
    this.readAt,
    this.readBy,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? json['messageId'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'].toString())
          : DateTime.now(),
      read: json['read'] ?? false,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'].toString())
          : null,
      readBy: json['readBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'from': from,
      'to': to,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'read': read,
      'readAt': readAt?.toIso8601String(),
      'readBy': readBy,
    };
  }
}
