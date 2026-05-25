import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:imperios/core/services/product_service.dart';
import 'package:imperios/modules/home/models/product_model.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

http.Client _mockClient(int statusCode, Object body) => MockClient((_) async =>
    http.Response(jsonEncode(body), statusCode,
        headers: {'content-type': 'application/json'}));

final _produtoCloudinary = {
  'id': '1',
  'nome': 'X-Burguer',
  'descricao': 'Pão, carne e queijo',
  'valor': 25.0,
  'imagem': {'url': 'https://res.cloudinary.com/img1.jpg'},
  'categoria': 'lanches',
};

final _produtoImagemString = {
  'id': '2',
  'nome': 'Pizza Margherita',
  'descricao': 'Molho, queijo e manjericão',
  'valor': 49.90,
  'imagem': 'https://res.cloudinary.com/img2.jpg',
  'categoria': 'pizzas',
};

final _produtoSemCategoria = {
  'id': '3',
  'nome': 'Suco Natural',
  'descricao': 'Laranja espremida',
  'valor': 8.0,
  'imagem': null,
};

final _produtoValorInt = {
  'id': '4',
  'nome': 'Água',
  'descricao': 'Mineral 500ml',
  'valor': 3,
  'imagem': null,
  'categoria': 'bebidas',
};

// ─── Testes ───────────────────────────────────────────────────────────────────

void main() {
  group('ProductService.getAll — integração com REST API', () {
    // ── Cenários de sucesso ──────────────────────────────────────────────────

    test(
        'TC-PS-01: retorna lista de ProductModel corretamente com status 200',
        () async {
      final client = _mockClient(200, {
        'data': [_produtoCloudinary, _produtoImagemString],
      });

      final produtos = await ProductService.getAll(client: client);

      expect(produtos, isA<List<ProductModel>>());
      expect(produtos.length, equals(2));
    });

    test('TC-PS-02: mapeia nome e preço dos produtos corretamente', () async {
      final client = _mockClient(200, {
        'data': [_produtoCloudinary, _produtoImagemString],
      });

      final produtos = await ProductService.getAll(client: client);

      expect(produtos[0].name, equals('X-Burguer'));
      expect(produtos[0].price, equals(25.0));
      expect(produtos[1].name, equals('Pizza Margherita'));
      expect(produtos[1].price, equals(49.90));
    });

    test(
        'TC-PS-03: mapeia imagem Cloudinary (Map com url) para string correta',
        () async {
      final client =
          _mockClient(200, {'data': [_produtoCloudinary]});

      final produtos = await ProductService.getAll(client: client);

      expect(produtos[0].image,
          equals('https://res.cloudinary.com/img1.jpg'));
    });

    test('TC-PS-04: mapeia imagem como String direta corretamente', () async {
      final client =
          _mockClient(200, {'data': [_produtoImagemString]});

      final produtos = await ProductService.getAll(client: client);

      expect(produtos[0].image,
          equals('https://res.cloudinary.com/img2.jpg'));
    });

    test('TC-PS-05: imagem null resulta em string vazia no modelo', () async {
      final client =
          _mockClient(200, {'data': [_produtoSemCategoria]});

      final produtos = await ProductService.getAll(client: client);

      expect(produtos[0].image, equals(''));
    });

    test('TC-PS-06: valor int no JSON é convertido para double', () async {
      final client =
          _mockClient(200, {'data': [_produtoValorInt]});

      final produtos = await ProductService.getAll(client: client);

      expect(produtos[0].price, equals(3.0));
      expect(produtos[0].price, isA<double>());
    });

    test('TC-PS-07: categoria ausente no JSON resulta em null no modelo',
        () async {
      final client =
          _mockClient(200, {'data': [_produtoSemCategoria]});

      final produtos = await ProductService.getAll(client: client);

      expect(produtos[0].categoria, isNull);
    });

    test('TC-PS-08: retorna lista vazia quando "data" é []', () async {
      final client = _mockClient(200, {'data': []});

      final produtos = await ProductService.getAll(client: client);

      expect(produtos, isEmpty);
    });

    test('TC-PS-09: retorna lista com múltiplos produtos mistos', () async {
      final client = _mockClient(200, {
        'data': [
          _produtoCloudinary,
          _produtoImagemString,
          _produtoSemCategoria,
          _produtoValorInt,
        ],
      });

      final produtos = await ProductService.getAll(client: client);

      expect(produtos.length, equals(4));
    });

    // ── Cenários de erro HTTP ────────────────────────────────────────────────

    test('TC-PS-10: lança Exception quando status é 401 (não autorizado)',
        () async {
      final client = _mockClient(401, {'message': 'Não autorizado'});

      expect(
        () async => ProductService.getAll(client: client),
        throwsA(isA<Exception>()),
      );
    });

    test('TC-PS-11: lança Exception quando status é 404', () async {
      final client = MockClient((_) async => http.Response('Not Found', 404));

      expect(
        () async => ProductService.getAll(client: client),
        throwsA(isA<Exception>()),
      );
    });

    test('TC-PS-12: lança Exception quando status é 500', () async {
      final client =
          MockClient((_) async => http.Response('Server Error', 500));

      expect(
        () async => ProductService.getAll(client: client),
        throwsA(isA<Exception>()),
      );
    });

    test('TC-PS-13: lança Exception quando há erro de rede (exception no client)',
        () async {
      final client = MockClient((_) async => throw Exception('Sem conexão'));

      expect(
        () async => ProductService.getAll(client: client),
        throwsA(isA<Exception>()),
      );
    });

    // ── Contrato de URL ──────────────────────────────────────────────────────

    test('TC-PS-14: requisição é feita para URL contendo /produto', () async {
      Uri? urlCapturada;

      final client = MockClient((request) async {
        urlCapturada = request.url;
        return http.Response(jsonEncode({'data': []}), 200,
            headers: {'content-type': 'application/json'});
      });

      await ProductService.getAll(client: client);

      expect(urlCapturada, isNotNull);
      expect(urlCapturada!.path, contains('/produto'));
    });

    test('TC-PS-15: requisição usa método GET', () async {
      String? metodo;

      final client = MockClient((request) async {
        metodo = request.method;
        return http.Response(jsonEncode({'data': []}), 200,
            headers: {'content-type': 'application/json'});
      });

      await ProductService.getAll(client: client);

      expect(metodo, equals('GET'));
    });
  });
}
