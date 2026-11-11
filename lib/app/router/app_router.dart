import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:test_point/app/screens/collection_overview_screen.dart';
import 'package:test_point/app/screens/welcome_screen.dart';
import 'package:test_point/app/shell/app_shell.dart';
import 'package:test_point/modules/environments/environments.dart';
import 'package:test_point/modules/requests/requests.dart';
import 'package:test_point/modules/settings/settings.dart';

final appRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: '/collections',
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/collections',
            builder: (context, state) => const WelcomeScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => CollectionOverviewScreen(
                  collectionId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          ...requestsRoutes,
          ...environmentsRoutes,
          ...settingsRoutes,
        ],
      ),
    ],
  ),
);
