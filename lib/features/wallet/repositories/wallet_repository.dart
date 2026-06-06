import 'package:bagdja_wallet/core/network/api_client.dart';
import 'package:bagdja_wallet/features/wallet/models/wallet_model.dart';
import 'package:bagdja_wallet/features/wallet/models/transaction_model.dart';
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

  Future<TransactionListResult> getWalletTransactions({
    required String currency,
    required int page,
    int size = 20,
    String sort = 'createdAt:desc',
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/wallets/me/transactions',
        queryParameters: {
          'currency': currency,
          'page': page,
          'size': size,
          'sort': sort,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          final list = (data['data'] as List<dynamic>)
              .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
              .toList();
          final meta = TransactionListMeta.fromJson(
            data['meta'] as Map<String, dynamic>,
          );
          return TransactionListResult(data: list, meta: meta);
        } else {
          throw Exception('Data transaksi tidak ditemukan');
        }
      } else {
        throw Exception('Gagal mengambil data transaksi');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Gagal mengambil data transaksi',
        );
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
