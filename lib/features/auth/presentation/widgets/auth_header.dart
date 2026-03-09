import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imagePath;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (imagePath != null)
          Image.asset(imagePath!, height: 120, fit: BoxFit.contain)
        else
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }
}
