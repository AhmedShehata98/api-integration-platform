import 'package:freezed_annotation/freezed_annotation.dart';

part 'prepared_request.freezed.dart';

/// A fully built request, ready for the HTTP layer: auth applied, default
/// headers set. Exactly one of [body] / [multipartFields] is set for a body.
@freezed
abstract class PreparedRequest with _$PreparedRequest {
  const factory PreparedRequest({
    required String method,
    required Uri url,
    @Default({}) Map<String, String> headers,
    String? body,
    Map<String, String>? multipartFields,
  }) = _PreparedRequest;
}
