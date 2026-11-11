/// Public interface of the auth module.
/// Other modules must import ONLY this file.
library;

export 'models/auth_user.dart';
export 'models/github_account_exists_failure.dart';
export 'providers/auth_providers.dart';
export 'repositories/auth_repository.dart'; // abstract contract only
export 'widgets/user_avatar.dart';
