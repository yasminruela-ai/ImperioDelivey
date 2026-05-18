import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../modules/checkout/order_success_page.dart';

class OrderConfirmedPage extends StatefulWidget {
  final String orderId;
  const OrderConfirmedPage({super.key, required this.orderId});

  @override
  State<OrderConfirmedPage> createState() => _OrderConfirmedPageState();
}

class _OrderConfirmedPageState extends State<OrderConfirmedPage>
    with SingleTickerProviderStateMixin {

  late final AnimationController _ctrl;
  late final List<_Particle> _particles;

  static const _confettiColors = [
    Color(0xFFC62828),
    Color(0xFFFF6D00),
    Color(0xFFFFD600),
    Color(0xFF2E7D32),
    Color(0xFF1565C0),
    Color(0xFF6A1B9A),
    Color(0xFFE91E63),
    Color(0xFF00BCD4),
  ];

  @override
  void initState() {
    super.initState();

    final rng = Random(42);
    _particles = List.generate(20, (i) {
      final angle    = (i / 20) * 2 * pi + rng.nextDouble() * 0.5;
      final distance = 100.0 + rng.nextDouble() * 80;
      return _Particle(
        dx:     cos(angle) * distance,
        dy:     sin(angle) * distance,
        radius: 4.0 + rng.nextDouble() * 6,
        color:  _confettiColors[i % _confettiColors.length],
      );
    });

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();

    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) _goToTracking();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _goToTracking() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder:        (_, a, _) => OrderSuccessPage(orderId: widget.orderId),
        transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  // ── Interval helpers ────────────────────────────────────────────────────────

  static double _interval(double t, double from, double to, Curve curve) {
    if (t <= from) return 0;
    if (t >= to)   return 1;
    return curve.transform((t - from) / (to - from));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) {
          final t = _ctrl.value;

          final circleProg   = _interval(t, 0.00, 0.42, const ElasticOutCurve(0.65));
          final checkProg    = _interval(t, 0.38, 0.72, Curves.easeOut);
          final confettiProg = _interval(t, 0.42, 0.90, Curves.easeOut);
          final titleFade    = _interval(t, 0.58, 0.80, Curves.easeOut);
          final titleSlide   = (1 - titleFade) * 26.0;
          final subFade      = _interval(t, 0.66, 0.88, Curves.easeOut);
          final btnFade      = _interval(t, 0.76, 1.00, Curves.easeOut);
          final btnSlide     = (1 - btnFade) * 32.0;

          return Stack(
            children: [
              // ── Subtle background tint ─────────────────────────────────────
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.primary.withValues(alpha: 0.07 * t),
                        AppTheme.surface,
                        AppTheme.surface,
                      ],
                      stops: const [0.0, 0.35, 1.0],
                    ),
                  ),
                ),
              ),

              // ── Confetti ───────────────────────────────────────────────────
              Positioned.fill(
                child: CustomPaint(
                  painter: _ConfettiPainter(confettiProg, _particles),
                ),
              ),

              // ── Centre content ─────────────────────────────────────────────
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Circle + checkmark
                    Transform.scale(
                      scale: circleProg,
                      child: Container(
                        width: 130, height: 130,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.brandGradient,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x44C62828),
                              blurRadius: 32,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          painter: _CheckmarkPainter(checkProg),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Title
                    Opacity(
                      opacity: titleFade,
                      child: Transform.translate(
                        offset: Offset(0, titleSlide),
                        child: const Text(
                          'Pedido confirmado!',
                          style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary, letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Subtitle
                    Opacity(
                      opacity: subFade,
                      child: const Text(
                        'Seu pedido está sendo preparado\ncom todo o carinho 🍔',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15, height: 1.55,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Order ID badge
                    Opacity(
                      opacity: subFade,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceAlt,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          'Nº ${widget.orderId.substring(0, min(8, widget.orderId.length)).toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: AppTheme.textSecondary, letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Bottom button ──────────────────────────────────────────────
              Positioned(
                left: 24, right: 24, bottom: 48,
                child: Opacity(
                  opacity: btnFade,
                  child: Transform.translate(
                    offset: Offset(0, btnSlide),
                    child: SizedBox(
                      height: 54,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppTheme.brandGradient,
                          borderRadius: BorderRadius.circular(17),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x44C62828),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _goToTracking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Acompanhar pedido',
                                style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Painters ─────────────────────────────────────────────────────────────────

class _Particle {
  final double dx, dy, radius;
  final Color color;
  const _Particle({
    required this.dx,
    required this.dy,
    required this.radius,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;
  const _ConfettiPainter(this.progress, this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final scale = Curves.easeOut.transform(progress);
    final opacity = (1.0 - progress * 1.1).clamp(0.0, 1.0);

    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity);
      canvas.drawCircle(
        Offset(cx + p.dx * scale, cy + p.dy * scale),
        p.radius * (1.0 - progress * 0.35),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

class _CheckmarkPainter extends CustomPainter {
  final double progress;
  const _CheckmarkPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final paint = Paint()
      ..color  = Colors.white
      ..style  = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap   = StrokeCap.round
      ..strokeJoin  = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.50)
      ..lineTo(size.width * 0.44, size.height * 0.72)
      ..lineTo(size.width * 0.78, size.height * 0.30);

    final metric = path.computeMetrics().first;
    canvas.drawPath(metric.extractPath(0, metric.length * progress), paint);
  }

  @override
  bool shouldRepaint(_CheckmarkPainter old) => old.progress != progress;
}
