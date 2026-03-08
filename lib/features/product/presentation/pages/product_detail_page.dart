import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../injection_container.dart';
import '../bloc/product_detail_bloc.dart';
import '../bloc/product_detail_event.dart';
import '../bloc/product_detail_state.dart';
import '../widgets/add_to_cart_bottom_sheet.dart';
import '../widgets/product_image_carousel.dart';

class ProductDetailPage extends StatelessWidget {
  final Object
  productId; // Accepting Object to handle string/int safely from arguments

  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<ProductDetailBloc>()
            ..add(GetProductDetailEvent(productId: productId.toString())),
      child: const _ProductDetailPageView(),
    );
  }
}

class _ProductDetailPageView extends StatelessWidget {
  const _ProductDetailPageView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.8),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.8),
              child: IconButton(
                icon: const Icon(
                  Icons.favorite_border,
                  color: Colors.black,
                  size: 20,
                ),
                onPressed: () {},
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.8),
              child: IconButton(
                icon: const Icon(
                  Icons.share_outlined,
                  color: Colors.black,
                  size: 20,
                ),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: BlocBuilder<ProductDetailBloc, ProductDetailState>(
        builder: (context, state) {
          if (state is ProductDetailLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          } else if (state is ProductDetailError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (state is ProductDetailLoaded) {
            final product = state.product;
            final variant = state.selectedVariant;

            // Resolve dynamic price and stock
            final price = variant?.price ?? 0.0;

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    bottom: 120,
                  ), // Leave space for sticky bottom bar
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProductImageCarousel(images: product.images),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Info
                            Text(
                              product.category.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              NumberFormat.currency(
                                locale: 'vi_VN',
                                symbol: 'đ',
                              ).format(price),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Description
                            const Text(
                              'DESCRIPTION',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              product.description ??
                                  'No description available.',
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Sticky Bottom Add To Cart Button
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    // Removed double.infinity
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 16,
                      bottom:
                          MediaQuery.of(context).padding.bottom +
                          16, // Breathing room below
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey[200]!)),
                    ),
                    child: SizedBox(
                      width: double
                          .infinity, // Let button expand within padded container
                      child: ElevatedButton(
                        onPressed: () {
                          // Get the bloc instance from current context to pass down
                          final bloc = context.read<ProductDetailBloc>();
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              return AddToCartBottomSheet(
                                product: product,
                                bloc: bloc,
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          disabledBackgroundColor: Colors.grey[300],
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // Pill shape
                          ),
                        ),
                        child: const Text(
                          'CHỌN LOẠI HÀNG', // Rephrased correctly since logic moved to BottomSheet
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
