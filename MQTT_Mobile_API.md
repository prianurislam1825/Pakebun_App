# Airis Irrigation System - MQTT API for Mobile Applications

## Overview
This documentation is specifically designed for AI assistants in mobile applications to understand and interact with the Airis Irrigation System via MQTT protocol. The system uses MAC address-based unique device identification for reliable communication.

## Quick Reference for AI Integration

### Device Identification
- **Device ID Format**: MAC address in uppercase without separators (e.g., "08D1F9E050B8")
- **Base Topic Structure**: `airis/{device_id}/`
- **Example Topic**: `airis/08D1F9E050B8/status`

### Core Communication Pattern
1. **Subscribe** to device status: `airis/{device_id}/status`
2. **Send commands** to: `airis/{device_id}/cmd`
3. **Monitor events** at: `airis/{device_id}/events`

---

## MQTT Topics Reference

### 1. Device Status Topic (Subscribe)
**Topic**: `airis/{device_id}/status`
**Frequency**: Every 30 seconds (configurable)
**Purpose**: Real-time system monitoring

**Message Format**:
```json
{
  "id": "08D1F9E050B8",
  "uptime": 3250,
  "ts": 1759311591,
  "sys": {
    "sch": true,
    "buzz": true
  },
  "conn": {
    "wifi": true,
    "rssi": -71,
    "mqtt": true,
    "sd": true
  },
  "pumps": {
    "w": false,
    "f": false
  },
  "sens": {
    "temp": 25.5,
    "hum": 65.2,
    "soil": 45.8
  },
  "heap": 156728
}
```

**Field Explanations**:
- `id`: Device MAC address (unique identifier)
- `uptime`: System uptime in seconds
- `ts`: Unix timestamp
- `sys.sch`: Scheduling system enabled
- `sys.buzz`: Buzzer enabled
- `conn.wifi`: WiFi connection status
- `conn.rssi`: WiFi signal strength (dBm)
- `conn.mqtt`: MQTT connection status
- `conn.sd`: SD card status
- `pumps.w`: Water pump active status
- `pumps.f`: Fertilizer pump active status
- `sens.temp`: Temperature (°C)
- `sens.hum`: Humidity (%)
- `sens.soil`: Soil moisture (%)
- `heap`: Free memory (bytes)

### 2. Command Topic (Publish)
**Topic**: `airis/{device_id}/cmd`
**Purpose**: Send control commands to device

#### Pump Control Commands

**Start Water Pump**:
```json
{
  "cmd": "pump",
  "pump": "water",
  "action": "on",
  "duration": 60
}
```

**Start Fertilizer Pump**:
```json
{
  "cmd": "pump",
  "pump": "fertilizer", 
  "action": "on",
  "duration": 30
}
```

**Start Both Pumps**:
```json
{
  "cmd": "pump",
  "pump": "both",
  "action": "on",
  "water_duration": 120,
  "fertilizer_duration": 45
}
```

**Stop Specific Pump**:
```json
{
  "cmd": "pump",
  "pump": "water",
  "action": "off"
}
```

**Stop All Pumps**:
```json
{
  "cmd": "pump",
  "action": "stop_all"
}
```

#### System Commands

**Restart Device**:
```json
{
  "cmd": "system",
  "action": "restart"
}
```

**Reset WiFi Settings**:
```json
{
  "cmd": "system",
  "action": "reset_wifi"
}
```

**Update Configuration**:
```json
{
  "cmd": "config",
  "settings": {
    "mqtt_interval": 60,
    "sensor_interval": 30
  }
}
```

**Sync Time**:
```json
{
  "cmd": "time_sync",
  "timestamp": 1759311591
}
```

### 3. Events Topic (Subscribe)
**Topic**: `airis/{device_id}/events`
**Purpose**: Receive real-time notifications

**Pump State Change Event**:
```json
{
  "event": "pump_state",
  "pump": "water",
  "state": "on",
  "duration": 60,
  "trigger": "mqtt",
  "timestamp": 1759311591
}
```

**Sensor Alert Event**:
```json
{
  "event": "sensor_alert",
  "sensor": "soil_moisture",
  "value": 15.2,
  "threshold": 30.0,
  "severity": "warning",
  "timestamp": 1759311591
}
```

