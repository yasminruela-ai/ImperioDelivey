import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../modules/cart/cart_controller.dart';

class CheckoutBottomSheet extends StatefulWidget {
  const CheckoutBottomSheet({super.key});

  @override
  State<CheckoutBottomSheet> createState() => _CheckoutBottomSheetState();
}

class _CheckoutBottomSheetState extends State<CheckoutBottomSheet> {
  String _paymentMethod = 'Pix';
  String _selectedAddress = '';
  bool _loading = false;

  final List<String> _paymentOptions = [
    'Pix',
    'Cartão de crédito',
    'Dinheiro',
  ];

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    // endereço do usuário logado vem do token salvo
    // por simplicidade, deixa o campo em branco para o usuário digitar
  }

  Future<void> _confirmarPedido() async {
    if (_selectedAddress.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o endereço de entrega'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final cart = context.read<CartController>();

      final headers = await AuthService.authHeaders();

      // O backend já tem o carrinho sincronizado via CartController.
      // Basta finalizar o pedido.
      final response = await http.post(
        Uri.parse('$kBaseUrl/pedido'),
        headers: headers,
        body: jsonEncode({
          'enderecoEntrega': _selectedAddress,
          'formaPagamento': _paymentMethod,
          'observacao': '',
        }),
      );

      if (!mounted) return;
      setState(() => _loading = false);

      if (response.statusCode == 201) {
        cart.clear();
        Navigator.pop(context); // fecha o bottom sheet
        Navigator.pop(context); // fecha o cart

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido realizado com sucesso! 🍔🔥'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Erro ao finalizar pedido'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro de conexão com o servidor'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: SizedBox(
                width: 50,
                height: 5,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Endereço ──────────────────────────────────────────────────
            const Text(
              'Endereço de entrega',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: (v) => _selectedAddress = v,
              decoration: InputDecoration(
                hintText: 'Ex: Rua das Flores, 42, Centro',
                prefixIcon: const Icon(Icons.location_on_outlined),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Pagamento ─────────────────────────────────────────────────
            const Text(
              'Forma de pagamento',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            ..._paymentOptions.map(
              (method) => RadioListTile<String>(
                dense: true,
                value: method,
                groupValue: _paymentMethod,
                onChanged: (v) => setState(() => _paymentMethod = v!),
                title: Text(method),
              ),
            ),

            const SizedBox(height: 16),

            // ── Total ─────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'R\$ ${cart.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Confirmar ─────────────────────────────────────────────────
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _loading ? null : _confirmarPedido,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirmar pedido'),
            ),
          ],
        ),
      ),
    );
  }
}
