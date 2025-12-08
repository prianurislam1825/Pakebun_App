import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

// Uji publish manual ke broker untuk memastikan path topic benar.
// Jalankan: dart run tool/mqtt_publish_test.dart
// Pastikan sebelumnya jalankan subscriber: dart run tool/mqtt_subscribe.dart

const String BROKER = 'pentarium.id';
const int PORT = 1883;
const String TOPIC =
    'airis/irrigation/08D1F9E050B8/status'; // gunakan topic status agar subscriber menangkap

Future<void> main() async {
  final clientId = 'mqtt_pub_test_${DateTime.now().millisecondsSinceEpoch}';
  final client = MqttServerClient(BROKER, clientId);
  client.logging(on: false);
  client.port = PORT;
  client.keepAlivePeriod = 20;
  client.onConnected = () => print('[PUB] Connected');
  client.onDisconnected = () => print('[PUB] Disconnected');
  client.connectionMessage = MqttConnectMessage()
      .withClientIdentifier(clientId)
      .startClean();

  try {
    print('[PUB] Connecting ...');
    await client.connect();
  } catch (e) {
    print('[PUB][ERR] connect failed: $e');
    return;
  }
  if (client.connectionStatus?.state != MqttConnectionState.connected) {
    print('[PUB][ERR] state: ${client.connectionStatus?.state}');
    return;
  }

  final payload = jsonEncode({
    'id': '08D1F9E050B8',
    'uptime': 999,
    'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    'sys': {'sch': true, 'buzz': false},
    'conn': {'wifi': true, 'rssi': -40, 'mqtt': true, 'sd': true},
    'pumps': {'w': false, 'f': false},
    'sens': {
      'bme280': {'temp': 26.3, 'hum': 70.1, 'press': 922.11},
      'bh1750': {'lux': 120},
    },
    'heap': 150000,
  });

  final builder = MqttClientPayloadBuilder()..addString(payload);
  print('[PUB] Publishing test payload to $TOPIC');
  client.publishMessage(TOPIC, MqttQos.atMostOnce, builder.payload!);
  await Future.delayed(const Duration(seconds: 2));
  client.disconnect();
  print('[PUB] Done');
}
