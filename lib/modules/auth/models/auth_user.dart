import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';

/// The user of the current session: a guest (anonymous) or a signed-in account.
@freezed
abstract class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    required bool isAnonymous,
    String? email,

    /// GitHub user name or full name, when the provider shares it.
    String? name,
  }) = _AuthUser;

  const AuthUser._();

  /// What the Account dialog and avatar tooltip show for a signed-in user.
  String? get label {
    for (final value in [name, email]) {
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  /// Letter shown in the avatar for signed-in users.
  String get initial {
    final value = label;
    return value == null ? '?' : value[0].toUpperCase();
  }
}
