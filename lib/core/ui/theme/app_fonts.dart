import 'package:flutter/painting.dart';

/// Bundled font families (see `pubspec.yaml`).
abstract final class AppFonts {
  static const String headline = 'GoogleSansFlex';
  static const String ui = 'Inter';
  static const String mono = 'JetBrainsMono';

  /// Text style for URLs and code.
  static const TextStyle monoStyle = TextStyle(fontFamily: mono);
}
