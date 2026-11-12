@Tags(['design-audit'])
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/core/ui/theme/app_theme.dart';
import 'package:test_point/modules/auth/auth.dart';
import 'package:test_point/modules/collections/collections.dart';
import 'package:test_point/modules/environments/environments.dart';
import 'package:test_point/modules/requests/models/prepared_request.dart';
import 'package:test_point/modules/requests/requests.dart';
import 'package:test_point/modules/requests/widgets/method_menu.dart';
import 'package:test_point/modules/requests/widgets/url_field.dart';

import '../../support/fake_backend.dart';
import '../../support/pump_app.dart';

/// Renders each MVP screen at 1280x800 in both themes with the Stitch sample
/// data (Petstore API, "Development" environment) and writes golden PNGs to
/// `goldens/`. The goldens are what `docs/design/ui-audit.md` compares with
/// the Stitch exports in `docs/design/stitch-export/`.
///
/// Goldens depend on the platform's text rendering, so the audit is opt-in:
/// `flutter test test/app/design_audit --dart-define=DESIGN_AUDIT=true
/// --update-goldens`.
const _enabled = bool.fromEnvironment('DESIGN_AUDIT');

SavedRequest _request(
  String id,
  String name,
  HttpMethod method,
  String url,
  int position, [
  String collection = 'c1',
]) => SavedRequest(
  id: id,
  collectionId: collection,
  name: name,
  position: position,
  draft: HttpRequestDraft(
    method: method,
    url: url,
    params: id == 'r1'
        ? const [
            KeyValue(key: 'limit', value: '20'),
            KeyValue(key: 'status', value: 'available'),
          ]
        : const [],
    headers: const [
      KeyValue(key: 'Accept', value: 'application/json'),
      KeyValue(key: 'X-Api-Key', value: '{{apiKey}}'),
    ],
    body: id == 'r2'
        ? const RequestBody(
            type: BodyType.json,
            text: '{\n  "name": "Rex",\n  "status": "available"\n}',
          )
        : const RequestBody(),
  ),
);

FakeStore _petstore() => FakeStore(
  collections: [
    const Collection(id: 'c1', workspaceId: 'ws-1', name: 'Petstore API'),
    const Collection(
      id: 'c2',
      workspaceId: 'ws-1',
      name: 'Authentication',
      position: 1,
    ),
  ],
  requests: [
    _request(
      'r1',
      'List pets',
      HttpMethod.get,
      '{{baseUrl}}/pets?limit=20&status=available',
      0,
    ),
    _request('r2', 'Create pet', HttpMethod.post, '{{baseUrl}}/pets', 1),
    _request('r3', 'Get pet by ID', HttpMethod.get, '{{baseUrl}}/pets/42', 2),
    _request('r4', 'Update pet', HttpMethod.put, '{{baseUrl}}/pets/42', 3),
    _request(
      'r5',
      'Update pet status',
      HttpMethod.patch,
      '{{baseUrl}}/pets/42',
      4,
    ),
    _request('r6', 'Delete pet', HttpMethod.delete, '{{baseUrl}}/pets/42', 5),
    _request('r7', 'Login', HttpMethod.post, '{{baseUrl}}/login', 0, 'c2'),
    _request(
      'r8',
      'Refresh token',
      HttpMethod.post,
      '{{baseUrl}}/refresh',
      1,
      'c2',
    ),
  ],
  environments: [
    const Environment(
      id: 'e1',
      workspaceId: 'ws-1',
      name: 'Development',
      variables: [
        EnvironmentVariable(
          key: 'baseUrl',
          value: 'https://api.petstore.io/v2',
        ),
        EnvironmentVariable(key: 'apiKey', value: 'sk_test_123', secret: true),
        EnvironmentVariable(key: 'petId', value: '42'),
      ],
    ),
    const Environment(id: 'e2', workspaceId: 'ws-1', name: 'Staging'),
  ],
);

/// Answers every request with a canned 200, never answers (loading) or fails,
/// depending on [mode].
class _FakeHttp implements HttpRequestRepository {
  _FakeHttp(this.mode);
  final String mode;

