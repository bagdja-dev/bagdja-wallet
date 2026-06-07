import 'package:bagdja_wallet/core/network/api_client.dart';
import 'package:bagdja_wallet/shared/models/wallet_model.dart';
import 'package:bagdja_wallet/shared/models/transaction_model.dart';
import 'package:bagdja_wallet/shared/models/organization_model.dart';
import 'package:bagdja_wallet/shared/models/user_profile_model.dart';
import 'package:bagdja_wallet/shared/models/topup_response.dart';
import 'package:dio/dio.dart';

class WalletRepository {
  final ApiClient apiClient;

  WalletRepository({required this.apiClient});

  Future<WalletModel> activatePersonalWallet(String currencyCode) async {
    try {
      final response = await apiClient.dio.post(
        '/wallets/me/activate',
        data: {'currencyCode': currencyCode},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return WalletModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Gagal mengaktifkan wallet');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Gagal mengaktifkan wallet',
        );
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<WalletModel> activateOrganizationWallet(String organizationId, String currencyCode) async {
    try {
      final response = await apiClient.dio.post(
        '/wallets/activate',
        data: {'currencyCode': currencyCode},
        options: Options(
          headers: {
            'x-organization-id': organizationId,
            'x-org-id': organizationId,
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return WalletModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Gagal mengaktifkan wallet');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Gagal mengaktifkan wallet',
        );
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<TopUpResponse> createPersonalTopup({
    required num amount,
    required String currency,
    required String successRedirectUrl,
    required String failureRedirectUrl,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/topup/personal',
        data: {
          'amount': amount,
          'currency': currency,
          'successRedirectUrl': successRedirectUrl,
          'failureRedirectUrl': failureRedirectUrl,
        },
      );
      if (response.statusCode == 201) {
        return TopUpResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Gagal membuat topup');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Gagal membuat topup',
        );
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<TopUpResponse> createOrganizationTopup({
    required num amount,
    required String currency,
    required String organizationId,
    required String successRedirectUrl,
    required String failureRedirectUrl,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/topup/organization',
        data: {
          'amount': amount,
          'currency': currency,
          'orgId': organizationId,
          'successRedirectUrl': successRedirectUrl,
          'failureRedirectUrl': failureRedirectUrl,
        },
      );
      if (response.statusCode == 201) {
        return TopUpResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Gagal membuat topup');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Gagal membuat topup',
        );
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

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

  Future<UserProfileModel> getMyProfile() async {
    try {
      final response = await apiClient.dio.get('/auth/me');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['user'] != null) {
          return UserProfileModel.fromJson(data['user'] as Map<String, dynamic>);
        } else {
          throw Exception('Data profile tidak ditemukan');
        }
      } else {
        throw Exception('Gagal mengambil data profile');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Gagal mengambil data profile',
        );
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<OrganizationModel>> getMyOrganizations() async {
    try {
      final response = await apiClient.dio.get('/wallets/me/organizations');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          final list = (data as List<dynamic>)
              .map((e) => OrganizationModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return list;
        } else {
          return [];
        }
      } else {
        throw Exception('Gagal mengambil data organizations');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Gagal mengambil data organizations',
        );
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<WalletModel>> getOrganizationWallets(String organizationId) async {
    try {
      final response = await apiClient.dio.get(
        '/wallets',
        queryParameters: {
          'organizationId': organizationId,
        },
        options: Options(
          headers: {
            'x-organization-id': organizationId,
            'x-org-id': organizationId,
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          final list = (data as List<dynamic>)
              .map((e) => WalletModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return list;
        } else {
          return [];
        }
      } else {
        throw Exception('Gagal mengambil data wallet organisasi');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'Gagal mengambil data wallet organisasi',
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
    String ownerType = 'personal',
    String? organizationId,
    int size = 20,
    String sort = 'createdAt:desc',
  }) async {
    try {
      final endpoint = ownerType == 'organization'
          ? '/payments/transactions'
          : '/wallets/me/transactions';
      final queryParameters = {
        'currency': currency,
        'page': page,
        'size': size,
        'sort': sort,
      };
      
      final headers = <String, dynamic>{};

      if (ownerType == 'organization') {
        queryParameters['ownerType'] = 'organization';
        if (organizationId != null) {
          queryParameters['organizationId'] = organizationId;
          headers['x-organization-id'] = organizationId;
          headers['x-org-id'] = organizationId;
        }
      }

      final response = await apiClient.dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: headers.isNotEmpty ? headers : null),
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
