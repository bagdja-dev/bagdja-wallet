import 'package:equatable/equatable.dart';

/// Label yang ditampilkan untuk setiap tipe transaksi.
/// Mengikuti pola dari bagdja-console WalletLedgerGrid.tsx
const Map<String, String> transactionTypeLabels = {
  'SALE_PROCEEDS': 'Payment received',
  'TRANSACTION_FEE': 'Service fee',
  'WITHDRAWAL_HOLD': 'Withdrawal hold',
  'WITHDRAWAL_COMPLETED': 'Withdrawal completed',
  'TOP_UP': 'Top Up',
};

class TransactionModel extends Equatable {
  final String id;
  final String walletId;
  final double amount; // positif = kredit, negatif = debit
  final String type;
  final String? referenceId;
  final String? externalId;
  final String? description;
  final String? currency;
  final DateTime? createdAt;

  const TransactionModel({
    required this.id,
    required this.walletId,
    required this.amount,
    required this.type,
    this.referenceId,
    this.externalId,
    this.description,
    this.currency,
    this.createdAt,
  });

  /// Apakah transaksi ini merupakan kredit (saldo masuk)
  bool get isCredit => amount >= 0;

  /// Label yang ditampilkan sesuai tipe transaksi (fallback ke type yang diformat)
  String get typeLabel =>
      transactionTypeLabels[type] ??
      type.replaceAll('_', ' ').toLowerCase();

  /// Teks tampilan (deskripsi jika ada, fallback ke typeLabel)
  String get displayTitle => (description != null && description!.isNotEmpty)
      ? description!
      : typeLabel;

  /// Reference yang ditampilkan: external_id jika ada, fallback ke 8 karakter pertama reference_id
  String get displayReference {
    if (externalId != null && externalId!.isNotEmpty) return externalId!;
    if (referenceId != null && referenceId!.length > 8) {
      return '${referenceId!.substring(0, 8)}…';
    }
    return referenceId ?? '—';
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      walletId: json['wallet_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      referenceId: json['reference_id'] as String?,
      externalId: json['external_id'] as String?,
      description: json['description'] as String?,
      currency: json['currency'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        walletId,
        amount,
        type,
        referenceId,
        externalId,
        description,
        currency,
        createdAt,
      ];
}

class TransactionListMeta extends Equatable {
  final int totalItems;
  final int itemCount;
  final int itemsPerPage;
  final int totalPages;
  final int currentPage;

  const TransactionListMeta({
    required this.totalItems,
    required this.itemCount,
    required this.itemsPerPage,
    required this.totalPages,
    required this.currentPage,
  });

  factory TransactionListMeta.fromJson(Map<String, dynamic> json) {
    return TransactionListMeta(
      totalItems: (json['totalItems'] as num).toInt(),
      itemCount: (json['itemCount'] as num).toInt(),
      itemsPerPage: (json['itemsPerPage'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      currentPage: (json['currentPage'] as num).toInt(),
    );
  }

  @override
  List<Object?> get props =>
      [totalItems, itemCount, itemsPerPage, totalPages, currentPage];
}

class TransactionListResult extends Equatable {
  final List<TransactionModel> data;
  final TransactionListMeta meta;

  const TransactionListResult({required this.data, required this.meta});

  @override
  List<Object?> get props => [data, meta];
}
