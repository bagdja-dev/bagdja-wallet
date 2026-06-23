import 'package:bagdja_wallet/features/escrow/models/escrow_record_model.dart';

class EscrowListMeta {
  final int total;
  final int page;
  final int size;
  final int totalPages;

  EscrowListMeta({required this.total, required this.page, required this.size, required this.totalPages});

  factory EscrowListMeta.fromJson(Map<String, dynamic> json) {
    return EscrowListMeta(
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      size: (json['size'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );
  }
}

class EscrowListResult {
  final List<EscrowRecordModel> data;
  final EscrowListMeta meta;

  EscrowListResult({required this.data, required this.meta});

  factory EscrowListResult.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>).map((e) => EscrowRecordModel.fromJson(e as Map<String, dynamic>)).toList();
    return EscrowListResult(
      data: list,
      meta: EscrowListMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}
