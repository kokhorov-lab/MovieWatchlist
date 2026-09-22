import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/productModel.dart';

class Apiservice {
  static const String baseUrl = 'http://localhost:3000';

  static Future<List<Product>> fetchProduct() async {
    final response = await http.get(Uri.parse('$baseUrl/api/products'));

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic items) => Product.fromJson(items)).toList();
    } else {
      throw Exception('Failed to load product from server');
    }
  }
}
