import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bagdja_wallet/core/config/settings.dart';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

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
        // Bisa dihandle secara global, misalnya jika token expired (401)
        return handler.next(e);
      },
    ));
  }
}

