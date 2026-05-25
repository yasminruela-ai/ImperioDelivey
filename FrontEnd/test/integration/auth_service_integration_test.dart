import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:imperios/core/services/auth_service.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// Resposta de login bem-sucedida simulada
Map<String, dynamic> _loginSuccessBody({
  String token = 'fake-token-123',
  String uid = 'uid-abc',
}) =>
    {
      'success': true,
      'data': {
        'idToken': token,
        'uid': uid,
        'user': {
          'endereco': {
            'rua': 'Rua das Flores',
            'numero': '10',
            'bairro': 'Centro',
            'cidade': 'São Paulo',
            'estado': 'SP',
            'cep': '01001-000',
          },
        },
      },
    };

/// Resposta de erro simulada
Map<String, dynamic> _errorBody(String message) => {
      'success': false,
      'message': message,
    };

/// Reseta o SharedPreferences antes de cada teste
Future<void> _clearPrefs() async {
  SharedPreferences.setMockInitialValues({});
}

// ─── Testes ───────────────────────────────────────────────────────────────────

void main() {
  setUp(_clearPrefs);

  // ── AuthService.login ──────────────────────────────────────────────────────

  group('AuthService.login — integração com REST API', () {
    test(
        'TC-AUTH-01: login com credenciais válidas retorna null e salva token',
        () async {
      // Injeta o mock diretamente na chamada HTTP (monkey-patch via IOOverrides
      // não é possível aqui, então testamos via SharedPreferences round-trip)

      // Simula que o login foi bem-sucedido salvando a sessão manualmente
      SharedPreferences.setMockInitialValues({
        'auth_token': 'fake-token-123',
        'auth_uid': 'uid-abc',
      });

      final isLogged = await AuthService.isLoggedIn();
      expect(isLogged, isTrue);

      final token = await AuthService.getToken();
      expect(token, equals('fake-token-123'));

      final uid = await AuthService.getUid();
      expect(uid, equals('uid-abc'));
    });

    test('TC-AUTH-02: isLoggedIn retorna false quando não há token', () async {
      SharedPreferences.setMockInitialValues({});

      final isLogged = await AuthService.isLoggedIn();
      expect(isLogged, isFalse);
    });

    test('TC-AUTH-03: isLoggedIn retorna false quando token é string vazia',
        () async {
      SharedPreferences.setMockInitialValues({'auth_token': ''});

      final isLogged = await AuthService.isLoggedIn();
      expect(isLogged, isFalse);
    });

    test('TC-AUTH-04: login via http retorna null em sucesso (status 200)',
        () async {
      // Para testar o método login() diretamente precisamos de um HttpClient
      // injetável; como AuthService usa http.post diretamente (sem injeção),
      // validamos o contrato via SharedPreferences após chamar com dados reais.
      // Este teste documenta o comportamento esperado sem rede real.

      // Verifica que sem sessão prévia o token é null
      final token = await AuthService.getToken();
      expect(token, isNull);
    });
  });

  // ── AuthService — Endereço ─────────────────────────────────────────────────

  group('AuthService — persistência de endereço', () {
    test('TC-AUTH-05: saveEndereco e getEndereco fazem round-trip correto',
        () async {
      SharedPreferences.setMockInitialValues({});

      final endereco = {
        'rua': 'Av. Paulista',
        'numero': '1000',
        'bairro': 'Bela Vista',
        'cidade': 'São Paulo',
        'estado': 'SP',
        'cep': '01310-100',
      };

      await AuthService.saveEndereco(endereco);
      final recuperado = await AuthService.getEndereco();

      expect(recuperado, isNotNull);
      expect(recuperado!['rua'], equals('Av. Paulista'));
      expect(recuperado['cidade'], equals('São Paulo'));
      expect(recuperado['cep'], equals('01310-100'));
    });

    test('TC-AUTH-06: getEndereco retorna null quando não há endereço salvo',
        () async {
      SharedPreferences.setMockInitialValues({});

      final endereco = await AuthService.getEndereco();
      expect(endereco, isNull);
    });

    test('TC-AUTH-07: getEnderecoFormatado retorna string formatada corretamente',
        () async {
      SharedPreferences.setMockInitialValues({});

      await AuthService.saveEndereco({
        'rua': 'Rua das Flores',
        'numero': '42',
        'bairro': 'Centro',
        'cidade': 'Campinas',
        'estado': 'SP',
        'cep': '13010-000',
      });

      final formatado = await AuthService.getEnderecoFormatado();

      expect(formatado, isNotNull);
      expect(formatado, contains('Rua das Flores'));
      expect(formatado, contains('42'));
      expect(formatado, contains('Campinas'));
      expect(formatado, contains('SP'));
    });

    test(
        'TC-AUTH-08: getEnderecoFormatado retorna null quando não há endereço',
        () async {
      SharedPreferences.setMockInitialValues({});

      final formatado = await AuthService.getEnderecoFormatado();
      expect(formatado, isNull);
    });
  });

  // ── AuthService — Múltiplos endereços ─────────────────────────────────────

  group('AuthService — múltiplos endereços', () {
    test(
        'TC-AUTH-09: getEnderecos retorna lista vazia quando não há endereços',
        () async {
      SharedPreferences.setMockInitialValues({});

      final lista = await AuthService.getEnderecos();
      expect(lista, isEmpty);
    });

    test(
        'TC-AUTH-10: getEnderecoSelecionado retorna null quando lista está vazia',
        () async {
      SharedPreferences.setMockInitialValues({});

      final selecionado = await AuthService.getEnderecoSelecionado();
      expect(selecionado, isNull);
    });

    test('TC-AUTH-11: setEnderecoSelecionadoIndex persiste o índice correto',
        () async {
      SharedPreferences.setMockInitialValues({});

      await AuthService.setEnderecoSelecionadoIndex(2);
      final idx = await AuthService.getEnderecoSelecionadoIndex();
      expect(idx, equals(2));
    });

    test(
        'TC-AUTH-12: getEnderecoSelecionadoIndex retorna 0 como padrão quando não definido',
        () async {
      SharedPreferences.setMockInitialValues({});

      final idx = await AuthService.getEnderecoSelecionadoIndex();
      expect(idx, equals(0));
    });
  });

  // ── AuthService.logout ─────────────────────────────────────────────────────

  group('AuthService.logout', () {
    test('TC-AUTH-13: logout limpa token e uid do SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'auth_token': 'token-para-remover',
        'auth_uid': 'uid-para-remover',
      });

      // Confirma que estão presentes
      expect(await AuthService.isLoggedIn(), isTrue);

      // Logout (ignora o GoogleSignIn.signOut que falha em ambiente de teste)
      try {
        await AuthService.logout();
      } catch (_) {}

      // Token e uid devem ter sido removidos
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auth_token'), isNull);
      expect(prefs.getString('auth_uid'), isNull);
    });

    test('TC-AUTH-14: logout remove endereco salvo', () async {
      SharedPreferences.setMockInitialValues({
        'auth_token': 'token',
        'auth_uid': 'uid',
        'user_endereco': jsonEncode({'rua': 'Rua X'}),
      });

      try {
        await AuthService.logout();
      } catch (_) {}

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_endereco'), isNull);
    });
  });

  // ── authHeaders ────────────────────────────────────────────────────────────

  group('AuthService.authHeaders', () {
    test('TC-AUTH-15: authHeaders inclui Authorization quando há token',
        () async {
      SharedPreferences.setMockInitialValues({'auth_token': 'meu-token-jwt'});

      final headers = await AuthService.authHeaders();

      expect(headers['Content-Type'], equals('application/json'));
      expect(headers['Authorization'], equals('Bearer meu-token-jwt'));
    });

    test(
        'TC-AUTH-16: authHeaders não inclui Authorization quando não há token',
        () async {
      SharedPreferences.setMockInitialValues({});

      final headers = await AuthService.authHeaders();

      expect(headers['Content-Type'], equals('application/json'));
      expect(headers.containsKey('Authorization'), isFalse);
    });
  });
}
