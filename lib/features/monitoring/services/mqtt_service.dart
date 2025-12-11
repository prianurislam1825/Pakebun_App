import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class EnvData {
  final double? temp;
  final double? hum;
  final double? pressure;
  final DateTime receivedAt;

  EnvData({required this.receivedAt, this.temp, this.hum, this.pressure});
}

class AwsData {
  final double? temp;
  final double? hum;
  final double? dewPoint;
  final double? windSpeed;
  final double? gust;
  final double? rain;
  // Legacy derived fields (kept for backward-compat parsing)
  final double? rainToday; // deprecated: now use rainLastWeek
  final double? rainLastHour; // deprecated: now use rainLastDay
  final double? rainRate10m; // deprecated: now use rainRate1h
  // New derived fields
  final double? rainLastDay;
  final double? rainLastWeek;
  final double? rainLastMonth;
  final double? rainRate1h;
  final double? uv;
  final double? light;
  final double? pressure;
  final String? windDir;
  final DateTime receivedAt;

  AwsData({
    required this.receivedAt,
    this.temp,
    this.hum,
    this.dewPoint,
    this.windSpeed,
    this.gust,
    this.rain,
    this.rainToday,
    this.rainLastHour,
    this.rainRate10m,
    this.rainLastDay,
    this.rainLastWeek,
    this.rainLastMonth,
    this.rainRate1h,
    this.uv,
    this.light,
    this.pressure,
    this.windDir,
  });
}

class MqttService {
  // Public notifiers for the UI to listen to
  final ValueNotifier<EnvData?> env = ValueNotifier(null);
  final ValueNotifier<AwsData?> aws = ValueNotifier(null);
  final ValueNotifier<bool> connected = ValueNotifier(false);

  MqttServerClient? _client;
  StreamSubscription? _sub;

  // Default broker — override when calling connect
  final String broker;
  final int port;
  final String username;
  final String password;

  MqttService({
    this.broker = 'pentarium.id',
    this.port = 1883,
    this.username = 'penta',
    this.password = 'penta123',
  });

  Future<void> connect({String? clientId}) async {
    _client = MqttServerClient(
      broker,
      clientId ?? 'pakebun_app_${DateTime.now().millisecondsSinceEpoch}',
    );
    _client!.port = port;
    _client!.logging(on: false);
    _client!.keepAlivePeriod = 20;
    _client!.autoReconnect = true;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(_client!.clientIdentifier)
        .authenticateAs(username, password)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    _client!.connectionMessage = connMess;

    try {
      await _client!.connect();
      connected.value =
          _client!.connectionStatus?.state == MqttConnectionState.connected;

      _sub = _client!.updates?.listen(_onMessage);

      // subscribe to bme (sensor lingkungan) and aws (weather station) topics
      _client!.subscribe('airis/+/bme', MqttQos.atMostOnce);
      _client!.subscribe('airis/+/aws', MqttQos.atMostOnce);
    } catch (e) {
      connected.value = false;
      _client?.disconnect();
      rethrow;
    }
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>>? messages) {
    if (messages == null) return;
    for (final msg in messages) {
      final topic = msg.topic;
      final payload = (msg.payload as MqttPublishMessage).payload.message;
      final str = utf8.decode(payload);
      try {
        final Map<String, dynamic> data =
            json.decode(str) as Map<String, dynamic>;
        final now = DateTime.now();
        if (topic.contains('/bme')) {
          // Format baru: {"id":"F0F06D9FE8","bme":{"temp":25.27,"hum":92.45,"pres":922.92}}
          final bmeMap = data['bme'] as Map<String, dynamic>?;
          if (bmeMap != null) {
            final parsed = EnvData(
              receivedAt: now,
              temp: _toDouble(bmeMap['temp']),
              hum: _toDouble(bmeMap['hum']),
              pressure: _toDouble(bmeMap['pres']),
            );
            env.value = parsed;
          }
        } else if (topic.contains('/aws')) {
          final src =
              data.containsKey('aws') && data['aws'] is Map<String, dynamic>
              ? (data['aws'] as Map<String, dynamic>)
              : data;
          final parsed = AwsData(
            receivedAt: now,
            temp: _toDouble(src['temp']),
            hum: _toDouble(src['hum']),
            dewPoint: _toDouble(src['dewPoint']),
            windSpeed: _toDouble(src['windSpeed']),
            gust: _toDouble(src['gust']),
            rain: _toDouble(src['rain']),
            rainToday: _toDouble(src['rain_today'] ?? src['rainToday']),
            rainLastHour: _toDouble(
              src['rain_last_hour'] ?? src['rainLastHour'],
            ),
            rainRate10m: _toDouble(src['rain_rate_10m'] ?? src['rainRate10m']),
            // New fields
            rainLastDay: _toDouble(src['rain_last_day'] ?? src['rainLastDay']),
            rainLastWeek: _toDouble(
              src['rain_last_week'] ?? src['rainLastWeek'],
            ),
            rainLastMonth: _toDouble(
              src['rain_last_month'] ?? src['rainLastMonth'],
            ),
            rainRate1h: _toDouble(src['rain_rate_1h'] ?? src['rainRate1h']),
            uv: _toDouble(src['uv']),
            light: _toDouble(src['light']),
            pressure: _toDouble(src['pressure']),
            windDir: src['windDir']?.toString(),
          );
          aws.value = parsed;
        }
      } catch (e) {
        // ignore malformed messages
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

  // Request last BME280 data from InfluxDB via Node-RED
  Future<void> requestLastBmeData(String deviceId) async {
    if (_client == null ||
        _client!.connectionStatus?.state != MqttConnectionState.connected) {
      debugPrint('[MQTT] Cannot request BME: not connected');
      return;
    }

    final topic = 'airis/$deviceId/request/bme';
    final builder = MqttClientPayloadBuilder();
    builder.addString('{}');

    try {
      _client!.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
      debugPrint('[MQTT] 📤 Request last BME data sent to: $topic');
    } catch (e) {
      debugPrint('[MQTT] ❌ Failed to send BME request: $e');
    }
  }

  // Request last AWS weather data from InfluxDB via Node-RED
  Future<void> requestLastAwsData(String deviceId) async {
    if (_client == null ||
        _client!.connectionStatus?.state != MqttConnectionState.connected) {
      debugPrint('[MQTT] Cannot request AWS: not connected');
      return;
    }

    final topic = 'airis/$deviceId/request/aws';
    final builder = MqttClientPayloadBuilder();
    builder.addString('{}');

    try {
      _client!.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
      debugPrint('[MQTT] 📤 Request last AWS data sent to: $topic');
    } catch (e) {
      debugPrint('[MQTT] ❌ Failed to send AWS request: $e');
    }
  }
}
