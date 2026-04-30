import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

// Mapa: label exibido → valor do campo `categoria` no backend
const Map<String, String> kCategories = {
  'Todos'      : '',
  '🍔 Lanches' : 'Lanches',
  '🍕 Pizzas'  : 'Pizzas',
  '🍟 Porções' : 'Porções',
  '🥤 Bebidas' : 'Bebidas',
  '🍰 Sobremesas': 'Sobremesas',
};

class CategoryWidget extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const CategoryWidget({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final labels = kCategories.keys.toList();

    return SizedBox(
      height: 44,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        itemBuilder: (_, index) {
          final label = labels[index];
          final value = kCategories[label]!;
          final isSelected = selected == value;

          return GestureDetector(
            onTap: () => onChanged(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.surface,
                borderRadius: BorderRadius.circular(22),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.30),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : AppTheme.cardShadow,
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
