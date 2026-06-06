import 'package:bagdja_wallet/core/router.dart';
import 'package:bagdja_wallet/shared/widgets/scaffold_with_bottom_nav.dart';
import 'package:bagdja_wallet/localization/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InvoiceHistoryView extends StatelessWidget {
  const InvoiceHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBottomNav(
      appBarTitle: context.tr('home.invoiceHistory'),
      body: Stack(
        children: [
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 24),
                    onPressed: () => context.goNamed(RouteName.home),
                  ),
                  Text(context.tr('home.invoiceHistory')),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: _buildInvoiceHistory(),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceHistory() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Invoice History',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Coming Soon', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
