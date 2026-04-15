import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import '../cart/cart_controller.dart';
import '../home/models/product_model.dart';

// 1. ATUALIZAMOS O MODELO DA MENSAGEM PARA RECEBER A IMAGEM
class ChatMessage {
  final String text;
  final bool isUser;
  final String? imageUrl; // Pode ser nulo se não tiver imagem

  ChatMessage({required this.text, required this.isUser, this.imageUrl});
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Olá! Bem-vindo(a) à Impérios Burger! Como posso te ajudar hoje?",
      isUser: false,
    ),
  ];

  final List<ProductModel> _cardapioFake = [
    ProductModel(
      id: 1,
      name: 'Hambúrguer Artesanal',
      description: '180g de carne, queijo e molho especial',
      price: 29.90,
      image: 'https://i.imgur.com/6RLcK8F.png',
    ),
    ProductModel(
      id: 2,
      name: 'Combo Burger',
      description: 'Burger + fritas + refri',
      price: 39.90,
      image: 'https://i.imgur.com/YZ6Yq2M.png',
    ),
  ];

  Future<void> _sendMessage() async {
    final userText = _messageController.text;
    if (userText.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: userText, isUser: true));
    });

    _messageController.clear();

    final cartController = Provider.of<CartController>(context, listen: false);
    String statusCarrinho = "O carrinho está vazio.";

    if (!cartController.isEmpty) {
      final itensDescritos = cartController.items
          .map((item) {
            return "${item.quantity}x ${item.product.name}";
          })
          .join(", ");
      statusCarrinho =
          "O carrinho atual tem os seguintes itens: $itensDescritos.";
    }

    try {
      final url = Uri.parse('http://127.0.0.1:2580/api/chat');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': userText, 'carrinho': statusCarrinho}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final respostaIA = data['resposta_ia'];

        // 2. LÊ A IMAGEM QUE VEIO DO NODE.JS
        final imagemIA = data['imagem_url'];
        final itensParaAdicionar = data['itens_carrinho'] as List;

        setState(() {
          // Passa a imagem para o balãozinho
          _messages.add(
            ChatMessage(text: respostaIA, isUser: false, imageUrl: imagemIA),
          );
        });

        if (itensParaAdicionar.isNotEmpty) {
          for (var item in itensParaAdicionar) {
            int idProduto = item['id'];
            int quantidade = item['quantidade'];

            try {
              final produto = _cardapioFake.firstWhere(
                (p) => p.id == idProduto,
              );
              for (int i = 0; i < quantidade; i++) {
                cartController.add(produto);
              }
            } catch (e) {
              print("Produto com ID $idProduto não encontrado no app.");
            }
          }
        }
      } else {
        setState(() {
          _messages.add(
            ChatMessage(
              text: "Erro de comunicação com a cozinha.",
              isUser: false,
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: "Erro de conexão.", isUser: false));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistente Virtual'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Quero um X-Bacon e uma Coca...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).primaryColor
              : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isUser ? 16 : 0),
            bottomRight: Radius.circular(message.isUser ? 0 : 16),
          ),
        ),
        // 3. SE TIVER IMAGEM, MOSTRA A FOTO EMBRULHADA NUMA COLUNA!
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            if (message.imageUrl != null && message.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  message.imageUrl!,
                  width: 220, // Largura da foto no chat
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Text(
                    'Erro ao carregar a imagem',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
