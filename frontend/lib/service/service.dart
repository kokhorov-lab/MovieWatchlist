import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/model/movie_model.dart';
import 'package:frontend/model/user_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000';
  final _storage = FlutterSecureStorage();

  Future<void> saveSession(
    String token,
    String userId,
    String name,
    String email,
  ) async {
    await _storage.write(key: 'jwt_token', value: token);
    await _storage.write(key: 'user_id', value: userId);
    await _storage.write(key: 'user_name', value: name);
    await _storage.write(key: 'user_email', value: email);
  }

  Future<List<Movie>> fetchMovie() async {
    final response = await http.get(Uri.parse('$baseUrl/movies/'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);

      final List<dynamic> jsonList = body['data'];

      return jsonList.map((items) => Movie.fromJson(items)).toList();
    } else {
      throw Exception('failed to load Movies');
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode != 201) {
      throw Exception(body['error'] ?? 'Signup failed');
    }
  }

  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final body = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final token = body['data']['token'];
      final userData = body['data']['user'];

      final user = User.fromJson(userData);

      await saveSession(token, user.id.toString(), user.name, email);

      return user;
    } else {
      throw Exception('failed to login Invalid email or password');
    }
  }

  Future<User?> getCurrentUser() async {
    final id = await _storage.read(key: 'user_id');
    final name = await _storage.read(key: 'user_name');
    final email = await _storage.read(key: 'user_email');

    if (id != null && name != null && email != null) {
      return User(id: id, name: name, email: email);
    }

    return null;
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();

    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<void> addToWatchList(String movieId) async {
    final token = await getToken();
    final userId = await getUserId();

    if (token == null || userId == null) {
      throw Exception('User not logged in');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/watchlist/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'movieId': movieId,
        'userId': userId,
        'status': 'PLANNED',
      }),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(
        body['error'] ?? body['message'] ?? 'Failed to add to watchlist',
      );
    }
  }

  Future<List<Movie>> fetchWatchlist() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/watchlist/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((item) => Movie.fromJson(item)).toList();
    } else {
      throw Exception('failed to load watchlist');
    }
  }
}
