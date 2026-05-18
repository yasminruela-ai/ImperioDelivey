class OrderModel {
  final String id;
  final String status;
  final double total;
  final String? enderecoEntrega;
  final String? formaPagamento;
  final List<OrderItemModel> itens;

  const OrderModel({
    required this.id,
    required this.status,
    required this.total,
    this.enderecoEntrega,
    this.formaPagamento,
    this.itens = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'pendente',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      enderecoEntrega: json['enderecoEntrega'] as String?,
      formaPagamento: json['formaPagamento'] as String?,
      itens: (json['itens'] as List<dynamic>? ?? [])
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OrderItemModel {
  final String nome;
  final double valor;
  final int quantidade;

  const OrderItemModel({
    required this.nome,
    required this.valor,
    required this.quantidade,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      nome: json['nome'] as String? ?? '',
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      quantidade: (json['quantidade'] as num?)?.toInt() ?? 1,
    );
  }
}
