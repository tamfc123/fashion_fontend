import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';

import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

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
    return Scaffold(
      appBar: AppBar(title: const Text('Fashion Store')),
      body: const Center(
        child: Text(
          'Welcome to Fashion E-Commerce!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
