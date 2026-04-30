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
  late Animation<double> _slide;

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ruaController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _cepController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slide = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    for (final c in [
      _nomeController, _emailController, _telefoneController,
      _passwordController, _ruaController, _numeroController,
      _bairroController, _cidadeController, _estadoController, _cepController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final telefone = _telefoneController.text.trim();
    final password = _passwordController.text;
    final rua = _ruaController.text.trim();
    final numero = _numeroController.text.trim();
    final bairro = _bairroController.text.trim();
    final cidade = _cidadeController.text.trim();
    final estado = _estadoController.text.trim();
    final cep = _cepController.text.trim();

    if ([nome, email, password, telefone, rua, numero, cidade, estado, cep]
        .any((v) => v.isEmpty)) {
      _showError('Preencha todos os campos obrigatórios');
      return;
    }

    setState(() => _loading = true);

    final error = await AuthService.register(
      nome: nome,
      email: email,
      password: password,
      telefone: telefone,
      rua: rua,
      numero: numero,
      bairro: bairro,
      cidade: cidade,
      estado: estado,
      cep: cep,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      _showError(error);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conta criada! Faça o login.')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: AnimatedBuilder(
        animation: _slide,
        builder: (_, child) =>
            Transform.translate(offset: Offset(0, _slide.value), child: child),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _section('Dados pessoais'),
              AuthTextField(
                label: 'Nome completo',
                icon: Icons.person_outline,
                controller: _nomeController,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                label: 'Email',
                icon: Icons.email_outlined,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                label: 'Telefone',
                icon: Icons.phone_outlined,
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                label: 'Senha',
                icon: Icons.lock_outline,
                obscure: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 24),
              _section('Endereço'),
              AuthTextField(
                label: 'CEP',
                icon: Icons.pin_drop_outlined,
                controller: _cepController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
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
                      label: 'Número',
                      icon: Icons.tag,
                      controller: _numeroController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AuthTextField(
                label: 'Bairro',
                icon: Icons.location_city_outlined,
                controller: _bairroController,
              ),
              const SizedBox(height: 12),
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
                      label: 'Estado (UF)',
                      icon: Icons.map_outlined,
                      controller: _estadoController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Cadastrar',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }
}