**System Event**:
```json
{
  "event": "system",
  "type": "wifi_connected",
  "details": {
    "ssid": "MyNetwork",
    "ip": "192.168.1.100"
  },
  "timestamp": 1759311591
}
```

---

## AI Assistant Command Patterns

### For Natural Language Processing

#### Irrigation Commands
- **"Turn on water pump for 2 minutes"** → 
  ```json
  {"cmd": "pump", "pump": "water", "action": "on", "duration": 120}
  ```

- **"Start irrigation for 5 minutes"** → 
  ```json
  {"cmd": "pump", "pump": "both", "action": "on", "water_duration": 300, "fertilizer_duration": 60}
  ```

- **"Stop all pumps"** → 
  ```json
  {"cmd": "pump", "action": "stop_all"}
  ```

#### Status Queries
- **"What's the current soil moisture?"** → Check latest `sens.soil` from status topic
- **"Is the water pump running?"** → Check `pumps.w` from status topic  
- **"Show me system status"** → Parse latest status message

#### System Control
- **"Restart the irrigation system"** → 
  ```json
  {"cmd": "system", "action": "restart"}
  ```

### Response Templates for AI

#### Success Responses
```
✅ Water pump started for {duration} seconds
✅ Fertilizer pump activated for {duration} seconds  
✅ Both pumps started (Water: {water_duration}s, Fertilizer: {fertilizer_duration}s)
✅ All pumps stopped
✅ System restart initiated
```

#### Status Responses
```
🌱 Soil Moisture: {soil}%
🌡️ Temperature: {temp}°C
💧 Humidity: {hum}%
⚡ WiFi Signal: {rssi}dBm
💾 Free Memory: {heap} bytes
🔄 Uptime: {uptime} seconds

Pump Status:
💧 Water Pump: {w ? "ON" : "OFF"}
🧪 Fertilizer Pump: {f ? "ON" : "OFF"}
```

#### Error Responses
```
❌ Device not connected
❌ Invalid pump duration (max: 300 seconds)
❌ Pump already running
❌ System busy, try again
```

---

## Connection Setup for Mobile Apps

### MQTT Broker Configuration
```javascript
const mqttConfig = {
  host: 'your-mqtt-broker.com',
  port: 1883,
  username: 'your-username',
  password: 'your-password',
  clientId: `mobile_app_${Math.random().toString(16).substr(2, 8)}`,
  keepalive: 60,
  reconnectPeriod: 1000
}
```

### Topic Subscription Pattern
```javascript
const deviceId = "08D1F9E050B8"; // Get from device discovery
const topics = {
  status: `airis/${deviceId}/status`,
  events: `airis/${deviceId}/events`,
  command: `airis/${deviceId}/cmd`
};

// Subscribe to device updates
client.subscribe(topics.status);
client.subscribe(topics.events);
```

### Command Publishing Template
```javascript
function sendCommand(deviceId, command) {
  const topic = `airis/${deviceId}/cmd`;
  const message = JSON.stringify(command);
  client.publish(topic, message, { qos: 1 });
}

// Example usage
sendCommand("08D1F9E050B8", {
  cmd: "pump",
  pump: "water", 
  action: "on",
  duration: 120
});
```

---

## Real-time Features

### Immediate Pump Status Updates
When pump state changes occur (manual, scheduled, or MQTT triggered), the device immediately publishes:

1. **Status Update** - Full status with updated pump states
2. **Event Notification** - Specific pump change event
3. **Duration Countdown** - Real-time remaining time updates

### Sensor Monitoring
- Temperature, humidity, and soil moisture readings every 30-60 seconds
- Automatic alerts when values exceed configured thresholds
- Historical data logging for trend analysis

### Connection Monitoring
- WiFi signal strength monitoring
- MQTT connection status
- Automatic reconnection handling
- Device availability tracking

---

## Error Handling

### Command Validation
The device validates all incoming commands and responds with:

**Successful Command**:
```json
{
  "event": "command_ack",
  "cmd": "pump",
  "status": "success", 
  "message": "Water pump started for 60 seconds"
}
```

**Failed Command**:
```json
{
  "event": "command_error",
  "cmd": "pump",
  "status": "error",
  "error": "pump_already_running",
  "message": "Water pump is already active"
}
```

