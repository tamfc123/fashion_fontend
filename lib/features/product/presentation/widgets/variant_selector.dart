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
          RichText(
            text: TextSpan(
              text: 'COLOR',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.black,
              ),
              children: [
                if (selectedVariant?.color != null)
                  TextSpan(
                    text: ' : ${selectedVariant!.color}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.black87,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: uniqueColors.map((color) {
              final isSelected = selectedVariant?.color == color;

              return GestureDetector(
                onTap: () {
                  // Find a variant that matches the new color and the *current* size (if possible)
                  final matchedVariant = variants
                      .cast<ProductVariantEntity>()
                      .firstWhere(
                        (v) =>
                            v.color == color && v.size == selectedVariant?.size,
                        orElse: () => variants
                            .cast<ProductVariantEntity>()
                            .firstWhere((v) => v.color == color),
                      );
                  onVariantSelected(matchedVariant);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : Colors.white,
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey[300]!,
                      width: isSelected
                          ? 2
                          : 1, // Slightly bolder border for selected
                    ),
                    borderRadius: BorderRadius.circular(
                      8,
                    ), // Add subtle rounding
                  ),
                  child: Text(
                    color,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
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
          RichText(
            text: TextSpan(
              text: 'SIZE',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.black,
              ),
              children: [
                if (selectedVariant?.size != null)
                  TextSpan(
                    text: ' : ${selectedVariant!.size}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.black87,
                    ),
                  ),
              ],
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
                              : Colors.grey[200]), // Darker grey for disabled
                    border: Border.all(
                      color: isSelected
                          ? Colors.black
                          : (isValidCombination
                                ? Colors.grey[300]!
                                : Colors.grey[200]!),
                      width: isSelected
                          ? 2
                          : 1, // Match color selector thickness
                    ),
                    borderRadius: BorderRadius.circular(
                      8,
                    ), // Match color selector radius
                  ),
                  child: Text(
                    size,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isValidCombination
                                ? Colors.black87
                                : Colors.grey[500]), // Muted text for disabled
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      decoration: isValidCombination
                          ? null
                          : TextDecoration
                                .lineThrough, // Strikethrough for disabled
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
