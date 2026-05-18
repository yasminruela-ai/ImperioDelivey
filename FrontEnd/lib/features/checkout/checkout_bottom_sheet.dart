import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../modules/cart/cart_controller.dart';
import '../../modules/checkout/order_success_page.dart';
import '../address/address_picker_sheet.dart';

class CheckoutBottomSheet extends StatefulWidget {
  const CheckoutBottomSheet({super.key});

  @override
  State<CheckoutBottomSheet> createState() => _CheckoutBottomSheetState();
}

class _CheckoutBottomSheetState extends State<CheckoutBottomSheet> {
  String _paymentMethod = 'Pix';
  bool _loading = false;
  bool _loadingAddress = true;

  Map<String, dynamic>? _endereco;

  static const _payments = [
    _PaymentOption(label: 'Pix',               icon: Icons.qr_code_rounded,     color: Color(0xFF32BCAD)),
    _PaymentOption(label: 'Cartão de crédito', icon: Icons.credit_card_rounded, color: Color(0xFF2979FF)),
    _PaymentOption(label: 'Dinheiro',          icon: Icons.payments_outlined,   color: Color(0xFF43A047)),
  ];

  @override
  void initState() {
    super.initState();
    _loadEndereco();
  }

  Future<void> _loadEndereco() async {
    var enderecos = await AuthService.getEnderecos();

    // Migration: if no multi-address list yet, promote the legacy single address
    if (enderecos.isEmpty) {
      var legacy = await AuthService.getEndereco();
      if (legacy == null) {
        await AuthService.fetchAndSaveEndereco();
        legacy = await AuthService.getEndereco();
      }
      if (legacy != null) {
        final migrated = {...legacy, 'label': 'Casa'};
        enderecos = [migrated];
        await AuthService.saveEnderecosList(enderecos);
      }
    }

    final selected = await AuthService.getEnderecoSelecionado();
    if (mounted) setState(() { _endereco = selected; _loadingAddress = false; });
  }

  Future<void> _changeAddress() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddressPickerSheet(),
    );
    if (result != null && mounted) {
      setState(() => _endereco = result);
    }
  }

  String get _enderecoFormatado {
    final e = _endereco;
    if (e == null) return '';
    final rua    = e['rua']    as String? ?? '';
    final numero = e['numero'] as String? ?? '';
    final bairro = e['bairro'] as String? ?? '';
    final cidade = e['cidade'] as String? ?? '';
    final estado = e['estado'] as String? ?? '';
    final cep    = e['cep']    as String? ?? '';
    return '$rua, $numero, $bairro, $cidade - $estado, CEP $cep';
  }

  Future<void> _confirmarPedido() async {
    if (_enderecoFormatado.trim().isEmpty) {
      _showSnack('Endereço não encontrado. Faça login novamente.', isError: true);
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
          'enderecoEntrega': _enderecoFormatado,
          'formaPagamento': _paymentMethod,
          'observacao': '',
        }),
      );

      if (!mounted) return;
      setState(() => _loading = false);

      if (response.statusCode == 201) {
        final data    = jsonDecode(response.body) as Map<String, dynamic>;
        final orderId = (data['data'] as Map<String, dynamic>)['id'] as String;

        cart.clear();

        Navigator.pop(context); // fecha bottom sheet
        Navigator.pop(context); // fecha cart page

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderSuccessPage(orderId: orderId),
          ),
        );
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _showSnack(data['message'] as String? ?? 'Erro ao finalizar pedido', isError: true);
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
                  const Text(
                    'Finalizar pedido',
                    style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary, letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Endereço ───────────────────────────────────────────────
                  _Label(text: 'Endereço de entrega', icon: Icons.location_on_outlined),
                  const SizedBox(height: 10),
                  _addressCard(),

                  const SizedBox(height: 24),

                  // ── Pagamento ──────────────────────────────────────────────
                  _Label(text: 'Forma de pagamento', icon: Icons.payment_rounded),
                  const SizedBox(height: 12),
                  ..._payments.map((option) => _PaymentTile(
                    option: option,
                    selected: _paymentMethod == option.label,
                    onTap: () => setState(() => _paymentMethod = option.label),
                  )),

                  const SizedBox(height: 24),

                  // ── Resumo ─────────────────────────────────────────────────
                  _Label(text: 'Resumo do pedido', icon: Icons.receipt_long_outlined),
                  const SizedBox(height: 10),
                  _OrderSummary(cart: cart),

                  const SizedBox(height: 28),

                  // ── Botão confirmar ────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: (_loading || _loadingAddress) ? null : AppTheme.brandGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ElevatedButton(
                        onPressed: (_loading || _loadingAddress) ? null : _confirmarPedido,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: (_loading || _loadingAddress)
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

  Widget _addressCard() {
    if (_loadingAddress) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: SizedBox(
            height: 20, width: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
          ),
        ),
      );
    }

    if (_endereco == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.error, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Endereço não encontrado. Atualize seu perfil.',
                style: TextStyle(color: AppTheme.error, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    final e      = _endereco!;
    final rua    = e['rua']    as String? ?? '';
    final numero = e['numero'] as String? ?? '';
    final bairro = e['bairro'] as String? ?? '';
    final cidade = e['cidade'] as String? ?? '';
    final estado = e['estado'] as String? ?? '';
    final cep    = e['cep']    as String? ?? '';

    return GestureDetector(
      onTap: _changeAddress,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (e['label'] != null)
                    Text(
                      e['label'] as String,
                      style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  Text(
                    '$rua, $numero\n$bairro — $cidade/$estado\nCEP $cep',
                    style: const TextStyle(
                      fontSize: 13, height: 1.6, color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Alterar',
              style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: AppTheme.primary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _OrderSummary extends StatelessWidget {
  final CartController cart;
  const _OrderSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    color: AppTheme.primary.withValues(alpha: 0.12),
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
              const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              Text('R\$ ${cart.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primary)),
            ],
          ),
        ],
      ),
    );
  }
}

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
        Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
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

  const _PaymentTile({required this.option, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? option.color.withValues(alpha: 0.08) : AppTheme.surfaceAlt,
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
                color: option.color.withValues(alpha: 0.12),
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
                border: Border.all(color: selected ? option.color : AppTheme.textHint, width: 2),
                color: selected ? option.color : Colors.transparent,
              ),
              child: selected ? const Icon(Icons.check_rounded, color: Colors.white, size: 12) : null,
            ),
          ],
        ),
      ),
    );
  }
}
