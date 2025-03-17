// lib/screens/detalle_pelicula_screen.dart - Modificar para incluir valoraciones
import 'package:flutter/material.dart';
import '../models/pelicula.dart';
import '../models/rating_data.dart';
import '../services/favorites_service.dart';
import '../services/rating_service.dart';
import '../widgets/rating_stars.dart';
import '../widgets/rating_dialog.dart';

class DetallePeliculaScreen extends StatefulWidget {
  final Pelicula pelicula;
  final VoidCallback? onFavoriteChanged;

  const DetallePeliculaScreen({
    super.key, 
    required this.pelicula, 
    this.onFavoriteChanged,
  });

  @override
  State<DetallePeliculaScreen> createState() => _DetallePeliculaScreenState();
}

class _DetallePeliculaScreenState extends State<DetallePeliculaScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  final RatingService _ratingService = RatingService();
  bool _isFavorite = false;
  bool _isLoading = true;
  bool _isRatingLoading = true;
  RatingData? _userRating;
  double _movieRating = 0;
  List<RatingData> _movieRatings = [];
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    _checkFavoriteStatus();
    await _loadRatingData();
  }
  
  Future<void> _checkFavoriteStatus() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final isFavorite = await _favoritesService.isFavorite(widget.pelicula);
      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFavorite = false;
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _loadRatingData() async {
    if (widget.pelicula.id == null) return;
    
    setState(() => _isRatingLoading = true);
    
    try {
      // Cargar la valoración del usuario
      final userRating = await _ratingService.getUserRating(widget.pelicula.id!);
      
      // Cargar la valoración media
      final movieRating = await _ratingService.getMovieAverageRating(widget.pelicula.id!);
      
      // Cargar todas las valoraciones
      final movieRatings = await _ratingService.getMovieRatings(widget.pelicula.id!);
      
      if (mounted) {
        setState(() {
          _userRating = userRating;
          _movieRating = movieRating ?? 0;
          _movieRatings = movieRatings;
          _isRatingLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRatingLoading = false;
        });
        _showErrorMessage('Error al cargar valoraciones');
      }
    }
  }
  
  Future<void> _toggleFavorite() async {
    setState(() => _isLoading = true);
    
    try {
      bool success;
      if (_isFavorite) {
        success = await _favoritesService.removeFavorite(widget.pelicula);
      } else {
        success = await _favoritesService.addFavorite(widget.pelicula);
      }
      
      if (success && mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
          _isLoading = false;
        });
        
        // Notificar cambios si hay un callback
        widget.onFavoriteChanged?.call();
        
        // Mostrar mensaje
        final message = _isFavorite 
            ? 'Película añadida a favoritos' 
            : 'Película eliminada de favoritos';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } else if (mounted) {
        setState(() => _isLoading = false);
        _showErrorMessage('No se pudo actualizar favoritos');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorMessage('Error: $e');
      }
    }
  }

 // Reemplaza solo estos métodos en lib/screens/detalle_pelicula_screen.dart
Future<void> _showRatingDialog() async {
  if (widget.pelicula.id == null) return;
  
  if (!mounted) return;
  
  showDialog(
    context: context,
    builder: (dialogContext) => RatingDialog(
      initialRating: _userRating?.rating ?? 0,
      initialComment: _userRating?.comentario,
      allowDelete: _userRating != null,
      onDelete: () {
        Navigator.pop(dialogContext);
        _deleteRatingHandler();
      },
      onSubmit: (rating, comment) {
        Navigator.pop(dialogContext);
        _saveRatingHandler(rating, comment);
      },
    ),
  );
}

