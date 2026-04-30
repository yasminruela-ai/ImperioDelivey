class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String? categoria;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.categoria,
  });

  // Mapeia a resposta do backend (campos em português)
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // imagem pode ser null ou um objeto Cloudinary { url: "..." }
    String imageUrl = '';
    final imagem = json['imagem'];
    if (imagem is Map && imagem['url'] != null) {
      imageUrl = imagem['url'] as String;
    } else if (imagem is String) {
      imageUrl = imagem;
    }

    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['nome'] ?? '',
      description: json['descricao'] ?? '',
      price: (json['valor'] is num)
          ? (json['valor'] as num).toDouble()
          : double.tryParse(json['valor']?.toString() ?? '0') ?? 0,
      image: imageUrl,
      categoria: json['categoria'] as String?,
    );
  }

  // Usado para SharedPreferences (formato local)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'categoria': categoria,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] is num)
          ? (map['price'] as num).toDouble()
          : double.tryParse(map['price']?.toString() ?? '0') ?? 0,
      image: map['image'] ?? '',
      categoria: map['categoria'] as String?,
    );
  }

  // Formato para enviar ao backend (POST /carrinho/item)
  Map<String, dynamic> toBackendMap() {
    return {
      'produtoId': id,
      'nome': name,
      'descricao': description,
      'valor': price,
      'imagem': image,
      'categoria': categoria ?? '',
    };
  }
}
