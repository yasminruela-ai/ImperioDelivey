import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../modules/home/home_page.dart';

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 120,
                color: AppTheme.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'Pedido realizado!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Seu pedido foi enviado para a cozinha 👨‍🍳',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HomePage(),
                    ),
                    (_) => false,
                  );
                },
                child: const Text('Voltar para tela inicial'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
