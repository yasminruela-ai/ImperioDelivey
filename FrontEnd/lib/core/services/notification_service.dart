import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'auth_service.dart';
import '../../modules/checkout/order_success_page.dart';

// Handler executado quando o app está fechado/background — deve ser top-level
@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {}

final _localNotifications = FlutterLocalNotificationsPlugin();

const _channel = AndroidNotificationChannel(
  'imperios_orders',
  'Pedidos',
  description: 'Notificações sobre o andamento do seu pedido',
  importance: Importance.high,
);

class NotificationService {
  static final _fcm = FirebaseMessaging.instance;

  static Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // Cria o canal de notificação no Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (details) {
        _handlePayload(details.payload, navigatorKey);
      },
    );

    // Solicita permissão (obrigatório no Android 13+)
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // Mensagem recebida com app em foreground → exibe local notification
    FirebaseMessaging.onMessage.listen((message) {
      _showLocal(message);
    });

    // Usuário tocou na notificação com app em background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _navigate(message.data['pedidoId'] as String?, navigatorKey);
    });

    // Usuário tocou na notificação com app terminado
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      _navigate(initial.data['pedidoId'] as String?, navigatorKey);
    }
  }

  // Chame após login ou ao iniciar já logado
  static Future<void> registerToken() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (!loggedIn) return;

    final token = await _fcm.getToken();
    if (token != null) await _saveToken(token);

    _fcm.onTokenRefresh.listen(_saveToken);
  }

  static Future<void> _saveToken(String token) async {
    try {
      final headers = await AuthService.authHeaders();
      await http.post(
        Uri.parse('$kBaseUrl/user/fcm-token'),
        headers: headers,
        body: jsonEncode({'fcmToken': token}),
      );
    } catch (_) {}
  }

  static void _showLocal(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;

    _localNotifications.show(
      n.hashCode,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  static void _handlePayload(
      String? payload, GlobalKey<NavigatorState> navigatorKey) {
    if (payload == null) return;
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      _navigate(data['pedidoId'] as String?, navigatorKey);
    } catch (_) {}
  }

  static void _navigate(
      String? pedidoId, GlobalKey<NavigatorState> navigatorKey) {
    if (pedidoId == null) return;
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => OrderSuccessPage(orderId: pedidoId),
      ),
    );
  }
}
