import 'dart:async';

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:mocktail/mocktail.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/auth/auth.dart';
import 'package:test_point/modules/collections/collections.dart';
import 'package:test_point/modules/environments/environments.dart';
import 'package:test_point/modules/requests/requests.dart';
import 'package:test_point/modules/settings/settings.dart';
import 'package:test_point/modules/workspaces/workspaces.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockWorkspaceRepository extends Mock implements WorkspaceRepository {}

const guestUser = AuthUser(id: 'guest-1', isAnonymous: true);
const testWorkspace = Workspace(
  id: 'ws-1',
  organizationId: 'org-1',
  name: 'My Workspace',
);

/// Mocked auth and workspace repositories so widget tests never touch Supabase.
MockAuthRepository stubAuth({AuthUser? user = guestUser}) {
  final repository = MockAuthRepository();
  when(() => repository.currentUser).thenReturn(user);
  when(() => repository.userChanges).thenAnswer((_) => const Stream.empty());
  when(() => repository.callbackErrors).thenAnswer((_) => const Stream.empty());
  when(() => repository.signInAnonymously())
      .thenAnswer((_) async => const Result.success(guestUser));
  return repository;
}

MockWorkspaceRepository stubWorkspaces([Result<Workspace>? result]) {
  final repository = MockWorkspaceRepository();
  when(() => repository.loadDefault())
      .thenAnswer((_) async => result ?? const Result.success(testWorkspace));
  return repository;
}

/// In-memory stand-in for the database, shared by the fake collection and
/// request repositories so deletes cascade and duplicates copy requests.
class FakeStore {
  FakeStore({
    List<Collection> collections = const [],
    List<SavedRequest> requests = const [],
    List<Environment> environments = const [],
  }) : collections = [...collections],
       requests = [...requests],
       environments = [...environments];

  final List<Collection> collections;
  final List<SavedRequest> requests;
  final List<Environment> environments;

  /// When set, every repository call fails with it.
  Failure? failure;

  int _counter = 0;
  String nextId(String prefix) => '$prefix-${++_counter}';
}

class FakeCollectionRepository implements CollectionRepository {
  FakeCollectionRepository(this.store);

  final FakeStore store;

  Result<T>? _failed<T>() =>
      store.failure == null ? null : Result.failure(store.failure!);

  @override
  Future<Result<List<Collection>>> list(String workspaceId) async =>
      _failed() ?? Result.success([...store.collections]);

  @override
  Future<Result<Collection>> create({
    required String workspaceId,
    required String name,
    required int position,
  }) async {
    final failed = _failed<Collection>();
    if (failed != null) return failed;
    final created = Collection(
      id: store.nextId('col'),
      workspaceId: workspaceId,
      name: name,
      position: position,
    );
    store.collections.add(created);
    return Result.success(created);
  }

  @override
  Future<Result<Collection>> rename(String id, String name) async {
    final failed = _failed<Collection>();
    if (failed != null) return failed;
    final index = store.collections.indexWhere((c) => c.id == id);
    store.collections[index] = store.collections[index].copyWith(name: name);
    return Result.success(store.collections[index]);
  }

  @override
  Future<Result<void>> delete(String id) async {
    final failed = _failed<void>();
    if (failed != null) return failed;
    store.collections.removeWhere((c) => c.id == id);
    store.requests.removeWhere((r) => r.collectionId == id);
    return const Result.success(null);
  }

  @override
  Future<Result<Collection>> duplicate(String id, String newName) async {
    final failed = _failed<Collection>();
    if (failed != null) return failed;
    final source = store.collections.firstWhere((c) => c.id == id);
    final copy = source.copyWith(
      id: store.nextId('col'),
      name: newName,
      position: store.collections.length,
    );
    store.collections.add(copy);
    for (final r in [...store.requests.where((r) => r.collectionId == id)]) {
      store.requests.add(
        r.copyWith(id: store.nextId('req'), collectionId: copy.id),
      );
    }
    return Result.success(copy);
  }
}

class FakeSavedRequestRepository implements SavedRequestRepository {
  FakeSavedRequestRepository(this.store);

