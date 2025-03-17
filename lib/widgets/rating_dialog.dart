// lib/widgets/rating_dialog.dart
import 'package:flutter/material.dart';
import 'rating_stars.dart';

class RatingDialog extends StatefulWidget {
  final double initialRating;
  final String? initialComment;
  final bool allowDelete;
  final Function(double, String?)? onSubmit;
  final VoidCallback? onDelete;

  const RatingDialog({
    super.key, 
    this.initialRating = 0, 
    this.initialComment,
    this.allowDelete = false,
    this.onSubmit, 
    this.onDelete,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late double _rating;
  late TextEditingController _commentController;
  
  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    _commentController = TextEditingController(text: widget.initialComment ?? '');
  }
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Valorar Película'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Qué te ha parecido esta película?'),
            const SizedBox(height: 16),
            RatingStars(
              rating: _rating,
              size: 40,
              onRatingChanged: (value) {
                setState(() {
                  _rating = value;
                });
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Tu valoración: ${_rating.toInt().toString()} / 5',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Comentario (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        if (widget.allowDelete)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (widget.onDelete != null) {
                widget.onDelete!();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar valoración'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _rating > 0
              ? () {
                  Navigator.of(context).pop();
                  if (widget.onSubmit != null) {
                    final commentText = _commentController.text.trim();
                    widget.onSubmit!(
                      _rating,
                      commentText.isNotEmpty ? commentText : null,
                    );
                  }
                }
              : null,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}