import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';

import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../product/presentation/bloc/product_event.dart';
import '../../../product/presentation/bloc/product_state.dart';
import '../../../product/presentation/widgets/category_filter_list.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../../../product/presentation/widgets/promo_banner_slider.dart';
import '../../../product/presentation/pages/product_detail_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../../injection_container.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
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
          actions: [
            IconButton(
              icon: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.black,
              ),
              onPressed: () {},
            ),
          ],
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
                              'CATEGORIES',
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
                              ? 'NEW ARRIVALS'
                              : '$_selectedCategory COLLECTION',
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
                                  'NO PRODUCTS FOUND.',
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
      appBar: AppBar(title: const Text('Search')),
      body: const Center(
        child: Chip(label: Text('Tính năng Tìm Kiếm đang phát triển 🚧')),
      ),
    );
  }

  // --- TAB 3: CART ---
  Widget _buildCartTab() {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: const Center(
        child: Chip(label: Text('Tính năng Giỏ Hàng đang phát triển 🚧')),
      ),
    );
  }

  // --- TAB 4: PROFILE ---
  Widget _buildProfileTab(BuildContext context) {
    return const ProfilePage();
  }
}
