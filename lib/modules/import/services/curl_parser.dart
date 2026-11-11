import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/import/models/import_result.dart';
import 'package:test_point/modules/requests/requests.dart';

/// Options that take a value but have no effect on the request we build.
const _ignoredWithValue = {
  '-o',
  '--output',
  '-m',
  '--max-time',
  '--connect-timeout',
  '-x',
  '--proxy',
  '--cacert',
  '--cert',
  '--key',
  '-w',
  '--write-out',
  '-e',
  '--referer',
  '--retry',
};

/// Options without a value that do not change the request.
const _ignoredFlags = {
  '-L',
  '--location',
  '-s',
  '--silent',
  '-S',
  '--show-error',
  '-k',
  '--insecure',
  '--compressed',
  '-i',
  '--include',
  '-v',
  '--verbose',
  '-g',
  '--globoff',
  '-f',
  '--fail',
  '-N',
  '--no-buffer',
  '--http1.1',
  '--http2',
};

const _dataOptions = {
  '-d',
  '--data',
  '--data-raw',
  '--data-binary',
  '--data-ascii',
  '--data-urlencode',
};

/// Turns a cURL command line into a request. Handles quoting, `\` line
/// continuations and the bash `$'...'` form that browsers produce.
class CurlParser {
  const CurlParser();

  Result<ParsedImport> parse(String input) {
    final List<String> tokens;
    try {
      tokens = _tokenize(input);
    } on FormatException catch (error) {
      return Result.failure(ValidationFailure(error.message));
    }
    if (tokens.isEmpty || tokens.first != 'curl') {
      return const Result.failure(
        ValidationFailure('This does not look like a cURL command.'),
      );
    }
    return _build(tokens.skip(1).toList());
  }

  Result<ParsedImport> _build(List<String> args) {
    final state = _CurlState();
    for (var i = 0; i < args.length; i++) {
      final arg = args[i];
      if (!arg.startsWith('-') || arg == '-') {
        state.url ??= arg;
        continue;
      }
      // "--request=POST" and "-XPOST" carry their value inside the token.
      var option = arg;
      String? attached;
      if (arg.startsWith('--') && arg.contains('=')) {
        option = arg.substring(0, arg.indexOf('='));
        attached = arg.substring(arg.indexOf('=') + 1);
      } else if (!arg.startsWith('--') && arg.length > 2) {
        option = arg.substring(0, 2);
        attached = arg.substring(2);
      }

      final takesValue =
          const {
            '-X',
            '--request',
            '-H',
            '--header',
            '-u',
            '--user',
            '-F',
            '--form',
            '--url',
            '-b',
            '--cookie',
            '-A',
            '--user-agent',
          }.contains(option) ||
          _dataOptions.contains(option) ||
          _ignoredWithValue.contains(option);

      if (takesValue) {
        final value = attached ?? (i + 1 < args.length ? args[++i] : null);
        if (value == null) {
          return Result.failure(ValidationFailure('"$option" needs a value.'));
        }
        state.apply(option, value);
      } else if (option == '-G' || option == '--get') {
        state.getMode = true;
      } else if (option == '-I' || option == '--head') {
        state.method ??= HttpMethod.head;
      } else if (_ignoredFlags.contains(option)) {
        continue;
      } else if (attached != null && !arg.startsWith('--')) {
        // Combined short flags such as "-sS" or "-sL".
        for (final flag in arg.substring(1).split('')) {
          if (!_ignoredFlags.contains('-$flag')) {
            state.skipped.add('Option -$flag was ignored.');
          }
        }
      } else {
        state.skipped.add('Option $option was ignored.');
      }
    }
    return state.finish();
  }
}

