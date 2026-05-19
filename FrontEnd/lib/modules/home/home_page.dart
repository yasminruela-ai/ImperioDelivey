import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../orders/orders_history_page.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/product_service.dart';
import '../../core/theme/app_theme.dart';
import '../auth/login_page.dart';
import '../cart/cart_controller.dart';
import '../cart/cart_page.dart';
import '../chat/chat_page.dart';
import 'models/product_model.dart';
import 'widgets/banner_widget.dart';
import 'widgets/category_widget.dart';
import 'widgets/product_card.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});
 
  @override
  State<HomePage> createState() => _HomePageState();
}
 
class _HomePageState extends State<HomePage> {
  final GlobalKey cartIconKey = GlobalKey();
  late Future<List<ProductModel>> _productsFuture;
 
  String _selectedCategory = '';
 
  @override
  void initState() {
    super.initState();
    _productsFuture = ProductService.getAll();
  }
 
  List<ProductModel> _filtered(List<ProductModel> all) {
    if (_selectedCategory.isEmpty) return all;
    return all
        .where((p) =>
            (p.categoria ?? '').toLowerCase() ==
            _selectedCategory.toLowerCase())
        .toList();
  }
 
  void _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          FutureBuilder<List<ProductModel>>(
            future: _productsFuture,
            builder: (context, snapshot) {
              final allProducts = snapshot.data ?? [];
              final products    = _filtered(allProducts);
 
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildAppBar(context),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: BannerWidget(),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  SliverToBoxAdapter(
                    child: CategoryWidget(
                      selected: _selectedCategory,
                      onChanged: (v) => setState(() => _selectedCategory = v),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            _selectedCategory.isEmpty
                                ? 'Mais pedidos'
                                : _selectedCategory,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('🔥', style: TextStyle(fontSize: 18)),
                          const Spacer(),
                          if (snapshot.hasData)
                            Text(
                              '${products.length} itens',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                    )
                  else if (snapshot.hasError)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.wifi_off_rounded,
                              size: 48,
                              color: AppTheme.textHint,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Falha ao carregar produtos',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Tentar novamente'),
                              onPressed: () => setState(() {
                                _productsFuture = ProductService.getAll();
                              }),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (products.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          children: [
                            const Text(
                              '🍽️',
                              style: TextStyle(fontSize: 48),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Nenhum item nessa categoria',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => ProductCard(
                          product: products[index],
                          cartKey: cartIconKey,
                        ),
                        childCount: products.length,
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              );
            },
          ),
          _buildCartBottomBar(context),
        ],
      ),
    );
  }
 
  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppTheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Image.asset('assets/images/logo.png', height: 36),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Imperios Delivery',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Peça agora, receba rápido',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.80),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        // ── Histórico de pedidos ─────────────────────────────────────────
        IconButton(
          icon: const Icon(Icons.receipt_long_rounded, color: Colors.white),
          tooltip: 'Meus pedidos',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrdersHistoryPage()),
          ),
        ),
 
        // ── Carrinho com badge ───────────────────────────────────────────
        Stack(
          children: [
            IconButton(
              key: cartIconKey,
              icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              ),
            ),
            Positioned(
              right: 4,
              top: 4,
              child: Consumer<CartController>(
                builder: (_, cart, _) {
                  if (cart.items.isEmpty) return const SizedBox();
                  return AnimatedScale(
                    scale: 1,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: AppTheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        cart.items.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
 
        // ── Logout ───────────────────────────────────────────────────────
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
          onPressed: _logout,
          tooltip: 'Sair',
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: _buildAIButton(context),
        ),
      ),
    );
  }
 
  Widget _buildAIButton(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatPage()),
        ),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: AppTheme.heroGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 14),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Pedir com Inteligência Artificial',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textHint, size: 18),
            ],
          ),
        ),
      ),
    );
  }
 
  Widget _buildCartBottomBar(BuildContext context) {
    return Consumer<CartController>(
      builder: (_, cart, _) {
        if (cart.isEmpty) return const SizedBox();
        return Positioned(
          left: 16, right: 16, bottom: 20,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
            decoration: BoxDecoration(
              gradient: AppTheme.brandGradient,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  blurRadius: 28,
                  color: AppTheme.primary.withOpacity(0.40),
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    color: Colors.white, size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${cart.items.length} ${cart.items.length == 1 ? 'item' : 'itens'}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'R\$ ${cart.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartPage()),
                  ),
                  child: const Text('Ver carrinho'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}