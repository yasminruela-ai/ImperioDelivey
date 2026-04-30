import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../modules/home/models/product_model.dart';
import '../constants.dart';

class ProductService {
  static Future<List<ProductModel>> getAll() async {
    final response = await http.get(Uri.parse('$kBaseUrl/produto'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'] as List;
      return list.map((e) => ProductModel.fromJson(e)).toList();
    }

    throw Exception('Falha ao carregar produtos');
  }
}
