import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/product_entity.dart';
import '../bloc/product_detail_bloc.dart';
import '../bloc/product_detail_event.dart';
import '../bloc/product_detail_state.dart';
import 'variant_selector.dart';

class AddToCartBottomSheet extends StatelessWidget {
  final ProductEntity product;
  final ProductDetailBloc bloc;

  const AddToCartBottomSheet({
    super.key,
    required this.product,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    // Provide the existing bloc to the bottom sheet context
    return BlocProvider.value(
      value: bloc,
      child: Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: BlocBuilder<ProductDetailBloc, ProductDetailState>(
          builder: (context, state) {
            if (state is ProductDetailLoaded) {
              final variant = state.selectedVariant;
              final price = variant?.price ?? 0.0;
              final stock = variant?.stock ?? 0;
              final inStock = stock > 0;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Image Thumbnail + Price + Stock
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          image: product.images.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(product.images.first),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: product.images.isEmpty
                            ? const Icon(Icons.image, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              NumberFormat.currency(
                                locale: 'vi_VN',
                                symbol: 'đ',
                              ).format(price),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Kho: $stock',
                              style: TextStyle(
                                fontSize: 14,
                                color: inStock ? Colors.grey[700] : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1, color: Colors.black12),
                  const SizedBox(height: 24),

                  // Variant Selection (Live updates via Bloc)
                  VariantSelector(
                    variants: product.variants,
                    selectedVariant: variant,
                    onVariantSelected: (v) {
                      context.read<ProductDetailBloc>().add(
                        SelectVariantEvent(variant: v),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: inStock
                          ? () {
                              // TODO: Dispatch AddToCart event here
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã thêm vào giỏ hàng!'),
                                  backgroundColor: Colors.black,
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        disabledBackgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 20,
                            color: inStock ? Colors.white : Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            inStock ? 'THÊM VÀO GIỎ' : 'HẾT HÀNG',
                            style: TextStyle(
                              color: inStock ? Colors.white : Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
