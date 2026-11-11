import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:test_point/modules/requests/models/key_value.dart';

part 'request_body.freezed.dart';

enum BodyType {
  none('none'),
  json('JSON'),
  formData('form-data'),
  urlEncoded('x-www-form-urlencoded'),
  raw('raw');

  const BodyType(this.label);

  final String label;
}

/// Body tab settings. [text] is used by JSON and raw; [fields] by the form types.
@freezed
abstract class RequestBody with _$RequestBody {
  const factory RequestBody({
    @Default(BodyType.none) BodyType type,
    @Default('') String text,
    @Default([]) List<KeyValue> fields,
  }) = _RequestBody;
}
