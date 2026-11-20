import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BildirimServisi {
  BildirimServisi._();
  static final BildirimServisi instance = BildirimServisi._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  String? _bekleyenPayload;
  bool _baslatildi = false;

  Future<void> baslat() async {
    if (_baslatildi) return;

    const androidAyarlari = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initAyarlari = InitializationSettings(
      android: androidAyarlari,
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      _bekleyenPayload = launchDetails?.notificationResponse?.payload;
    }

    await _plugin.initialize(
      initAyarlari,
      onDidReceiveNotificationResponse: _bildirimeTiklandi,
    );

    _baslatildi = true;
  }

  void _bildirimeTiklandi(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) {
      _anaEkranaGit();
      return;
    }
    _payloadYonlendir(payload);
  }

  void bekleyenBildirimiIsle() {
    final payload = _bekleyenPayload;
    _bekleyenPayload = null;
    if (payload != null && payload.isNotEmpty) {
      _payloadYonlendir(payload);
    }
  }

  void _payloadYonlendir(String payload) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _bekleyenPayload = payload;
      return;
    }

    switch (payload) {
      case 'ozfit':
        navigator.pushNamed('/ozfit');
        break;
      case 'ozday':
        navigator.pushNamed('/ozday');
        break;
      default:
        _anaEkranaGit();
        break;
    }
  }

  void _anaEkranaGit() {
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  Future<void> bildirimGoster({
    required int id,
    required String baslik,
    required String icerik,
    String payload = 'ozfit',
  }) async {
    const androidDetay = AndroidNotificationDetails(
      'ozcook_hatirlatici_kanali',
      'Ozcook Hatırlatıcılar',
      channelDescription: 'Öğün, kalori ve OzFit hatırlatma bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
    );

    const detaylar = NotificationDetails(android: androidDetay);

    await _plugin.show(
      id,
      baslik,
      icerik,
      detaylar,
      payload: payload,
    );
  }
}