import 'package:shared_preferences/shared_preferences.dart';
import '../models/index.dart';
import 'dart:convert';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  late SharedPreferences _prefs;

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User storage
  Future<void> saveUser(User user) async {
    await _prefs.setString('user', jsonEncode(user.toJson()));
  }

  User? getUser() {
    final userJson = _prefs.getString('user');
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> clearUser() async {
    await _prefs.remove('user');
  }

  // Token storage
  Future<void> saveToken(String token) async {
    await _prefs.setString('token', token);
  }

  String? getToken() {
    return _prefs.getString('token');
  }

  Future<void> clearToken() async {
    await _prefs.remove('token');
  }

  // Settings
  Future<void> saveNotificationsEnabled(bool enabled) async {
    await _prefs.setBool('notifications_enabled', enabled);
  }

  bool getNotificationsEnabled() {
    return _prefs.getBool('notifications_enabled') ?? true;
  }

  Future<void> saveSoundEnabled(bool enabled) async {
    await _prefs.setBool('sound_enabled', enabled);
  }

  bool getSoundEnabled() {
    return _prefs.getBool('sound_enabled') ?? true;
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }

  bool get isLoggedIn => getUser() != null && getToken() != null;
}
