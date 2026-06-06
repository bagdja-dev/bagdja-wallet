import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bagdja_wallet/core/config/settings.dart';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage secureStorage;
  final StreamController<void> _unauthorizedController = StreamController<void>.broadcast();

  Stream<void> get onUnauthorized => _unauthorizedController.stream;

  ApiClient({this.secureStorage = const FlutterSecureStorage()}) : dio = Dio(BaseOptions(
    baseUrl: Settings.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  )) {
    // Menambahkan interceptor untuk Token dan Logging
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Mengambil token dari secure storage
        final token = await secureStorage.read(key: 'access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Handle 401 Unauthorized globally
        if (e.response?.statusCode == 401) {
          _unauthorizedController.add(null);
        }
        return handler.next(e);
      },
    ));
  }

  void dispose() {
    _unauthorizedController.close();
  }
}