  @override
  Future<Result<HttpResponseResult>> send(
    PreparedRequest request,
    CancelSignal cancelSignal,
  ) {
    if (mode == 'loading') {
      return Completer<Result<HttpResponseResult>>().future;
    }
    if (mode == 'error') {
      return Future.value(
        const Result.failure(NetworkFailure('Request timed out after 30 s.')),
      );
    }
    return Future.value(
      const Result.success(
        HttpResponseResult(
          statusCode: 200,
          reason: 'OK',
          headers: {
            'content-type': ['application/json'],
            'content-length': ['66'],
          },
          body: '{"id":42,"name":"Rex","status":"available","tags":["dog","good"]}',
          prettyBody:
              '{\n  "id": 42,\n  "name": "Rex",\n  "status": "available",\n'
              '  "tags": [\n    "dog",\n    "good"\n  ]\n}',
          duration: Duration(milliseconds: 142),
          sizeBytes: 66,
        ),
      ),
    );
  }
}

Future<ProviderContainer> _open(
  WidgetTester tester,
  ThemeData theme, {
  FakeStore? store,
  AuthRepository? auth,
  String http = 'ok',
}) async {
  final container = await pumpApp(
    tester,
    store ?? _petstore(),
    theme: theme,
    auth: auth,
    extraOverrides: [
      httpRequestRepositoryProvider.overrideWithValue(_FakeHttp(http)),
    ],
  );
  // The Stitch screens show the Development environment as active.
  container.read(activeEnvironmentIdProvider.notifier).select('e1');
  await tester.pumpAndSettle();
  return container;
}

Future<void> _openRequest(WidgetTester tester, String name) async {
  while (find.byTooltip('Expand').evaluate().isNotEmpty) {
    await tester.tap(find.byTooltip('Expand').first);
    await tester.pumpAndSettle();
  }
  await tester.tap(find.text(name).first);
  await tester.pumpAndSettle();
}

/// Lets work that runs on another isolate (JSON formatting) finish.
Future<void> _settleAsync(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
  }
}

Future<void> _capture(WidgetTester tester, String name, String theme) =>
    expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/${name}_$theme.png'),
    );

