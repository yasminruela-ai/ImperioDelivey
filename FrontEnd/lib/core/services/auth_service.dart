import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _uidKey = 'auth_uid';

  // ─── Token ───────────────────────────────────────────────────────────────

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_uidKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> _saveSession(String token, String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_uidKey, uid);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_uidKey);
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  /// Retorna null em caso de sucesso, ou a mensagem de erro.
  static Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$kBaseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final token = data['data']['idToken'] as String;
        final uid = data['data']['uid'] as String;
        await _saveSession(token, uid);
        return null;
      }

      return data['message'] ?? 'Erro ao fazer login';
    } catch (e) {
      return 'Erro de conexão com o servidor';
    }
  }

  // ─── Register ─────────────────────────────────────────────────────────────

  /// Retorna null em caso de sucesso, ou a mensagem de erro.
  static Future<String?> register({
    required String nome,
    required String email,
    required String password,
    required String telefone,
    required String rua,
    required String numero,
    required String bairro,
    required String cidade,
    required String estado,
    required String cep,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$kBaseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nome,
          'email': email,
          'password': password,
          'telefone': telefone,
          'endereco': {
            'pais': 'Brasil',
            'estado': estado,
            'cidade': cidade,
            'bairro': bairro,
            'rua': rua,
            'numero': numero,
            'cep': cep,
          },
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return null;
      }

      return data['message'] ?? 'Erro ao criar conta';
    } catch (e) {
      return 'Erro de conexão com o servidor';
    }
  }

  // ─── Headers autenticados ─────────────────────────────────────────────────

  static Future<Map<String, String>> authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
