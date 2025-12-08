import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter/foundation.dart';

class RainDerivedData {
  final double rainToday;
  final double rainLastHour;
  final double rainRate10m;
  final DateTime updatedAt;

  RainDerivedData({
    required this.rainToday,
    required this.rainLastHour,
    required this.rainRate10m,
    required this.updatedAt,
  });
}

/// Optional client for derived rain metrics published by the temporary server.
class RainDerivedService {
  final String broker;
  final int port;
  final String deviceId;
  final String? username;
  final String? password;
  final bool useTls;

  final ValueNotifier<RainDerivedData?> rain = ValueNotifier<RainDerivedData?>(
    null,
  );

  late final MqttServerClient _client;
  bool _connecting = false;

  RainDerivedService({
    required this.broker,
    required this.port,
    required this.deviceId,
    this.username,
    this.password,
    this.useTls = false,
  }) {
    _client = MqttServerClient(broker, 'pakebun-app-rain-derived-$deviceId')
      ..port = port
      ..secure = useTls
      ..keepAlivePeriod = 30
      ..autoReconnect = true
      ..onConnected = () {}
      ..onDisconnected = () {}
      ..setProtocolV311();
  }

  Future<void> connect() async {
    if (_connecting ||
        _client.connectionStatus?.state == MqttConnectionState.connected)
      return;
    _connecting = true;
    try {
      if (username != null && username!.isNotEmpty) {
        _client.connectionMessage = MqttConnectMessage()
            .withClientIdentifier('pakebun-app-rain-derived-$deviceId')
            .authenticateAs(username!, password ?? '')
            .startClean();
      } else {
        _client.connectionMessage = MqttConnectMessage()
            .withClientIdentifier('pakebun-app-rain-derived-$deviceId')
            .startClean();
      }
      await _client.connect();
      final topic = 'aws/$deviceId/rain/derived';
      _client.subscribe(topic, MqttQos.atLeastOnce);
      _client.updates?.listen((events) {
        for (final e in events) {
          final rec = e.payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(
            rec.payload.message,
          );
          try {
            final map = json.decode(payload) as Map<String, dynamic>;
            final data = RainDerivedData(
              rainToday: (map['rain_today'] ?? 0).toDouble(),
              rainLastHour: (map['rain_last_hour'] ?? 0).toDouble(),
              rainRate10m: (map['rain_rate_10m'] ?? 0).toDouble(),
              updatedAt:
                  DateTime.tryParse(map['updated_at']?.toString() ?? '') ??
                  DateTime.now(),
            );
            rain.value = data;
          } catch (_) {
            // ignore parse errors
          }
        }
      });
    } catch (_) {
      // Swallow errors; service is optional
    } finally {
      _connecting = false;
    }
  }

  void disconnect() {
    try {
      _client.disconnect();
    } catch (_) {}
  }
}
