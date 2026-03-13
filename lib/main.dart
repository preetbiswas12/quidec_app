import 'package:flutter/material.dart';
import 'screens/index.dart';
import 'services/index.dart';
import 'models/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storageService = StorageService();
  await storageService.initialize();
  
  runApp(const QuidecApp());
}

class QuidecApp extends StatefulWidget {
  const QuidecApp({Key? key}) : super(key: key);

  @override
  State<QuidecApp> createState() => _QuidecAppState();
}

class _QuidecAppState extends State<QuidecApp> {
  late StorageService _storageService;
  User? _currentUser;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _storageService = StorageService();
    _checkLoggedInUser();
  }

  Future<void> _checkLoggedInUser() async {
    final user = _storageService.getUser();
    setState(() {
      _currentUser = user;
      _isInitialized = true;
    });
  }

  void _handleLoginSuccess(User user) {
    setState(() {
      _currentUser = user;
    });
  }

  void _handleLogout() {
    setState(() {
      _currentUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quidec',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: Color(0xFF234C6A),
        scaffoldBackgroundColor: Color(0xFF0a0a14),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF111122),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF234C6A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF234C6A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Color(0xFF4A89FF),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Color(0xFF1a1a2e),
          hintStyle: TextStyle(color: Color(0xFF7A8FA0)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF234C6A),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: _isInitialized
          ? (_currentUser != null
              ? ChatHomeScreen(currentUser: _currentUser!)
              : LoginScreen(onLoginSuccess: _handleLoginSuccess))
          : Scaffold(
              body: Container(
                color: Color(0xFF0a0a14),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF234C6A),
                    ),
                  ),
                ),
              ),
            ),
      routes: {
        '/login': (_) => LoginScreen(onLoginSuccess: _handleLoginSuccess),
      },
    );
  }
}
