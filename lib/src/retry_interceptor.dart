import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'connectivity_service.dart';

/// This interceptor retries a request when a connection error occurs.
/// It checks if the request is retryable and if the device is connected to the internet.
/// If the request is retryable and the device is connected, it retries the request.
/// It uses the [Dio] package for making HTTP requests.
/// It is used in the [DioClient] to handle connection errors.
/// The interceptor checks if the request method is idempotent (GET, POST, PUT)
/// and if the request is marked as retryable.
/// It also checks if the request is a POST request and if the [retryPost] flag is set to true.
/// If the request is retryable and the device is connected, it retries the request.
/// It uses the [ConnectivityService] to check the connectivity status of the device.
/// It also has a logging feature that can be enabled or disabled.
/// It tracks the number of retries for each request and stops retrying if the maximum number of attempts is reached.

class RetryOnConnectionChangeInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetryAttempts;
  final bool retryPost;
  final bool enableLogging;

  // Track retries per request
  final Map<RequestOptions, int> _retryCount = {};

  RetryOnConnectionChangeInterceptor(
    this.dio, {
    this.maxRetryAttempts = 3,
    this.retryPost = false,
    this.enableLogging = false,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;

    if (_shouldRetry(err)) {
      final retryCount = _retryCount[request] ?? 0;

      if (retryCount >= maxRetryAttempts) {
        _log('Max retry attempts reached for: ${request.uri}');
        return handler.next(err);
      }

      final isConnected = await ConnectivityService.isConnected();
      if (isConnected) {
        _log('Retrying request: ${request.uri} (attempt: ${retryCount + 1})');

        _retryCount[request] = retryCount + 1;

        try {
          final response = await dio.fetch(request);
          _retryCount.remove(request);
          return handler.resolve(response);
        } on DioException catch (retryErr) {
          return handler.reject(retryErr);
        }
      } else {
        _log('No connection. Waiting to retry: ${request.uri}');
      }
    }

    return handler.next(err);
  }

  /// This method checks if the request should be retried based on the error type
  /// and the request method.
  /// It checks if the request method is idempotent (GET, POST, PUT)
  /// and if the request is marked as retryable.
  bool _shouldRetry(DioException err) {
    final method = err.requestOptions.method.toUpperCase();
    final retryable = err.requestOptions.extra['retryable'] == true;

    final isIdempotent =
        method == 'GET' || (retryPost && (method == 'POST' || method == 'PUT'));

    return (err.type == DioExceptionType.connectionError ||
            err.type == DioExceptionType.connectionTimeout) &&
        (isIdempotent || retryable);
  }

  /// This method logs the message if logging is enabled and the app is in debug mode.
  void _log(String message) {
    if (enableLogging && kDebugMode) {
      // You can route this to a logger if needed
      print('[RetryInterceptor] $message');
    }
  }
}
