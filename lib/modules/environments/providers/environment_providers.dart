import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_point/core/database/supabase_client_provider.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/environments/models/environment.dart';
import 'package:test_point/modules/environments/models/environment_variable.dart';
import 'package:test_point/modules/environments/repositories/environment_repository.dart';
import 'package:test_point/modules/environments/repositories/environment_repository_impl.dart';
import 'package:test_point/modules/environments/services/environment_service.dart';
import 'package:test_point/modules/environments/services/variable_resolver.dart';
import 'package:test_point/modules/workspaces/workspaces.dart';

final environmentRepositoryProvider = Provider<EnvironmentRepository>(
  (ref) => EnvironmentRepositoryImpl(ref.watch(supabaseClientProvider)),
);

final environmentServiceProvider = Provider<EnvironmentService>(
  (ref) => EnvironmentService(ref.watch(environmentRepositoryProvider)),
);

/// Environments of the current workspace. Errors carry a `Failure`.
final environmentsProvider =
    AsyncNotifierProvider<EnvironmentsNotifier, List<Environment>>(
      EnvironmentsNotifier.new,
      retry: (_, _) => null,
    );

class EnvironmentsNotifier extends AsyncNotifier<List<Environment>> {
  EnvironmentService get _service => ref.read(environmentServiceProvider);

  List<Environment> get _current => state.value ?? const [];

  @override
  Future<List<Environment>> build() async {
    final workspace = await ref.watch(currentWorkspaceProvider.future);
    final result = await ref
        .watch(environmentServiceProvider)
        .list(workspace.id);
    return result.when(
      success: (environments) => environments,
      failure: (failure) => throw failure,
    );
  }

  Future<Result<Environment>> create(String name) async {
    final workspace = await ref.read(currentWorkspaceProvider.future);
    final result = await _service.create(workspaceId: workspace.id, name: name);
    if (result case Success(:final value)) {
      state = AsyncData([..._current, value]);
    }
    return result;
  }

  Future<Result<Environment>> rename(String id, String name) =>
      _replace(_service.rename(id, name));

  Future<Result<Environment>> saveVariables(
    String id,
    List<EnvironmentVariable> variables,
  ) => _replace(_service.saveVariables(id, variables));

  Future<Result<void>> delete(String id) async {
    final result = await _service.delete(id);
    if (result.isSuccess) {
      state = AsyncData([
        for (final e in _current)
          if (e.id != id) e,
      ]);
    }
    return result;
  }

  Future<Result<Environment>> _replace(
    Future<Result<Environment>> pending,
  ) async {
    final result = await pending;
    if (result case Success(:final value)) {
      state = AsyncData([
        for (final e in _current) e.id == value.id ? value : e,
      ]);
    }
    return result;
  }
}

/// Id of the environment picked in the top bar; null means "No environment".
final activeEnvironmentIdProvider =
    NotifierProvider<ActiveEnvironmentIdNotifier, String?>(
      ActiveEnvironmentIdNotifier.new,
    );

class ActiveEnvironmentIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

/// The selected environment, or null when none is selected (or it was deleted).
final activeEnvironmentProvider = Provider<Environment?>((ref) {
  final id = ref.watch(activeEnvironmentIdProvider);
  final environments = ref.watch(environmentsProvider).value ?? const [];
  return environments.where((e) => e.id == id).firstOrNull;
});

/// Resolver over the active environment's enabled variables.
final variableResolverProvider = Provider<VariableResolver>((ref) {
  final environment = ref.watch(activeEnvironmentProvider);
  return environment == null
      ? VariableResolver.empty
      : VariableResolver(environment.values);
});

/// The active environment's `baseUrl` variable, resolved; null if unset.
final activeBaseUrlProvider = Provider<String?>((ref) {
  final resolver = ref.watch(variableResolverProvider);
  if (!resolver.values.containsKey('baseUrl')) return null;
  final url = resolver.apply('{{baseUrl}}');
  return url.isEmpty ? null : url;
});
