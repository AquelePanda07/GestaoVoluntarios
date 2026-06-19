import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/user.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost/voluntarios_api',
  );

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Uri _endpoint(String path) => Uri.parse('$_baseUrl/$path');

  Future<User?> loginUser(String email, String password) async {
    try {
      final response = await http
          .post(
            _endpoint('login.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'senha': password}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] != true) {
        return null;
      }

      final user = data['user'] as Map<String, dynamic>?;
      if (user == null) {
        return null;
      }

      return User(
        id: null,
        email: user['email']?.toString() ?? email,
        password: '',
        fullName: user['nome']?.toString() ?? email,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> registerUser(String email, String password, String fullName) async {
    if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
      return false;
    }

    try {
      final response = await http
          .post(
            _endpoint('register.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'nome': fullName, 'email': email, 'senha': password}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return false;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> userExists(String email) async {
    try {
      final response = await http
          .post(
            _endpoint('user_exists.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return false;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['exists'] == true;
    } catch (_) {
      return false;
    }
  }
}
