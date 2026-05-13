import 'package:flutter_test/flutter_test.dart';
import 'package:imperios/modules/home/models/product_model.dart';

void main() {
  group('ProductModel — fromJson', () {
    // TC01 — imagem como Map (Cloudinary)
    test('TC01: fromJson com imagem como Map retorna URL corretamente', () {
      final json = {
        'id': '1',
        'nome': 'X-Burguer',
        'descricao': 'Delicioso',
        'valor': 25.0,
        'imagem': {'url': 'https://res.cloudinary.com/img.jpg'},
        'categoria': 'lanches',
      };

      final model = ProductModel.fromJson(json);

      expect(model.image, equals('https://res.cloudinary.com/img.jpg'));
    });

    // TC02 — imagem como String direta
    test('TC02: fromJson com imagem como String retorna URL corretamente', () {
      final json = {
        'id': '1',
        'nome': 'X-Burguer',
        'descricao': 'Delicioso',
        'valor': 25.0,
        'imagem': 'https://exemplo.com/img.jpg',
        'categoria': 'lanches',
      };

      final model = ProductModel.fromJson(json);

      expect(model.image, equals('https://exemplo.com/img.jpg'));
    });

    // TC03 — imagem null
    test('TC03: fromJson com imagem null retorna string vazia', () {
      final json = {
        'id': '1',
        'nome': 'X-Burguer',
        'descricao': 'Delicioso',
        'valor': 25.0,
        'imagem': null,
        'categoria': 'lanches',
      };

      final model = ProductModel.fromJson(json);

      expect(model.image, equals(''));
    });

    // TC04 — valor como int
    test('TC04: fromJson com valor int converte para double', () {
      final json = {
        'id': '1',
        'nome': 'X-Burguer',
        'descricao': 'Delicioso',
        'valor': 25,
        'imagem': null,
        'categoria': 'lanches',
      };

      final model = ProductModel.fromJson(json);

      expect(model.price, equals(25.0));
      expect(model.price, isA<double>());
    });

    // TC05 — valor como double
    test('TC05: fromJson com valor double mantém precisão', () {
      final json = {
        'id': '1',
        'nome': 'X-Burguer',
        'descricao': 'Delicioso',
        'valor': 19.99,
        'imagem': null,
        'categoria': 'lanches',
      };

      final model = ProductModel.fromJson(json);

      expect(model.price, equals(19.99));
    });

    // TC06 — valor como String numérica
    test('TC06: fromJson com valor como String numérica converte corretamente', () {
      final json = {
        'id': '1',
        'nome': 'X-Burguer',
        'descricao': 'Delicioso',
        'valor': '29.90',
        'imagem': null,
        'categoria': 'lanches',
      };

      final model = ProductModel.fromJson(json);

      expect(model.price, equals(29.90));
    });

    // TC07 — valor inválido
    test('TC07: fromJson com valor inválido retorna 0.0', () {
      final json = {
        'id': '1',
        'nome': 'X-Burguer',
        'descricao': 'Delicioso',
        'valor': 'abc',
        'imagem': null,
        'categoria': 'lanches',
      };

      final model = ProductModel.fromJson(json);

      expect(model.price, equals(0.0));
    });

    // TC08 — id como int
    test('TC08: fromJson com id numérico converte para String', () {
      final json = {
        'id': 42,
        'nome': 'X-Burguer',
        'descricao': 'Delicioso',
        'valor': 25.0,
        'imagem': null,
        'categoria': 'lanches',
      };

      final model = ProductModel.fromJson(json);

      expect(model.id, equals('42'));
      expect(model.id, isA<String>());
    });

    // TC09 — categoria ausente
    test('TC09: fromJson sem campo categoria retorna null', () {
      final json = {
        'id': '1',
        'nome': 'X-Burguer',
        'descricao': 'Delicioso',
        'valor': 25.0,
        'imagem': null,
      };

      final model = ProductModel.fromJson(json);

      expect(model.categoria, isNull);
    });

    // TC13 — nome e descricao ausentes
    test('TC13: fromJson sem nome e descricao retorna strings vazias', () {
      final json = {
        'id': '1',
        'valor': 25.0,
        'imagem': null,
      };

      final model = ProductModel.fromJson(json);

      expect(model.name, equals(''));
      expect(model.description, equals(''));
    });
  });

  group('ProductModel — toMap e fromMap', () {
    // TC10 — round-trip
    test('TC10: toMap e fromMap reconstroem o modelo corretamente', () {
      final original = ProductModel(
        id: '99',
        name: 'Pizza',
        description: 'Saborosa',
        price: 45.90,
        image: 'https://img.jpg',
        categoria: 'pizzas',
      );

      final map = original.toMap();
      final reconstruido = ProductModel.fromMap(map);

      expect(reconstruido.id, equals(original.id));
      expect(reconstruido.name, equals(original.name));
      expect(reconstruido.description, equals(original.description));
      expect(reconstruido.price, equals(original.price));
      expect(reconstruido.image, equals(original.image));
      expect(reconstruido.categoria, equals(original.categoria));
    });
  });

  group('ProductModel — toBackendMap', () {
    // TC11 — chaves em português
    test('TC11: toBackendMap retorna mapa com chaves em português', () {
      final model = ProductModel(
        id: '10',
        name: 'Frango',
        description: 'Grelhado',
        price: 32.0,
        image: 'https://img.jpg',
        categoria: 'grelhados',
      );

      final map = model.toBackendMap();

      expect(map.containsKey('produtoId'), isTrue);
      expect(map.containsKey('nome'), isTrue);
      expect(map.containsKey('descricao'), isTrue);
      expect(map.containsKey('valor'), isTrue);
      expect(map.containsKey('imagem'), isTrue);
      expect(map.containsKey('categoria'), isTrue);
    });

    // TC12 — categoria null vira string vazia
    test('TC12: toBackendMap com categoria null retorna campo categoria vazio', () {
      final model = ProductModel(
        id: '10',
        name: 'Frango',
        description: 'Grelhado',
        price: 32.0,
        image: 'https://img.jpg',
        categoria: null,
      );

      final map = model.toBackendMap();

      expect(map['categoria'], equals(''));
    });
  });
}
