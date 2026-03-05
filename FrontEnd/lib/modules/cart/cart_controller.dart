import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:imperios/modules/cart/models/cart_item_model.dart';
import 'package:imperios/modules/home/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CartController extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;
  bool get isEmpty => _items.isEmpty;

  double get total => _items.fold(
        0,
        (sum, item) => sum + item.product.price * item.quantity,
      );

  CartController() {
    loadCart();
  }

  void add(ProductModel product) {
    final index =
        _items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }

    saveCart();
    notifyListeners();
  }

  void increment(ProductModel product) {
    add(product);
  }

  void decrement(ProductModel product) {
    final index =
        _items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      saveCart();
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    saveCart();
    notifyListeners();
  }

  // 💾 SALVAR
  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonCart = jsonEncode(_items.map((e) => e.toMap()).toList());
    await prefs.setString('cart_items', jsonCart);
  }

  // 📦 RECUPERAR
  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('cart_items');

    if (data != null) {
      final List decoded = jsonDecode(data);
      _items.clear();
      _items.addAll(
        decoded.map((e) => CartItem.fromMap(e)).toList(),
      );
      notifyListeners();
    }
  }
}
