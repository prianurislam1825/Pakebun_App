import 'dart:convert';

class DeviceStatus {
  final String id;
  final int uptime; // seconds
  final int ts; // unix timestamp
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

  factory DeviceStatus.fromJson(Map<String, dynamic> json) => DeviceStatus(
    id: json['id'] ?? '',
    uptime: (json['uptime'] ?? 0) as int,
    ts: (json['ts'] ?? 0) as int,
    sys: SystemInfo.fromJson(json['sys'] ?? const {}),
    conn: ConnectionInfo.fromJson(json['conn'] ?? const {}),
    pumps: PumpInfo.fromJson(json['pumps'] ?? const {}),
    sens: SensorInfo.fromJson(json['sens'] ?? const {}),
    heap: (json['heap'] ?? 0) as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'uptime': uptime,
    'ts': ts,
    'sys': sys.toJson(),
    'conn': conn.toJson(),
    'pumps': pumps.toJson(),
    'sens': sens.toJson(),
    'heap': heap,
  };

  @override
  String toString() => jsonEncode(toJson());
}

class SystemInfo {
  final bool sch;
  final bool buzz;
  const SystemInfo({required this.sch, required this.buzz});
  factory SystemInfo.fromJson(Map<String, dynamic> json) => SystemInfo(
    sch: (json['sch'] ?? false) as bool,
    buzz: (json['buzz'] ?? false) as bool,
  );
  Map<String, dynamic> toJson() => {'sch': sch, 'buzz': buzz};
}

class ConnectionInfo {
  final bool wifi;
  final int rssi;
  final bool mqtt;
  final bool sd;
  const ConnectionInfo({
    required this.wifi,
    required this.rssi,
    required this.mqtt,
    required this.sd,
  });
  factory ConnectionInfo.fromJson(Map<String, dynamic> json) => ConnectionInfo(
    wifi: (json['wifi'] ?? false) as bool,
    rssi: (json['rssi'] ?? 0) as int,
    mqtt: (json['mqtt'] ?? false) as bool,
    sd: (json['sd'] ?? false) as bool,
  );
  Map<String, dynamic> toJson() => {
    'wifi': wifi,
    'rssi': rssi,
    'mqtt': mqtt,
    'sd': sd,
  };
}

class PumpInfo {
  final bool w; // water
  final bool f; // fertilizer
  const PumpInfo({required this.w, required this.f});
  factory PumpInfo.fromJson(Map<String, dynamic> json) => PumpInfo(
    w: (json['w'] ?? false) as bool,
    f: (json['f'] ?? false) as bool,
  );
  Map<String, dynamic> toJson() => {'w': w, 'f': f};
}

class SensorInfo {
  final double temp;
  final double hum;
  final double soil;
  final double press; // pressure (hPa)
  final double lux; // light intensity

  const SensorInfo({
    required this.temp,
    required this.hum,
    required this.soil,
    required this.press,
    required this.lux,
  });

  factory SensorInfo.fromJson(Map<String, dynamic> json) {
    // Support both flat format and nested sensors (bme280 / bh1750)
    double temp = 0.0;
    double hum = 0.0;
    double soil = 0.0;
    double press = 0.0;
    double lux = 0.0;

    if (json.containsKey('bme280') && json['bme280'] is Map<String, dynamic>) {
      final b = Map<String, dynamic>.from(json['bme280']);
      temp = (b['temp'] ?? 0).toDouble();
      hum = (b['hum'] ?? 0).toDouble();
      press = (b['press'] ?? 0).toDouble();
    } else {
      temp = (json['temp'] ?? 0).toDouble();
      hum = (json['hum'] ?? 0).toDouble();
    }

    if (json.containsKey('bh1750') && json['bh1750'] is Map<String, dynamic>) {
      final l = Map<String, dynamic>.from(json['bh1750']);
      lux = (l['lux'] ?? 0).toDouble();
    } else {
      lux = (json['lux'] ?? 0).toDouble();
    }

    soil = (json['soil'] ?? 0).toDouble();

    return SensorInfo(temp: temp, hum: hum, soil: soil, press: press, lux: lux);
  }

  Map<String, dynamic> toJson() => {
    'temp': temp,
    'hum': hum,
    'soil': soil,
    'press': press,
    'lux': lux,
  };
}

class PumpCommand {
  final String cmd;
  final String? pump; // water | fertilizer | both
  final String? action; // on | off | stop_all
  final int? duration; // for single pump
  final int? waterDuration; // for both
  final int? fertilizerDuration; // for both

  PumpCommand({
    required this.cmd,
    this.pump,
    this.action,
    this.duration,
    this.waterDuration,
    this.fertilizerDuration,
  });

  Map<String, dynamic> toJson() => {
    'cmd': cmd,
    if (pump != null) 'pump': pump,
    if (action != null) 'action': action,
    if (duration != null) 'duration': duration,
    if (waterDuration != null) 'water_duration': waterDuration,
    if (fertilizerDuration != null) 'fertilizer_duration': fertilizerDuration,
  };

  factory PumpCommand.startWater(int dur) =>
      PumpCommand(cmd: 'pump', pump: 'water', action: 'on', duration: dur);
  factory PumpCommand.startFertilizer(int dur) =>
      PumpCommand(cmd: 'pump', pump: 'fertilizer', action: 'on', duration: dur);
  factory PumpCommand.startBoth(int waterDur, int fertDur) => PumpCommand(
    cmd: 'pump',
    pump: 'both',
    action: 'on',
    waterDuration: waterDur,
    fertilizerDuration: fertDur,
  );
  factory PumpCommand.stopAll() => PumpCommand(cmd: 'pump', action: 'stop_all');
}
