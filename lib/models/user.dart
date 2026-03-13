class User {
  final String username;
  final String userId;
  final String? token;

  User({
    required this.username,
    required this.userId,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      userId: json['userId'] ?? '',
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'userId': userId,
      'token': token,
    };
  }
}
