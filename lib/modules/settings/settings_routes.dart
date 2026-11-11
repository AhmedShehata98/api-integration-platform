import 'package:go_router/go_router.dart';
import 'package:test_point/modules/settings/screens/settings_screen.dart';

const settingsPath = '/settings';

/// Routes owned by the settings module, composed in `app/router/`.
final settingsRoutes = <RouteBase>[
  GoRoute(
    path: settingsPath,
    builder: (context, state) => const SettingsScreen(),
  ),
];
