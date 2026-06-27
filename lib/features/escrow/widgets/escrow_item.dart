import 'package:bagdja_wallet/features/escrow/models/escrow_record_model.dart';
import 'package:bagdja_wallet/core/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EscrowItem extends StatelessWidget {
  final EscrowRecordModel model;
  const EscrowItem({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.pushNamed(RouteName.escrowDetail, extra: model),
      title: Text('${model.buyerIdentifier} → ${model.sellerIdentifier}'),
      subtitle: Text('${model.amount.toStringAsFixed(0)} ${model.currency} • ${model.status}'),
      trailing: Text(model.createdAt.toLocal().toString().split(' ').first),
    );
  }
}
