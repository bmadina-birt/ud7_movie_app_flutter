import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // URL base configurable para desarrollo vs producción
  final String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080' // URL predeterminada para desarrollo
  );

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("jwt_token", data['token']);
      return true;
    }
    return false;
  }

  Future<bool> register(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/usuarios/registro"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return response.statusCode == 200;
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("jwt_token");
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }

  Future<bool> isLoggedIn() async {
    String? token = await getToken();
    return token != null;
  }

  // lib/services/auth_service.dart - Añadir método getUserId
Future<String?> getUserId() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final jwtToken = prefs.getString("jwt_token");
    
    if (jwtToken == null) return null;
    
    // Decodificar el token JWT para obtener el ID (esto es una implementación simplificada)
    final parts = jwtToken.split('.');
    if (parts.length != 3) return null;
    
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final data = jsonDecode(decoded);
    
    // El campo con el ID puede variar según la implementación del backend
    // Comúnmente puede ser 'sub', 'id', 'userId'
    return data['sub'] ?? data['id'] ?? data['userId'];
  } catch (e) {
    return null;
  }
}
}
