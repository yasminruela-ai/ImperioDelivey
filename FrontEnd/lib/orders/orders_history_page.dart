import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../modules/cart/cart_controller.dart';

class OrdersHistoryPage extends StatefulWidget {
  const OrdersHistoryPage({super.key});

  @override
  State<OrdersHistoryPage> createState() => _OrdersHistoryPageState();
}

class _OrdersHistoryPageState extends State<OrdersHistoryPage> {
  late Future<List<Map<String, dynamic>>> _pedidosFuture;

  @override
  void initState() {
    super.initState();
    _pedidosFuture = _fetchMeusPedidos();
  }

  Future<List<Map<String, dynamic>>> _fetchMeusPedidos() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$kBaseUrl/pedido/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      final data = body['data'] as List<dynamic>;
      // Ordenar do mais recente ao mais antigo
      final pedidos = data.cast<Map<String, dynamic>>();
      pedidos.sort((a, b) {
        final aDate = _parseDate(a['createdAt']);
        final bDate = _parseDate(b['createdAt']);
        return bDate.compareTo(aDate);
      });
      return pedidos;
    }
    throw Exception(body['message'] ?? 'Erro ao carregar pedidos');
  }

  DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime(2000);
    if (value is Map && value['_seconds'] != null) {
      // Firestore Timestamp serializado
      return DateTime.fromMillisecondsSinceEpoch(
          (value['_seconds'] as int) * 1000);
    }
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime(2000);
    }
  }

  String _formatDate(dynamic value) {
    final date = _parseDate(value);
    final d = date.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  String _formatStatus(String status) {
    const map = {
      'pendente': 'Pendente',
      'em_preparo': 'Em preparo',
      'saiu_para_entrega': 'Saiu para entrega',
      'entregue': 'Entregue',
      'cancelado': 'Cancelado',
    };
    return map[status] ?? status;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'entregue':
        return AppTheme.success;
      case 'cancelado':
        return AppTheme.error;
      case 'saiu_para_entrega':
        return AppTheme.secondary;
      case 'em_preparo':
        return const Color(0xFFF59E0B);
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'entregue':
        return Icons.check_circle_rounded;
      case 'cancelado':
        return Icons.cancel_rounded;
      case 'saiu_para_entrega':
        return Icons.delivery_dining_rounded;
      case 'em_preparo':
        return Icons.outdoor_grill_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Meus Pedidos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Atualizar',
            onPressed: () => setState(() {
              _pedidosFuture = _fetchMeusPedidos();
            }),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _pedidosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 2.5,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        size: 48, color: AppTheme.textHint),
                    const SizedBox(height: 12),
                    const Text(
                      'Falha ao carregar pedidos',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Tentar novamente'),
                      onPressed: () => setState(() {
                        _pedidosFuture = _fetchMeusPedidos();
                      }),
                    ),
                  ],
                ),
              ),
            );
          }

          final pedidos = snapshot.data ?? [];

          if (pedidos.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🧾', style: TextStyle(fontSize: 52)),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhum pedido ainda',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Seus pedidos aparecerão aqui',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: pedidos.length,
            itemBuilder: (context, index) =>
                _PedidoCard(pedido: pedidos[index], page: this),
          );
        },
      ),
    );
  }
}

// ─── Card de pedido ──────────────────────────────────────────────────────────

class _PedidoCard extends StatelessWidget {
  final Map<String, dynamic> pedido;
  final _OrdersHistoryPageState page;

  const _PedidoCard({required this.pedido, required this.page});

  @override
  Widget build(BuildContext context) {
    final status = pedido['status'] as String? ?? 'pendente';
    final itens = (pedido['itens'] as List<dynamic>?) ?? [];
    final total = (pedido['total'] as num?)?.toDouble() ?? 0.0;
    final enderecoEntrega = pedido['enderecoEntrega'];
    final formaPagamento = pedido['formaPagamento'];
    final pedidoId = pedido['id'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cabeçalho ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradient,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pedido #${pedidoId.length > 8 ? pedidoId.substring(0, 8).toUpperCase() : pedidoId.toUpperCase()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  page._formatDate(pedido['createdAt']),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.80),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Status ────────────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: page._statusColor(status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(page._statusIcon(status),
                              size: 13, color: page._statusColor(status)),
                          const SizedBox(width: 5),
                          Text(
                            page._formatStatus(status),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: page._statusColor(status),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: AppTheme.divider),
                const SizedBox(height: 14),

                // ── Itens ─────────────────────────────────────────────────
                ...itens.take(3).map((item) {
                  final nome = item['nome'] ?? '';
                  final qtd = item['quantidade'] ?? 1;
                  final valor = (item['valor'] as num?)?.toDouble() ?? 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceAlt,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              '$qtd',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            nome,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'R\$ ${(valor * qtd).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                if (itens.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '+ ${itens.length - 3} ${itens.length - 3 == 1 ? 'item' : 'itens'} a mais',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textHint,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                const SizedBox(height: 10),
                const Divider(height: 1, color: AppTheme.divider),
                const SizedBox(height: 12),

                // ── Rodapé: entrega + total ────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (enderecoEntrega != null &&
                              enderecoEntrega.toString().isNotEmpty) ...[
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded,
                                    size: 13,
                                    color: AppTheme.textHint),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    enderecoEntrega.toString(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                          if (formaPagamento != null &&
                              formaPagamento.toString().isNotEmpty)
                            Row(
                              children: [
                                const Icon(Icons.payment_rounded,
                                    size: 13,
                                    color: AppTheme.textHint),
                                const SizedBox(width: 4),
                                Text(
                                  formaPagamento.toString(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textHint,
                          ),
                        ),
                        Text(
                          'R\$ ${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: AppTheme.divider),
                const SizedBox(height: 10),

                // ── Refazer pedido ─────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      final cart = Provider.of<CartController>(
                          context,
                          listen: false);
                      cart.reorder(itens);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${itens.length} ${itens.length == 1 ? 'item adicionado' : 'itens adicionados'} ao carrinho',
                          ),
                          backgroundColor: AppTheme.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          action: SnackBarAction(
                            label: 'Ver carrinho',
                            textColor: Colors.white,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.replay_rounded, size: 16),
                    label: const Text('Refazer pedido'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
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