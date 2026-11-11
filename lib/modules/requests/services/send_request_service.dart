import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/environments/environments.dart';
import 'package:test_point/modules/requests/models/http_request_draft.dart';
import 'package:test_point/modules/requests/models/http_response_result.dart';
import 'package:test_point/modules/requests/repositories/http_request_repository.dart';
import 'package:test_point/modules/requests/services/draft_variable_resolver.dart';
import 'package:test_point/modules/requests/services/json_formatter.dart';
import 'package:test_point/modules/requests/services/request_builder.dart';

/// Resolves variables, builds, sends and post-processes a request.
class SendRequestService {
  SendRequestService(
    this._repository, {
    VariableResolver resolver = VariableResolver.empty,
    this._builder = const RequestBuilder(),
  }) : _resolver = DraftVariableResolver(resolver);

  final HttpRequestRepository _repository;
  final DraftVariableResolver _resolver;
  final RequestBuilder _builder;

  Future<Result<HttpResponseResult>> call(
    HttpRequestDraft draft,
    CancelSignal cancelSignal,
  ) async {
    final resolved = _resolver.resolve(draft);
    if (resolved.unresolvedInUrl.isNotEmpty) {
      final names = resolved.unresolvedInUrl.map((n) => '{{$n}}').join(', ');
      return Result.failure(
        ValidationFailure('Undefined variable in the URL: $names.'),
      );
    }

    final prepared = _builder.build(resolved.draft);
    final request = prepared.valueOrNull;
    if (request == null) {
      return Result.failure(prepared.failureOrNull!);
    }

    final sent = await _repository.send(request, cancelSignal);
    final response = sent.valueOrNull;
    if (response == null) return sent;

    return Result.success(await _withPrettyBody(response));
  }

  Future<HttpResponseResult> _withPrettyBody(
    HttpResponseResult response,
  ) async {
    final contentType = response.headers.entries
        .where((e) => e.key.toLowerCase() == 'content-type')
        .expand((e) => e.value)
        .firstOrNull;
    if (!looksLikeJson(response.body, contentType: contentType)) {
      return response;
    }
    return response.copyWith(prettyBody: await prettyPrintJson(response.body));
  }
}
