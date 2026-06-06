import 'package:bagdja_wallet/core/router.dart';
import 'package:bagdja_wallet/shared/widgets/scaffold_with_bottom_nav.dart';
import 'package:bagdja_wallet/localization/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EscrowHistoryView extends StatelessWidget {
  const EscrowHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBottomNav(
      appBarTitle: context.tr('home.escrowHistory'),
      body: Stack(children: [
             SafeArea(
               child: Align(
                 alignment: Alignment.topLeft,
                 child: Row(
                   children: [
                     IconButton(
                       icon: const Icon(Icons.arrow_back, size: 24),
                       onPressed: () => context.goNamed(RouteName.home),
                     ),
                     Text(context.tr('home.escrowHistory')),
                   ],
                 ),
               ),
             ),
             SizedBox(
               width: double.infinity,
               height: double.infinity,
               child: _buildEscrowHistory(context),
             ),
          ],
        ),
    );
  }

  Widget _buildEscrowHistory(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_balance_wallet,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('home.escrowHistory'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('home.comingSoon'),
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
