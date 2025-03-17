// lib/services/api_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Para compilación de desarrollo vs producción
  final String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080' // URL predeterminada para desarrollo
  );

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }

  // Método GET
  Future<http.Response> get(String path) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception("No se ha encontrado el token JWT");
    }
    
    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
    
    debugPrint("GET Request: $baseUrl$path");
    
    return await http.get(
      Uri.parse("$baseUrl$path"),
      headers: headers,
    );
  }

  // Método POST
  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception("No se ha encontrado el token JWT");
    }
    
    final encodedBody = jsonEncode(body);
    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
    
    debugPrint("POST Request: $baseUrl$path");
    debugPrint("Body: $encodedBody");
    
    return await http.post(
      Uri.parse("$baseUrl$path"),
      headers: headers,
      body: encodedBody,
    );
  }

  // Método PUT
  Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception("No se ha encontrado el token JWT");
    }
    
    final encodedBody = jsonEncode(body);
    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
    
    debugPrint("PUT Request: $baseUrl$path");
    debugPrint("Body: $encodedBody");
    
    return await http.put(
      Uri.parse("$baseUrl$path"),
      headers: headers,
      body: encodedBody,
    );
  }

  // Método DELETE
  Future<http.Response> delete(String path) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception("No se ha encontrado el token JWT");
    }
    
    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
    
    return await http.delete(
      Uri.parse("$baseUrl$path"),
      headers: headers,
    );
  }
}