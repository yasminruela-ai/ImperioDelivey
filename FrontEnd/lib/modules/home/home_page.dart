import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../cart/cart_controller.dart';
import '../cart/cart_page.dart';
import 'models/product_model.dart';
import 'widgets/banner_widget.dart';
import 'widgets/category_widget.dart';
import 'widgets/product_card.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final GlobalKey cartIconKey = GlobalKey();

  List<ProductModel> get products => [
        ProductModel(
          id: 1,
          name: 'Hambúrguer Artesanal',
          description: '180g de carne, queijo e molho especial',
          price: 29.90,
          image: 'https://i.imgur.com/6RLcK8F.png',
        ),
        ProductModel(
          id: 2,
          name: 'Combo Burger',
          description: 'Burger + fritas + refri',
          price: 39.90,
          image: 'https://i.imgur.com/YZ6Yq2M.png',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context),
              const SliverToBoxAdapter(child: BannerWidget()),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              const SliverToBoxAdapter(child: CategoryWidget()),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Mais pedidos 🔥',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              _buildProductsList(),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          _buildCartBottomBar(context),
        ],
      ),
    );
  }

  // ================= APP BAR =================

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 28,
            ),
            const SizedBox(width: 8),
            const Text(
              'Imperios Burger',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primary,
                AppTheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Stack(
            children: [
              IconButton(
  key: cartIconKey,
  icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CartPage(),
                    ),
                  );
                },
              ),
              Positioned(
                right: 4,
                top: 4,
                child: Consumer<CartController>(
                  builder: (_, cart, __) {
                    if (cart.items.isEmpty) return const SizedBox();
                    return AnimatedScale(
                      scale: 1,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cart.items.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= PRODUTOS =================

  SliverList _buildProductsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return ProductCard( product: products[index],
  cartKey: cartIconKey,);
        },
        childCount: products.length,
      ),
    );
  }

  // ================= BOTTOM CART =================

  Widget _buildCartBottomBar(BuildContext context) {
    return Consumer<CartController>(
      builder: (_, cart, __) {
        if (cart.isEmpty) return const SizedBox();

        return Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: AnimatedSlide(
            offset: Offset.zero,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.black.withOpacity(0.25),
                  ),
                ],
              ),
              child: Row(
                children: [
                  /// TEXTOS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${cart.items.length} itens',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'R\$ ${cart.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// BOTÃO
                  SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CartPage(),
                          ),
                        );
                      },
                      child: const Text('Ver carrinho'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
