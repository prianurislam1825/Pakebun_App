import 'dart:math';

final _rand = Random();

/// Generate pseudo-unique id (tanpa dependency eksternal) berbasis timestamp + random.
String generateId() {
  final ts = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final r = _rand.nextInt(0xFFFFFFFF).toRadixString(36);
  return '${ts}_$r';
}
