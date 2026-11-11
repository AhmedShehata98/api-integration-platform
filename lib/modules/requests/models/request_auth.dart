import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_auth.freezed.dart';

enum ApiKeyLocation { header, query }

/// Auth tab settings.
@freezed
sealed class RequestAuth with _$RequestAuth {
  const factory RequestAuth.none() = NoAuth;
  const factory RequestAuth.bearer({@Default('') String token}) = BearerAuth;
  const factory RequestAuth.basic({
    @Default('') String username,
    @Default('') String password,
  }) = BasicAuth;
  const factory RequestAuth.apiKey({
    @Default('') String name,
    @Default('') String value,
    @Default(ApiKeyLocation.header) ApiKeyLocation location,
  }) = ApiKeyAuth;
}
