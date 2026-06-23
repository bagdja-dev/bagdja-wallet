import 'package:bagdja_wallet/core/utils/widget_extensions.dart';
import 'package:bagdja_wallet/features/home/view/widgets/recent_transactions_section.dart';
import 'package:bagdja_wallet/features/home/view/widgets/wallets_section.dart';
import 'package:bagdja_wallet/shared/widgets/action_bottom_sheet.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_bloc.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_event.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_state.dart';
import 'package:bagdja_wallet/shared/models/wallet_model.dart';
import 'package:bagdja_wallet/shared/models/transaction_model.dart';
import 'package:bagdja_wallet/shared/models/organization_model.dart';
import 'package:bagdja_wallet/shared/models/user_profile_model.dart';
import 'package:bagdja_wallet/shared/widgets/scaffold_with_bottom_nav.dart';
import 'package:bagdja_wallet/localization/main.dart';
import 'package:bagdja_wallet/features/escrow/bloc/escrow_bloc.dart';
import 'package:bagdja_wallet/injection.dart';
import 'package:bagdja_wallet/core/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<EscrowBloc>(),
      child: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          return ScaffoldWithBottomNav(
            appBarTitle: context.tr('home.wallet'),
            onFloatingActionButtonTap: state is WalletLoaded
                ? () => _showActionBottomSheet(context, state)
                : null,
            body: const _HomeTab(),
          );
        },
      ),
    );
  }

  void _showActionBottomSheet(BuildContext outerContext, WalletLoaded state) {
    final walletBloc = outerContext.read<WalletBloc>();
    showModalBottomSheet(
      context: outerContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (innerContext) => ActionBottomSheet(
        onTopUpTap: () {
          Navigator.pop(innerContext);
          final currencyCode = state.selectedWallet?.currencyCode ?? 'IDR';
          walletBloc.add(ShowTopUpModal(currencyCode));
        },
        onCreateEscrowTap: () {
          Navigator.pop(innerContext);
          outerContext.pushNamed(RouteName.createEscrow);
        },
      ),
    );
  }

}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return SafeArea(
      child: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          return switch (state) {
            WalletLoading() => const _LoadingState(),
            WalletError() => _ErrorState(message: state.message),
            WalletLoaded() => _LoadedState(
              wallets: state.wallets,
              selectedWallet: state.selectedWallet,
              transactions: state.transactions,
              isLoadingTransactions: state.isLoadingTransactions,
              hasMoreTransactions: state.hasMoreTransactions,
              transactionError: state.transactionError,
              formatter: formatter,
              walletOwners: state.walletOwners,
              selectedWalletOwner: state.selectedWalletOwner,
              userProfile: state.userProfile,
              isActivatingWallet: state.isActivatingWallet,
            ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            Text(
              message,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<WalletBloc>().add(const FetchWalletBalance()),
              icon: const Icon(Icons.refresh),
              label: Text(context.tr('common.tryAgain')),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadedState extends StatefulWidget {
  final List<WalletModel> wallets;
  final WalletModel? selectedWallet;
  final List<TransactionModel> transactions;
  final bool isLoadingTransactions;
  final bool hasMoreTransactions;
  final String? transactionError;
  final NumberFormat formatter;
  final List<WalletOwner> walletOwners;
  final WalletOwner? selectedWalletOwner;
  final UserProfileModel? userProfile;
  final bool isActivatingWallet;

  const _LoadedState({
    required this.wallets,
    required this.selectedWallet,
    required this.transactions,
    required this.isLoadingTransactions,
    required this.hasMoreTransactions,
    required this.transactionError,
    required this.formatter,
    required this.walletOwners,
    required this.selectedWalletOwner,
    this.userProfile,
    this.isActivatingWallet = false,
  });

  @override
  State<_LoadedState> createState() => _LoadedStateState();
}

class _LoadedStateState extends State<_LoadedState> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<WalletBloc>().add(const LoadMoreTransactions());
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<WalletBloc>().add(const FetchWalletBalance());
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Column(
          children: [
            WalletsSection(
              wallets: widget.wallets,
              selectedWallet: widget.selectedWallet,
              formatter: widget.formatter,
              walletOwners: widget.walletOwners,
              selectedWalletOwner: widget.selectedWalletOwner,
              userProfile: widget.userProfile,
              isActivatingWallet: widget.isActivatingWallet,
            ),
            Expanded(
              child: SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: RecentMutation(
                  transactions: widget.transactions,
                  isLoading: widget.isLoadingTransactions,
                  hasMore: widget.hasMoreTransactions,
                  error: widget.transactionError,
                  formatter: widget.formatter,
                ),
              ),
            ),
          ].withGap(10),
        ),
      ),
    );
  }
}