  final FakeStore store;

  Result<T>? _failed<T>() =>
      store.failure == null ? null : Result.failure(store.failure!);

  @override
  Future<Result<List<SavedRequest>>> listByCollections(
    List<String> collectionIds,
  ) async =>
      _failed() ??
      Result.success([
        for (final r in store.requests)
          if (collectionIds.contains(r.collectionId)) r,
      ]);

  @override
  Future<Result<SavedRequest>> create({
    required String collectionId,
    required String name,
    required int position,
    required HttpRequestDraft draft,
  }) async {
    final failed = _failed<SavedRequest>();
    if (failed != null) return failed;
    final created = SavedRequest(
      id: store.nextId('req'),
      collectionId: collectionId,
      name: name,
      position: position,
      draft: draft,
    );
    store.requests.add(created);
    return Result.success(created);
  }

  @override
  Future<Result<SavedRequest>> update(
    String id, {
    required String name,
    required HttpRequestDraft draft,
  }) async {
    final failed = _failed<SavedRequest>();
    if (failed != null) return failed;
    final index = store.requests.indexWhere((r) => r.id == id);
    store.requests[index] = store.requests[index].copyWith(
      name: name,
      draft: draft,
    );
    return Result.success(store.requests[index]);
  }

  @override
  Future<Result<SavedRequest>> rename(String id, String name) async {
    final failed = _failed<SavedRequest>();
    if (failed != null) return failed;
    final index = store.requests.indexWhere((r) => r.id == id);
    store.requests[index] = store.requests[index].copyWith(name: name);
    return Result.success(store.requests[index]);
  }

  @override
  Future<Result<void>> delete(String id) async {
    final failed = _failed<void>();
    if (failed != null) return failed;
    store.requests.removeWhere((r) => r.id == id);
    return const Result.success(null);
  }
}

class FakeEnvironmentRepository implements EnvironmentRepository {
  FakeEnvironmentRepository(this.store);

  final FakeStore store;

  Result<T>? _failed<T>() =>
      store.failure == null ? null : Result.failure(store.failure!);

  @override
  Future<Result<List<Environment>>> list(String workspaceId) async =>
      _failed() ?? Result.success([...store.environments]);

  @override
  Future<Result<Environment>> create({
    required String workspaceId,
    required String name,
  }) async {
    final failed = _failed<Environment>();
    if (failed != null) return failed;
    final created = Environment(
      id: store.nextId('env'),
      workspaceId: workspaceId,
      name: name,
    );
    store.environments.add(created);
    return Result.success(created);
  }

  Future<Result<Environment>> _update(
    String id,
    Environment Function(Environment) change,
  ) async {
    final failed = _failed<Environment>();
    if (failed != null) return failed;
    final index = store.environments.indexWhere((e) => e.id == id);
    store.environments[index] = change(store.environments[index]);
    return Result.success(store.environments[index]);
  }

  @override
  Future<Result<Environment>> rename(String id, String name) =>
      _update(id, (e) => e.copyWith(name: name));

  @override
  Future<Result<Environment>> saveVariables(
    String id,
    List<EnvironmentVariable> variables,
  ) => _update(id, (e) => e.copyWith(variables: variables));

  @override
  Future<Result<void>> delete(String id) async {
    final failed = _failed<void>();
    if (failed != null) return failed;
    store.environments.removeWhere((e) => e.id == id);
    return const Result.success(null);
  }
}

