import 'package:bagdja_wallet/features/wallet/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final NumberFormat formatter;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final icon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;
    final iconColor = isCredit ? Colors.green : Colors.red;
    final amountPrefix = isCredit ? '+ ' : '- ';
    final amountColor = isCredit ? Colors.green : Colors.red;

    return ListTile(
      leading: CircleAvatar(child: Icon(icon, color: iconColor)),
      title: Text(transaction.displayTitle),
      subtitle: Text(transaction.displayReference),
      trailing: Text(
        '$amountPrefix${formatter.format(transaction.amount.abs())}',
        style: TextStyle(
          color: amountColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
