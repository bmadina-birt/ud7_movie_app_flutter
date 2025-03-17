// lib/services/favorites_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pelicula.dart';
import 'api_service.dart';

class FavoritesService {
  final ApiService _apiService = ApiService();
  static const String _favoritesKey = 'user_favorites';
  
  // Obtener favoritos desde el backend
  Future<List<Pelicula>> getFavorites() async {
    try {
      final response = await _apiService.get("/api/usuarios/favoritos");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List)
            .map((item) => Pelicula.fromJson(item))
            .toList();
      } else if (response.statusCode == 404) {
        // Si no hay favoritos, el backend puede devolver 404
        return [];
      } else {
        // Manejo de otros errores
        return [];
      }
    } catch (e) {
      // Fallback al almacenamiento local si hay error con el backend
      return _getFavoritesFromLocal();
    }
  }
  
  // Verificar si una película está en favoritos
  Future<bool> isFavorite(Pelicula pelicula) async {
    try {
      if (pelicula.id == null) return false;
      
      final response = await _apiService.get("/api/usuarios/favoritos/${pelicula.id}");
      
      // Verificamos con precisión el código de estado
      if (response.statusCode == 200) {
        // 200 significa que existe (es favorito)
        return true;
      } else if (response.statusCode == 404) {
        // 404 significa que no existe (no es favorito)
        return false;
      } else {
        // Cualquier otro código es un error, intentamos verificación local
        return _isFavoriteLocal(pelicula);
      }
    } catch (e) {
      // Fallback al almacenamiento local
      return _isFavoriteLocal(pelicula);
    }
  }
  
  // Método privado para verificar favoritos localmente
  Future<bool> _isFavoriteLocal(Pelicula pelicula) async {
    final favoritos = await _getFavoritesFromLocal();
    // Verificamos por ID si está disponible
    if (pelicula.id != null) {
      return favoritos.any((p) => p.id == pelicula.id);
    }
    // Si no hay ID, verificamos por título (menos preciso)
    return favoritos.any((p) => p.titulo == pelicula.titulo);
  }
  
  // Añadir película a favoritos
  Future<bool> addFavorite(Pelicula pelicula) async {
    try {
      if (pelicula.id == null) return false;
      
      final response = await _apiService.post(
        "/api/usuarios/favoritos/${pelicula.id}", 
        {}
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Si la operación en el backend es exitosa, actualizamos también localmente
        await _addFavoriteToLocal(pelicula);
        return true;
      }
      return false;
    } catch (e) {
      // Si falla el backend, guardamos solo localmente
      await _addFavoriteToLocal(pelicula);
      return true;
    }
  }
  
  // Eliminar película de favoritos
  Future<bool> removeFavorite(Pelicula pelicula) async {
    try {
      if (pelicula.id == null) return false;
      
      final response = await _apiService.delete("/api/usuarios/favoritos/${pelicula.id}");
      
      // Códigos de éxito para DELETE: 200 (OK), 202 (Accepted), 204 (No Content)
      if (response.statusCode == 200 || response.statusCode == 202 || 
          response.statusCode == 204) {
        // Si la operación en el backend es exitosa, actualizamos también localmente
        await _removeFavoriteFromLocal(pelicula);
        return true;
      } else if (response.statusCode == 404) {
        // Ya no existía como favorito
        await _removeFavoriteFromLocal(pelicula); // Aseguramos consistencia local
        return true;
      }
      return false;
    } catch (e) {
      // Si falla el backend, eliminamos solo localmente
      await _removeFavoriteFromLocal(pelicula);
      return true;
    }
  }
  
  // Métodos privados para manejo local (como respaldo)
  Future<List<Pelicula>> _getFavoritesFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
    
    return favoritesJson.map((movie) {
      Map<String, dynamic> movieMap = jsonDecode(movie);
      return Pelicula.fromJson(movieMap);
    }).toList();
  }
  
  Future<void> _addFavoriteToLocal(Pelicula pelicula) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
    
    // Verificar si ya existe
    final peliculaJson = jsonEncode(pelicula.toJson());
    if (!favoritesJson.contains(peliculaJson)) {
      favoritesJson.add(peliculaJson);
      await prefs.setStringList(_favoritesKey, favoritesJson);
    }
  }
  
  Future<void> _removeFavoriteFromLocal(Pelicula pelicula) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
    
    // Buscar por ID
    favoritesJson.removeWhere((movie) {
      Map<String, dynamic> movieMap = jsonDecode(movie);
      return movieMap['id'] == pelicula.id;
    });
    
    await prefs.setStringList(_favoritesKey, favoritesJson);
  }
}