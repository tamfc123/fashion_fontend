import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../product/presentation/bloc/product_event.dart';
import '../../../product/presentation/bloc/product_state.dart';
import '../../../product/presentation/widgets/category_filter_list.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../../../product/presentation/widgets/promo_banner_slider.dart';
import '../../../product/presentation/pages/product_detail_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../../injection_container.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String? _selectedCategory;

  String _getCategoryName(String category) {
    switch (category.toUpperCase()) {
      case 'SHIRT':
        return 'ÁO';
      case 'PANTS':
        return 'QUẦN';
      case 'HOODIE':
        return 'HOODIE';
      case 'DRESS':
        return 'VÁY';
      case 'JACKET':
        return 'ÁO KHOÁC';
      default:
        return category.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // Clear the cart state and SharedPreferences on logout
          context.read<CartBloc>().add(const ClearCartEvent());
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeTab(context),
            _buildSearchTab(),
            _buildCartTab(),
            _buildProfileTab(context),
          ],
        ),
        bottomNavigationBar: _currentIndex == 2
            ? null
            : BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Theme.of(context).primaryColor,
                unselectedItemColor: Colors.grey,
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Trang Chủ',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: 'Tìm Kiếm',
                  ),
                  BottomNavigationBarItem(
                    icon: BlocBuilder<CartBloc, CartState>(
                      builder: (context, state) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.shopping_cart),
                            if (state.itemCount > 0)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '${state.itemCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    label: 'Giỏ Hàng',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Cá Nhân',
                  ),
                ],
              ),
      ),
    );
  }

  // --- TAB 1: HOME (Feed) ---
  Widget _buildHomeTab(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProductBloc>()..add(const GetProductsEvent()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'FASHION.',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              fontSize: 22,
            ),
          ),
        ),
        body: RefreshIndicator(
          color: Colors.black,
          onRefresh: () async {
            // Because we create the Bloc inside BlocProvider, to refresh we need to access it via context inside standard Builder
            // However, typical pattern when Provider wraps Scaffold is to extract body to access context
            // Here we use a simpler approach by letting the Builder handle the context
          },
          child: Builder(
            builder: (blocContext) {
              return RefreshIndicator(
                color: Colors.black,
                onRefresh: () async {
                  blocContext.read<ProductBloc>().add(
                    GetProductsEvent(
                      category: _selectedCategory,
                      isRefresh: true,
                    ),
                  );
                  // Artificial delay to show spinner
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(child: PromoBannerSlider()),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'DANH MỤC',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverToBoxAdapter(
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          return CategoryFilterList(
                            selectedCategory: _selectedCategory,
                            onCategorySelected: (category) {
                              setState(() {
                                _selectedCategory = category;
                              });
                              // Dispatch event to bloc to fetch filtered products
                              blocContext.read<ProductBloc>().add(
                                GetProductsEvent(category: category),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          _selectedCategory == null
                              ? 'BỘ SƯU TẬP MỚI'
                              : 'BỘ SƯU TẬP ${_getCategoryName(_selectedCategory!)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    BlocBuilder<ProductBloc, ProductState>(
                      builder: (context, state) {
                        if (state is ProductLoading) {
                          return const SliverFillRemaining(
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
                            ),
                          );
                        } else if (state is ProductError) {
                          return SliverFillRemaining(
                            child: Center(
                              child: Text(
                                state.message,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          );
                        } else if (state is ProductLoaded) {
                          if (state.products.isEmpty) {
                            return const SliverFillRemaining(
                              child: Center(
                                child: Text(
                                  'KHÔNG TÌM THẤY SẢN PHẨM NÀO.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            );
                          }

                          return SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.65,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                  ),
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                return ProductCard(
                                  product: state.products[index],
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ProductDetailPage(
                                          productId: state.products[index].id,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }, childCount: state.products.length),
                            ),
                          );
                        }
                        return const SliverFillRemaining(
                          child: SizedBox.shrink(),
                        );
                      },
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // --- TAB 2: SEARCH ---
  Widget _buildSearchTab() {
    return Scaffold(
      appBar: AppBar(title: const Text('Tìm Kiếm')),
      body: const Center(
        child: Chip(label: Text('Hệ thống đang cập nhật dữ liệu... 🚧')),
      ),
    );
  }

  Widget _buildCartTab() {
    return CartPage(
      isTab: true,
      onBack: () {
        setState(() {
          _currentIndex = 0; // Return to Home
        });
      },
    );
  }

  // --- TAB 4: PROFILE ---
  Widget _buildProfileTab(BuildContext context) {
    return const ProfilePage();
  }
}
