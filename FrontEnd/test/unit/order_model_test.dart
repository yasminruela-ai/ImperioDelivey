import 'package:flutter_test/flutter_test.dart';
import 'package:imperios/modules/checkout/models/order_model.dart';

void main() {
  // ── OrderItemModel ──────────────────────────────────────────────────────────

  group('OrderItemModel — fromJson', () {
    test('TC-OI-01: fromJson com dados válidos mapeia corretamente', () {
      final json = {
        'nome': 'X-Burguer',
        'valor': 25.0,
        'quantidade': 2,
      };

      final item = OrderItemModel.fromJson(json);

      expect(item.nome, equals('X-Burguer'));
      expect(item.valor, equals(25.0));
      expect(item.quantidade, equals(2));
    });

    test('TC-OI-02: fromJson com valor como int converte para double', () {
      final json = {
        'nome': 'Pizza',
        'valor': 40,
        'quantidade': 1,
      };

      final item = OrderItemModel.fromJson(json);

      expect(item.valor, equals(40.0));
      expect(item.valor, isA<double>());
    });

    test('TC-OI-03: fromJson com quantidade como double converte para int', () {
      final json = {
        'nome': 'Suco',
        'valor': 8.0,
        'quantidade': 3.0,
      };

      final item = OrderItemModel.fromJson(json);

      expect(item.quantidade, equals(3));
      expect(item.quantidade, isA<int>());
    });

    test('TC-OI-04: fromJson com nome ausente retorna string vazia', () {
      final json = {
        'valor': 10.0,
        'quantidade': 1,
      };

      final item = OrderItemModel.fromJson(json);

      expect(item.nome, equals(''));
    });

    test('TC-OI-05: fromJson com valor null retorna 0.0', () {
      final json = {
        'nome': 'Refrigerante',
        'valor': null,
        'quantidade': 1,
      };

      final item = OrderItemModel.fromJson(json);

      expect(item.valor, equals(0.0));
    });

    test('TC-OI-06: fromJson com quantidade null retorna 1 como padrão', () {
      final json = {
        'nome': 'Refrigerante',
        'valor': 5.0,
        'quantidade': null,
      };

      final item = OrderItemModel.fromJson(json);

      expect(item.quantidade, equals(1));
    });
  });

  // ── OrderModel ──────────────────────────────────────────────────────────────

  group('OrderModel — fromJson', () {
    test('TC-OM-01: fromJson com dados válidos e itens mapeia corretamente', () {
      final json = {
        'id': 'pedido-abc-123',
        'status': 'pendente',
        'total': 75.90,
        'enderecoEntrega': 'Rua das Flores, 10',
        'formaPagamento': 'pix',
        'itens': [
          {'nome': 'X-Burguer', 'valor': 25.0, 'quantidade': 2},
          {'nome': 'Suco', 'valor': 8.0, 'quantidade': 1},
        ],
      };

      final order = OrderModel.fromJson(json);

      expect(order.id, equals('pedido-abc-123'));
      expect(order.status, equals('pendente'));
      expect(order.total, equals(75.90));
      expect(order.enderecoEntrega, equals('Rua das Flores, 10'));
      expect(order.formaPagamento, equals('pix'));
      expect(order.itens.length, equals(2));
      expect(order.itens[0].nome, equals('X-Burguer'));
      expect(order.itens[1].nome, equals('Suco'));
    });

    test('TC-OM-02: fromJson com itens ausentes retorna lista vazia', () {
      final json = {
        'id': 'pedido-xyz',
        'status': 'pendente',
        'total': 30.0,
      };

      final order = OrderModel.fromJson(json);

      expect(order.itens, isEmpty);
    });

    test('TC-OM-03: fromJson com total como int converte para double', () {
      final json = {
        'id': 'pedido-001',
        'status': 'entregue',
        'total': 50,
        'itens': [],
      };

      final order = OrderModel.fromJson(json);

      expect(order.total, equals(50.0));
      expect(order.total, isA<double>());
    });

    test('TC-OM-04: fromJson com total null retorna 0.0', () {
      final json = {
        'id': 'pedido-001',
        'status': 'pendente',
        'total': null,
        'itens': [],
      };

      final order = OrderModel.fromJson(json);

      expect(order.total, equals(0.0));
    });

    test('TC-OM-05: fromJson com status ausente usa "pendente" como padrão', () {
      final json = {
        'id': 'pedido-002',
        'total': 20.0,
        'itens': [],
      };

      final order = OrderModel.fromJson(json);

      expect(order.status, equals('pendente'));
    });

    test('TC-OM-06: fromJson com id null retorna string vazia', () {
      final json = {
        'id': null,
        'status': 'pendente',
        'total': 20.0,
        'itens': [],
      };

      final order = OrderModel.fromJson(json);

      expect(order.id, equals(''));
    });

    test('TC-OM-07: fromJson com enderecoEntrega e formaPagamento null mantém null', () {
      final json = {
        'id': 'pedido-003',
        'status': 'pendente',
        'total': 20.0,
        'enderecoEntrega': null,
        'formaPagamento': null,
        'itens': [],
      };

      final order = OrderModel.fromJson(json);

      expect(order.enderecoEntrega, isNull);
      expect(order.formaPagamento, isNull);
    });

    test('TC-OM-08: fromJson mapeia corretamente os valores dos itens aninhados', () {
      final json = {
        'id': 'pedido-004',
        'status': 'saiu_para_entrega',
        'total': 98.0,
        'itens': [
          {'nome': 'Pizza', 'valor': 49.0, 'quantidade': 2},
        ],
      };

      final order = OrderModel.fromJson(json);

      expect(order.itens[0].valor, equals(49.0));
      expect(order.itens[0].quantidade, equals(2));
    });
  });
}
