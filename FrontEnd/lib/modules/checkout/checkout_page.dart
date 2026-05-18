import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cart/cart_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/order_service.dart';
import 'order_success_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String paymentMethod = 'PIX';
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _sectionTitle('Endereço de entrega'),
                _addressCard(),

                const SizedBox(height: 24),
                _sectionTitle('Pagamento'),
                _paymentOptions(),

                const SizedBox(height: 24),
                _sectionTitle('Resumo do pedido'),
                ...cart.items.map(
                  (item) => ListTile(
                    title: Text(item.product.name),
                    trailing: Text(
                      'x${item.quantity}  R\$ ${(item.product.price * item.quantity).toStringAsFixed(2)}',
                    ),
                  ),
                ),
              ],
            ),
          ),

          _bottomBar(cart),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _addressCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Rua Exemplo, 123\nBairro Centro\nCidade - SP',
        ),
      ),
    );
  }

  Widget _paymentOptions() {
    return Column(
      children: [
        _paymentTile('PIX'),
        _paymentTile('Cartão de crédito'),
        _paymentTile('Dinheiro'),
      ],
    );
  }

  Widget _paymentTile(String method) {
    return RadioListTile<String>(
      value: method,
      groupValue: paymentMethod,
      onChanged: (value) {
        setState(() => paymentMethod = value!);
      },
      title: Text(method),
    );
  }

  Widget _bottomBar(CartController cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: R\$ ${cart.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                minimumSize: const Size(0, 48),
              ),
              onPressed: _loading ? null : () => _finalizarPedido(cart),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Finalizar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finalizarPedido(CartController cart) async {
    setState(() => _loading = true);

    final result = await OrderService.finalizarPedido(
      enderecoEntrega: 'Rua Exemplo, 123, Bairro Centro, Cidade - SP',
      formaPagamento: paymentMethod,
    );

    if (!mounted) return;

    if (result.error != null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error!),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    cart.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderSuccessPage(orderId: result.orderId!),
      ),
    );
  }
}
