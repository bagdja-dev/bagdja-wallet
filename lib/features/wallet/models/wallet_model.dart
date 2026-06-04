import 'package:equatable/equatable.dart';

class WalletModel extends Equatable {
  final String id;
  final String? orgId;
  final String userId;
  final String currencyCode;
  final String provider;
  final double balance;
  final double heldBalance;
  final bool isActive;
  final DateTime? activatedAt;
  final DateTime updatedAt;

  const WalletModel({
    required this.id,
    this.orgId,
    required this.userId,
    required this.currencyCode,
    required this.provider,
    required this.balance,
    required this.heldBalance,
    required this.isActive,
    this.activatedAt,
    required this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String,
      orgId: json['org_id'] as String?,
      userId: json['user_id'] as String,
      currencyCode: json['currency_code'] as String,
      provider: json['provider'] as String,
      balance: (json['balance'] as num).toDouble(),
      heldBalance: (json['held_balance'] as num).toDouble(),
      isActive: json['is_active'] as bool,
      activatedAt: json['activated_at'] != null ? DateTime.parse(json['activated_at'] as String) : null,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'org_id': orgId,
      'user_id': userId,
      'currency_code': currencyCode,
      'provider': provider,
      'balance': balance,
      'held_balance': heldBalance,
      'is_active': isActive,
      'activated_at': activatedAt?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        orgId,
        userId,
        currencyCode,
        provider,
        balance,
        heldBalance,
        isActive,
        activatedAt,
        updatedAt,
      ];
}
