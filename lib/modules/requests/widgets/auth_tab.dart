import 'package:flutter/material.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/modules/requests/models/request_auth.dart';

enum _AuthKind {
  none('None'),
  bearer('Bearer token'),
  basic('Basic auth'),
  apiKey('API key');

  const _AuthKind(this.label);

  final String label;
}

/// Auth tab: None, Bearer token, Basic auth or API key.
class AuthTab extends StatelessWidget {
  const AuthTab({required this.auth, required this.onChanged, super.key});

  final RequestAuth auth;
  final ValueChanged<RequestAuth> onChanged;

  _AuthKind get _kind => switch (auth) {
    NoAuth() => _AuthKind.none,
    BearerAuth() => _AuthKind.bearer,
    BasicAuth() => _AuthKind.basic,
    ApiKeyAuth() => _AuthKind.apiKey,
  };

  RequestAuth _defaultFor(_AuthKind kind) => switch (kind) {
    _AuthKind.none => const RequestAuth.none(),
    _AuthKind.bearer => const RequestAuth.bearer(),
    _AuthKind.basic => const RequestAuth.basic(),
    _AuthKind.apiKey => const RequestAuth.apiKey(),
  };

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SegmentedButton<_AuthKind>(
            showSelectedIcon: false,
            segments: [
              for (final kind in _AuthKind.values)
                ButtonSegment(
                  value: kind,
                  label: Text(kind.label, maxLines: 1),
                ),
            ],
            selected: {_kind},
            onSelectionChanged: (selection) =>
                onChanged(_defaultFor(selection.first)),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ..._fields(),
      ],
    );
  }

  List<Widget> _fields() {
    return switch (auth) {
      NoAuth() => const [Text('This request does not use authorization.')],
      final BearerAuth a => [
        _Field(
          label: 'Token',
          value: a.token,
          obscure: true,
          onChanged: (v) => onChanged(a.copyWith(token: v)),
        ),
      ],
      final BasicAuth a => [
        _Field(
          label: 'Username',
          value: a.username,
          onChanged: (v) => onChanged(a.copyWith(username: v)),
        ),
        _Field(
          label: 'Password',
          value: a.password,
          obscure: true,
          onChanged: (v) => onChanged(a.copyWith(password: v)),
        ),
      ],
      final ApiKeyAuth a => [
        _Field(
          label: 'Key',
          value: a.name,
          onChanged: (v) => onChanged(a.copyWith(name: v)),
        ),
        _Field(
          label: 'Value',
          value: a.value,
          obscure: true,
          onChanged: (v) => onChanged(a.copyWith(value: v)),
        ),
        SegmentedButton<ApiKeyLocation>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: ApiKeyLocation.header, label: Text('Header')),
            ButtonSegment(
              value: ApiKeyLocation.query,
              label: Text('Query params'),
            ),
          ],
          selected: {a.location},
          onSelectionChanged: (s) => onChanged(a.copyWith(location: s.first)),
        ),
      ],
    };
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.value,
    required this.onChanged,
    this.obscure = false,
  });

  final String label;
  final String value;
  final bool obscure;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: SizedBox(
        width: 420,
        child: TextFormField(
          initialValue: value,
          obscureText: obscure,
          onChanged: onChanged,
          decoration: InputDecoration(labelText: label, isDense: true),
        ),
      ),
    );
  }
}
