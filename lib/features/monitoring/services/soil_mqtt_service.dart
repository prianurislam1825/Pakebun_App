import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class SoilData {
  final double? cond; // EC/conductivity (renamed from 'ec')
  final double? n;
  final double? p;
  final double? k;
  final double? ph;
  final double? hum; // Humidity (new field from format baru)
  final double? temp;
  final DateTime receivedAt;

  SoilData({
    required this.receivedAt,
    this.cond,
    this.n,
    this.p,
    this.k,
    this.ph,
    this.hum,
    this.temp,
  });
}

class SoilMqttService {
  final ValueNotifier<SoilData?> soil = ValueNotifier(null);
  final ValueNotifier<bool> connected = ValueNotifier(false);

  final String broker;
  final int port;
  final String? username;
  final String? password;
  final String? deviceId; // if provided, will subscribe only to this device

  MqttServerClient? _client;
  StreamSubscription? _sub;

  SoilMqttService({
    this.broker = 'pentarium.id',
    this.port = 1883,
    this.username = 'penta',
    this.password = 'penta123',
    this.deviceId,
  });

  Future<void> connect({String? clientId}) async {
    _client = MqttServerClient(
      broker,
      clientId ?? 'pakebun_soil_${DateTime.now().millisecondsSinceEpoch}',
    );
    _client!.port = port;
    _client!.logging(on: false);
    _client!.keepAlivePeriod = 20;
    _client!.autoReconnect = true;
    _client!.onConnected = () {
      debugPrint('[SoilMQTT] Connected to $broker:$port');
      connected.value = true;
    };
    _client!.onDisconnected = () {
      debugPrint('[SoilMQTT] Disconnected from $broker:$port');
      connected.value = false;
    };

    final connMess = MqttConnectMessage()
        .withClientIdentifier(_client!.clientIdentifier)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    _client!.connectionMessage = connMess;

    try {
      debugPrint('[SoilMQTT] Connecting to $broker:$port ...');
      await _client!.connect(username, password);
      connected.value =
          _client!.connectionStatus?.state == MqttConnectionState.connected;

      _sub = _client!.updates?.listen(_onMessage);

      final topic = deviceId != null ? 'airis/$deviceId/soil' : 'airis/+/soil';
      debugPrint('[SoilMQTT] Subscribing to $topic with deviceId: $deviceId');
      final subscription = _client!.subscribe(topic, MqttQos.atMostOnce);
      debugPrint('[SoilMQTT] Subscription result: ${subscription?.toString()}');
    } catch (e) {
      debugPrint('[SoilMQTT] Connect error: $e');
      connected.value = false;
      _client?.disconnect();
      rethrow;
    }
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>>? messages) {
    if (messages == null) {
      debugPrint('[SoilMQTT] No messages received');
      return;
    }
    debugPrint('[SoilMQTT] Processing ${messages.length} messages');
    for (final msg in messages) {
      final payload = (msg.payload as MqttPublishMessage).payload.message;
      final str = utf8.decode(payload);
      debugPrint('[SoilMQTT] Message on ${msg.topic}: $str');
      try {
        final Map<String, dynamic> data =
            json.decode(str) as Map<String, dynamic>;
        debugPrint('[SoilMQTT] Parsed JSON: $data');

        // Format baru: data langsung di root level "soil"
        final soilMap = data['soil'] as Map<String, dynamic>?;
        debugPrint('[SoilMQTT] Soil map: $soilMap');

        if (soilMap == null) {
          debugPrint('[SoilMQTT] No soil data found in message');
          continue;
        }

        final now = DateTime.now();
        final parsed = SoilData(
          receivedAt: now,
          cond: _toDouble(soilMap['cond']), // conductivity/EC
          n: _toDouble(soilMap['n']),
          p: _toDouble(soilMap['p']),
          k: _toDouble(soilMap['k']),
          ph: _toDouble(soilMap['ph']),
          hum: _toDouble(soilMap['hum']), // humidity baru
          temp: _toDouble(soilMap['temp']),
        );
        debugPrint(
          '[SoilMQTT] Parsed soil data: hum=${parsed.hum}, temp=${parsed.temp}, ph=${parsed.ph}, cond=${parsed.cond}',
        );
        soil.value = parsed;
      } catch (e) {
        debugPrint('[SoilMQTT] Error parsing message: $e');
      }
    }
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    final s = v.toString();
    return double.tryParse(s);
  }

  Future<void> disconnect() async {
    await _sub?.cancel();
    _client?.disconnect();
    connected.value = false;
  }

  // Publish pump command to device
  // Topic: airis/api/<deviceId>/pump/POST
  // Payload example: {"type":"water","action":"on","duration":60}
  Future<bool> publishPumpCommand({
    String? deviceId,
    required String type,
    required String action,
    int? duration,
  }) async {
    final id = (deviceId ?? this.deviceId)?.toLowerCase();
    if (id == null || id.isEmpty) return false;
    // Ensure client is connected
    if (_client == null ||
        _client!.connectionStatus?.state != MqttConnectionState.connected) {
      try {
        await connect();
      } catch (_) {
        return false;
      }
    }
    final topic = 'airis/api/$id/pump/POST';
    final payload = <String, dynamic>{
      'type': type,
      'action': action,
      if (duration != null) 'duration': duration,
    };
    final jsonStr = json.encode(payload);
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(jsonStr);
    try {
      _client!.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
      return true;
    } catch (_) {
      return false;
    }
  }
}
