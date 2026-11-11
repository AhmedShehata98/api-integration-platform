import 'package:go_router/go_router.dart';
import 'package:test_point/modules/environments/screens/environments_screen.dart';

const environmentsPath = '/environments';

/// Routes owned by the environments module, composed in `app/router/`.
final environmentsRoutes = <RouteBase>[
  GoRoute(
    path: environmentsPath,
    builder: (context, state) => const EnvironmentsScreen(),
  ),
];
