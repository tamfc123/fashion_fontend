import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/product_entity.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../bloc/product_detail_bloc.dart';
import '../bloc/product_detail_event.dart';
import '../bloc/product_detail_state.dart';
import 'variant_selector.dart';

class AddToCartBottomSheet extends StatefulWidget {
  final ProductEntity product;
  final ProductDetailBloc bloc;
  final GlobalKey cartKey;

  const AddToCartBottomSheet({
    super.key,
    required this.product,
    required this.bloc,
    required this.cartKey,
  });

  @override
  State<AddToCartBottomSheet> createState() => _AddToCartBottomSheetState();
}

class _AddToCartBottomSheetState extends State<AddToCartBottomSheet> {
  final GlobalKey _imageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // Provide the existing bloc to the bottom sheet context
    return BlocProvider.value(
      value: widget.bloc,
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
                        key: _imageKey,
                        width: 80,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          image: widget.product.images.isNotEmpty
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    widget.product.images.first,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: widget.product.images.isEmpty
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
                    variants: widget.product.variants,
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
                              final cartBloc = context.read<CartBloc>();
                              final scaffoldMessenger = ScaffoldMessenger.of(
                                context,
                              );
                              final overlayState = Overlay.of(
                                context,
                                rootOverlay: true,
                              );

                              Offset? startPosition;
                              Offset? endPosition;

                              if (_imageKey.currentContext != null &&
                                  widget.cartKey.currentContext != null) {
                                final startRenderBox =
                                    _imageKey.currentContext!.findRenderObject()
                                        as RenderBox;
                                startPosition = startRenderBox.localToGlobal(
                                  Offset.zero,
                                );

                                final endRenderBox =
                                    widget.cartKey.currentContext!
                                            .findRenderObject()
                                        as RenderBox;
                                endPosition = endRenderBox.localToGlobal(
                                  Offset.zero,
                                );
                              }

                              final String imageUrl =
                                  widget.product.images.isNotEmpty
                                  ? widget.product.images.first
                                  : '';

                              final cartItem = CartItemEntity(
                                productId: widget.product.id,
                                variantId: variant?.id ?? '',
                                name: widget.product.name,
                                price: price,
                                imageUrl: imageUrl,
                                color: variant?.color ?? '',
                                size: variant?.size ?? '',
                                quantity: 1, // Fixed to 1 for now
                              );

                              // Bấm xong ẩn BottomSheet ngay
                              Navigator.of(context).pop();

                              if (startPosition != null &&
                                  endPosition != null) {
                                late OverlayEntry overlayEntry;

                                overlayEntry = OverlayEntry(
                                  builder: (context) {
                                    return FlightAnimationWidget(
                                      startPosition: startPosition!,
                                      endPosition: endPosition!,
                                      imageUrl: imageUrl,
                                      onCompleted: () {
                                        overlayEntry.remove();
                                        // Khi ảnh chạm giỏ hàng, nổ event thêm vào giỏ và hiện SnackBar
                                        cartBloc.add(AddToCartEvent(cartItem));
                                        scaffoldMessenger.showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Đã thêm vào giỏ hàng!',
                                            ),
                                            backgroundColor: Colors.black,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                                overlayState.insert(overlayEntry);
                              } else {
                                // Fallback nếu không bắt được tọa độ
                                cartBloc.add(AddToCartEvent(cartItem));
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã thêm vào giỏ hàng!'),
                                    backgroundColor: Colors.black,
                                  ),
                                );
                              }
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

class FlightAnimationWidget extends StatefulWidget {
  final Offset startPosition;
  final Offset endPosition;
  final String imageUrl;
  final VoidCallback onCompleted;

  const FlightAnimationWidget({
    super.key,
    required this.startPosition,
    required this.endPosition,
    required this.imageUrl,
    required this.onCompleted,
  });

  @override
  State<FlightAnimationWidget> createState() => _FlightAnimationWidgetState();
}

class _FlightAnimationWidgetState extends State<FlightAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _positionAnimation =
        Tween<Offset>(
          begin: widget.startPosition,
          end: widget.endPosition,
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
        );

    // Shrinks from 1x down to 0.1x so it disappears into the cart
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInQuad));

    _controller.forward().then((_) {
      if (mounted) {
        widget.onCompleted();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 10,
                    offset: const Offset(4, 4),
                  ),
                ],
                image: widget.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(widget.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: widget.imageUrl.isEmpty
                  ? const Icon(Icons.image, color: Colors.grey)
                  : null,
            ),
          ),
        );
      },
    );
  }
}
