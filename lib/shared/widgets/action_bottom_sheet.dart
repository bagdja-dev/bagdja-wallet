import 'package:bagdja_wallet/core/theme/app_colors.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_bloc.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_event.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_state.dart';
import 'package:bagdja_wallet/core/router.dart';
import 'package:bagdja_wallet/localization/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ActionBottomSheet extends StatelessWidget {
  final VoidCallback? onTopUpTap;
  final VoidCallback? onCreateInvoiceTap;
  final VoidCallback? onCreateEscrowTap;

  const ActionBottomSheet({
    super.key,
    this.onTopUpTap,
    this.onCreateInvoiceTap,
    this.onCreateEscrowTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                context.tr('home.chooseAction'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _ActionItem(
              icon: Icons.account_balance_wallet,
              title: context.tr('home.topUp'),
              description: context.tr('home.topUpDescription'),
              onTap: onTopUpTap ?? () {
                Navigator.pop(context);
                final walletBloc = context.read<WalletBloc>();
                final state = walletBloc.state;
                if (state is WalletLoaded) {
                  final currencyCode = state.selectedWallet?.currencyCode ?? 'IDR';
                  walletBloc.add(ShowTopUpModal(currencyCode));
                }
              },
            ),
            const SizedBox(height: 16),
            _ActionItem(
              icon: Icons.receipt_long,
              title: context.tr('home.createInvoice'),
              description: context.tr('home.createInvoiceDescription'),
              onTap: onCreateInvoiceTap ?? () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
            _ActionItem(
              icon: Icons.shield,
              title: context.tr('home.createEscrow'),
              description: context.tr('home.createEscrowDescription'),
              onTap: onCreateEscrowTap ?? () {
                Navigator.pop(context);
                context.pushNamed(RouteName.createEscrow);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.blue[800],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