/// Flutter tests draw text with the Ahem font unless the real ones are
/// loaded, which makes the goldens unreadable.
Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> assets) async {
    final loader = FontLoader(family);
    for (final asset in assets) {
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }

  await load('Inter', ['assets/fonts/Inter[opsz,wght].ttf']);
  await load('JetBrainsMono', ['assets/fonts/JetBrainsMono[wght].ttf']);
  await load('GoogleSansFlex', ['assets/fonts/GoogleSansFlex.ttf']);

  final root = Platform.environment['FLUTTER_ROOT'];
  if (root != null) {
    final icons = File(
      '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    );
    if (icons.existsSync()) {
      final bytes = icons.readAsBytesSync();
      await load('MaterialIcons', []);
      final loader = FontLoader('MaterialIcons')
        ..addFont(Future.value(ByteData.sublistView(bytes)));
      await loader.load();
    }
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    WidgetsApp.debugAllowBannerOverride = false;
    if (_enabled) await _loadFonts();
  });

  for (final entry in {
    'dark': AppTheme.dark,
    'light': AppTheme.light,
  }.entries) {
    final theme = entry.value;
    final name = entry.key;

    group('screens ($name)', skip: !_enabled, () {
      testWidgets('01 request params', (tester) async {
        await _open(tester, theme);
        await _openRequest(tester, 'List pets');
        await _capture(tester, '01_request_params', name);
      });

      testWidgets('02 request body', (tester) async {
        await _open(tester, theme);
        await _openRequest(tester, 'Create pet');
        await tester.tap(find.widgetWithText(Tab, 'Body'));
        await _settleAsync(tester);
        await _capture(tester, '02_request_body', name);
      });

      testWidgets('03 request headers and auth', (tester) async {
        await _open(tester, theme);
        await _openRequest(tester, 'List pets');
        await tester.tap(find.widgetWithText(Tab, 'Headers'));
        await tester.pumpAndSettle();
        await _capture(tester, '03_request_headers', name);
        await tester.tap(find.widgetWithText(Tab, 'Auth'));
        await tester.pumpAndSettle();
        await _capture(tester, '03_request_auth', name);
      });

      testWidgets('04 response success', (tester) async {
        await _open(tester, theme);
        await _openRequest(tester, 'List pets');
        await tester.tap(find.text('Send'));
        await _settleAsync(tester);
        await _capture(tester, '04_response_success', name);
      });

      testWidgets('05 response loading', (tester) async {
        await _open(tester, theme, http: 'loading');
        await _openRequest(tester, 'List pets');
        await tester.tap(find.text('Send'));
        await tester.pump(const Duration(milliseconds: 100));
        await _capture(tester, '05_response_loading', name);
      });

      testWidgets('05 response error', (tester) async {
        await _open(tester, theme, http: 'error');
        await _openRequest(tester, 'List pets');
        await tester.tap(find.text('Send'));
        await tester.pumpAndSettle();
        await _capture(tester, '05_response_error', name);
      });

      testWidgets('06 method menu', (tester) async {
        await _open(tester, theme);
        await _openRequest(tester, 'List pets');
        await tester.tap(find.byType(MethodMenu));
        await tester.pumpAndSettle();
        await _capture(tester, '06_method_menu', name);
      });

      testWidgets('06 variable autocomplete', (tester) async {
        await _open(tester, theme);
        await tester.tap(find.text('New request').first);
        await tester.pumpAndSettle();
        await tester.tap(find.byType(UrlField));
        await tester.enterText(find.byType(UrlField), '{{');
        await tester.pumpAndSettle();
        await _capture(tester, '06_variable_autocomplete', name);
      });

      testWidgets('12 save request dialog', (tester) async {
        await _open(tester, theme);
        await tester.tap(find.text('New request').first);
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(UrlField), 'https://a.test/pets');
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Save (Ctrl+S)'));
        await tester.pumpAndSettle();
        await _capture(tester, '12_save_request_dialog', name);
      });

      testWidgets('12 delete collection confirm', (tester) async {
        await _open(tester, theme);
        await tester.tap(
          find.text('Petstore API').first,
          buttons: kSecondaryButton,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete').last);
        await tester.pumpAndSettle();
        await _capture(tester, '12_delete_confirm', name);
      });

      testWidgets('07 collection context menu and overview', (tester) async {
        await _open(tester, theme);
        await tester.tap(
          find.text('Petstore API').first,
          buttons: kSecondaryButton,
        );
        await tester.pumpAndSettle();
        await _capture(tester, '07_context_menu', name);
        await tester.tapAt(const Offset(1100, 700));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Petstore API').first);
        await tester.pumpAndSettle();
        await _capture(tester, '07_collection_overview', name);
      });

      testWidgets('08 welcome', (tester) async {
        await _open(tester, theme, store: FakeStore());
        await _capture(tester, '08_welcome', name);
      });

      testWidgets('09 environments', (tester) async {
        await _open(tester, theme);
        await tester.tap(find.text('Environments').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Development').last);
        await tester.pumpAndSettle();
        await _capture(tester, '09_environments', name);
      });

      testWidgets('10 import dialog', (tester) async {
        await _open(tester, theme);
        await tester.tap(find.byTooltip('Import'));
        await tester.pumpAndSettle();
        await _capture(tester, '10_import_dialog', name);
      });

      testWidgets('11 settings', (tester) async {
        await _open(tester, theme);
        await tester.tap(find.text('Settings').first);
        await tester.pumpAndSettle();
        await _capture(tester, '11_settings', name);
      });

      testWidgets('12 new menu', (tester) async {
        await _open(tester, theme);
        await tester.tap(find.text('New'));
        await tester.pumpAndSettle();
        await _capture(tester, '12_new_menu', name);
      });

      testWidgets('13 account guest', (tester) async {
        await _open(tester, theme, auth: FakeAuthRepository());
        await tester.tap(find.byType(UserAvatar));
        await tester.pumpAndSettle();
        await _capture(tester, '13_account_guest', name);
      });

      testWidgets('13 account waiting', (tester) async {
        final auth = FakeAuthRepository()..holdBrowser = true;
        await _open(tester, theme, auth: auth);
        await tester.tap(find.byType(UserAvatar));
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(OutlinedButton, 'Continue with GitHub'),
        );
        await tester.pump();
        await _capture(tester, '13_account_waiting', name);
      });

      testWidgets('13 account guest data warning', (tester) async {
        final auth = FakeAuthRepository()..githubAccountExists = true;
        await _open(tester, theme, auth: auth);
        await tester.tap(find.byType(UserAvatar));
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(OutlinedButton, 'Continue with GitHub'),
        );
        await tester.pumpAndSettle();
        await _capture(tester, '13_account_warning', name);
      });

      testWidgets('13 account signed in', (tester) async {
        await _open(
          tester,
          theme,
          auth: FakeAuthRepository(user: FakeAuthRepository.githubUser),
        );
        await tester.tap(find.byType(UserAvatar));
        await tester.pumpAndSettle();
        await _capture(tester, '13_account_signed_in', name);
      });
    });
  }
}
