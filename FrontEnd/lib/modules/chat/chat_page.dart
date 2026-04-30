import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/services/product_service.dart';
import '../../../core/theme/app_theme.dart';
import '../cart/cart_controller.dart';
import '../home/models/product_model.dart';

// ─── Modelos locais ───────────────────────────────────────────────────────────

class _ChatMessage {
  final String text;
  final bool isUser;
  final String? imageUrl;

  const _ChatMessage({required this.text, required this.isUser, this.imageUrl});
}

/// Par de turno para o histórico enviado ao backend
class _HistoryTurn {
  final String user;
  final String assistant;

  const _HistoryTurn({required this.user, required this.assistant});

  Map<String, String> toJson() => {'user': user, 'assistant': assistant};
}

// ─── Página ───────────────────────────────────────────────────────────────────

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  // Catálogo real carregado do backend — necessário para adicionar ao carrinho
  List<ProductModel> _catalogo = [];
  bool _loadingCatalogo = true;

  // Histórico de exibição na tela
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text: 'Olá! Sou o assistente do Impérios Delivery 🍔\n'
          'Me diga o que você quer comer e eu já adiciono no seu carrinho!',
      isUser: false,
    ),
  ];

  // Histórico enviado ao backend (últimas 5 trocas para multi-turn)
  final List<_HistoryTurn> _history = [];
  static const int _maxHistory = 5;

  bool _sending = false;

  // ── Ciclo de vida ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadCatalogo();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalogo() async {
    try {
      final produtos = await ProductService.getAll();
      if (mounted) setState(() { _catalogo = produtos; _loadingCatalogo = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingCatalogo = false);
    }
  }

  // ── Envio de mensagem ─────────────────────────────────────────────────────

  Future<void> _send() async {
    final texto = _inputController.text.trim();
    if (texto.isEmpty || _sending) return;

    final cart = context.read<CartController>();

    setState(() {
      _messages.add(_ChatMessage(text: texto, isUser: true));
      _sending = true;
    });
    _inputController.clear();
    _scrollToBottom();

    // Status compacto do carrinho
    final statusCarrinho = cart.isEmpty
        ? 'O carrinho está vazio.'
        : cart.items
            .map((i) => '${i.quantity}x ${i.product.name}')
            .join(', ');

    // Mantém apenas as últimas N trocas para não inflar o contexto
    final historico = _history.length > _maxHistory
        ? _history.sublist(_history.length - _maxHistory)
        : _history;

    try {
      final response = await http.post(
        Uri.parse('$kBaseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message':   texto,
          'carrinho':  statusCarrinho,
          'historico': historico.map((t) => t.toJson()).toList(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data       = jsonDecode(response.body);
        final respostaIA = (data['resposta_ia'] as String? ?? '').trim();
        final imagemUrl  = data['imagem_url'] as String?;
        final itens      = (data['itens_carrinho'] as List? ?? []);

        // Adiciona mensagem da IA na tela
        setState(() {
          _messages.add(_ChatMessage(
            text: respostaIA,
            isUser: false,
            imageUrl: imagemUrl?.isNotEmpty == true ? imagemUrl : null,
          ));
        });

        // Salva no histórico para multi-turn
        _history.add(_HistoryTurn(user: texto, assistant: respostaIA));

        // Adiciona itens ao carrinho usando o catálogo REAL (IDs do Firestore)
        for (final item in itens) {
          final id         = item['id']?.toString() ?? '';
          final quantidade = (item['quantidade'] as num?)?.toInt() ?? 1;

          final produto = _catalogo.where((p) => p.id == id).firstOrNull;
          if (produto != null) {
            for (int i = 0; i < quantidade; i++) {
              cart.add(produto);
            }
          }
        }
      } else {
        _addErro('Não consegui responder agora. Tente novamente!');
      }
    } catch (_) {
      if (mounted) _addErro('Erro de conexão com o servidor.');
    } finally {
      if (mounted) setState(() => _sending = false);
      _scrollToBottom();
    }
  }

  void _addErro(String msg) {
    setState(() {
      _messages.add(_ChatMessage(text: msg, isUser: false));
      _sending = false;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppTheme.heroGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text('Assistente IA'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Badge com itens no carrinho
          Consumer<CartController>(
            builder: (_, cart, _) {
              if (cart.isEmpty) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.success, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shopping_bag_outlined,
                            size: 14, color: AppTheme.success),
                        const SizedBox(width: 4),
                        Text(
                          '${cart.items.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner de carregamento do cardápio
          if (_loadingCatalogo)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: AppTheme.secondary.withOpacity(0.1),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 12, height: 12,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.secondary),
                  ),
                  SizedBox(width: 8),
                  Text('Carregando cardápio...',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),

          // Lista de mensagens
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: _messages.length + (_sending ? 1 : 0),
              itemBuilder: (context, index) {
                if (_sending && index == _messages.length) {
                  return const _TypingIndicator();
                }
                return _BubbleWidget(message: _messages[index]);
              },
            ),
          ),

          // Sugestões rápidas (só aparece se catálogo carregado e sem histórico)
          if (!_loadingCatalogo && _history.isEmpty)
            _QuickSuggestions(onTap: (sugestao) {
              _inputController.text = sugestao;
              _send();
            }),

          // Campo de input
          _InputBar(
            controller: _inputController,
            sending: _sending,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

// ─── Sugestões rápidas ────────────────────────────────────────────────────────

class _QuickSuggestions extends StatelessWidget {
  final ValueChanged<String> onTap;

  const _QuickSuggestions({required this.onTap});

  static const _sugestoes = [
    'Ver o cardápio completo',
    'Quero um hambúrguer',
    'O que vocês têm de bebida?',
    'Qual o mais barato?',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _sugestoes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => onTap(_sugestoes[i]),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.divider),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Text(
              _sugestoes[i],
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Barra de input ───────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 12, top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(
                  fontSize: 14, color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Ex: quero um X-Bacon e uma Coca...',
                  filled: true,
                  fillColor: AppTheme.surfaceAlt,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 12,
                  ),
                ),
                onSubmitted: (_) => onSend(),
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: sending ? null : onSend,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: sending ? null : AppTheme.brandGradient,
                  color: sending ? AppTheme.surfaceAlt : null,
                  shape: BoxShape.circle,
                  boxShadow: sending
                      ? []
                      : [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.30),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: sending
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.primary,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white, size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bolha de mensagem ────────────────────────────────────────────────────────

class _BubbleWidget extends StatelessWidget {
  final _ChatMessage message;
  const _BubbleWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _IaAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primary : AppTheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: isUser ? [] : AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color:
                          isUser ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                  if (message.imageUrl != null) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        message.imageUrl!,
                        width: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox(),
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
  }
}

class _IaAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30, height: 30,
      decoration: const BoxDecoration(
        gradient: AppTheme.heroGradient,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.auto_awesome_rounded,
        color: Colors.white, size: 14,
      ),
    );
  }
}

// ─── Indicador de digitação ───────────────────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _IaAvatar(),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) {
                    final phase  = ((_ctrl.value + i * 0.28) % 1.0);
                    final bounce = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      child: Transform.translate(
                        offset: Offset(0, -5 * bounce),
                        child: Container(
                          width: 7, height: 7,
                          decoration: BoxDecoration(
                            color: AppTheme.textHint,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
