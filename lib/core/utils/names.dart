import 'package:test_point/core/error/failure.dart';

const maxNameLength = 255;

/// The trimmed [input] if it is a usable name, otherwise a [ValidationFailure].
({String? name, Failure? failure}) validateName(
  String input, {
  String label = 'Name',
}) {
  final name = input.trim();
  if (name.isEmpty) {
    return (name: null, failure: ValidationFailure('$label is required.'));
  }
  if (name.length > maxNameLength) {
    return (
      name: null,
      failure: ValidationFailure(
        '$label must be $maxNameLength characters or fewer.',
      ),
    );
  }
  return (name: name, failure: null);
}

final _copySuffix = RegExp(r' copy( \d+)?$');

/// Name for a duplicate of [name]: `X copy`, then `X copy 2`, `X copy 3`...
/// Never collides (case-insensitively) with [existing].
String nextCopyName(String name, Iterable<String> existing) {
  final taken = {for (final n in existing) n.toLowerCase()};
  final base = name.replaceFirst(_copySuffix, '');

  var candidate = '$base copy';
  for (var i = 2; taken.contains(candidate.toLowerCase()); i++) {
    candidate = '$base copy $i';
  }
  return candidate;
}
