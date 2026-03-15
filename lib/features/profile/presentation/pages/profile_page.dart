import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../address/presentation/pages/address_page.dart';
import '../../../admin/presentation/pages/add_product_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../injection_container.dart' as di;
import '../../../admin/presentation/bloc/add_product_bloc.dart';
import '../../../order/presentation/pages/order_history_page.dart';
import '../../../wishlist/presentation/pages/wishlist_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final user = state.user;
            final isAdmin = user.role == 'ADMIN';

            return CustomScrollView(
              slivers: [
                // ─── HERO HEADER ───────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _HeroHeader(
                    name: user.name,
                    email: user.email,
                    isAdmin: isAdmin,
                  ),
                ),


                // ─── GENERAL MENU ──────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _MenuSection(
                    title: 'TÙY CHỌN CHUNG',
                    tiles: [
                      _MenuItemData(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Lịch sử đơn hàng',
                        subtitle: 'Xem các đơn hàng đã đặt',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OrderHistoryPage(),
                            ),
                          );
                        },
                      ),
                      _MenuItemData(
                        icon: Icons.favorite_border_rounded,
                        title: 'Yêu thích',
                        subtitle: 'Sản phẩm bạn đã thích',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WishlistPage(),
                            ),
                          );
                        },
                      ),
                      _MenuItemData(
                        icon: Icons.location_on_outlined,
                        title: 'Địa chỉ giao hàng',
                        subtitle: 'Quản lý địa chỉ nhận hàng',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddressPage(),
                            ),
                          );
                        },
                      ),
                      _MenuItemData(
                        icon: Icons.settings_outlined,
                        title: 'Cài đặt tài khoản',
                        subtitle: 'Bảo mật & thông báo',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                // ─── ADMIN ZONE ────────────────────────────────────────────
                if (isAdmin)
                  SliverToBoxAdapter(child: _AdminZone(context: context)),

                // ─── LOGOUT ────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black54,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        context.read<AuthBloc>().add(LogoutEvent());
                      },
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text(
                        'ĐĂNG XUẤT HỆ THỐNG',
                        style: TextStyle(
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: CircularProgressIndicator(color: Colors.black),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final String name;
  final String email;
  final bool isAdmin;

  const _HeroHeader({
    required this.name,
    required this.email,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 40,
        left: 24,
        right: 24,
      ),
      child: Column(
        children: [
          // App bar row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'HỒ SƠ CÁ NHÂN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  fontSize: 13,
                ),
              ),

            ],
          ),
          const SizedBox(height: 24),
          // Avatar
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name.toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.5,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            email,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white54,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(
                color: isAdmin
                    ? Colors.amber.shade400
                    : Colors.white.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAdmin ? Icons.diamond_outlined : Icons.person_outline,
                  size: 12,
                  color: isAdmin ? Colors.amber.shade400 : Colors.white54,
                ),
                const SizedBox(width: 6),
                Text(
                  isAdmin ? 'QUẢN TRỊ VIÊN' : 'THÀNH VIÊN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: isAdmin ? Colors.amber.shade400 : Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// MENU SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _MenuItemData {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _MenuItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItemData> tiles;
  const _MenuSection({required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: List.generate(tiles.length, (i) {
                final tile = tiles[i];
                return Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: tile.onTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                tile.icon,
                                size: 20,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tile.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    tile.subtitle,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 13,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (i < tiles.length - 1)
                      Divider(
                        height: 1,
                        indent: 74,
                        color: Colors.grey.shade100,
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ADMIN ZONE
// ─────────────────────────────────────────────────────────────────────────────
class _AdminZone extends StatelessWidget {
  final BuildContext context;
  const _AdminZone({required this.context});

  @override
  Widget build(BuildContext _) {
    final adminTiles = [
      _AdminTileData(
        icon: Icons.add_box_outlined,
        title: 'Thêm sản phẩm mới',
        subtitle: 'Đăng sản phẩm lên cửa hàng',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider<AddProductBloc>(
                create: (_) => di.sl<AddProductBloc>(),
                child: const AddProductPage(),
              ),
            ),
          );
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'QUYỀN QUẢN TRỊ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.diamond, size: 12, color: Colors.amber.shade500),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: List.generate(adminTiles.length, (i) {
                final tile = adminTiles[i];
                return Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: tile.onTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                tile.icon,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tile.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    tile.subtitle,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 13,
                              color: Colors.white38,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (i < adminTiles.length - 1)
                      Divider(
                        height: 1,
                        indent: 74,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminTileData {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _AdminTileData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
