// lib/services/rating_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/rating_data.dart';
import 'api_service.dart';

class RatingService {
  final ApiService _apiService = ApiService();
  
  // 1. Obtener valoración del usuario actual para una película
  Future<RatingData?> getUserRating(int peliculaId) async {
    try {
      final response = await _apiService.get("/api/peliculas/$peliculaId/ratings/user");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return RatingData.fromJson(data);
      } else if (response.statusCode == 204) {
        // No tiene valoración aún
        return null;
      }
      
      debugPrint("Error obteniendo valoración del usuario: ${response.statusCode}");
      return null;
    } catch (e) {
      debugPrint("Error obteniendo valoración del usuario: $e");
      return null;
    }
  }
  
  // 2. Obtener valoración media de una película
  Future<double?> getMovieAverageRating(int peliculaId) async {
    try {
      final response = await _apiService.get("/api/peliculas/$peliculaId/ratings/average");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['averageRating'] != null 
            ? double.tryParse(data['averageRating'].toString()) ?? 0.0
            : 0.0;
      } 
      return 0.0;
    } catch (e) {
      debugPrint("Error obteniendo valoración media: $e");
      return 0.0;
    }
  }
  
  // 3. Guardar una nueva valoración
  Future<bool> saveRating(int peliculaId, double rating, String? comentario) async {
    try {
      // Fecha actual en formato ISO con hora
      final now = DateTime.now();
      final fecha = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss').format(now);
      
      final valoracionDTO = {
        'rating': rating,
        'comentario': comentario,
        'fecha': fecha, // Ahora incluye la hora
      };
      
      debugPrint("Enviando valoración: $valoracionDTO");
      
      final response = await _apiService.post(
        "/api/peliculas/$peliculaId/ratings",
        valoracionDTO,
      );
      
      debugPrint("Respuesta: ${response.statusCode} - ${response.body}");
      
      if (response.statusCode == 403) {
        debugPrint("ERROR 403: No tienes permisos para realizar esta operación");
        return false;
      }
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Error guardando valoración: $e");
      return false;
    }
  }

  // 4. Actualizar una valoración existente
  Future<bool> updateRating(int peliculaId, double rating, String? comentario) async {
    try {
      // Fecha actual en formato ISO con hora
      final now = DateTime.now();
      final fecha = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss').format(now);
      
      final valoracionDTO = {
        'rating': rating,
        'comentario': comentario,
        'fecha': fecha, // Ahora incluye la hora
      };
      
      debugPrint("Actualizando valoración: $valoracionDTO");
      
      final response = await _apiService.put(
        "/api/peliculas/$peliculaId/ratings",
        valoracionDTO,
      );
      
      debugPrint("Respuesta: ${response.statusCode} - ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error actualizando valoración: $e");
      return false;
    }
  }
  
  // 5. Eliminar una valoración
  Future<bool> deleteRating(int peliculaId) async {
    try {
      final response = await _apiService.delete("/api/peliculas/$peliculaId/ratings");
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("Error eliminando valoración: $e");
      return false;
    }
  }

  // 6. Obtener todas las valoraciones de una película
  Future<List<RatingData>> getMovieRatings(int peliculaId) async {
    try {
      final response = await _apiService.get("/api/peliculas/$peliculaId/ratings");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((item) => RatingData.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error obteniendo valoraciones: $e");
      return [];
    }
  }
}