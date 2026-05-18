import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffix;

  const AuthTextField({
    super.key,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.suffix,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    Widget? suffixIcon;

    if (widget.obscure) {
      suffixIcon = IconButton(
        icon: Icon(
          _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: AppTheme.textSecondary,
        ),
        onPressed: () => setState(() => _showPassword = !_showPassword),
      );
    } else if (widget.suffix != null) {
      suffixIcon = Padding(
        padding: const EdgeInsets.all(12),
        child: widget.suffix,
      );
    }

    return TextField(
      controller: widget.controller,
      obscureText: widget.obscure && !_showPassword,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      style: const TextStyle(
        fontSize: 15,
        color: AppTheme.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(widget.icon, size: 20, color: AppTheme.textSecondary),
        labelText: widget.label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
