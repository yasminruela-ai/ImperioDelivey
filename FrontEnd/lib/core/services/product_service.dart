import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../modules/home/models/product_model.dart';
import '../constants.dart';

class ProductService {
  static Future<List<ProductModel>> getAll({http.Client? client}) async {
  final c = client ?? http.Client();
  final response = await c.get(Uri.parse('$kBaseUrl/produto'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'] as List;
      return list.map((e) => ProductModel.fromJson(e)).toList();
    }

    throw Exception('Falha ao carregar produtos');
  }
}
