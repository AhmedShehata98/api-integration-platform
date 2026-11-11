import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_point/app/app.dart';
import 'package:test_point/app/di/app_overrides.dart';
import 'package:test_point/core/database/supabase_config.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    _configureWindow();
  }

  if (!SupabaseConfig.isConfigured) {
    runApp(const _MissingConfigApp());
    return;
  }
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
  );
  final preferences = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(overrides: appOverrides(preferences), child: const App()),
  );
}

void _configureWindow() {
  final window = WindowManager.instance.getCurrent();
  if (window == null) return;
  window.title = 'Test Point';
  window.minimumSize = const Size(1024, 640).toNative();
  window.setSize(const Size(1280, 800).toNative(), false);
  window.center();
  window.show();
}

/// Shown when the app is started without the Supabase `--dart-define` values.
class _MissingConfigApp extends StatelessWidget {
  const _MissingConfigApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            'Missing SUPABASE_URL / SUPABASE_ANON_KEY. '
            'Run with --dart-define (see agents.md).',
          ),
        ),
      ),
    );
  }
}
