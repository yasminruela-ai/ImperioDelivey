import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _uidKey = 'auth_uid';

  // serverClientId é o OAuth 2.0 Web Client ID do Firebase Console
  // Encontre em: Firebase Console → Project Settings → General → Web API Key
  // TODO: substitua pelo seu serverClientId real
  static final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // serverClientId: 'SEU_WEB_CLIENT_ID.apps.googleusercontent.com',
  );

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
    await _googleSignIn.signOut();
  }

  // ─── Login ────────────────────────────────────────────────────────────────

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

  // ─── Google Sign-In ───────────────────────────────────────────────────────

  /// Obtém conta Google para o fluxo de cadastro.
  /// Retorna (name, email, idToken) ou null se cancelado/erro.
  static Future<({String name, String email, String idToken})?> getGoogleAccountForRegistration() async {
    try {
      await _googleSignIn.signOut(); // força seleção de conta
      final account = await _googleSignIn.signIn();
      if (account == null) return null;
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) return null;
      return (name: account.displayName ?? '', email: account.email, idToken: idToken);
    } catch (_) {
      return null;
    }
  }

  /// Login com Google — retorna null em sucesso, mensagem de erro caso contrário.
  /// Endpoint esperado: POST $kBaseUrl/auth/google
  /// Body: { idToken: string }
  /// Response: { success: bool, data: { idToken: string, uid: string } }
  static Future<String?> loginWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final account = await _googleSignIn.signIn();
      if (account == null) return 'Login cancelado';

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) return 'Não foi possível obter token do Google';

      final response = await http.post(
        Uri.parse('$kBaseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final token = data['data']['idToken'] as String;
        final uid = data['data']['uid'] as String;
        await _saveSession(token, uid);
        return null;
      }

      return data['message'] ?? 'Erro ao entrar com Google';
    } catch (_) {
      return 'Erro ao conectar com o Google';
    }
  }

  // ─── Register ─────────────────────────────────────────────────────────────

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

  /// Cadastro com Google — retorna null em sucesso, mensagem de erro caso contrário.
  /// Endpoint esperado: POST $kBaseUrl/auth/google-register
  /// Body: { idToken, nome, email, telefone, endereco }
  /// Response: { success: bool, data: { idToken: string, uid: string } }
  static Future<String?> registerWithGoogle({
    required String googleIdToken,
    required String nome,
    required String email,
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
        Uri.parse('$kBaseUrl/auth/google-register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': googleIdToken,
          'nome': nome,
          'email': email,
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

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        if (data['data'] != null) {
          final token = data['data']['idToken'] as String?;
          final uid = data['data']['uid'] as String?;
          if (token != null && uid != null) {
            await _saveSession(token, uid);
          }
        }
        return null;
      }

      return data['message'] ?? 'Erro ao criar conta com Google';
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
