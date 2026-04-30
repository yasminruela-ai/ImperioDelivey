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
  String _paymentMethod  = 'Pix';
  String _selectedAddress = '';
  bool _loading = false;

  static const _payments = [
    _PaymentOption(label: 'Pix',              icon: Icons.qr_code_rounded,      color: Color(0xFF32BCAD)),
    _PaymentOption(label: 'Cartão de crédito', icon: Icons.credit_card_rounded,  color: Color(0xFF2979FF)),
    _PaymentOption(label: 'Dinheiro',          icon: Icons.payments_outlined,    color: Color(0xFF43A047)),
  ];

  Future<void> _confirmarPedido() async {
    if (_selectedAddress.trim().isEmpty) {
      _showSnack('Informe o endereço de entrega', isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      final cart    = context.read<CartController>();
      final headers = await AuthService.authHeaders();

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
        Navigator.pop(context);
        Navigator.pop(context);
        _showSnack('Pedido realizado com sucesso! 🍔🔥', isError: false);
      } else {
        final data = jsonDecode(response.body);
        _showSnack(data['message'] ?? 'Erro ao finalizar pedido', isError: true);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnack('Erro de conexão com o servidor', isError: true);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20, right: 20, top: 4,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  const Text(
                    'Finalizar pedido',
                    style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary, letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Endereço ───────────────────────────────────────────
                  _Label(text: 'Endereço de entrega', icon: Icons.location_on_outlined),
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: (v) => _selectedAddress = v,
                    style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Ex: Rua das Flores, 42, Centro',
                      prefixIcon: const Icon(Icons.location_on_outlined,
                          size: 20, color: AppTheme.textSecondary),
                      filled: true,
                      fillColor: AppTheme.surfaceAlt,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Pagamento ──────────────────────────────────────────
                  _Label(text: 'Forma de pagamento', icon: Icons.payment_rounded),
                  const SizedBox(height: 12),
                  ..._payments.map((option) => _PaymentTile(
                    option: option,
                    selected: _paymentMethod == option.label,
                    onTap: () => setState(() => _paymentMethod = option.label),
                  )),

                  const SizedBox(height: 24),

                  // ── Resumo do pedido ───────────────────────────────────
                  _Label(text: 'Resumo do pedido', icon: Icons.receipt_long_outlined),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceAlt,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ...cart.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 24, height: 24,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    item.quantity.toString(),
                                    style: const TextStyle(
                                      fontSize: 11, fontWeight: FontWeight.w800,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item.product.name,
                                  style: const TextStyle(
                                    fontSize: 13, color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                'R\$ ${(item.product.price * item.quantity).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        )),
                        const Divider(color: AppTheme.divider, height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              'R\$ ${cart.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Botão confirmar ────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: _loading ? null : AppTheme.brandGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ElevatedButton(
                        onPressed: _loading ? null : _confirmarPedido,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 22, width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Confirmar pedido',
                                style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  final IconData icon;

  const _Label({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _PaymentOption {
  final String label;
  final IconData icon;
  final Color color;
  const _PaymentOption({required this.label, required this.icon, required this.color});
}

class _PaymentTile extends StatelessWidget {
  final _PaymentOption option;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? option.color.withOpacity(0.08)
              : AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? option.color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: option.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(option.icon, color: option.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppTheme.textPrimary : AppTheme.textSecondary,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? option.color : AppTheme.textHint,
                  width: 2,
                ),
                color: selected ? option.color : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 12)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
