import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../cart/models/cart_item_model.dart';
import '../home/models/product_model.dart';
import '../../core/constants.dart';
import '../../core/services/auth_service.dart';

class CartController extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;
  bool get isEmpty => _items.isEmpty;

  double get total => _items.fold(
        0,
        (sum, item) => sum + item.product.price * item.quantity,
      );

  CartController() {
    _load();
  }

  // ─── Operações locais + sync ──────────────────────────────────────────────

  void add(ProductModel product) {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
    _persistAndSync();
  }

  void increment(ProductModel product) => add(product);

  void decrement(ProductModel product) {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
      _persistAndSync();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
    _persistAndSync();
    _clearBackend();
  }

  // ─── Persistência local (SharedPreferences) ───────────────────────────────

  Future<void> _persistAndSync() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_items.map((e) => e.toMap()).toList());
    await prefs.setString('cart_items', json);
    _syncBackend();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('cart_items');
    if (data != null) {
      final List decoded = jsonDecode(data);
      _items.clear();
      _items.addAll(decoded.map((e) => CartItem.fromMap(e)).toList());
      notifyListeners();
    }
  }

  // ─── Sincronização com backend ────────────────────────────────────────────

  /// Envia o carrinho completo para o backend (ignora se não estiver logado).
  Future<void> _syncBackend() async {
    final logged = await AuthService.isLoggedIn();
    if (!logged) return;

    final headers = await AuthService.authHeaders();

    final itens = _items
        .map((e) => {
              ...e.product.toBackendMap(),
              'quantidade': e.quantity,
            })
        .toList();

    await http
        .post(
          Uri.parse('$kBaseUrl/carrinho'),
          headers: headers,
          body: jsonEncode({'tipo': 'carrinho', 'itens': itens}),
        )
        .catchError((_) {}); // falha silenciosa — carrinho local ainda funciona
  }

  Future<void> _clearBackend() async {
    final logged = await AuthService.isLoggedIn();
    if (!logged) return;

    final headers = await AuthService.authHeaders();
    await http
        .delete(Uri.parse('$kBaseUrl/carrinho'), headers: headers)
        .catchError((_) {});
  }

  /// Força sincronização imediata do carrinho com o backend.
  Future<void> syncToBackend() => _syncBackend();

  /// Carrega o carrinho do backend após o login (substitui o carrinho local).
  Future<void> loadFromBackend() async {
    final logged = await AuthService.isLoggedIn();
    if (!logged) return;

    try {
      final headers = await AuthService.authHeaders();
      final response =
          await http.get(Uri.parse('$kBaseUrl/carrinho'), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List itens = data['data']?['itens'] ?? [];

        _items.clear();

        for (final item in itens) {
          final product = ProductModel(
            id: item['produtoId']?.toString() ?? '',
            name: item['nome'] ?? '',
            description: item['descricao'] ?? '',
            price: (item['valor'] is num)
                ? (item['valor'] as num).toDouble()
                : double.tryParse(item['valor']?.toString() ?? '0') ?? 0,
            image: item['imagem'] is String ? item['imagem'] : '',
            categoria: item['categoria'] as String?,
          );

          final qty = (item['quantidade'] as num?)?.toInt() ?? 1;
          _items.add(CartItem(product: product, quantity: qty));
        }

        // persiste localmente também
        final prefs = await SharedPreferences.getInstance();
        final json = jsonEncode(_items.map((e) => e.toMap()).toList());
        await prefs.setString('cart_items', json);

        notifyListeners();
      }
    } catch (_) {
      // se falhar, mantém o carrinho local
    }
  }
}
