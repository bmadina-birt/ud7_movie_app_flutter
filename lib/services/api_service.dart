import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = "https://alluring-laughter-production.up.railway.app";

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }

  // Método GET con mejor manejo de errores
  Future<http.Response> get(String path) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception("No se ha encontrado el token JWT");
      }
      
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };
      
      debugPrint("GET Request: $baseUrl$path");
      
      final response = await http.get(
        Uri.parse("$baseUrl$path"),
        headers: headers,
      );
      
      debugPrint("GET Response status: ${response.statusCode}");
      if (response.body.length < 1000) {
        debugPrint("GET Response body: ${response.body}");
      }
      
      return response;
    } catch (e) {
      debugPrint("Error en GET request: $e");
      rethrow;
    }
  }

  // Método POST con mejor manejo de errores
  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    try {
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
      debugPrint("POST Body: $encodedBody");
      
      final response = await http.post(
        Uri.parse("$baseUrl$path"),
        headers: headers,
        body: encodedBody,
      );
      
      debugPrint("POST Response status: ${response.statusCode}");
      if (response.body.length < 1000) {
        debugPrint("POST Response body: ${response.body}");
      }
      
      return response;
    } catch (e) {
      debugPrint("Error en POST request: $e");
      rethrow;
    }
  }

  // Método PUT con mejor manejo de errores
  Future<http.Response> put(String path, Map<String, dynamic> body) async {
    try {
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
      debugPrint("PUT Body: $encodedBody");
      
      final response = await http.put(
        Uri.parse("$baseUrl$path"),
        headers: headers,
        body: encodedBody,
      );
      
      debugPrint("PUT Response status: ${response.statusCode}");
      if (response.body.length < 1000) {
        debugPrint("PUT Response body: ${response.body}");
      }
      
      return response;
    } catch (e) {
      debugPrint("Error en PUT request: $e");
      rethrow;
    }
  }

  // Método DELETE con mejor manejo de errores
  Future<http.Response> delete(String path) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception("No se ha encontrado el token JWT");
      }
      
      final headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };
      
      debugPrint("DELETE Request: $baseUrl$path");
      
      final response = await http.delete(
        Uri.parse("$baseUrl$path"),
        headers: headers,
      );
      
      debugPrint("DELETE Response status: ${response.statusCode}");
      if (response.body.length < 1000) {
        debugPrint("DELETE Response body: ${response.body}");
      }
      
      return response;
    } catch (e) {
      debugPrint("Error en DELETE request: $e");
      rethrow;
    }
  }
}