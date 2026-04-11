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

class _ProductCardState extends State<ProductCard> {
  bool _pressed = false;

 void _addToCart(BuildContext context) {
  final box = context.findRenderObject() as RenderBox;
  final startPosition =
      box.localToGlobal(box.size.center(Offset.zero));

  FlyToCart.animate(
    context: context,
    cartKey: widget.cartKey,
    image: NetworkImage(widget.product.image),
    startPosition: startPosition,
  );

  context.read<CartController>().add(widget.product);
}


  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: const Offset(0, 0.04),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: 1,
        duration: const Duration(milliseconds: 300),
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              elevation: 6,
              shadowColor: Colors.black.withOpacity(0.15),
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTapDown: (_) => setState(() => _pressed = true),
                onTapCancel: () => setState(() => _pressed = false),
                onTap: () {
                  setState(() => _pressed = false);
                  _addToCart(context);
                },
                child: Row(
                  children: [
                    /// IMAGEM
                    Hero(
                      tag: 'product-${widget.product.id}',
                      child: ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(22),
                        ),
                        child: Image.network(
                          widget.product.image,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// CONTEÚDO
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name,
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.product.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AnimatedSwitcher(
                                  duration:
                                      const Duration(milliseconds: 250),
                                  child: Text(
                                    'R\$ ${widget.product.price.toStringAsFixed(2)}',
                                    key:
                                        ValueKey(widget.product.price),
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: _pressed
                                        ? AppTheme.primary.withOpacity(0.2)
                                        : AppTheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: AppTheme.primary,
                                    size: 18,
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
      ),
    );
  }
}
