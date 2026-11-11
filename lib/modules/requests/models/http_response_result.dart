import 'package:freezed_annotation/freezed_annotation.dart';

part 'http_response_result.freezed.dart';

@freezed
abstract class HttpResponseResult with _$HttpResponseResult {
  const factory HttpResponseResult({
    required int statusCode,
    required Map<String, List<String>> headers,
    required String body,
    required Duration duration,
    required int sizeBytes,
    String? reason,

    /// Indented JSON, set when the body is valid JSON.
    String? prettyBody,
  }) = _HttpResponseResult;
}
