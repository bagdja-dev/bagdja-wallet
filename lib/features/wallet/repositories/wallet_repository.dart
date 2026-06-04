import 'package:bagdja_wallet/core/network/api_client.dart';
import 'package:bagdja_wallet/features/wallet/models/wallet_model.dart';
import 'package:dio/dio.dart';

class WalletRepository {
  final ApiClient apiClient;

  WalletRepository({required this.apiClient});

  Future<List<WalletModel>> getMyWallet() async {
    try {
      final response = await apiClient.dio.get('/wallets/me');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          final list = (data as List<dynamic>)
              .map((e) => WalletModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return list;
        } else {
          throw Exception('Data wallet tidak ditemukan');
        }
      } else {
        throw Exception('Gagal mengambil data wallet');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Gagal mengambil data wallet',
        );
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
