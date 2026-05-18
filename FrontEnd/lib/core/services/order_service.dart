import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'auth_service.dart';
import '../../modules/checkout/models/order_model.dart';

class OrderService {
  static Future<({String? orderId, String? error})> finalizarPedido({
    String? enderecoEntrega,
    String? formaPagamento,
    String? observacao,
  }) async {
    try {
      final headers = await AuthService.authHeaders();
      final response = await http.post(
        Uri.parse('$kBaseUrl/pedido'),
        headers: headers,
        body: jsonEncode({
          if (enderecoEntrega case final v?) 'enderecoEntrega': v,
          if (formaPagamento case final v?) 'formaPagamento': v,
          if (observacao case final v?) 'observacao': v,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && data['success'] == true) {
        final id = (data['data'] as Map<String, dynamic>)['id'] as String;
        return (orderId: id, error: null);
      }

      return (orderId: null, error: data['message'] as String? ?? 'Erro ao finalizar pedido');
    } catch (_) {
      return (orderId: null, error: 'Erro de conexão com o servidor');
    }
  }

  static Future<OrderModel?> getOrder(String id) async {
    try {
      final headers = await AuthService.authHeaders();
      final response = await http.get(
        Uri.parse('$kBaseUrl/pedido/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return OrderModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