/// Splits a command line into arguments the way a POSIX shell would.
List<String> _tokenize(String input) {
  final text = input.replaceAll(RegExp(r'\\\r?\n'), ' ').trim();
  final tokens = <String>[];
  final current = StringBuffer();
  var inToken = false;

  void flush() {
    if (inToken) tokens.add(current.toString());
    current.clear();
    inToken = false;
  }

  for (var i = 0; i < text.length; i++) {
    final char = text[i];
    if (char == ' ' || char == '\t' || char == '\n' || char == '\r') {
      flush();
    } else if (char == "'") {
      inToken = true;
      final end = text.indexOf("'", i + 1);
      if (end == -1) throw const FormatException('Unclosed quote in command.');
      current.write(text.substring(i + 1, end));
      i = end;
    } else if (char == r'$' && i + 1 < text.length && text[i + 1] == "'") {
      inToken = true;
      i = _readAnsiC(text, i + 2, current);
    } else if (char == '"') {
      inToken = true;
      i = _readDoubleQuoted(text, i + 1, current);
    } else if (char == r'\' && i + 1 < text.length) {
      inToken = true;
      current.write(text[++i]);
    } else {
      inToken = true;
      current.write(char);
    }
  }
  flush();
  return tokens;
}

/// Reads a `"..."` string starting after the opening quote; returns the index
/// of the closing quote.
int _readDoubleQuoted(String text, int start, StringBuffer out) {
  for (var i = start; i < text.length; i++) {
    final char = text[i];
    if (char == '"') return i;
    if (char == r'\' && i + 1 < text.length && r'"\$`'.contains(text[i + 1])) {
      out.write(text[++i]);
    } else {
      out.write(char);
    }
  }
  throw const FormatException('Unclosed quote in command.');
}

/// Reads a `$'...'` string starting after the opening quote; returns the
/// index of the closing quote.
int _readAnsiC(String text, int start, StringBuffer out) {
  for (var i = start; i < text.length; i++) {
    final char = text[i];
    if (char == "'") return i;
    if (char != r'\' || i + 1 >= text.length) {
      out.write(char);
      continue;
    }
    final next = text[++i];
    switch (next) {
      case 'n':
        out.write('\n');
      case 'r':
        out.write('\r');
      case 't':
        out.write('\t');
      case 'u':
        final hex = text.substring(i + 1, (i + 5).clamp(0, text.length));
        final code = int.tryParse(hex, radix: 16);
        if (code == null) {
          out.write(r'\u');
        } else {
          out.writeCharCode(code);
          i += 4;
        }
      default:
        out.write(next); // \\ \' \" and unknown escapes
    }
  }
  throw const FormatException('Unclosed quote in command.');
}

/// What the options collected so far; turns into a request at the end.
class _CurlState {
  String? url;
  HttpMethod? method;
  bool getMode = false;
  final headers = <KeyValue>[];
  final data = <String>[];
  final form = <KeyValue>[];
  RequestAuth auth = const RequestAuth.none();
  final skipped = <String>[];

  void apply(String option, String value) {
    switch (option) {
      case '-X' || '--request':
        final parsed = HttpMethod.values.asNameMap()[value.toLowerCase()];
        if (parsed == null) {
          skipped.add('Method $value is not supported; using GET.');
        } else {
          method = parsed;
        }
      case '-H' || '--header':
        _addHeader(value);
      case '-u' || '--user':
        final colon = value.indexOf(':');
        auth = RequestAuth.basic(
          username: colon == -1 ? value : value.substring(0, colon),
          password: colon == -1 ? '' : value.substring(colon + 1),
        );
      case '-F' || '--form':
        final eq = value.indexOf('=');
        final key = eq == -1 ? value : value.substring(0, eq);
        final text = eq == -1 ? '' : value.substring(eq + 1);
        if (text.startsWith('@')) {
          skipped.add('File upload for "$key" was skipped.');
        } else {
          form.add(KeyValue(key: key, value: text));
        }
      case '--url':
        url = value;
      case '-b' || '--cookie':
        headers.add(KeyValue(key: 'Cookie', value: value));
      case '-A' || '--user-agent':
        headers.add(KeyValue(key: 'User-Agent', value: value));
      default:
        if (_dataOptions.contains(option)) {
          if (value.startsWith('@')) {
            skipped.add('Data from file "$value" was skipped.');
          } else {
            data.add(value);
          }
        } else {
          skipped.add('Option $option was ignored.');
        }
    }
  }

