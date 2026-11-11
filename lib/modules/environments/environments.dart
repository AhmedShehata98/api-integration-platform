/// Public interface of the environments module.
/// Other modules must import ONLY this file.
library;

export 'environments_routes.dart';
export 'models/environment.dart';
export 'models/environment_variable.dart';
export 'providers/environment_providers.dart';
export 'repositories/environment_repository.dart'; // abstract contract only
export 'services/variable_resolver.dart';
export 'widgets/environment_dropdown.dart';