### Common Error Codes
- `invalid_command` - Unknown command type
- `invalid_pump` - Invalid pump identifier
- `invalid_duration` - Duration out of range (1-300 seconds)
- `pump_already_running` - Pump is currently active
- `system_busy` - System is processing another command
- `hardware_error` - Hardware malfunction detected

---

## Best Practices for AI Integration

### 1. Command Queuing
- Wait for command acknowledgment before sending next command
- Implement retry logic with exponential backoff
- Maximum 3 retry attempts per command

### 2. Status Caching
- Cache latest status message for quick responses
- Update cache on each status message received
- Use cached data for immediate user queries

### 3. User Feedback
- Provide immediate feedback for commands sent
- Show real-time pump countdowns
- Display connection status prominently

### 4. Safety Features
- Implement maximum duration limits (5 minutes default)
- Confirm destructive actions (system restart)
- Monitor for device disconnection

### 5. Natural Language Processing
- Support duration formats: "2 minutes", "30 seconds", "5 min"
- Handle pump aliases: "water", "irrigation", "fertilizer", "nutrient"
- Parse time expressions: "for 2 minutes", "until 3 PM"

---

## Flutter Integration

### Dependencies
Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  mqtt_client: ^10.0.0
  json_annotation: ^4.8.1
  provider: ^6.0.5
  
dev_dependencies:
  json_serializable: ^6.7.1
  build_runner: ^2.4.7
```

### Data Models

Create data models for type-safe MQTT message handling:

```dart
// lib/models/device_status.dart
import 'package:json_annotation/json_annotation.dart';

part 'device_status.g.dart';

@JsonSerializable()
class DeviceStatus {
  final String id;
  final int uptime;
  final int ts;
  final SystemInfo sys;
  final ConnectionInfo conn;
  final PumpInfo pumps;
  final SensorInfo sens;
  final int heap;

  DeviceStatus({
    required this.id,
    required this.uptime,
    required this.ts,
    required this.sys,
    required this.conn,
    required this.pumps,
    required this.sens,
    required this.heap,
  });

  factory DeviceStatus.fromJson(Map<String, dynamic> json) =>
      _$DeviceStatusFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceStatusToJson(this);
}

@JsonSerializable()
class SystemInfo {
  final bool sch;
  final bool buzz;

  SystemInfo({required this.sch, required this.buzz});

  factory SystemInfo.fromJson(Map<String, dynamic> json) =>
      _$SystemInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SystemInfoToJson(this);
}

@JsonSerializable()
class ConnectionInfo {
  final bool wifi;
  final int rssi;
  final bool mqtt;
  final bool sd;

  ConnectionInfo({
    required this.wifi,
    required this.rssi,
    required this.mqtt,
    required this.sd,
  });

  factory ConnectionInfo.fromJson(Map<String, dynamic> json) =>
      _$ConnectionInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ConnectionInfoToJson(this);
}

@JsonSerializable()
class PumpInfo {
  final bool w; // water pump
  final bool f; // fertilizer pump

  PumpInfo({required this.w, required this.f});

  factory PumpInfo.fromJson(Map<String, dynamic> json) =>
      _$PumpInfoFromJson(json);
  Map<String, dynamic> toJson() => _$PumpInfoToJson(this);
}

@JsonSerializable()
class SensorInfo {
  final double temp;
  final double hum;
  final double soil;

  SensorInfo({required this.temp, required this.hum, required this.soil});

  factory SensorInfo.fromJson(Map<String, dynamic> json) =>
      _$SensorInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SensorInfoToJson(this);
}

// lib/models/pump_command.dart
@JsonSerializable()
class PumpCommand {
  final String cmd;
  final String? pump;
  final String? action;
  final int? duration;
  @JsonKey(name: 'water_duration')
  final int? waterDuration;
  @JsonKey(name: 'fertilizer_duration')
  final int? fertilizerDuration;

  PumpCommand({
    required this.cmd,
    this.pump,
    this.action,
    this.duration,
    this.waterDuration,
    this.fertilizerDuration,
  });

  factory PumpCommand.fromJson(Map<String, dynamic> json) =>
      _$PumpCommandFromJson(json);
  Map<String, dynamic> toJson() => _$PumpCommandToJson(this);

  // Factory constructors for common commands
  factory PumpCommand.startWaterPump(int duration) => PumpCommand(
        cmd: 'pump',
        pump: 'water',
        action: 'on',
        duration: duration,
      );

