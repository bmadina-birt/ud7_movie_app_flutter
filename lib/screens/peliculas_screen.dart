// lib/screens/peliculas_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/rating_service.dart';
import '../models/pelicula.dart';
import '../widgets/rating_stars.dart';
import 'login_screen.dart';
import 'detalle_pelicula_screen.dart';
import 'create_movie_screen.dart';
import 'favoritos_screen.dart';

class PeliculasScreen extends StatefulWidget {
  const PeliculasScreen({super.key});

  @override
  State<PeliculasScreen> createState() => _PeliculasScreenState();
}

class _PeliculasScreenState extends State<PeliculasScreen> {
  final ApiService apiService = ApiService();
  final RatingService ratingService = RatingService();
  List<Pelicula> peliculas = [];
  Map<int?, double> peliculasRatings = {};
  bool isLoading = true;
  String? searchQuery;

  @override
  void initState() {
    super.initState();
    _cargarPeliculas();
  }

  Future<void> _cargarPeliculas() async {
    setState(() => isLoading = true);
    final response = await apiService.get("/api/peliculas");

    if (response.statusCode == 200) {
      setState(() {
        final data = jsonDecode(response.body);
        peliculas =
            (data as List).map((item) => Pelicula.fromJson(item)).toList();
        isLoading = false;
      });

      // Cargar ratings después de cargar películas
      _cargarRatings();
    } else {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${response.statusCode}")));
    }
  }

  // Método para cargar las valoraciones de todas las películas
  Future<void> _cargarRatings() async {
    for (var pelicula in peliculas) {
      if (pelicula.id != null) {
        try {
          final rating = await ratingService.getMovieAverageRating(
            pelicula.id!,
          );
          if (rating != null && mounted) {
            setState(() {
              peliculasRatings[pelicula.id] = rating;
            });
          }
        } catch (e) {
          // Ignorar errores individuales para que no afecten al resto
          debugPrint('Error al cargar rating de película ${pelicula.id}: $e');
        }
      }
    }
  }

  void _searchMovies(String query) {
    setState(() {
      searchQuery = query.isEmpty ? null : query.toLowerCase();
    });
  }

  List<Pelicula> get _filteredMovies {
    if (searchQuery == null) return peliculas;
    return peliculas.where((pelicula) {
      return pelicula.titulo.toLowerCase().contains(searchQuery!) ||
          pelicula.genero.toLowerCase().contains(searchQuery!);
    }).toList();
  }

  void _logout() async {
    final authService = AuthService();
    await authService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // Navega a la pantalla de crear nueva película
  void _irACrearPelicula() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateMovieScreen()),
    );
    if (result == true) {
      // Si se creó una película, refrescamos la lista
      _cargarPeliculas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Películas"),
        actions: [
          // Botón de favoritos
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritosScreen(),
                ),
              ).then((_) {
                // Refrescamos la lista por si los favoritos cambiaron
                setState(() {});
              });
            },
            tooltip: 'Mis Favoritos',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Mostramos un diálogo simple para buscar
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Buscar películas'),
                      content: TextField(
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Título o género...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: _searchMovies,
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Cerrar'),
                          onPressed: () {
                            _searchMovies(''); // Limpiamos la búsqueda
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _cargarPeliculas,
                child:
                    _filteredMovies.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.local_movies_outlined,
                                size: 80,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                searchQuery != null
                                    ? "No se encontraron películas"
                                    : "No hay películas disponibles",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              if (searchQuery != null)
                                TextButton(
                                  onPressed: () {
                                    setState(() => searchQuery = null);
                                  },
                                  child: const Text("Limpiar búsqueda"),
                                ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          itemCount: _filteredMovies.length,
                          padding: const EdgeInsets.all(8),
                          itemBuilder: (context, index) {
                            final pelicula = _filteredMovies[index];
                            final hasRating = peliculasRatings.containsKey(
                              pelicula.id,
                            );
                            final rating =
                                hasRating
                                    ? peliculasRatings[pelicula.id]!
                                    : 0.0;

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              elevation: 4,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: InkWell(
                                onTap:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => DetallePeliculaScreen(
                                              pelicula: pelicula,
                                            ),
                                      ),
                                    ).then((_) => _cargarPeliculas()),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (pelicula.imagenUrl != null &&
                                        pelicula.imagenUrl!.isNotEmpty)
                                      SizedBox(
                                        height: 180,
                                        width: double.infinity,
                                        child: Image.network(
                                          pelicula.imagenUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              color: Colors.grey[300],
                                              child: const Center(
                                                child: Icon(
                                                  Icons.error,
                                                  size: 40,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    else
                                      Container(
                                        height: 120,
                                        width: double.infinity,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.movie,
                                          size: 80,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pelicula.titulo,
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.titleLarge,
                                          ),
                                          const SizedBox(height: 8),
                                          // Añadir estrellas de valoración
                                          if (hasRating && rating > 0)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 8,
                                              ),
                                              child: RatingStars(
                                                rating: rating,
                                                size: 20,
                                                showLabel: true,
                                              ),
                                            ),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.category,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                pelicula.genero,
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.bodyMedium,
                                              ),
                                              const Spacer(),
                                              const Icon(
                                                Icons.calendar_month,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                pelicula.fechaEstreno,
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.bodyMedium,
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
                          },
                        ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _irACrearPelicula,
        child: const Icon(Icons.add),
      ),
    );
  }
}
