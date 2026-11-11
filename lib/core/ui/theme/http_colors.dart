import 'package:flutter/material.dart';

/// HTTP method and status colors that are not part of [ColorScheme].
@immutable
class HttpColors extends ThemeExtension<HttpColors> {
  const HttpColors({
    required this.get,
    required this.post,
    required this.put,
    required this.patch,
    required this.delete,
    required this.other,
    required this.status2xx,
    required this.status3xx,
    required this.status4xx,
    required this.status5xx,
  });

  final Color get;
  final Color post;
  final Color put;
  final Color patch;
  final Color delete;

  /// HEAD, OPTIONS and any other method.
  final Color other;

  final Color status2xx;
  final Color status3xx;
  final Color status4xx;
  final Color status5xx;

  static const dark = HttpColors(
    get: Color(0xFF34C759),
    post: Color(0xFFF5A524),
    put: Color(0xFF4C9AFF),
    patch: Color(0xFFA78BFA),
    delete: Color(0xFFF25F5C),
    other: Color(0xFF9AA4A2),
    status2xx: Color(0xFF34C759),
    status3xx: Color(0xFF4C9AFF),
    status4xx: Color(0xFFF5A524),
    status5xx: Color(0xFFF25F5C),
  );

  static const light = HttpColors(
    get: Color(0xFF176F30),
    post: Color(0xFF855000),
    put: Color(0xFF1757B5),
    patch: Color(0xFF6A3FC4),
    delete: Color(0xFFB71C1C),
    other: Color(0xFF55605D),
    status2xx: Color(0xFF176F30),
    status3xx: Color(0xFF1757B5),
    status4xx: Color(0xFF855000),
    status5xx: Color(0xFFB71C1C),
  );

  /// Color for an HTTP [method] such as `GET` (case-insensitive).
  Color methodColor(String method) {
    return switch (method.toUpperCase()) {
      'GET' => get,
      'POST' => post,
      'PUT' => put,
      'PATCH' => patch,
      'DELETE' => delete,
      _ => other,
    };
  }

  /// Color for a response [statusCode]; falls back to [other].
  Color statusColor(int statusCode) {
    return switch (statusCode ~/ 100) {
      2 => status2xx,
      3 => status3xx,
      4 => status4xx,
      5 => status5xx,
      _ => other,
    };
  }

  @override
  HttpColors copyWith({
    Color? get,
    Color? post,
    Color? put,
    Color? patch,
    Color? delete,
    Color? other,
    Color? status2xx,
    Color? status3xx,
    Color? status4xx,
    Color? status5xx,
  }) {
    return HttpColors(
      get: get ?? this.get,
      post: post ?? this.post,
      put: put ?? this.put,
      patch: patch ?? this.patch,
      delete: delete ?? this.delete,
      other: other ?? this.other,
      status2xx: status2xx ?? this.status2xx,
      status3xx: status3xx ?? this.status3xx,
      status4xx: status4xx ?? this.status4xx,
      status5xx: status5xx ?? this.status5xx,
    );
  }

  @override
  HttpColors lerp(ThemeExtension<HttpColors>? other, double t) {
    if (other is! HttpColors) return this;
    return HttpColors(
      get: Color.lerp(get, other.get, t)!,
      post: Color.lerp(post, other.post, t)!,
      put: Color.lerp(put, other.put, t)!,
      patch: Color.lerp(patch, other.patch, t)!,
      delete: Color.lerp(delete, other.delete, t)!,
      other: Color.lerp(this.other, other.other, t)!,
      status2xx: Color.lerp(status2xx, other.status2xx, t)!,
      status3xx: Color.lerp(status3xx, other.status3xx, t)!,
      status4xx: Color.lerp(status4xx, other.status4xx, t)!,
      status5xx: Color.lerp(status5xx, other.status5xx, t)!,
    );
  }
}

extension HttpColorsContext on BuildContext {
  HttpColors get httpColors => Theme.of(this).extension<HttpColors>()!;
}
