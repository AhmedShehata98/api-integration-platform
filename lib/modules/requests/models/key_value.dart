import 'package:freezed_annotation/freezed_annotation.dart';

part 'key_value.freezed.dart';

/// One row of a Params / Headers / form table.
@freezed
abstract class KeyValue with _$KeyValue {
  const factory KeyValue({
    @Default('') String key,
    @Default('') String value,
    @Default(true) bool enabled,
  }) = _KeyValue;
}
