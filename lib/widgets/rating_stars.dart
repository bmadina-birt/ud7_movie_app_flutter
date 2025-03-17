// lib/widgets/rating_stars.dart
import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;
  final Function(double)? onRatingChanged;
  final bool showLabel;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 24,
    this.color = Colors.amber,
    this.onRatingChanged,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final value = index + 1;
            
            IconData icon;
            if (value <= rating) {
              icon = Icons.star;
            } else if (value - 0.5 <= rating && rating < value) {
              icon = Icons.star_half;
            } else {
              icon = Icons.star_border;
            }
            
            return GestureDetector(
              onTap: onRatingChanged != null ? () => onRatingChanged!(value.toDouble()) : null,
              child: Icon(
                icon,
                size: size,
                color: color,
              ),
            );
          }),
        ),
        if (showLabel && rating > 0) ...[
          const SizedBox(width: 8),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.75,
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade800,
            ),
          ),
        ]
      ],
    );
  }
}