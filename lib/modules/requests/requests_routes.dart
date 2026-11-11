import 'package:go_router/go_router.dart';
import 'package:test_point/modules/requests/screens/request_screen.dart';

const requestPath = '/request';

/// Routes owned by the requests module, composed in `app/router/`.
final requestsRoutes = <RouteBase>[
  GoRoute(
    path: requestPath,
    builder: (context, state) => const RequestScreen(),
  ),
];
