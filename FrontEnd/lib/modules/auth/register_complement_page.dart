import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../cart/cart_controller.dart';
import '../home/home_page.dart';
import 'login_page.dart';
import 'widgets/auth_text_field.dart';

class RegisterComplementPage extends StatefulWidget {
  final String nome;
  final String email;
  final String? password;
  final String? googleIdToken;
  final bool isGoogle;

  const RegisterComplementPage({
    super.key,
    required this.nome,
    required this.email,
    this.password,
    this.googleIdToken,
    this.isGoogle = false,
  });

  @override
  State<RegisterComplementPage> createState() => _RegisterComplementPageState();
}

class _RegisterComplementPageState extends State<RegisterComplementPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  final _telefoneController = TextEditingController();
  final _cepController      = TextEditingController();
  final _ruaController      = TextEditingController();
  final _numeroController   = TextEditingController();
  final _bairroController   = TextEditingController();
  final _cidadeController   = TextEditingController();
  final _estadoController   = TextEditingController();

  bool _loading    = false;
  bool _loadingCep = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
    _cepController.addListener(_onCepChanged);
  }

  Future<void> _onCepChanged() async {
    final cep = _cepController.text.replaceAll(RegExp(r'\D'), '');
    if (cep.length != 8) return;
    if (_loadingCep) return;

    setState(() => _loadingCep = true);
    try {
      final response = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cep/json/'),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['erro'] == true || data['erro'] == 'true') {
          _showError('CEP não encontrado');
        } else {
          _ruaController.text    = data['logradouro'] as String? ?? '';
          _bairroController.text = data['bairro']     as String? ?? '';
          _cidadeController.text = data['localidade'] as String? ?? '';
          _estadoController.text = data['uf']         as String? ?? '';
        }
      }
    } catch (_) {
      // falha silenciosa — usuário preenche manualmente
    } finally {
      if (mounted) setState(() => _loadingCep = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    for (final c in [
      _telefoneController, _cepController, _ruaController,
      _numeroController, _bairroController, _cidadeController, _estadoController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final cart     = context.read<CartController>();
    final telefone = _telefoneController.text.trim();
    final cep      = _cepController.text.trim();
    final rua      = _ruaController.text.trim();
    final numero   = _numeroController.text.trim();
    final bairro   = _bairroController.text.trim();
    final cidade   = _cidadeController.text.trim();
    final estado   = _estadoController.text.trim();

    if ([telefone, cep, rua, numero, cidade, estado].any((v) => v.isEmpty)) {
      _showError('Preencha todos os campos obrigatórios');
      return;
    }

    setState(() => _loading = true);

    String? error;

    if (widget.isGoogle) {
      error = await AuthService.registerWithGoogle(
        googleIdToken: widget.googleIdToken!,
        nome: widget.nome,
        email: widget.email,
        telefone: telefone,
        rua: rua,
        numero: numero,
        bairro: bairro,
        cidade: cidade,
        estado: estado,
        cep: cep,
      );
    } else {
      error = await AuthService.register(
        nome: widget.nome,
        email: widget.email,
        password: widget.password!,
        telefone: telefone,
        rua: rua,
        numero: numero,
        bairro: bairro,
        cidade: cidade,
        estado: estado,
        cep: cep,
      );
    }

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      _showError(error);
      return;
    }

    if (widget.isGoogle) {
      await AuthService.saveEndereco({
        'rua': rua, 'numero': numero, 'bairro': bairro,
        'cidade': cidade, 'estado': estado, 'cep': cep, 'pais': 'Brasil',
      });
      await Future.wait([
        cart.loadFromBackend(),
        NotificationService.registerToken(),
      ]);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Conta criada! Faça o login.'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Criar conta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Indicador de etapa ─────────────────────────────────────
                _StepIndicator(current: 2, total: 2),
                const SizedBox(height: 20),

                // ── Resumo da etapa anterior ───────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.isGoogle
                            ? Icons.verified_user_outlined
                            : Icons.person_outline,
                        size: 18,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.nome,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              widget.email,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.isGoogle)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4285F4).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Google',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4285F4),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Contato ────────────────────────────────────────────────
                _SectionHeader(
                  title: 'Contato',
                  icon: Icons.phone_outlined,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: AuthTextField(
                    label: 'Telefone / WhatsApp',
                    icon: Icons.phone_outlined,
                    controller: _telefoneController,
                    keyboardType: TextInputType.phone,
                  ),
                ),

                const SizedBox(height: 24),

                // ── Endereço ───────────────────────────────────────────────
                _SectionHeader(
                  title: 'Endereço de entrega',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    children: [
                      AuthTextField(
                        label: 'CEP',
                        icon: Icons.pin_drop_outlined,
                        controller: _cepController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(8),
                        ],
                        suffix: _loadingCep
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppTheme.primary,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: AuthTextField(
                              label: 'Rua',
                              icon: Icons.home_outlined,
                              controller: _ruaController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: AuthTextField(
                              label: 'Nº',
                              icon: Icons.tag,
                              controller: _numeroController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      AuthTextField(
                        label: 'Bairro',
                        icon: Icons.location_city_outlined,
                        controller: _bairroController,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: AuthTextField(
                              label: 'Cidade',
                              icon: Icons.location_on_outlined,
                              controller: _cidadeController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: AuthTextField(
                              label: 'UF',
                              icon: Icons.map_outlined,
                              controller: _estadoController,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Botão finalizar ────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: _loading ? null : AppTheme.brandGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              widget.isGoogle
                                  ? 'Concluir cadastro'
                                  : 'Criar conta',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ──────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i + 1 == current;
        final done   = i + 1 < current;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < total - 1 ? 8 : 0),
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: (active || done)
                  ? AppTheme.primary
                  : Colors.grey.shade200,
            ),
          ),
        );
      }),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
