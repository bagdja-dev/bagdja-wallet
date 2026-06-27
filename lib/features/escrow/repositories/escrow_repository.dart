import 'package:bagdja_wallet/core/network/api_client.dart';
import 'package:bagdja_wallet/features/escrow/models/create_escrow_invoice_dto.dart';
import 'package:bagdja_wallet/features/escrow/models/escrow_record_model.dart';
import 'package:bagdja_wallet/features/escrow/models/escrow_list_result.dart';
import 'package:bagdja_wallet/shared/models/wallet_model.dart';
import 'package:dio/dio.dart';

class EscrowRepository {
  final ApiClient apiClient;

  EscrowRepository({required this.apiClient});

  Future<EscrowRecordModel> createEscrowInvoice(CreateEscrowInvoiceDto dto) async {
    try {
      final response = await apiClient.dio.post(
        '/escrow/invoice',
        data: dto.toJson(),
      );
      return EscrowRecordModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to create escrow invoice');
    }
  }

  Future<dynamic> getUserByIdentifier(String identifier) async {
    try {
      final response = await apiClient.dio.get('/escrow/users/$identifier');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to get user');
    }
  }

  Future<dynamic> getWalletById(String walletId) async {
    try {
      final response = await apiClient.dio.get('/escrow/wallets/$walletId');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to get wallet');
    }
  }

  Future<dynamic> validateUserByIdentifier(String identifier) async {
    try {
      final response = await apiClient.dio.get('/escrow/users/$identifier');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? 'User not found');
    }
  }

  Future<dynamic> validateOrgByIdentifier(String identifier) async {
    try {
      final response = await apiClient.dio.get(
        '/escrow/wallets/organization/$identifier',
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?.toString() ?? 'Organization not found',
      );
    }
  }


  //get personal wallet by user id and currency
  Future<WalletModel> getUserWallet(String userId, String currency) async {
    try {
      final response = await apiClient.dio.get(
        '/escrow/wallets/user/$userId/$currency',
      );
      return WalletModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?.toString() ?? 'User wallet not found',
      );
    }
  }

  //get organization wallet by org slug and currency
  Future<WalletModel> getOrganizationWallet(String orgSlug, String currency) async {
    try {
      final response = await apiClient.dio.get(
        '/escrow/wallets/organization/$orgSlug/$currency',
      );
      return WalletModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?.toString() ?? 'Organization wallet not found',
      );
    }
  }
  
  Future<EscrowListResult> getMyEscrows({int page = 1, int size = 20, String? status, String? search}) async {
    try {
      final queryParameters = <String, dynamic>{'page': page, 'size': size};
      if (status != null && status.isNotEmpty) queryParameters['status'] = status;
      if (search != null && search.isNotEmpty) queryParameters['search'] = search;

      final resp = await apiClient.dio.get('/escrow/mine', queryParameters: queryParameters);
      return EscrowListResult.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to fetch my escrows');
    }
  }

  Future<EscrowListResult> getInvitedEscrows({int page = 1, int size = 20, String? role, String? search}) async {
    try {
      final queryParameters = <String, dynamic>{'page': page, 'size': size};
      if (role != null && role.isNotEmpty) queryParameters['role'] = role;
      if (search != null && search.isNotEmpty) queryParameters['search'] = search;

      final resp = await apiClient.dio.get('/escrow/invitations', queryParameters: queryParameters);
      return EscrowListResult.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to fetch invited escrows');
    }
  }

  Future<EscrowRecordModel> getEscrowById(String id) async {
    try {
      final resp = await apiClient.dio.get('/escrow/$id');
      return EscrowRecordModel.fromJson(resp.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to fetch escrow detail');
    }
  }

  Future<EscrowRecordModel> initializePayment(String id) async {
    try {
      final resp = await apiClient.dio.post('/escrow/$id/initialize-payment');
      return EscrowRecordModel.fromJson(resp.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to initialize payment');
    }
  }

  Future<EscrowRecordModel> releaseEscrow(String id) async {
    try {
      final resp = await apiClient.dio.post('/escrow/$id/release');
      final data = resp.data as Map<String, dynamic>;
      return EscrowRecordModel.fromJson(data['escrow'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Failed to release escrow');
    }
  }

}
