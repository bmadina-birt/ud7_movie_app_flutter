import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/pelicula.dart';

class CreateMovieScreen extends StatefulWidget {
  const CreateMovieScreen({super.key});

  @override
  State<CreateMovieScreen> createState() => _CreateMovieScreenState();
}

class _CreateMovieScreenState extends State<CreateMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _generoController = TextEditingController();
  final _fechaEstrenoController = TextEditingController();
  final _imagenUrlController = TextEditingController();

  bool _isLoading = false;
  final ApiService apiService = ApiService();

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Formato YYYY-MM-DD usando partes de la fecha directamente
      String day = picked.day.toString().padLeft(2, '0');
      String month = picked.month.toString().padLeft(2, '0');
      String year = picked.year.toString();
      
      setState(() {
        _fechaEstrenoController.text = "$year-$month-$day";
      });
    }
  }

  Future<void> _saveMovie() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isLoading = true);

    final nuevaPelicula = Pelicula(
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      genero: _generoController.text.trim(),
      fechaEstreno: _fechaEstrenoController.text.trim(),
      imagenUrl: _imagenUrlController.text.trim().isNotEmpty 
          ? _imagenUrlController.text.trim() 
          : null,
    );
    
    final response = await apiService.post(
      "/api/peliculas", 
      nuevaPelicula.toJson()
    );
    
    setState(() => _isLoading = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Película creada con éxito")),
      );
      Navigator.pop(context, true);
      // 'true' indica que se creó la película, así la lista puede refrescar
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al crear la película: ${response.statusCode}"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nueva Película")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: "Título",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: "Descripción",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _generoController,
                decoration: const InputDecoration(
                  labelText: "Género",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un género';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fechaEstrenoController,
                decoration: InputDecoration(
                  labelText: "Fecha de estreno",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDate,
                  ),
                ),
                readOnly: true,
                onTap: _selectDate,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona una fecha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imagenUrlController,
                decoration: const InputDecoration(
                  labelText: "URL de Imagen (opcional)",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    bool validURL = Uri.tryParse(value)?.hasAbsolutePath ?? false;
                    if (!validURL) {
                      return 'Por favor ingresa una URL válida';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text("Guardar Película"),
                        onPressed: _saveMovie,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _generoController.dispose();
    _fechaEstrenoController.dispose();
    _imagenUrlController.dispose();
    super.dispose();
  }
}