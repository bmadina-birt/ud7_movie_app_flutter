// lib/models/rating_data.dart
class RatingData {
  final int? id;
  final int peliculaId;
  final String userId;
  final double rating;
  final String? comentario;
  final String fecha;
  final String? nombreUsuario;

  RatingData({
    this.id,
    required this.peliculaId,
    required this.userId,
    required this.rating,
    this.comentario,
    required this.fecha,
    this.nombreUsuario,
  });

  factory RatingData.fromJson(Map<String, dynamic> json) {
    // Convertir la fecha a formato legible si viene como ISO
    String fecha = '';
    if (json['fecha'] != null) {
      try {
        if (json['fecha'] is String) {
          // Intentar parsear como DateTime para mostrar solo la fecha
          final dateTime = DateTime.parse(json['fecha']);
          fecha = "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
        } else {
          fecha = json['fecha'].toString();
        }
      } catch (e) {
        fecha = json['fecha'].toString();
      }
    }

    return RatingData(
      id: json['id'],
      peliculaId: json['peliculaId'],
      userId: json['userId']?.toString() ?? '',
      rating: _parseRating(json['rating']),
      comentario: json['comentario'],
      fecha: fecha,
      nombreUsuario: json['nombreUsuario'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'peliculaId': peliculaId,
      'rating': rating,
      if (comentario != null && comentario!.isNotEmpty) 'comentario': comentario,
      'fecha': fecha,
      if (nombreUsuario != null) 'nombreUsuario': nombreUsuario,
    };
  }
  
  static double _parseRating(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}