  void _addHeader(String raw) {
    final colon = raw.indexOf(':');
    if (colon <= 0) {
      skipped.add('Header "$raw" was skipped.');
      return;
    }
    final key = raw.substring(0, colon).trim();
    final value = raw.substring(colon + 1).trim();
    if (key.toLowerCase() == 'authorization' &&
        value.toLowerCase().startsWith('bearer ')) {
      auth = RequestAuth.bearer(token: value.substring(7).trim());
      return;
    }
    headers.add(KeyValue(key: key, value: value));
  }

  Result<ParsedImport> finish() {
    final target = url;
    if (target == null || target.isEmpty) {
      return const Result.failure(
        ValidationFailure('The cURL command has no URL.'),
      );
    }

    var requestUrl = target;
    var body = const RequestBody();
    var requestHeaders = headers;
    final dataText = data.join('&');

    if (form.isNotEmpty) {
      body = RequestBody(type: BodyType.formData, fields: form);
    } else if (dataText.isNotEmpty && getMode) {
      // -G sends the data as the query string.
      requestUrl = '$target${target.contains('?') ? '&' : '?'}$dataText';
    } else if (dataText.isNotEmpty) {
      (body, requestHeaders) = _bodyFrom(dataText, headers);
    }

    final hasBody = body.type != BodyType.none;
    final resolved =
        method ??
        (getMode
            ? HttpMethod.get
            : (hasBody ? HttpMethod.post : HttpMethod.get));

    return Result.success(
      ParsedImport(
        name: _nameFor(resolved, requestUrl),
        requests: [
          ImportedRequest(
            name: _nameFor(resolved, requestUrl),
            draft: HttpRequestDraft(
              method: resolved,
              url: requestUrl,
              headers: requestHeaders,
              auth: auth,
              body: body,
            ),
          ),
        ],
        skipped: skipped,
      ),
    );
  }

  /// Picks the body type from the Content-Type header or the data's shape.
  /// A Content-Type the builder would set by itself is dropped from headers.
  (RequestBody, List<KeyValue>) _bodyFrom(String text, List<KeyValue> all) {
    final contentType = all
        .where((h) => h.key.toLowerCase() == 'content-type')
        .map((h) => h.value.toLowerCase())
        .firstOrNull;
    final trimmed = text.trimLeft();
    final looksJson = trimmed.startsWith('{') || trimmed.startsWith('[');

    if ((contentType?.contains('json') ?? false) ||
        (contentType == null && looksJson)) {
      final redundant = contentType?.trim() == 'application/json';
      return (
        RequestBody(type: BodyType.json, text: text),
        redundant ? _without(all, 'content-type') : all,
      );
    }
    final isForm =
        contentType?.contains('x-www-form-urlencoded') ??
        (contentType == null && RegExp(r'^[^\s=&]+=[^\s]*$').hasMatch(text));
    if (isForm) {
      return (
        RequestBody(type: BodyType.urlEncoded, fields: _formFields(text)),
        _without(all, 'content-type'),
      );
    }
    return (RequestBody(type: BodyType.raw, text: text), all);
  }

  List<KeyValue> _without(List<KeyValue> all, String lowerName) => [
    for (final h in all)
      if (h.key.toLowerCase() != lowerName) h,
  ];

  List<KeyValue> _formFields(String text) => [
    for (final pair in text.split('&'))
      if (pair.isNotEmpty) _decodePair(pair),
  ];

  KeyValue _decodePair(String pair) {
    final eq = pair.indexOf('=');
    String decode(String s) {
      try {
        return Uri.decodeQueryComponent(s);
      } on Object {
        return s;
      }
    }

    return eq == -1
        ? KeyValue(key: decode(pair))
        : KeyValue(
            key: decode(pair.substring(0, eq)),
            value: decode(pair.substring(eq + 1)),
          );
  }

  /// `GET /users` for `https://api.test/users?x=1`; the host if no path.
  String _nameFor(HttpMethod method, String url) {
    final withScheme = url.contains('://') ? url : 'http://$url';
    final uri = Uri.tryParse(withScheme);
    final path = uri == null || uri.path.isEmpty || uri.path == '/'
        ? (uri?.host ?? url)
        : uri.path;
    return '${method.label} $path';
  }
}
