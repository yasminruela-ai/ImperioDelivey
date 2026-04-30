import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/animations/fly_to_cart.dart';
import '../../../core/theme/app_theme.dart';
import '../../cart/cart_controller.dart';
import '../models/product_model.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final GlobalKey cartKey;

  const ProductCard({
    super.key,
    required this.product,
    required this.cartKey,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _scaleAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _addToCart(BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final startPosition = box.localToGlobal(box.size.center(Offset.zero));

    FlyToCart.animate(
      context: context,
      cartKey: widget.cartKey,
      image: NetworkImage(widget.product.image),
      startPosition: startPosition,
    );

    context.read<CartController>().add(widget.product);

    _bounceController.forward().then((_) => _bounceController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTapDown: (_) => setState(() => _pressed = true),
              onTapCancel: () => setState(() => _pressed = false),
              onTap: () {
                setState(() => _pressed = false);
                _addToCart(context);
              },
              child: Row(
                children: [
                  // ── Imagem ──────────────────────────────────────────────
                  Hero(
                    tag: 'product-${widget.product.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      child: Image.network(
                        widget.product.image,
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return _imagePlaceholder();
                        },
                        errorBuilder: (_, __, ___) => _imagePlaceholder(),
                      ),
                    ),
                  ),

                  // ── Conteúdo ────────────────────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge categoria
                          if (widget.product.categoria != null &&
                              widget.product.categoria!.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.product.categoria!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primary,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),

                          Text(
                            widget.product.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.product.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'R\$ ${widget.product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              // Botão adicionar com bounce
                              ScaleTransition(
                                scale: Tween<double>(begin: 1, end: 1).animate(
                                  _bounceController,
                                ),
                                child: AnimatedBuilder(
                                  animation: _bounceController,
                                  builder: (_, __) => Transform.scale(
                                    scale: 1.0 -
                                        (_bounceController.value * 0.15),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.brandGradient,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primary
                                                .withOpacity(0.35),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.add_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
    width: 110,
    height: 110,
    color: AppTheme.surfaceAlt,
    child: const Icon(
      Icons.fastfood_rounded,
      color: AppTheme.textHint,
      size: 32,
    ),
  );
}
