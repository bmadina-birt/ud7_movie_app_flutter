import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // URL base configurable para desarrollo vs producción
  final String baseUrl = "https://alluring-laughter-production.up.railway.app";

  Future<bool> login(String email, String password) async {
    try {
      debugPrint("Intentando login con: $email");
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      
      debugPrint("Status code: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        // El token viene en data['token']
        await prefs.setString("jwt_token", data['token']);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error en login: $e");
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      // Generar nombreUsuario a partir del email (parte antes del @)
      String nombreUsuario = email.split('@')[0];
      
      debugPrint("Intentando registro con: email=$email, nombreUsuario=$nombreUsuario");
      
      final response = await http.post(
        Uri.parse("$baseUrl/api/usuarios/registro"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nombreUsuario": nombreUsuario,
          "email": email,
          "password": password
        }),
      );
      
      debugPrint("Status code: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Error en registro: $e");
      return false;
    }
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

  // Obtener el ID del usuario actual
  Future<int?> getUserId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("jwt_token");
      
      if (token == null) return null;
      
      final response = await http.get(
        Uri.parse("$baseUrl/api/usuarios/perfil"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id'] as int?;
      }
      return null;
    } catch (e) {
      debugPrint("Error obteniendo ID de usuario: $e");
      return null;
    }
  }
}