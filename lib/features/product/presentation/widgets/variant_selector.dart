import 'package:flutter/material.dart';

import '../../domain/entities/product_variant_entity.dart';

class VariantSelector extends StatelessWidget {
  final List<ProductVariantEntity> variants;
  final ProductVariantEntity? selectedVariant;
  final Function(ProductVariantEntity) onVariantSelected;

  const VariantSelector({
    super.key,
    required this.variants,
    required this.selectedVariant,
    required this.onVariantSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Extract unique colors and sizes from variants
    final uniqueColors = variants.map((v) => v.color).toSet().toList();
    final uniqueSizes = variants.map((v) => v.size).toSet().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // COLOR SELECTOR
        if (uniqueColors.isNotEmpty && uniqueColors.first != '') ...[
          const Text(
            'COLOR',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: uniqueColors.map((color) {
              final isSelected = selectedVariant?.color == color;
              // Map color name to actual color if possible, fallback to black border
              Color circleColor = Colors.grey[300]!;
              if (color.toLowerCase() == 'black') circleColor = Colors.black;
              if (color.toLowerCase() == 'white') circleColor = Colors.white;
              if (color.toLowerCase() == 'red') circleColor = Colors.red;
              if (color.toLowerCase() == 'blue') circleColor = Colors.blue;

              return GestureDetector(
                onTap: () {
                  // Find a variant that matches the new color and the *current* size (if possible)
                  final matchedVariant = variants.firstWhere(
                    (v) => v.color == color && v.size == selectedVariant?.size,
                    orElse: () => variants.firstWhere((v) => v.color == color),
                  );
                  onVariantSelected(matchedVariant);
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey[300]!,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // SIZE SELECTOR
        if (uniqueSizes.isNotEmpty && uniqueSizes.first != '') ...[
          const Text(
            'SIZE',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: uniqueSizes.map((size) {
              final isSelected = selectedVariant?.size == size;
              // Check if combination exists in stock
              final isValidCombination = variants.any(
                (v) => v.size == size && v.color == selectedVariant?.color,
              );

              return GestureDetector(
                onTap: () {
                  if (!isValidCombination) return;
                  final matchedVariant = variants.firstWhere(
                    (v) => v.size == size && v.color == selectedVariant?.color,
                  );
                  onVariantSelected(matchedVariant);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.black
                        : (isValidCombination
                              ? Colors.white
                              : Colors.grey[100]),
                    border: Border.all(
                      color: isSelected
                          ? Colors.black
                          : (isValidCombination
                                ? Colors.grey[400]!
                                : Colors.grey[200]!),
                    ),
                  ),
                  child: Text(
                    size,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isValidCombination
                                ? Colors.black
                                : Colors.grey[400]),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
