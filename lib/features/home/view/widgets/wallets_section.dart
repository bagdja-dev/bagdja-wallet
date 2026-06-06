import 'package:bagdja_wallet/core/theme/app_colors.dart';
import 'package:bagdja_wallet/core/theme/app_text_styles.dart';
import 'package:bagdja_wallet/core/utils/widget_extensions.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_bloc.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_event.dart';
import 'package:bagdja_wallet/features/wallet/models/wallet_model.dart';
import 'package:bagdja_wallet/localization/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:svg_flutter/svg_flutter.dart';

class WalletsSection extends StatelessWidget {
  final List<WalletModel> wallets;
  final WalletModel? selectedWallet;
  final NumberFormat formatter;

  const WalletsSection({
    super.key,
    required this.wallets,
    required this.selectedWallet,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
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
      child: Row(
        children: [
          Expanded(
            child: selectedWallet != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${context.tr('home.wallet')} ${selectedWallet!.currencyCode}',
                          style: AppTextStyles.bodyLarge.copyWith(
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
                        if (selectedWallet!.heldBalance > 0)
                          Text(
                            '${context.tr('home.held')}: ${formatter.format(selectedWallet!.heldBalance)}',
                            style: const TextStyle(
                              color: Colors.amberAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        Text(
                          '${context.tr('home.provider')}: ${selectedWallet!.provider}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                      ].withVerticalGap(4),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          SizedBox(
            width: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: wallets
                  .map((wallet) {
                    final isSelected = selectedWallet?.id == wallet.id;
                    return GestureDetector(
                      onTap: () {
                        context.read<WalletBloc>().add(SelectWallet(wallet));
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
                              : AppColors.secondary.withOpacity(0.4),
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 1.5)
                              : null,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
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
                              color: isSelected ? Colors.white : AppColors.primary,
                            ),
                            Text(
                              wallet.currencyCode,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ].withGap(4),
                        ),
                      ),
                    );
                  })
                  .toList()
                  .withGap(8),
            ),
          ),
        ].withGap(5),
      ),
    );
  }
}
