import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import 'login_page.dart';
import 'widgets/auth_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  final _nomeController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _telefoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ruaController      = TextEditingController();
  final _numeroController   = TextEditingController();
  final _bairroController   = TextEditingController();
  final _cidadeController   = TextEditingController();
  final _estadoController   = TextEditingController();
  final _cepController      = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    for (final c in [
      _nomeController, _emailController, _telefoneController,
      _passwordController, _ruaController, _numeroController,
      _bairroController, _cidadeController, _estadoController, _cepController,
    ]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _register() async {
    final nome     = _nomeController.text.trim();
    final email    = _emailController.text.trim();
    final telefone = _telefoneController.text.trim();
    final password = _passwordController.text;
    final rua      = _ruaController.text.trim();
    final numero   = _numeroController.text.trim();
    final bairro   = _bairroController.text.trim();
    final cidade   = _cidadeController.text.trim();
    final estado   = _estadoController.text.trim();
    final cep      = _cepController.text.trim();

    if ([nome, email, password, telefone, rua, numero, cidade, estado, cep]
        .any((v) => v.isEmpty)) {
      _showError('Preencha todos os campos obrigatórios');
      return;
    }

    setState(() => _loading = true);

    final error = await AuthService.register(
      nome: nome, email: email, password: password, telefone: telefone,
      rua: rua, numero: numero, bairro: bairro,
      cidade: cidade, estado: estado, cep: cep,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) { _showError(error); return; }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Conta criada! Faça o login.'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Dados pessoais ──────────────────────────────────────────
              _SectionHeader(title: 'Dados pessoais', icon: Icons.person_outline),
              const SizedBox(height: 16),
              _card(
                children: [
                  AuthTextField(
                    label: 'Nome completo',
                    icon: Icons.badge_outlined,
                    controller: _nomeController,
                  ),
                  const SizedBox(height: 14),
                  AuthTextField(
                    label: 'E-mail',
                    icon: Icons.email_outlined,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  AuthTextField(
                    label: 'Telefone',
                    icon: Icons.phone_outlined,
                    controller: _telefoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  AuthTextField(
                    label: 'Senha',
                    icon: Icons.lock_outline,
                    obscure: true,
                    controller: _passwordController,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Endereço ────────────────────────────────────────────────
              _SectionHeader(title: 'Endereço de entrega', icon: Icons.location_on_outlined),
              const SizedBox(height: 16),
              _card(
                children: [
                  AuthTextField(
                    label: 'CEP',
                    icon: Icons.pin_drop_outlined,
                    controller: _cepController,
                    keyboardType: TextInputType.number,
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

              const SizedBox(height: 32),

              // ── Botão cadastrar ─────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: _loading ? null : AppTheme.brandGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: _loading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 22, width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Cadastrar',
                            style: TextStyle(
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
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
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
            color: AppTheme.primary.withOpacity(0.10),
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
