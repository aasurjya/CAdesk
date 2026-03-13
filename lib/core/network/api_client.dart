import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/network/api_interceptors.dart';

/// Provides a configured [Dio] instance with auth, idempotency, and logging
/// interceptors attached. Use this provider wherever HTTP requests are needed.
final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://127.0.0.1:54321',
      ),
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(),
    IdempotencyInterceptor(),
    LoggingInterceptor(),
  ]);

  return dio;
});
