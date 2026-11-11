import 'dart:async';

import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/requests/models/http_response_result.dart';
import 'package:test_point/modules/requests/models/prepared_request.dart';

/// Lets the caller cancel an in-flight request without knowing the HTTP client.
class CancelSignal {
  final _completer = Completer<void>();

  bool get isCancelled => _completer.isCompleted;
  Future<void> get whenCancelled => _completer.future;

  void cancel() {
    if (!isCancelled) _completer.complete();
  }
}

abstract interface class HttpRequestRepository {
  /// Sends [request]. A cancelled request returns a `NetworkFailure`.
  Future<Result<HttpResponseResult>> send(
    PreparedRequest request,
    CancelSignal cancelSignal,
  );
}
