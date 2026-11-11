final _variablePattern = RegExp(r'\{\{\s*([^{}\s]+)\s*\}\}');

/// Text with its `{{variables}}` replaced, plus the names that had no value.
class ResolvedText {
  const ResolvedText(this.text, [this.unresolved = const {}]);

  final String text;
  final Set<String> unresolved;
}

/// Replaces `{{name}}` with the value from [values].
///
/// - Values may reference other variables (`{{a}}` -> `{{b}}/x`); a cycle is
///   left unresolved instead of looping.
/// - Unknown names stay as written and are reported in [ResolvedText.unresolved].
/// - Secret variables resolve like any other; secrecy only affects the UI.
class VariableResolver {
  const VariableResolver(this.values);

  /// Resolver with no variables: everything stays unresolved.
  static const empty = VariableResolver({});

  final Map<String, String> values;

  ResolvedText resolve(String input) {
    final unresolved = <String>{};
    final text = _expand(input, const {}, unresolved);
    return ResolvedText(text, unresolved);
  }

  /// Shortcut for callers that only need the text.
  String apply(String input) => resolve(input).text;

  /// Names referenced by [input], in order, without duplicates.
  static List<String> namesIn(String input) =>
      {for (final match in _variablePattern.allMatches(input)) match.group(1)!}
          .toList();

  String _expand(String input, Set<String> stack, Set<String> unresolved) {
    return input.replaceAllMapped(_variablePattern, (match) {
      final name = match.group(1)!;
      final value = values[name];
      if (value == null || stack.contains(name)) {
        unresolved.add(name);
        return match.group(0)!;
      }
      return _expand(value, {...stack, name}, unresolved);
    });
  }
}
