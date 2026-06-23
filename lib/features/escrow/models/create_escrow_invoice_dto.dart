class CreateEscrowInvoiceDto {
  final String buyerType;
  final String buyerIdentifier;
  final String sellerType;
  final String sellerIdentifier;
  final String? buyerWalletId;
  final String? sellerWalletId;
  final double amount;
  final String currency;
  final String? notes;
  final dynamic metadata;

  CreateEscrowInvoiceDto({
    required this.buyerType,
    required this.buyerIdentifier,
    required this.sellerType,
    required this.sellerIdentifier,
    this.buyerWalletId,
    this.sellerWalletId,
    required this.amount,
    this.currency = 'IDR',
    this.notes,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'buyer_type': buyerType,
      'buyer_identifier': buyerIdentifier,
      'seller_type': sellerType,
      'seller_identifier': sellerIdentifier,
      'buyer_wallet_id': buyerWalletId,
      'seller_wallet_id': sellerWalletId,
      'amount': amount,
      'currency': currency,
      'notes': notes,
      'metadata': metadata,
    };
  }
}
