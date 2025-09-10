import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/environment.dart';

class AuthService {
  final String baseUrl = apiBaseUrl;

  Future<bool> login(String email, String password) async {
    try {
      debugPrint("Intentando login con: $email");
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      debugPrint("Status code: ${response.statusCode}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("jwt_token", data['token']);
        return true;
      }
      debugPrint("Login fallido: ${response.body}");
      return false;
    } catch (e) {
      debugPrint("Error en login: $e");
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      final nombreUsuario = email.split('@').first;
      final response = await http.post(
        Uri.parse("$baseUrl/api/usuarios/registro"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "nombreUsuario": nombreUsuario,
        }),
      );

      debugPrint("Registro status: ${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) return true;
      debugPrint("Registro fallido: ${response.body}");
      return false;
    } catch (e) {
      debugPrint("Error en registro: $e");
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("jwt_token");
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<int?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");
      if (token == null) return null;

      final response = await http.get(
        Uri.parse("$baseUrl/api/usuarios/perfil"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return (data['id'] as num).toInt();
      }
      debugPrint("Perfil fallido: ${response.statusCode} ${response.body}");
      return null;
    } catch (e) {
      debugPrint("Error obteniendo ID de usuario: $e");
      return null;
    }
  }
}