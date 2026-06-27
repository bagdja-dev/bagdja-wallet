
import 'package:bagdja_wallet/core/config/wallet_config.dart';
import 'package:bagdja_wallet/core/router.dart';
import 'package:bagdja_wallet/core/theme/app_colors.dart';
import 'package:bagdja_wallet/core/theme/app_text_styles.dart';
import 'package:bagdja_wallet/core/utils/widget_extensions.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_bloc.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_event.dart';
import 'package:bagdja_wallet/shared/models/wallet_model.dart';
import 'package:bagdja_wallet/shared/models/organization_model.dart';
import 'package:bagdja_wallet/shared/models/user_profile_model.dart';
import 'package:bagdja_wallet/localization/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:svg_flutter/svg_flutter.dart';

class WalletsSection extends StatelessWidget {
  final List<WalletModel> wallets;
  final WalletModel? selectedWallet;
  final NumberFormat formatter;
  final List<WalletOwner> walletOwners;
  final WalletOwner? selectedWalletOwner;
  final UserProfileModel? userProfile;
  final bool isActivatingWallet;

  const WalletsSection({
    super.key,
    required this.wallets,
    required this.selectedWallet,
    required this.formatter,
    required this.walletOwners,
    required this.selectedWalletOwner,
    this.userProfile,
    this.isActivatingWallet = false,
  });

  @override
  Widget build(BuildContext context) {
    // Gabungkan wallet yang sudah ada dengan wallet yang didukung tapi belum ada
    final List<Widget> walletCards = [];

    for (final supportedWallet in WalletConfig.supportedWallets) {
      final existingWallet = wallets.firstWhere(
        (w) => w.currencyCode == supportedWallet.currencyCode,
        orElse: () => WalletModel(
          id: '',
          userId: '',
          currencyCode: supportedWallet.currencyCode,
          provider: '',
          balance: 0,
          heldBalance: 0,
          isActive: false,
          updatedAt: DateTime.now(),
        ),
      );

      final isExisting = existingWallet.id.isNotEmpty;
      final isSelected = selectedWallet?.currencyCode == supportedWallet.currencyCode;

      if (isExisting) {
        walletCards.add(
          GestureDetector(
            onTap: () {
              context.read<WalletBloc>().add(
                SelectWallet(existingWallet),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.secondary
                    // ignore: deprecated_member_use
                    : AppColors.secondary.withOpacity(0.4),
                border: isSelected
                    ? Border.all(
                        color: Colors.white,
                        width: 1.5,
                      )
                    : null,
                borderRadius: BorderRadius.circular(6),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(
                            0.2,
                          ),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icon-wallet.svg',
                    width: 13,
                    height: 13,
                    // ignore: deprecated_member_use
                    color: isSelected
                        ? Colors.white
                        : AppColors.primary,
                  ),
                  Text(
                    existingWallet.currencyCode,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          // ignore: deprecated_member_use
                          : Colors.white.withOpacity(0.8),
                    ),
                  ),
                ].withGap(4),
              ),
            ),
          ),
        );
      } else {
        walletCards.add(
          GestureDetector(
            onTap: isActivatingWallet
                ? null
                : () {
                    context.read<WalletBloc>().add(
                      ActivateWallet(supportedWallet.currencyCode),
                    );
                  },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.5),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    size: 13,
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.7),
                  ),
                  Text(
                    supportedWallet.currencyCode,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ].withGap(4),
              ),
            ),
          ),
        );
      }
    }

    return IntrinsicHeight(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/ilustration.png'),
            fit: BoxFit.cover,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Owner Dropdown
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<WalletOwner>(
                        value: selectedWalletOwner,
                        isDense: true,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                        dropdownColor: AppColors.dropdown,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        items: walletOwners.map((owner) {
                          return DropdownMenuItem<WalletOwner>(
                            value: owner,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  owner.isPersonal
                                      ? Icons.person
                                      : Icons.business,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(owner.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (owner) {
                          if (owner != null) {
                            context.read<WalletBloc>().add(
                              SelectWalletOwner(owner),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    child: Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            context.read<WalletBloc>().add(const FetchWalletBalance());
                          },
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 20,
                          ),
                          tooltip: context.tr('home.refresh'),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.pushNamed(RouteName.profile);
                          },
                          child: Icon(
                            Icons.account_circle,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ].withGap(10),
                    ),
                  ),
                ],
              ),
            ),
            // Wallet Content
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: selectedWallet != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 2.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${context.tr('home.wallet')} ${selectedWallet!.currencyCode}',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    // ignore: deprecated_member_use
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  formatter.format(selectedWallet!.balance),
                                  style: AppTextStyles.heading2.copyWith(
                                    color: Colors.white,
                                    fontSize: 22,
                                  ),
                                ),

                                // Username here!
                                if (selectedWallet!.heldBalance > 0)
                                  Text(
                                    '${context.tr('home.held')}: ${formatter.format(selectedWallet!.heldBalance)}',
                                    style: const TextStyle(
                                      color: Colors.amberAccent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ].withVerticalGap(4),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 2.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Pilih Wallet',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    // ignore: deprecated_member_use
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Tap wallet untuk mengaktifkan',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    // ignore: deprecated_member_use
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                ),
                              ].withVerticalGap(4),
                            ),
                          ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: walletCards.withGap(8),
                    ),
                  ),
                ].withGap(5),
              ),
            ),
            // Action Buttons
            if (selectedWallet != null && !selectedWallet!.isActive)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isActivatingWallet
                          ? null
                          : () {
                              context.read<WalletBloc>().add(
                                ActivateWallet(selectedWallet!.currencyCode),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: isActivatingWallet
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text('Aktifkan Wallet'),
                    ),
                  ),
                ],
              ),
            // Wallet Owner
            if (userProfile != null)
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      userProfile!.username.toUpperCase(),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
          ].withGap(10),
        ),
      ),
    );
  }
}