/// In-memory auth backend: guests, GitHub link / sign-in and sign-out.
///
/// With [holdBrowser] the GitHub calls wait, like the real browser round trip,
/// until [finishBrowser] or `cancelPendingGitHub` is called.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this._user = guestUser});

  AuthUser? _user;
  final _changes = StreamController<AuthUser?>.broadcast();

  /// When true the GitHub account already has a Test Point account, so linking
  /// fails and signing in switches to that account.
  bool githubAccountExists = false;

  /// Make GitHub calls wait for [finishBrowser].
  bool holdBrowser = false;

  Failure? nextFailure;
  final calls = <String>[];
  Completer<void>? _browser;
  Completer<Failure?>? _cancelled;
  int _guests = 0;

  static const githubUser = AuthUser(
    id: 'acct-github',
    isAnonymous: false,
    email: 'rex@test.dev',
    name: 'rex',
  );

  void _emit(AuthUser? user) {
    _user = user;
    _changes.add(user);
  }

  /// Simulates the browser returning to the app.
  void finishBrowser() => _browser?.complete();

  Result<T>? _fail<T>() {
    final failure = nextFailure;
    nextFailure = null;
    return failure == null ? null : Result.failure(failure);
  }

  /// Waits for the "browser" when held; returns a failure if cancelled.
  Future<Failure?> _browse() async {
    if (!holdBrowser) return null;
    _browser = Completer<void>();
    _cancelled = Completer<Failure?>();
    final outcome = await Future.any<Failure?>([
      _browser!.future.then((_) => null),
      _cancelled!.future,
    ]);
    _browser = null;
    _cancelled = null;
    return outcome;
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Stream<AuthUser?> get userChanges => _changes.stream;

  @override
  Stream<Failure> get callbackErrors => const Stream.empty();

  @override
  Future<Result<AuthUser>> signInAnonymously() async {
    calls.add('guest');
    final guest = AuthUser(id: 'guest-${++_guests + 1}', isAnonymous: true);
    _emit(guest);
    return Result.success(guest);
  }

  @override
  Future<Result<AuthUser>> linkGitHub() async {
    calls.add('link');
    final cancelled = await _browse();
    if (cancelled != null) return Result.failure(cancelled);
    final failed = _fail<AuthUser>();
    if (failed != null) return failed;
    if (githubAccountExists) {
      return const Result.failure(GitHubAccountExistsFailure());
    }
    final upgraded = AuthUser(
      id: _user!.id,
      isAnonymous: false,
      email: githubUser.email,
      name: githubUser.name,
    );
    _emit(upgraded);
    return Result.success(upgraded);
  }

  @override
  Future<Result<AuthUser>> signInWithGitHub() async {
    calls.add('signIn');
    final cancelled = await _browse();
    if (cancelled != null) return Result.failure(cancelled);
    final failed = _fail<AuthUser>();
    if (failed != null) return failed;
    _emit(githubUser);
    return const Result.success(githubUser);
  }

  @override
  void cancelPendingGitHub() {
    calls.add('cancel');
    final pending = _cancelled;
    if (pending != null && !pending.isCompleted) {
      pending.complete(const AuthFailure('GitHub sign-in was cancelled.'));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    calls.add('signOut');
    final failed = _fail<void>();
    if (failed != null) return failed;
    _emit(null);
    return const Result.success(null);
  }
}

/// Keeps settings in memory so tests never touch the device's preferences.
class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository([this.settings = const AppSettings()]);

  AppSettings settings;

  /// When set, saving fails with it.
  Failure? saveFailure;

  @override
  AppSettings load() => settings;

  @override
  Future<Result<void>> save(AppSettings settings) async {
    if (saveFailure != null) return Result.failure(saveFailure!);
    this.settings = settings;
    return const Result.success(null);
  }
}

List<Override> fakeBackend({
  AuthRepository? auth,
  WorkspaceRepository? workspaces,
  FakeStore? store,
  SettingsRepository? settings,
}) {
  final data = store ?? FakeStore();
  return [
    authRepositoryProvider.overrideWithValue(auth ?? stubAuth()),
    workspaceRepositoryProvider.overrideWithValue(
      workspaces ?? stubWorkspaces(),
    ),
    collectionRepositoryProvider.overrideWithValue(
      FakeCollectionRepository(data),
    ),
    savedRequestRepositoryProvider.overrideWithValue(
      FakeSavedRequestRepository(data),
    ),
    environmentRepositoryProvider.overrideWithValue(
      FakeEnvironmentRepository(data),
    ),
    settingsRepositoryProvider.overrideWithValue(
      settings ?? FakeSettingsRepository(),
    ),
  ];
}
