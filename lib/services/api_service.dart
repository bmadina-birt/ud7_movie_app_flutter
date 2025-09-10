import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/environment.dart';

class ApiService {
  final String baseUrl = apiBaseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }

  Map<String, String> _headers(String? token) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> get(String path) async {
    try {
      final token = await _getToken();
      final uri = Uri.parse("$baseUrl$path");
      final headers = _headers(token);

      debugPrint("GET $uri");
      final response = await http.get(uri, headers: headers);
      _logSmallBody("GET", response);
      return response;
    } catch (e) {
      debugPrint("Error GET $path: $e");
      rethrow;
    }
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    try {
      final token = await _getToken();
      final uri = Uri.parse("$baseUrl$path");
      final headers = _headers(token);
      final encodedBody = jsonEncode(body);

      debugPrint("POST $uri body=$encodedBody");
      final response = await http.post(uri, headers: headers, body: encodedBody);
      _logSmallBody("POST", response);
      return response;
    } catch (e) {
      debugPrint("Error POST $path: $e");
      rethrow;
    }
  }

  Future<http.Response> put(String path, Map<String, dynamic> body) async {
    try {
      final token = await _getToken();
      final uri = Uri.parse("$baseUrl$path");
      final headers = _headers(token);
      final encodedBody = jsonEncode(body);

      debugPrint("PUT $uri body=$encodedBody");
      final response = await http.put(uri, headers: headers, body: encodedBody);
      _logSmallBody("PUT", response);
      return response;
    } catch (e) {
      debugPrint("Error PUT $path: $e");
      rethrow;
    }
  }

  Future<http.Response> delete(String path) async {
    try {
      final token = await _getToken();
      final uri = Uri.parse("$baseUrl$path");
      final headers = _headers(token);

      debugPrint("DELETE $uri");
      final response = await http.delete(uri, headers: headers);
      _logSmallBody("DELETE", response);
      return response;
    } catch (e) {
      debugPrint("Error DELETE $path: $e");
      rethrow;
    }
  }

  void _logSmallBody(String method, http.Response r) {
    debugPrint("$method status: ${r.statusCode}");
    if (r.body.isNotEmpty && r.body.length < 1500) {
      debugPrint("$method body: ${r.body}");
    }
  }
}