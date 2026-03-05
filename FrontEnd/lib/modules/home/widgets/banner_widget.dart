import 'package:flutter/material.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  final PageController _controller = PageController(viewportFraction: 0.9);
  double currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => currentPage = _controller.page ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: PageView.builder(
        controller: _controller,
        itemCount: 3,
        itemBuilder: (_, index) {
          final scale = 1 - (currentPage - index).abs() * 0.1;
          return Transform.scale(
            scale: scale.clamp(0.9, 1),
            child: _bannerItem(index),
          );
        },
      ),
    );
  }

  Widget _bannerItem(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            Colors.red.shade400,
            Colors.orange.shade400,
          ],
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'Promo ${index + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
