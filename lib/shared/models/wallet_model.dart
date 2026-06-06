import 'package:equatable/equatable.dart';

class WalletModel extends Equatable {
  final String id;
  final String? orgId;
  final String? userId;
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

  static T? _get<T>(Map<String, dynamic> json, String camelCase, String snakeCase) {
    return json[camelCase] as T? ?? json[snakeCase] as T?;
  }

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String,
      orgId: _get<String>(json, 'orgId', 'org_id') ,
      userId: _get<String>(json, 'userId', 'user_id'),
      currencyCode: _get<String>(json, 'currencyCode', 'currency_code')!,
      provider: json['provider'] as String,
      balance: (json['balance'] as num).toDouble(),
      heldBalance: (_get<num>(json, 'heldBalance', 'held_balance') ?? 0).toDouble(),
      isActive: _get<bool>(json, 'isActive', 'is_active') ?? false,
      activatedAt: _get<String>(json, 'activatedAt', 'activated_at') != null
          ? DateTime.parse(_get<String>(json, 'activatedAt', 'activated_at')!)
          : null,
      updatedAt: DateTime.parse(_get<String>(json, 'updatedAt', 'updated_at')!),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orgId': orgId,
      'userId': userId,
      'currencyCode': currencyCode,
      'provider': provider,
      'balance': balance,
      'heldBalance': heldBalance,
      'isActive': isActive,
      'activatedAt': activatedAt?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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
