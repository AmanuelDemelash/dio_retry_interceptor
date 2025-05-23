import 'package:dio_retry_interceptor/src/connectivity_service.dart';
import 'package:test/test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:dio_retry_interceptor/dio_retry_interceptor.dart';

import 'dio_retry_interceptor_test.mocks.dart';

@GenerateMocks([Dio, ConnectivityService])
void main() {
  group('RetryOnConnectionChangeInterceptor', () {
    late MockDio mockDio;
    late RetryOnConnectionChangeInterceptor interceptor;

    final testOptions = RequestOptions(path: '/test');

    setUp(() {
      mockDio = MockDio();

      interceptor = RetryOnConnectionChangeInterceptor(
        mockDio,
        maxRetryAttempts: 2,
        retryPost: true,
        enableLogging: true,
      );
    });

    test('should retry on connection error when connected', () async {
      final dioException = DioException(
        requestOptions: testOptions,
        type: DioExceptionType.connectionError,
        error: 'Network error',
      );

      // Mock connectivity service
      when(ConnectivityService.isConnected()).thenAnswer((_) async => true);

      // Simulate retry response
      final expectedResponse = Response(
        requestOptions: testOptions,
        statusCode: 200,
        data: {'success': true},
      );

      when(mockDio.fetch(testOptions))
          .thenAnswer((_) async => expectedResponse);

      final handler = _FakeErrorInterceptorHandler();

      interceptor.onError(dioException, handler);

      expect(handler.response, isNotNull);
      expect(handler.response?.data, {'success': true});
    });

    test('should not retry if not connected', () async {
      final dioException = DioException(
        requestOptions: testOptions,
        type: DioExceptionType.connectionError,
        error: 'Network error',
      );

      // Mock offline
      when(ConnectivityService.isConnected()).thenAnswer((_) async => false);

      final handler = _FakeErrorInterceptorHandler();

      interceptor.onError(dioException, handler);

      expect(handler.response, isNull);
      expect(handler.error, isNotNull);
    });

    test('should stop retrying after max attempts', () async {
      final dioException = DioException(
        requestOptions: testOptions,
        type: DioExceptionType.connectionError,
        error: 'Network error',
      );

      when(ConnectivityService.isConnected()).thenAnswer((_) async => true);
      when(mockDio.fetch(testOptions)).thenThrow(dioException);

      final handler = _FakeErrorInterceptorHandler();

      interceptor.onError(dioException, handler);
      interceptor.onError(dioException, handler); // 2nd retry
      interceptor.onError(dioException, handler); // Should stop

      expect(handler.error, isNotNull);
    });
  });
}

class _FakeErrorInterceptorHandler extends ErrorInterceptorHandler {
  Response? response;
  DioException? error;

  @override
  void resolve(Response response) {
    this.response = response;
  }

  @override
  void reject(DioException err) {
    error = err;
  }

  @override
  void next(DioException err) {
    error = err;
  }
}
