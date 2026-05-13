import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:imperios/core/services/product_service.dart';
import 'package:imperios/modules/home/models/product_model.dart';

// Helper: monta o JSON que o backend retorna
String _buildResponseBody(List<Map<String, dynamic>> produtos) {
  return jsonEncode({'data': produtos});
}

// Produto fictício válido para reutilizar nos testes
final _produtoValido1 = {
  'id': '1',
  'nome': 'X-Burguer',
  'descricao': 'Pão, carne, queijo',
  'valor': 25.0,
  'imagem': {'url': 'https://res.cloudinary.com/img1.jpg'},
  'categoria': 'lanches',
};

final _produtoValido2 = {
  'id': '2',
  'nome': 'Pizza Margherita',
  'descricao': 'Molho, queijo, manjericão',
  'valor': 49.90,
  'imagem': 'https://res.cloudinary.com/img2.jpg',
  'categoria': 'pizzas',
};

void main() {
  group('ProductService — getAll()', () {
    // TC14 — status 200 com 2 produtos
    test('TC14: retorna lista com 2 produtos quando status é 200', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          _buildResponseBody([_produtoValido1, _produtoValido2]),
          200,
        );
      });

      final produtos = await ProductService.getAll(client: mockClient);

      expect(produtos, isA<List<ProductModel>>());
      expect(produtos.length, equals(2));
      expect(produtos[0].name, equals('X-Burguer'));
      expect(produtos[1].name, equals('Pizza Margherita'));
    });

    // TC15 — status 404
    test('TC15: lança Exception quando status é 404', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      expect(
        () async => await ProductService.getAll(client: mockClient),
        throwsA(isA<Exception>()),
      );
    });

    // TC16 — status 500
    test('TC16: lança Exception quando status é 500', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      expect(
        () async => await ProductService.getAll(client: mockClient),
        throwsA(isA<Exception>()),
      );
    });

    // TC17 — lista vazia no body
    test('TC17: retorna lista vazia sem erro quando data é []', () async {
      final mockClient = MockClient((request) async {
        return http.Response(_buildResponseBody([]), 200);
      });

      final produtos = await ProductService.getAll(client: mockClient);

      expect(produtos, isA<List<ProductModel>>());
      expect(produtos, isEmpty);
    });

    // TC18 — URL correta
    test('TC18: faz requisição para URL contendo /produto', () async {
      Uri? urlChamada;

      final mockClient = MockClient((request) async {
        urlChamada = request.url;
        return http.Response(_buildResponseBody([]), 200);
      });

      await ProductService.getAll(client: mockClient);

      expect(urlChamada, isNotNull);
      expect(urlChamada!.path, contains('/produto'));
    });
  });
}
