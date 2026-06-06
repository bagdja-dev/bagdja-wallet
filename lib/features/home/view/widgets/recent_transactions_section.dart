import 'package:bagdja_wallet/features/home/view/widgets/transaction_tile.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_bloc.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_event.dart';
import 'package:bagdja_wallet/shared/models/transaction_model.dart';
import 'package:bagdja_wallet/localization/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class RecentMutation extends StatelessWidget {
  final List<TransactionModel> transactions;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final NumberFormat formatter;

  const RecentMutation({
    super.key,
    required this.transactions,
    required this.isLoading,
    required this.hasMore,
    required this.error,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('home.recentMutation'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        
        if (error != null && transactions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  Text(error!, style: const TextStyle(color: Colors.red)),
                  ElevatedButton(
                    onPressed: () => context.read<WalletBloc>().add(const LoadMoreTransactions()),
                    child: Text(context.tr('common.tryAgain')),
                  ),
                ],
              ),
            ),
          )
        else if (transactions.isEmpty && !isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.receipt_long, color: Colors.grey, size: 40),
                  SizedBox(height: 8),
                  Text('Belum ada transaksi', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: transactions.map((tx) => TransactionTile(
                  transaction: tx,
                  formatter: formatter,
                )).toList(),
              ),
            ),
          ),
        
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
