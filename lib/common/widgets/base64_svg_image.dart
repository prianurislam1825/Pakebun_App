import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show rootBundle; // for loading asset as string

/// Many of the SVG files under assets/monitoring/ are actually
/// simple <svg><rect fill="url(#pattern...)"/> wrappers that embed a PNG
/// via a base64 data URI (<image xlink:href="data:image/png;base64,..."/>).
///
/// The flutter_svg library (as of current stable versions) does NOT render
/// <image> tags (embedded raster images) inside SVG. That is why those
/// monitoring icons appear invisible while the regular outline/path icons
/// (in assets/icon/) show correctly.
///
/// This widget loads the SVG file as text, extracts the base64 PNG payload,
/// decodes it, caches the bytes, and displays it with Image.memory.
/// If the extraction fails it optionally falls back to an empty box or
/// a provided placeholder.
class Base64SvgImage extends StatelessWidget {
  const Base64SvgImage(
    this.assetPath, {
    super.key,
    this.size = 22.0,
    this.fit = BoxFit.contain,
    this.placeholder,
  });

  final String assetPath;
  final double size;
  final BoxFit fit;
  final Widget? placeholder;

  static final Map<String, Uint8List?> _cache = {};
  static final RegExp _dataUriRegex = RegExp(
    r'data:image/(?:png|jpeg);base64,([^"\\)]+)',
  );

  Future<Uint8List?> _load() async {
    if (_cache.containsKey(assetPath)) return _cache[assetPath];
    try {
      final raw = await rootBundle.loadString(assetPath);
      final match = _dataUriRegex.firstMatch(raw);
      if (match != null) {
        final b64 = match.group(1)!;
        final bytes = base64Decode(b64);
        _cache[assetPath] = bytes;
        return bytes;
      }
      _cache[assetPath] = null; // cache miss to avoid repeated IO
      return null;
    } catch (_) {
      _cache[assetPath] = null;
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox(width: size, height: size, child: placeholder);
        }
        final data = snapshot.data;
        if (data == null) {
          return placeholder ?? SizedBox(width: size, height: size);
        }
        return Image.memory(
          data,
          width: size,
          height: size,
          fit: fit,
          filterQuality: FilterQuality.high,
        );
      },
    );
  }
}
