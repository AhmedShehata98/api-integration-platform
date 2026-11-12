import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_point/app/shell/nav_rail.dart';
import 'package:test_point/modules/auth/auth.dart';
import 'package:test_point/app/shell/sidebar/sidebar.dart';
import 'package:test_point/app/shell/status_bar.dart';
import 'package:test_point/app/shell/top_bar.dart';
import 'package:test_point/app/shell/workspace_gate.dart';

class _FocusFilterIntent extends Intent {
  const _FocusFilterIntent();
}

/// Workspace shell: nav rail, top bar, sidebar, page content and status bar.
class AppShell extends StatefulWidget {
  const AppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _filterFocus = FocusNode(debugLabel: 'sidebar filter');

  /// Sections that browse collections show the sidebar.
  bool get _showSidebar =>
      widget.location.startsWith('/collections') ||
      widget.location.startsWith('/request');

  @override
  void dispose() {
    _filterFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.keyK, control: true):
            _FocusFilterIntent(),
      },
      child: Actions(
        actions: {
          _FocusFilterIntent: CallbackAction<_FocusFilterIntent>(
            onInvoke: (_) {
              if (_showSidebar) _filterFocus.requestFocus();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: AuthCallbackErrorListener(
            child: Scaffold(
              body: Row(
                children: [
                  ShellNavRail(location: widget.location),
                  Expanded(
                    child: Column(
                      children: [
                        const ShellTopBar(),
                        Expanded(
                          child: WorkspaceGate(
                            child: Row(
                              children: [
                                if (_showSidebar)
                                  ShellSidebar(filterFocus: _filterFocus),
                                Expanded(child: widget.child),
                              ],
                            ),
                          ),
                        ),
                        const ShellStatusBar(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
