import 'package:bagdja_wallet/core/utils/widget_extensions.dart';
import 'package:flutter/material.dart';
import 'package:bagdja_wallet/shared/models/wallet_model.dart';
import 'package:bagdja_wallet/shared/models/organization_model.dart';
import 'package:bagdja_wallet/localization/main.dart';

/// Reusable component for selecting a wallet
class EscrowWalletSelector extends StatelessWidget {
  final List<WalletModel> wallets;
  final WalletModel? selectedWallet;
  final ValueChanged<WalletModel> onWalletSelected;
  final WalletOwner? walletOwner;

  const EscrowWalletSelector({
    super.key,
    required this.wallets,
    required this.selectedWallet,
    required this.onWalletSelected,
    this.walletOwner,
  });

  @override
  Widget build(BuildContext context) {
    return wallets.isNotEmpty && wallets.length > 1
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('escrow.selectYourWallet'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              _WalletDropdown(
                wallets: wallets,
                selectedWallet: selectedWallet,
                onWalletSelected: onWalletSelected,
                walletOwner: walletOwner,
              ),
            ],
          )
        : SizedBox.shrink();
  }
}

class _WalletDropdown extends StatelessWidget {
  final List<WalletModel> wallets;
  final WalletModel? selectedWallet;
  final ValueChanged<WalletModel> onWalletSelected;
  final WalletOwner? walletOwner;

  const _WalletDropdown({
    required this.wallets,
    required this.selectedWallet,
    required this.onWalletSelected,
    this.walletOwner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: wallets
            .map((wallet) {
              final isSelected = selectedWallet?.id == wallet.id;
              return GestureDetector(
                onTap: () => onWalletSelected(wallet),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        //ignore: deprecated_member_use, use_build_context_synchronously
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.white,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        wallet.currencyCode,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            })
            .toList()
            .withGap(5),
      ),
    );
  }
}
