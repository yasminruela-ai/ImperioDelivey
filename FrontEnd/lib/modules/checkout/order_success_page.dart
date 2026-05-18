import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/order_service.dart';
import '../home/home_page.dart';
import 'models/order_model.dart';

class OrderSuccessPage extends StatefulWidget {
  final String orderId;

  const OrderSuccessPage({super.key, required this.orderId});

  @override
  State<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  OrderModel? _order;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();

    _fetchStatus();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) => _fetchStatus());
  }

  Future<void> _fetchStatus() async {
    final order = await OrderService.getOrder(widget.orderId);
    if (mounted && order != null) {
      setState(() => _order = order);
      if (order.status == 'entregue' || order.status == 'cancelado') {
        _pollTimer?.cancel();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                ScaleTransition(
                  scale: _scale,
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: const BoxDecoration(
                        color: AppTheme.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Pedido confirmado!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  '#${widget.orderId.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textHint,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 32),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Acompanhamento',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            if (_order == null)
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primary,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: _OrderTimeline(
                            status: _order?.status ?? 'pendente',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppTheme.brandGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => HomePage()),
                        (_) => false,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Voltar ao cardápio',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Timeline ─────────────────────────────────────────────────────────────────

const _steps = [
  _StepInfo(status: 'pendente',           label: 'Pedido criado',       icon: Icons.receipt_long_rounded),
  _StepInfo(status: 'aceito',             label: 'Pedido aceito',       icon: Icons.thumb_up_rounded),
  _StepInfo(status: 'em_preparo',         label: 'Em preparo',          icon: Icons.outdoor_grill_rounded),
  _StepInfo(status: 'saiu_para_entrega',  label: 'Saiu para entrega',   icon: Icons.delivery_dining_rounded),
  _StepInfo(status: 'entregue',           label: 'Entregue',            icon: Icons.home_rounded),
];

class _StepInfo {
  final String status;
  final String label;
  final IconData icon;
  const _StepInfo({required this.status, required this.label, required this.icon});
}

int _statusIndex(String status) {
  final idx = _steps.indexWhere((s) => s.status == status);
  return idx < 0 ? 0 : idx;
}

class _OrderTimeline extends StatelessWidget {
  final String status;

  const _OrderTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final currentIndex = _statusIndex(status);
    final cancelled = status == 'cancelado';

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _steps.length,
      itemBuilder: (context, index) {
        final step = _steps[index];
        final isDone = !cancelled && index < currentIndex;
        final isCurrent = !cancelled && index == currentIndex;
        final isLast = index == _steps.length - 1;

        Color dotColor;
        Color iconColor;
        Color lineColor;

        if (cancelled) {
          dotColor = AppTheme.surfaceAlt;
          iconColor = AppTheme.textHint;
          lineColor = AppTheme.divider;
        } else if (isDone) {
          dotColor = AppTheme.success.withValues(alpha: 0.15);
          iconColor = AppTheme.success;
          lineColor = AppTheme.success;
        } else if (isCurrent) {
          dotColor = AppTheme.primary.withValues(alpha: 0.12);
          iconColor = AppTheme.primary;
          lineColor = AppTheme.divider;
        } else {
          dotColor = AppTheme.surfaceAlt;
          iconColor = AppTheme.textHint;
          lineColor = AppTheme.divider;
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 44,
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(step.icon, size: 18, color: iconColor),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Center(
                          child: Container(
                            width: 2,
                            color: lineColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 8,
                    bottom: isLast ? 0 : 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: cancelled
                              ? AppTheme.textHint
                              : isCurrent
                                  ? AppTheme.primary
                                  : isDone
                                      ? AppTheme.textPrimary
                                      : AppTheme.textHint,
                        ),
                      ),
                      if (isCurrent && !cancelled) ...[
                        const SizedBox(height: 3),
                        const Text(
                          'Status atual',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textHint,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
