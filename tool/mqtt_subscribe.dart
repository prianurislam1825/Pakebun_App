import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

/// Jalankan dengan perintah (mode debug, berhenti setelah 1 pesan atau timeout 20 detik):
///   dart run tool/mqtt_subscribe.dart
/// atau (jika pakai flutter SDK):
///   flutter pub run tool/mqtt_subscribe.dart
///
/// Ubah konstanta TOPIC / BROKER bila diperlukan.

const String BROKER = 'pentarium.id';
const int PORT = 1883;
const List<String> TOPICS = [
  // Uppercase device id
  'airis/irrigation/08D1F9E050B8/status',
  // Lowercase device id
  'airis/irrigation/08d1f9e050b8/status',
  // Wildcard (any device)
  'airis/irrigation/+/status',
];
// Continuous listen (device kirim tiap ~30s). Stop manual: CTRL+C.

Future<int> main() async {
  final clientId = 'mqtt_sub_test_${DateTime.now().millisecondsSinceEpoch}';
  final client = MqttServerClient(BROKER, clientId);
  client.logging(on: false);
  client.port = PORT;
  client.keepAlivePeriod = 30;
  client.secure = false;
  client.onConnected = () => print('[OK] Connected to $BROKER:$PORT');
  client.onDisconnected = () => print('[!] Disconnected');

  client.connectionMessage = MqttConnectMessage()
      .withClientIdentifier(clientId)
      .startClean();

  print('[*] Connecting ...');
  try {
    await client.connect();
  } catch (e) {
    print('[ERR] Connect failed: $e');
    return 1;
  }

  if (client.connectionStatus?.state != MqttConnectionState.connected) {
    print('[ERR] Connection status: ${client.connectionStatus?.state}');
    return 2;
  }

  for (final t in TOPICS) {
    print('[*] Subscribing topic: $t');
    client.subscribe(t, MqttQos.atMostOnce);
  }

  print('[*] Listening (continuous)... CTRL+C untuk berhenti.');
  client.updates?.listen((events) {
    for (final ev in events) {
      final msg = ev.payload;
      if (msg is! MqttPublishMessage) continue;
      final payload = MqttPublishPayload.bytesToStringAsString(
        msg.payload.message,
      );
      final ts = DateTime.now().toIso8601String();
      print('\n[$ts] Topic: ${ev.topic}');
      print(payload);
      try {
        final map = jsonDecode(payload);
        if (map is Map<String, dynamic>) {
          final uptime = map['uptime'];
          final pumps = map['pumps'];
          final sens = map['sens'] as Map<String, dynamic>?;
          final bme = sens?['bme280'];
          final light = sens?['bh1750'];
          print('[INFO] uptime=$uptime pumps=$pumps bme280=$bme bh1750=$light');
        }
      } catch (_) {}
    }
  });
  // Keep process alive (never completes). Tekan CTRL+C untuk keluar.
  await Future<void>.delayed(const Duration(days: 365 * 10));
  return 0; // practically unreachable
}
