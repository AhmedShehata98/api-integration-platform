import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/core/ui/widgets/resizable_split_pane.dart';

const _first = Key('first');
const _second = Key('second');
final _handle = find.bySemanticsLabel('Resize panels');

Widget _pane({
  double width = 400,
  double height = 600,
  Axis axis = Axis.vertical,
  double minFirst = 100,
  double minSecond = 80,
}) => MaterialApp(
  home: Align(
    alignment: Alignment.topLeft,
    child: SizedBox(
      width: width,
      height: height,
      child: ResizableSplitPane(
        axis: axis,
        minFirstSize: minFirst,
        minSecondSize: minSecond,
        first: Container(key: _first, color: Colors.red),
        second: Container(key: _second, color: Colors.blue),
      ),
    ),
  ),
);

double _size(WidgetTester tester, Key key, {bool vertical = true}) {
  final size = tester.getSize(find.byKey(key));
  return vertical ? size.height : size.width;
}

void main() {
  const handle = ResizableSplitPane.handleThickness;

  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1000, 1200);
    view.devicePixelRatio = 1;
    addTearDown(view.reset);
  });

  testWidgets('starts at 55% / 45% of the available height', (tester) async {
    await tester.pumpWidget(_pane());

    const available = 600 - handle;
    expect(_size(tester, _first), closeTo(available * 0.55, 0.5));
    expect(_size(tester, _second), closeTo(available * 0.45, 0.5));
  });

  testWidgets('dragging the handle moves the split', (tester) async {
    await tester.pumpWidget(_pane());
    final before = _size(tester, _first);

    await _drag(tester, const Offset(0, 60));
    await tester.pump();

    expect(_size(tester, _first), closeTo(before + 60, 1));
    expect(_size(tester, _first) + _size(tester, _second) + handle, 600);
  });

  testWidgets('neither panel can go below its minimum size', (tester) async {
    await tester.pumpWidget(_pane());

    await _drag(tester, const Offset(0, -1000));
    await tester.pump();
    expect(_size(tester, _first), 100);

    await _drag(tester, const Offset(0, 2000));
    await tester.pump();
    expect(_size(tester, _second), 80);
  });

  testWidgets('the split follows the parent when it is resized', (
    tester,
  ) async {
    await tester.pumpWidget(_pane(height: 600));
    await _drag(tester, const Offset(0, 100));
    await tester.pump();
    final ratio = _size(tester, _first) / (600 - handle);

    await tester.pumpWidget(_pane(height: 900));

    expect(_size(tester, _first), closeTo(ratio * (900 - handle), 1));
    expect(_size(tester, _first) + _size(tester, _second) + handle, 900);
  });

  testWidgets('minimum sizes win when the parent shrinks', (tester) async {
    await tester.pumpWidget(_pane(height: 600));
    await _drag(tester, const Offset(0, -1000));
    await tester.pump();

    await tester.pumpWidget(_pane(height: 250));

    expect(_size(tester, _first), greaterThanOrEqualTo(100));
    expect(_size(tester, _second), greaterThanOrEqualTo(80));
  });

  testWidgets('a parent too small for both minimums shares the space', (
    tester,
  ) async {
    await tester.pumpWidget(_pane(height: 150));

    expect(tester.takeException(), isNull);
    expect(_size(tester, _first) + _size(tester, _second) + handle, 150);
    expect(_size(tester, _first), greaterThan(0));
    expect(_size(tester, _second), greaterThan(0));
  });

  testWidgets('double-tapping the handle restores the default split', (
    tester,
  ) async {
    await tester.pumpWidget(_pane());
    final initial = _size(tester, _first);
    await _drag(tester, const Offset(0, 120));
    await tester.pump();

    await tester.tap(_handle);
    await tester.pump(kDoubleTapMinTime);
    await tester.tap(_handle);
    await tester.pump(const Duration(milliseconds: 300));

    expect(_size(tester, _first), closeTo(initial, 0.5));
  });

  testWidgets('shows a row-resize cursor on hover', (tester) async {
    await tester.pumpWidget(_pane());
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);

    await mouse.moveTo(tester.getCenter(_handle));
    await tester.pump();

    expect(
      RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
      SystemMouseCursors.resizeRow,
    );
  });

  testWidgets('works side by side with a column-resize cursor', (tester) async {
    await tester.pumpWidget(_pane(axis: Axis.horizontal));
    final before = _size(tester, _first, vertical: false);

    await _drag(tester, const Offset(50, 0));
    await tester.pump();

    expect(_size(tester, _first, vertical: false), closeTo(before + 50, 1));
  });

  testWidgets('taps inside the panels still reach them', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 600,
          child: ResizableSplitPane(
            first: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => taps++,
              child: const ColoredBox(color: Colors.red),
            ),
            second: const ColoredBox(color: Colors.blue),
          ),
        ),
      ),
    );

    await tester.tapAt(const Offset(100, 100));

    expect(taps, 1);
  });
}

/// Drags the handle by exactly [offset]. A first small move starts the drag
/// (the framework does not report it as an update), the second is measured.
Future<void> _drag(WidgetTester tester, Offset offset) async {
  final gesture = await tester.startGesture(tester.getCenter(_handle));
  final start = Offset(
    offset.dx == 0 ? 0 : offset.dx.sign * 30,
    offset.dy == 0 ? 0 : offset.dy.sign * 30,
  );
  await gesture.moveBy(start);
  await gesture.moveBy(offset);
  await gesture.up();
  // Let the double-tap recognizer's timer run out.
  await tester.pump(const Duration(milliseconds: 300));
}
