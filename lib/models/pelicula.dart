// lib/models/pelicula.dart - Modificar la clase Pelicula
class Pelicula {
  final int? id;
  final String titulo;
  final String descripcion;
  final String genero;
  final String fechaEstreno;
  final String? imagenUrl;
  double? valoracionMedia; // Nueva propiedad
  int? numValoraciones; // Nueva propiedad
  
  Pelicula({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.genero,
    required this.fechaEstreno,
    this.imagenUrl,
    this.valoracionMedia,
    this.numValoraciones,
  });
  
  // Constructor para crear un objeto desde JSON
  factory Pelicula.fromJson(Map<String, dynamic> json) {
    return Pelicula(
      id: json['id'],
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      genero: json['genero'] ?? '',
      fechaEstreno: json['fechaEstreno'] ?? '',
      imagenUrl: json['imagenUrl'],
      valoracionMedia: json['valoracionMedia'] != null
          ? (json['valoracionMedia'] is int)
              ? (json['valoracionMedia'] as int).toDouble()
              : double.tryParse(json['valoracionMedia'].toString())
          : null,
      numValoraciones: json['numValoraciones'],
    );
  }
  
  // Método para convertir el objeto a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'genero': genero,
      'fechaEstreno': fechaEstreno,
      'imagenUrl': imagenUrl,
      'valoracionMedia': valoracionMedia,
      'numValoraciones': numValoraciones,
    };
  }
}