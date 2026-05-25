import 'package:flutter_test/flutter_test.dart';
import 'package:imperios/modules/home/models/product_model.dart';
import 'package:imperios/modules/cart/models/cart_item_model.dart';

// Produto reutilizável nos testes
ProductModel _makeProduct({
  String id = '1',
  String name = 'X-Burguer',
  String description = 'Pão, carne, queijo',
  double price = 25.0,
  String image = 'https://img.jpg',
  String? categoria = 'lanches',
}) {
  return ProductModel(
    id: id,
    name: name,
    description: description,
    price: price,
    image: image,
    categoria: categoria,
  );
}

void main() {
  group('CartItem — toMap', () {
    test('TC-CI-01: toMap inclui chaves "product" e "quantity"', () {
      final item = CartItem(product: _makeProduct(), quantity: 3);

      final map = item.toMap();

      expect(map.containsKey('product'), isTrue);
      expect(map.containsKey('quantity'), isTrue);
    });

    test('TC-CI-02: toMap serializa quantity corretamente', () {
      final item = CartItem(product: _makeProduct(), quantity: 5);

      final map = item.toMap();

      expect(map['quantity'], equals(5));
    });

    test('TC-CI-03: toMap serializa product usando toMap() do ProductModel', () {
      final product = _makeProduct(id: '42', name: 'Pizza');
      final item = CartItem(product: product, quantity: 1);

      final map = item.toMap();
      final productMap = map['product'] as Map<String, dynamic>;

      expect(productMap['id'], equals('42'));
      expect(productMap['name'], equals('Pizza'));
    });

    test('TC-CI-04: quantity padrão é 1 quando não informado', () {
      final item = CartItem(product: _makeProduct());

      expect(item.quantity, equals(1));
    });
  });

  group('CartItem — fromMap', () {
    test('TC-CI-05: fromMap reconstrói CartItem corretamente (round-trip)', () {
      final original = CartItem(product: _makeProduct(), quantity: 4);

      final map = original.toMap();
      final reconstruido = CartItem.fromMap(map);

      expect(reconstruido.quantity, equals(original.quantity));
      expect(reconstruido.product.id, equals(original.product.id));
      expect(reconstruido.product.name, equals(original.product.name));
      expect(reconstruido.product.price, equals(original.product.price));
      expect(reconstruido.product.image, equals(original.product.image));
      expect(reconstruido.product.categoria, equals(original.product.categoria));
    });

    test('TC-CI-06: fromMap com product contendo categoria null reconstrói sem erro', () {
      final product = _makeProduct(categoria: null);
      final original = CartItem(product: product, quantity: 2);

      final map = original.toMap();
      final reconstruido = CartItem.fromMap(map);

      expect(reconstruido.product.categoria, isNull);
      expect(reconstruido.quantity, equals(2));
    });

    test('TC-CI-07: fromMap preserva preço com casas decimais', () {
      final product = _makeProduct(price: 49.99);
      final original = CartItem(product: product, quantity: 1);

      final map = original.toMap();
      final reconstruido = CartItem.fromMap(map);

      expect(reconstruido.product.price, equals(49.99));
    });
  });
}