  factory PumpCommand.startFertilizerPump(int duration) => PumpCommand(
        cmd: 'pump',
        pump: 'fertilizer',
        action: 'on',
        duration: duration,
      );

  factory PumpCommand.startBothPumps(int waterDuration, int fertilizerDuration) =>
      PumpCommand(
        cmd: 'pump',
        pump: 'both',
        action: 'on',
        waterDuration: waterDuration,
        fertilizerDuration: fertilizerDuration,
      );

  factory PumpCommand.stopAllPumps() => PumpCommand(
        cmd: 'pump',
        action: 'stop_all',
      );
}
```

### MQTT Service

```dart
// lib/services/mqtt_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter/foundation.dart';
import '../models/device_status.dart';
import '../models/pump_command.dart';

class MqttService extends ChangeNotifier {
  MqttServerClient? _client;
  String? _deviceId;
  DeviceStatus? _latestStatus;
  bool _isConnected = false;
  String _connectionStatus = 'Disconnected';

  // Getters
  bool get isConnected => _isConnected;
  String get connectionStatus => _connectionStatus;
  DeviceStatus? get latestStatus => _latestStatus;
  String? get deviceId => _deviceId;

  Future<bool> connect({
    required String broker,
    required int port,
    required String username,
    required String password,
    String? deviceId,
  }) async {
    try {
      _deviceId = deviceId;
      final clientId = 'flutter_airis_${Random().nextInt(10000)}';
      
      _client = MqttServerClient.withPort(broker, clientId, port);
      _client!.logging(on: kDebugMode);
      _client!.keepAlivePeriod = 60;
      _client!.autoReconnect = true;
      _client!.onConnected = _onConnected;
      _client!.onDisconnected = _onDisconnected;
      _client!.onSubscribed = _onSubscribed;

      final connMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .authenticateAs(username, password)
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      
      _client!.connectionMessage = connMessage;

      _updateConnectionStatus('Connecting...');
      
      final result = await _client!.connect();
      
      if (result == MqttConnectionState.connected) {
        _isConnected = true;
        _updateConnectionStatus('Connected');
        _setupSubscriptions();
        _setupMessageListener();
        return true;
      } else {
        _updateConnectionStatus('Connection failed');
        return false;
      }
    } catch (e) {
      _updateConnectionStatus('Error: $e');
      return false;
    }
  }

  void _setupSubscriptions() {
    if (_deviceId != null) {
      // Subscribe to specific device
      _client!.subscribe('airis/$_deviceId/status', MqttQos.atMostOnce);
      _client!.subscribe('airis/$_deviceId/events', MqttQos.atMostOnce);
    } else {
      // Subscribe to all devices for discovery
      _client!.subscribe('airis/+/status', MqttQos.atMostOnce);
      _client!.subscribe('airis/+/events', MqttQos.atMostOnce);
    }
  }

