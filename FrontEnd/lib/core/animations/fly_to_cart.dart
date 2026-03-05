import 'dart:ui';

import 'package:flutter/material.dart';

class FlyToCart {
  static void animate({
    required BuildContext context,
    required GlobalKey cartKey,
    required ImageProvider image,
    required Offset startPosition,
  }) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final cartBox =
        cartKey.currentContext?.findRenderObject() as RenderBox?;
    if (cartBox == null) return;

    final endPosition = cartBox.localToGlobal(
      cartBox.size.center(Offset.zero),
    );

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) {
        return _FlyWidget(
          start: startPosition,
          end: endPosition,
          image: image,
          onFinish: () => entry.remove(),
        );
      },
    );

    overlay.insert(entry);
  }
}

class _FlyWidget extends StatefulWidget {
  final Offset start;
  final Offset end;
  final ImageProvider image;
  final VoidCallback onFinish;

  const _FlyWidget({
    required this.start,
    required this.end,
    required this.image,
    required this.onFinish,
  });

  @override
  State<_FlyWidget> createState() => _FlyWidgetState();
}

class _FlyWidgetState extends State<_FlyWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward().whenComplete(widget.onFinish);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        final x = lerpDouble(
          widget.start.dx,
          widget.end.dx,
          _animation.value,
        )!;
        final y = lerpDouble(
          widget.start.dy,
          widget.end.dy,
          _animation.value,
        )!;

        return Positioned(
          left: x,
          top: y,
          child: Transform.scale(
            scale: 1 - _animation.value * 0.5,
            child: Opacity(
              opacity: 1 - _animation.value,
              child: Image(
                image: widget.image,
                width: 48,
                height: 48,
              ),
            ),
          ),
        );
      },
    );
  }
}
