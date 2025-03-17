// lib/screens/favoritos_screen.dart
import 'package:flutter/material.dart';
import '../models/pelicula.dart';
import '../services/favorites_service.dart';
import 'detalle_pelicula_screen.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  List<Pelicula> _favoritos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
  }

  Future<void> _cargarFavoritos() async {
    setState(() => _isLoading = true);
    try {
      final favoritos = await _favoritesService.getFavorites();
      if (mounted) {
        setState(() {
          _favoritos = favoritos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar favoritos: $e')),
        );
      }
    }
  }

  Future<void> _quitarDeFavoritos(Pelicula pelicula) async {
    try {
      final success = await _favoritesService.removeFavorite(pelicula);
      if (success && mounted) {
        setState(() {
          _favoritos.removeWhere((p) => p.id == pelicula.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Película eliminada de favoritos')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoritos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No tienes películas favoritas',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        icon: const Icon(Icons.movie),
                        label: const Text('Explorar películas'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarFavoritos,
                  child: ListView.builder(
                    itemCount: _favoritos.length,
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      final pelicula = _favoritos[index];
                      
                      return Dismissible(
                        key: Key(pelicula.id?.toString() ?? index.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          _quitarDeFavoritos(pelicula);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetallePeliculaScreen(
                                  pelicula: pelicula,
                                  onFavoriteChanged: () => _cargarFavoritos(),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Miniatura de la película
                                SizedBox(
                                  width: 100,
                                  height: 120,
                                  child: (pelicula.imagenUrl != null && pelicula.imagenUrl!.isNotEmpty)
                                      ? Image.network(
                                          pelicula.imagenUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Center(child: Icon(Icons.error, size: 40));
                                          },
                                        )
                                      : Container(
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.movie, size: 40, color: Colors.grey),
                                        ),
                                ),
                                
                                // Información de la película
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pelicula.titulo,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          pelicula.genero,
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              pelicula.fechaEstreno,
                                              style: Theme.of(context).textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                // Botón para quitar de favoritos
                                IconButton(
                                  icon: const Icon(Icons.favorite, color: Colors.red),
                                  onPressed: () => _quitarDeFavoritos(pelicula),
                                  tooltip: 'Quitar de favoritos',
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}