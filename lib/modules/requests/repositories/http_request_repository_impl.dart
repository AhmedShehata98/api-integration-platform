import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/core/network/dio_failure_mapper.dart';
import 'package:test_point/modules/requests/models/http_response_result.dart';
import 'package:test_point/modules/requests/models/prepared_request.dart';
import 'package:test_point/modules/requests/repositories/http_request_repository.dart';

/// Bodies above this size are decoded off the main isolate.
const _isolateDecodeThreshold = 1024 * 1024;

class HttpRequestRepositoryImpl implements HttpRequestRepository {
  HttpRequestRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Result<HttpResponseResult>> send(
    PreparedRequest request,
    CancelSignal cancelSignal,
  ) async {
    final token = CancelToken();
    unawaited(cancelSignal.whenCancelled.then((_) => token.cancel()));

    final stopwatch = Stopwatch()..start();
    try {
      final response = await _dio.requestUri<List<int>>(
        request.url,
        data: _data(request),
        options: Options(method: request.method, headers: request.headers),
        cancelToken: token,
      );
      stopwatch.stop();

      final bytes = response.data ?? const <int>[];
      return Result.success(
        HttpResponseResult(
          statusCode: response.statusCode ?? 0,
          reason: response.statusMessage,
          headers: response.headers.map,
          body: await _decode(bytes),
          duration: stopwatch.elapsed,
          sizeBytes: bytes.length,
        ),
      );
    } on DioException catch (error) {
      return Result.failure(mapDioError(error));
    } on Object {
      return const Result.failure(UnexpectedFailure());
    }
  }

  Object? _data(PreparedRequest request) {
    final fields = request.multipartFields;
    if (fields != null) return FormData.fromMap(fields);
    return request.body;
  }

  Future<String> _decode(List<int> bytes) {
    if (bytes.length > _isolateDecodeThreshold) {
      return Isolate.run(() => utf8.decode(bytes, allowMalformed: true));
    }
    return Future.value(utf8.decode(bytes, allowMalformed: true));
  }
}
