import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/core/ui/theme/app_theme.dart';
import 'package:test_point/core/ui/widgets/status_chip.dart';
import 'package:test_point/modules/requests/models/prepared_request.dart';
import 'package:test_point/modules/requests/requests.dart';
import 'package:test_point/modules/requests/screens/request_screen.dart';
import 'package:test_point/modules/requests/widgets/response_viewer.dart';

import '../../../support/fake_backend.dart';

class MockHttpRequestRepository extends Mock implements HttpRequestRepository {}

const _jsonResponse = HttpResponseResult(
  statusCode: 200,
  reason: 'OK',
  headers: {
    'content-type': ['application/json'],
  },
  body: '{"a":1}',
  prettyBody: '{\n  "a": 1\n}',
  duration: Duration(milliseconds: 42),
  sizeBytes: 2048,
);

final _urlField = find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.hintText == 'Enter request URL',
);

Future<ProviderContainer> _pump(
  WidgetTester tester,
  MockHttpRequestRepository repository, {
  ThemeData? theme,
}) async {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final List<Override> overrides = [
    httpRequestRepositoryProvider.overrideWithValue(repository),
    ...fakeBackend(),
  ];
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: theme ?? AppTheme.dark,
        home: const Scaffold(body: RequestScreen()),
      ),
    ),
  );
  await tester.pump();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(RequestScreen)),
  );
  // Tabs start empty; the builder needs one open request.
  container.read(requestTabsProvider.notifier).openNew();
  await tester.pump();
  return container;
}

void _stubResponse(
  MockHttpRequestRepository repository,
  Result<HttpResponseResult> result,
) {
  when(() => repository.send(any(), any())).thenAnswer((_) async => result);
}

void main() {
  late MockHttpRequestRepository repository;

  setUpAll(() {
    registerFallbackValue(PreparedRequest(method: 'GET', url: Uri()));
    registerFallbackValue(CancelSignal());
  });

  setUp(() => repository = MockHttpRequestRepository());

  testWidgets('shows an idle response pane first', (tester) async {
    await _pump(tester, repository);

    expect(find.text('Send a request to see the response.'), findsOneWidget);
    expect(find.text('GET'), findsOneWidget);
  });

  testWidgets('typing a query in the URL fills the Params table', (
    tester,
  ) async {
    await _pump(tester, repository);

    await tester.enterText(_urlField, 'http://a.test/p?x=1&y=2');
    await tester.pump();

    expect(find.widgetWithText(TextField, 'x'), findsOneWidget);
    expect(find.widgetWithText(TextField, '2'), findsOneWidget);
  });

  testWidgets('editing a param rewrites the URL field', (tester) async {
    final container = await _pump(tester, repository);
    await tester.enterText(_urlField, 'http://a.test/p');
    await tester.tap(find.text('Add'));
    await tester.pump();

    // The new row's key field is the first empty text field.
    await tester.enterText(find.widgetWithText(TextField, '').first, 'page');
    await tester.pump();

    expect(container.read(requestDraftProvider).url, 'http://a.test/p?page');
    expect(
      tester.widget<TextField>(_urlField).controller!.text,
      'http://a.test/p?page',
    );
  });

  testWidgets('Send shows status, time, size and headers', (tester) async {
    _stubResponse(repository, const Result.success(_jsonResponse));
    await _pump(tester, repository);

    await tester.enterText(_urlField, 'http://a.test');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    expect(find.byType(StatusChip), findsOneWidget);
    expect(find.text('200 OK'), findsOneWidget);
    expect(find.text('42 ms'), findsOneWidget);
    expect(find.text('2.0 KB'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(ResponseViewer),
        matching: find.text('Headers'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is SelectableText &&
            (w.textSpan?.toPlainText() ?? '') ==
                'content-type: application/json',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Ctrl+Enter sends the request', (tester) async {
    _stubResponse(repository, const Result.success(_jsonResponse));
    await _pump(tester, repository);
    await tester.enterText(_urlField, 'http://a.test');

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();

    verify(() => repository.send(any(), any())).called(1);
    expect(find.text('200 OK'), findsOneWidget);
  });

  testWidgets('shows a loading state that can be cancelled', (tester) async {
    final pending = Completer<Result<HttpResponseResult>>();
    when(() => repository.send(any(), any())).thenAnswer((_) => pending.future);
    await _pump(tester, repository);
    await tester.enterText(_urlField, 'http://a.test');

    await tester.tap(find.text('Send'));
    await tester.pump();
    expect(find.text('Sending…'), findsOneWidget);
    expect(find.text('Cancel'), findsNWidgets(2));

    await tester.tap(find.text('Cancel').first);
    await tester.pump();

    expect(find.text('Sending…'), findsNothing);
    expect(find.text('Send'), findsOneWidget);
    pending.complete(const Result.success(_jsonResponse));
  });

  testWidgets('shows validation and network failures', (tester) async {
    _stubResponse(
      repository,
      const Result.failure(NetworkFailure('The request timed out.')),
    );
    await _pump(tester, repository);

    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a URL.'), findsOneWidget);

    await tester.enterText(_urlField, 'http://a.test');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect(find.text('The request timed out.'), findsOneWidget);
  });

  testWidgets('toggles Pretty / Raw and copies the shown body', (tester) async {
    _stubResponse(repository, const Result.success(_jsonResponse));
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await _pump(tester, repository);
    await tester.enterText(_urlField, 'http://a.test');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Copy body'));
    await tester.pump();
    expect(copied, _jsonResponse.prettyBody);

    await tester.tap(find.text('Raw'));
    await tester.pump();
    await tester.tap(find.byTooltip('Copy body'));
    await tester.pump();
    expect(copied, _jsonResponse.body);
  });

  testWidgets('Auth tab updates the draft', (tester) async {
    final container = await _pump(tester, repository);

    await tester.tap(find.text('Auth'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bearer token'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Token'), 'abc');

    expect(
      container.read(requestDraftProvider).auth,
      const RequestAuth.bearer(token: 'abc'),
    );
  });

  testWidgets('Body tab switches types', (tester) async {
    final container = await _pump(tester, repository);

    await tester.tap(find.text('Body'));
    await tester.pumpAndSettle();
    expect(find.text('This request has no body.'), findsOneWidget);

    await tester.tap(find.text('x-www-form-urlencoded'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pump();

    final body = container.read(requestDraftProvider).body;
    expect(body.type, BodyType.urlEncoded);
    expect(body.fields, hasLength(1));

    await tester.tap(find.text('JSON'));
    await tester.pumpAndSettle();
    expect(container.read(requestDraftProvider).body.type, BodyType.json);
  });

  testWidgets('works in the light theme', (tester) async {
    _stubResponse(repository, const Result.success(_jsonResponse));
    await _pump(tester, repository, theme: AppTheme.light);
    await tester.enterText(_urlField, 'http://a.test');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    expect(find.text('200 OK'), findsOneWidget);
  });
}