Future<void> _deleteRatingHandler() async {
  setState(() => _isRatingLoading = true);
  
  try {
    final success = await _ratingService.deleteRating(widget.pelicula.id!);
    
    if (success) {
      await _loadRatingData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Valoración eliminada correctamente')),
        );
      }
    } else if (mounted) {
      setState(() => _isRatingLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar valoración')),
      );
    }
  } catch (e) {
    if (mounted) {
      setState(() => _isRatingLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

Future<void> _saveRatingHandler(double rating, String? comment) async {
  setState(() => _isRatingLoading = true);
  
  try {
    bool success;
    if (_userRating == null) {
      success = await _ratingService.saveRating(
        widget.pelicula.id!, 
        rating, 
        comment,
      );
    } else {
      success = await _ratingService.updateRating(
        widget.pelicula.id!, 
        rating, 
        comment,
      );
    }
    
    if (success) {
      await _loadRatingData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Valoración guardada correctamente')),
        );
      }
    } else {
      if (mounted) {
        setState(() => _isRatingLoading = false);
        _showRatingError('Error al guardar la valoración');
      }
    }
  } catch (e) {
    if (mounted) {
      setState(() => _isRatingLoading = false);
      _showRatingError('Error al procesar la valoración');
    }
  }
}

void _showRatingError(String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Error'),
      content: Text('$message. Por favor, intenta nuevamente o inicia sesión de nuevo.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Aceptar'),
        ),
      ],
    ),
  );
}

void _showErrorMessage(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pelicula.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Botón de favoritos en la barra de acción
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : null,
                  ),
            onPressed: _isLoading ? null : _toggleFavorite,
            tooltip: 'Añadir/quitar de favoritos',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen destacada - MODIFICADA para verse completa
            if (widget.pelicula.imagenUrl != null && widget.pelicula.imagenUrl!.isNotEmpty)
              Container(
                constraints: BoxConstraints(
                  maxHeight: screenSize.height * 0.5,
                ),
                width: double.infinity,
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Image.network(
                    widget.pelicula.imagenUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.error, size: 50)),
                      );
                    },
                  ),
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.movie, size: 100, color: Colors.grey)),
              ),

            // Información principal
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    widget.pelicula.titulo,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // Valoración
                  Row(
                    children: [
                      _isRatingLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : RatingStars(
                              rating: _movieRating,
                              size: 24,
                              color: Colors.amber,
                              showLabel: true,
                            ),
                      const Spacer(),
                      TextButton.icon(
                        icon: const Icon(Icons.star),
                        label: Text(_userRating != null ? 'Editar valoración' : 'Valorar'),
                        onPressed: _showRatingDialog,
                      ),
                    ],
                  ),
                  if (_movieRating > 0 && _movieRatings.isNotEmpty)
                    Text(
                      '${_movieRatings.length} ${_movieRatings.length == 1 ? "valoración" : "valoraciones"}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 16),

                  // Género y fecha de estreno
                  Wrap(
                    spacing: 16,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.category, size: 20),
                        label: Text(widget.pelicula.genero),
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      Chip(
                        avatar: const Icon(Icons.calendar_today, size: 20),
                        label: Text(widget.pelicula.fechaEstreno),
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Sección de descripción
                  Text(
                    'Descripción',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.pelicula.descripcion,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Sección de valoraciones
                  if (_movieRatings.isNotEmpty) ...[
                    Text(
                      'Valoraciones de usuarios',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ..._buildRatingsList(),
                    const SizedBox(height: 32),
                  ],

                  // Botones de acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text('Compartir'),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Función de compartir no implementada')),
                          );
                        },
                      ),
                      FilledButton.icon(
                        icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
                        label: Text(_isFavorite ? 'En Favoritos' : 'Añadir a Favoritos'),
                        onPressed: _toggleFavorite,
                        style: FilledButton.styleFrom(
                          backgroundColor: _isFavorite ? Colors.red : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
List<Widget> _buildRatingsList() {
  return _movieRatings.map((rating) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Añadir nombre de usuario si está disponible
                if (rating.nombreUsuario != null)
                  Text(
                    rating.nombreUsuario!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                const Spacer(),
                Text(
                  rating.fecha,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            RatingStars(
              rating: rating.rating,
              size: 20,
            ),
            if (rating.comentario != null && rating.comentario!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(rating.comentario!),
            ],
          ],
        ),
      ),
    );
  }).toList();
}
}