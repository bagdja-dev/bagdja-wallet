import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient() : dio = Dio(BaseOptions(
    baseUrl: 'https://api.bagdja-wallet.com/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  )) {
    // Menambahkan interceptor untuk Token dan Logging
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Contoh: Mengambil token dari SharedPreferences atau tempat lain
        const token = 'AMBIL_TOKEN_DISINI'; 
        if (token.isNotEmpty) {
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