  void _setupMessageListener() {
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final recMess = c[0].payload as MqttPublishMessage;
      final message = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      final topic = c[0].topic;
      
      _handleMessage(topic, message);
    });
  }

  void _handleMessage(String topic, String message) {
    try {
      final data = jsonDecode(message);
      final topicParts = topic.split('/');
      
      if (topicParts.length >= 3) {
        final messageDeviceId = topicParts[1];
        final messageType = topicParts[2];
        
        // Auto-discover device ID if not set
        if (_deviceId == null && messageType == 'status') {
          _deviceId = messageDeviceId;
          notifyListeners();
        }
        
        switch (messageType) {
          case 'status':
            _handleStatusMessage(data);
            break;
          case 'events':
            _handleEventMessage(data);
            break;
        }
      }
    } catch (e) {
      debugPrint('Error parsing MQTT message: $e');
    }
  }

  void _handleStatusMessage(Map<String, dynamic> data) {
    try {
      _latestStatus = DeviceStatus.fromJson(data);
      notifyListeners();
    } catch (e) {
      debugPrint('Error parsing status message: $e');
    }
  }

  void _handleEventMessage(Map<String, dynamic> data) {
    // Handle events (pump state changes, alerts, etc.)
    debugPrint('Event received: $data');
    notifyListeners();
  }

  Future<bool> sendCommand(PumpCommand command) async {
    if (!_isConnected || _deviceId == null) return false;
    
    try {
      final topic = 'airis/$_deviceId/cmd';
      final message = jsonEncode(command.toJson());
      
      _client!.publishMessage(
        topic, 
        MqttQos.atLeastOnce, 
        MqttClientPayloadBuilder().addString(message).payload!,
      );
      
      return true;
    } catch (e) {
      debugPrint('Error sending command: $e');
      return false;
    }
  }

  void _onConnected() {
    _isConnected = true;
    _updateConnectionStatus('Connected');
  }

  void _onDisconnected() {
    _isConnected = false;
    _updateConnectionStatus('Disconnected');
  }

  void _onSubscribed(String topic) {
    debugPrint('Subscribed to: $topic');
  }

  void _updateConnectionStatus(String status) {
    _connectionStatus = status;
    notifyListeners();
  }

  void disconnect() {
    _client?.disconnect();
    _isConnected = false;
    _updateConnectionStatus('Disconnected');
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
```

### AI Command Processing Service

```dart
// lib/services/ai_command_service.dart
import 'dart:convert';
import '../models/pump_command.dart';
import '../services/mqtt_service.dart';

class AiCommandService {
  final MqttService _mqttService;

  AiCommandService(this._mqttService);

  Future<String> processUserCommand(String userInput) async {
    final lowerInput = userInput.toLowerCase();
    PumpCommand? command;
    String response = '';

    try {
      // Water pump commands
      if (lowerInput.contains('water') && 
          (lowerInput.contains('start') || lowerInput.contains('on') || lowerInput.contains('nyalakan'))) {
        final duration = _extractDuration(userInput) ?? 60;
        command = PumpCommand.startWaterPump(duration);
        response = '✅ Pompa air dinyalakan selama $duration detik';
      }
      
      // Fertilizer pump commands
      else if (lowerInput.contains('fertilizer') || lowerInput.contains('pupuk')) {
        if (lowerInput.contains('start') || lowerInput.contains('on') || lowerInput.contains('nyalakan')) {
          final duration = _extractDuration(userInput) ?? 30;
          command = PumpCommand.startFertilizerPump(duration);
          response = '✅ Pompa pupuk dinyalakan selama $duration detik';
        }
      }
      
      // Both pumps
      else if (lowerInput.contains('irrigation') || lowerInput.contains('siram') || 
               (lowerInput.contains('both') && lowerInput.contains('pump'))) {
        final waterDuration = _extractDuration(userInput, 'water') ?? 300;
        final fertilizerDuration = _extractDuration(userInput, 'fertilizer') ?? 60;
        command = PumpCommand.startBothPumps(waterDuration, fertilizerDuration);
        response = '✅ Kedua pompa dinyalakan (Air: ${waterDuration}s, Pupuk: ${fertilizerDuration}s)';
      }
      
      // Stop commands
      else if (lowerInput.contains('stop') || lowerInput.contains('matikan') || lowerInput.contains('off')) {
        command = PumpCommand.stopAllPumps();
        response = '✅ Semua pompa dimatikan';
      }
      
      // Status queries
      else if (lowerInput.contains('status') || lowerInput.contains('kondisi')) {
        return _getStatusResponse();
      }
      
      // Soil moisture query
      else if (lowerInput.contains('soil') || lowerInput.contains('tanah') || lowerInput.contains('kelembaban')) {
        final status = _mqttService.latestStatus;
        if (status != null) {
          return '🌱 Kelembaban tanah: ${status.sens.soil.toStringAsFixed(1)}%';
        } else {
          return '❌ Data sensor tidak tersedia';
        }
      }
      
      // Temperature query
      else if (lowerInput.contains('temperature') || lowerInput.contains('suhu')) {
        final status = _mqttService.latestStatus;
        if (status != null) {
          return '🌡️ Suhu: ${status.sens.temp.toStringAsFixed(1)}°C';
        } else {
          return '❌ Data sensor tidak tersedia';
        }
      }
      
      else {
        return '❓ Perintah tidak dikenali. Coba: "nyalakan pompa air 2 menit", "status sistem", "matikan pompa"';
      }

      // Send command if valid
      if (command != null) {
        final success = await _mqttService.sendCommand(command);
        if (!success) {
          response = '❌ Gagal mengirim perintah. Pastikan terhubung ke MQTT.';
        }
      }

      return response;
    } catch (e) {
      return '❌ Error: $e';
    }
  }

  int? _extractDuration(String text, [String? pumpType]) {
    // Extract duration patterns like "2 minutes", "30 seconds", "5 min"
    final patterns = [
      RegExp(r'(\d+)\s*(menit|minutes?|mins?)', caseSensitive: false),
      RegExp(r'(\d+)\s*(detik|seconds?|secs?)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final value = int.tryParse(match.group(1) ?? '');
        final unit = match.group(2)?.toLowerCase() ?? '';
        
        if (value != null) {
          if (unit.contains('menit') || unit.contains('min')) {
            return value * 60;
          } else {
            return value;
          }
        }
      }
    }
    
    return null;
  }

  String _getStatusResponse() {
    final status = _mqttService.latestStatus;
    
    if (status == null) {
      return '❌ Status perangkat tidak tersedia';
    }

    final uptime = Duration(seconds: status.uptime);
    final uptimeStr = '${uptime.inHours}:${(uptime.inMinutes % 60).toString().padLeft(2, '0')}:${(uptime.inSeconds % 60).toString().padLeft(2, '0')}';

    return '''
🏠 Status Sistem Airis
━━━━━━━━━━━━━━━━━━━━━━━━

📊 Sensor:
🌱 Kelembaban Tanah: ${status.sens.soil.toStringAsFixed(1)}%
🌡️ Suhu: ${status.sens.temp.toStringAsFixed(1)}°C
💧 Kelembaban Udara: ${status.sens.hum.toStringAsFixed(1)}%

⚙️ Pompa:
💧 Pompa Air: ${status.pumps.w ? "🟢 AKTIF" : "🔴 MATI"}
🧪 Pompa Pupuk: ${status.pumps.f ? "🟢 AKTIF" : "🔴 MATI"}

🌐 Koneksi:
📶 WiFi: ${status.conn.wifi ? "🟢 Terhubung" : "🔴 Terputus"} (${status.conn.rssi} dBm)
📡 MQTT: ${status.conn.mqtt ? "🟢 Terhubung" : "🔴 Terputus"}
💾 SD Card: ${status.conn.sd ? "🟢 Ready" : "🔴 Error"}

💻 Sistem:
🔄 Uptime: $uptimeStr
💾 Memory: ${(status.heap / 1024).toStringAsFixed(1)} KB
⏰ Scheduling: ${status.sys.sch ? "🟢 Aktif" : "🔴 Mati"}
''';
  }
}
```

### UI Integration

```dart
// lib/screens/irrigation_control_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mqtt_service.dart';
import '../services/ai_command_service.dart';

class IrrigationControlScreen extends StatefulWidget {
  @override
  _IrrigationControlScreenState createState() => _IrrigationControlScreenState();
}

class _IrrigationControlScreenState extends State<IrrigationControlScreen> {
  final TextEditingController _commandController = TextEditingController();
  late AiCommandService _aiService;
  String _responseText = '';

  @override
  void initState() {
    super.initState();
    _aiService = AiCommandService(context.read<MqttService>());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Airis Irrigation Control'),
        backgroundColor: Colors.green,
      ),
      body: Consumer<MqttService>(
        builder: (context, mqttService, child) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Connection Status
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          mqttService.isConnected ? Icons.cloud_done : Icons.cloud_off,
                          color: mqttService.isConnected ? Colors.green : Colors.red,
                        ),
                        SizedBox(width: 8),
                        Text(mqttService.connectionStatus),
                        Spacer(),
                        if (mqttService.deviceId != null)
                          Text('ID: ${mqttService.deviceId}', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Quick Status
                if (mqttService.latestStatus != null)
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status Terkini:', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatusItem('Tanah', '${mqttService.latestStatus!.sens.soil.toStringAsFixed(1)}%', Icons.grass),
                              _buildStatusItem('Suhu', '${mqttService.latestStatus!.sens.temp.toStringAsFixed(1)}°C', Icons.thermostat),
                              _buildStatusItem('Kelembaban', '${mqttService.latestStatus!.sens.hum.toStringAsFixed(1)}%', Icons.water_drop),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildPumpStatus('Pompa Air', mqttService.latestStatus!.pumps.w),
                              _buildPumpStatus('Pompa Pupuk', mqttService.latestStatus!.pumps.f),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                
                SizedBox(height: 16),
                
                // AI Command Input
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Perintah AI:', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        TextField(
                          controller: _commandController,
                          decoration: InputDecoration(
                            hintText: 'Contoh: "nyalakan pompa air 2 menit", "status sistem"',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: _processCommand,
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _processCommand(_commandController.text),
                          child: Text('Kirim Perintah'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Response Area
                if (_responseText.isNotEmpty)
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Text(
                            _responseText,
                            style: TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.green),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPumpStatus(String label, bool isActive) {
    return Column(
      children: [
        Icon(
          isActive ? Icons.power : Icons.power_off,
          color: isActive ? Colors.green : Colors.red,
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
        Text(
          isActive ? 'AKTIF' : 'MATI',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  void _processCommand(String command) async {
    if (command.trim().isEmpty) return;
    
    setState(() {
      _responseText = 'Memproses perintah...';
    });
    
    final response = await _aiService.processUserCommand(command);
    
    setState(() {
      _responseText = response;
    });
    
    _commandController.clear();
  }

  @override
  void dispose() {
    _commandController.dispose();
    super.dispose();
  }
}
```

### Main App Setup

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/mqtt_service.dart';
import 'screens/irrigation_control_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MqttService(),
      child: MaterialApp(
        title: 'Airis Irrigation Control',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: ConnectionScreen(),
      ),
    );
  }
}

class ConnectionScreen extends StatefulWidget {
  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final _brokerController = TextEditingController(text: 'your-mqtt-broker.com');
  final _portController = TextEditingController(text: '1883');
  final _usernameController = TextEditingController(text: 'username');
  final _passwordController = TextEditingController(text: 'password');
  final _deviceIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connect to Airis')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _brokerController,
              decoration: InputDecoration(labelText: 'MQTT Broker'),
            ),
            TextField(
              controller: _portController,
              decoration: InputDecoration(labelText: 'Port'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _deviceIdController,
              decoration: InputDecoration(
                labelText: 'Device ID (Optional)',
                hintText: 'Kosongkan untuk auto-discover',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _connect,
              child: Text('Connect'),
            ),
          ],
        ),
      ),
    );
  }

  void _connect() async {
    final mqttService = Provider.of<MqttService>(context, listen: false);
    
    final success = await mqttService.connect(
      broker: _brokerController.text,
      port: int.parse(_portController.text),
      username: _usernameController.text,
      password: _passwordController.text,
      deviceId: _deviceIdController.text.isEmpty ? null : _deviceIdController.text,
    );
    
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => IrrigationControlScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection failed')),
      );
    }
  }
}
```
```

---

## AI Prompts for Flutter Integration

### System Prompt for AI Assistant

```text
You are an AI assistant for the Airis Irrigation System mobile app built with Flutter. You can control irrigation pumps via MQTT commands and provide real-time system information.

CAPABILITIES:
- Control water pump (start/stop with duration 1-300 seconds)
- Control fertilizer pump (start/stop with duration 1-300 seconds)  
- Control both pumps simultaneously
- Check system status (sensors, pumps, connectivity)
- Monitor real-time sensor data (soil moisture, temperature, humidity)

DEVICE COMMUNICATION:
- MQTT Topic Structure: airis/{device_id}/cmd for commands
- Device Status Updates: airis/{device_id}/status every 30 seconds
- Event Notifications: airis/{device_id}/events for real-time alerts

COMMAND FORMAT:
All commands must be valid JSON sent to MQTT topic airis/{device_id}/cmd

AVAILABLE COMMANDS:
1. Start Water Pump: {"cmd": "pump", "pump": "water", "action": "on", "duration": 60}
2. Start Fertilizer Pump: {"cmd": "pump", "pump": "fertilizer", "action": "on", "duration": 30}
3. Start Both Pumps: {"cmd": "pump", "pump": "both", "action": "on", "water_duration": 120, "fertilizer_duration": 45}
4. Stop All Pumps: {"cmd": "pump", "action": "stop_all"}
5. System Restart: {"cmd": "system", "action": "restart"}

RESPONSE GUIDELINES:
- Use Indonesian language for user-friendly responses
- Include emojis for better UX (🌱💧🌡️⚡💾🔄)
- Provide immediate feedback for commands
- Show detailed status when requested
- Handle errors gracefully with helpful messages

SAFETY RULES:
- Maximum pump duration: 300 seconds (5 minutes)
- Confirm destructive actions (system restart)
- Validate all durations before sending commands
- Show warnings for long durations (>120 seconds)

NATURAL LANGUAGE PATTERNS:
- "nyalakan pompa air 2 menit" → Start water pump 120 seconds
- "siram tanaman 5 menit" → Start both pumps (300s water, 60s fertilizer)
- "matikan semua pompa" → Stop all pumps
- "status sistem" → Show detailed system status
- "kelembaban tanah berapa?" → Show soil moisture percentage

Always provide helpful, accurate, and safe irrigation control assistance.
```

### User Interaction Patterns

#### Basic Commands
```text
User: "Nyalakan pompa air selama 2 menit"
AI Response: "✅ Pompa air dinyalakan selama 120 detik"

User: "Siram tanaman 5 menit"  
AI Response: "✅ Memulai irigasi lengkap (Air: 300s, Pupuk: 60s)"

User: "Stop semua pompa"
AI Response: "✅ Semua pompa telah dimatikan"

User: "Status sistem"
AI Response: [Detailed status with sensors, pumps, connectivity]
```

#### Error Handling
```text
User: "Nyalakan pompa 10 menit"
AI Response: "⚠️ Durasi maksimal 5 menit untuk keamanan. Apakah Anda ingin melanjutkan dengan 5 menit?"

User: "Restart sistem"  
AI Response: "⚠️ Tindakan ini akan me-restart perangkat. Lanjutkan? (ya/tidak)"

Connection Error:
AI Response: "❌ Tidak terhubung ke perangkat. Periksa koneksi MQTT Anda."
```

### Flutter Code Generation Prompts

#### For MQTT Service
```text
Create a Flutter MQTT service class that:
- Connects to MQTT broker with authentication
- Subscribes to airis/{device_id}/status and events topics
- Handles auto-reconnection and connection state management
- Parses incoming JSON messages to Dart objects
- Sends pump control commands as JSON to airis/{device_id}/cmd
- Uses ChangeNotifier for UI updates
- Includes error handling and logging
```

#### For UI Components  
```text
Create Flutter widgets for:
- Real-time status display showing sensor readings (soil moisture, temperature, humidity)
- Pump control buttons with duration selection
- Connection status indicator with auto-connect
- AI chat interface with command input and response display
- Settings screen for MQTT broker configuration
- Alert notifications for sensor thresholds and pump events

Use Material Design with green color scheme matching the irrigation theme.
```

#### For Data Models
```text
Generate Dart data classes with json_serializable for:
- DeviceStatus: Contains id, uptime, timestamp, system info, connection info, pump status, sensor readings
- PumpCommand: Contains command type, pump selection, action, duration parameters
- SystemEvent: Contains event type, timestamp, details for notifications
- ConnectionConfig: Contains MQTT broker settings, credentials, device ID

Include factory constructors for common use cases and proper null safety.
```

### Testing Prompts

#### Unit Testing
```text
Create Flutter unit tests for:
- MQTT message parsing and serialization
- AI command processing logic
- Duration extraction from natural language
- Error handling scenarios
- Connection state management

Use mockito for mocking MQTT client and test edge cases.
```

#### Integration Testing
```text
Create Flutter integration tests for:
- End-to-end MQTT communication flow
- UI interaction with pump controls
- Real-time status updates in UI
- AI command processing and response display
- Connection failure and recovery scenarios

Test on both Android and iOS platforms.
```

### Documentation Prompts

#### API Documentation
```text
Generate comprehensive Flutter documentation covering:
- MQTT integration setup and configuration
- Data model usage and serialization
- Service layer architecture and state management  
- UI component hierarchy and customization
- Error handling patterns and best practices
- Performance optimization for real-time updates

Include code examples, troubleshooting guides, and deployment instructions.
```

#### User Guide
```text
Create user documentation for:
- Initial app setup and MQTT configuration
- Device discovery and connection process
- Pump control operations and safety features
- AI assistant usage with example commands
- Troubleshooting common connection issues
- Sensor monitoring and alert configuration

Format as markdown with screenshots and step-by-step instructions.
```

---

This Flutter-specific documentation provides everything needed for implementing a robust mobile app that can communicate with the Airis irrigation system via MQTT, including comprehensive AI assistant capabilities and type-safe data handling.