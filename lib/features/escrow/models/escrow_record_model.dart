class EscrowRecordModel {
  final String id;
  final String? paymentRequestId;
  final String? checkoutUrl;
  final String buyerType;
  final String buyerIdentifier;
  final String sellerType;
  final String sellerIdentifier;
  final String? buyerWalletId;
  final String? sellerWalletId;
  final double amount;
  final String currency;
  final String status;
  final String? notes;
  final dynamic metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  EscrowRecordModel({
    required this.id,
    this.paymentRequestId,
    this.checkoutUrl,
    required this.buyerType,
    required this.buyerIdentifier,
    required this.sellerType,
    required this.sellerIdentifier,
    this.buyerWalletId,
    this.sellerWalletId,
    required this.amount,
    required this.currency,
    required this.status,
    this.notes,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EscrowRecordModel.fromJson(Map<String, dynamic> json) {
    // Helper to clean strings
    String? cleanString(dynamic value) {
      if (value == null) return null;
      return value.toString().trim().replaceAll(RegExp(r'^`|`$'), '');
    }

    return EscrowRecordModel(
      id: json['id'],
      paymentRequestId: cleanString(json['payment_request_id']),
      checkoutUrl: cleanString(json['checkout_url']),
      buyerType: json['buyer_type'],
      buyerIdentifier: json['buyer_identifier'],
      sellerType: json['seller_type'],
      sellerIdentifier: json['seller_identifier'],
      buyerWalletId: json['buyer_wallet_id'],
      sellerWalletId: json['seller_wallet_id'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      status: json['status'],
      notes: json['notes'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_request_id': paymentRequestId,
      'checkout_url': checkoutUrl,
      'buyer_type': buyerType,
      'buyer_identifier': buyerIdentifier,
      'seller_type': sellerType,
      'seller_identifier': sellerIdentifier,
      'buyer_wallet_id': buyerWalletId,
      'seller_wallet_id': sellerWalletId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'notes': notes,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
