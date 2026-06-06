import 'package:bagdja_wallet/core/utils/widget_extensions.dart';
import 'package:bagdja_wallet/features/escrow/view/escrow_history_view.dart';
import 'package:bagdja_wallet/features/home/view/widgets/action_bottom_sheet.dart';
import 'package:bagdja_wallet/features/home/view/widgets/recent_transactions_section.dart';
import 'package:bagdja_wallet/features/home/view/widgets/wallets_section.dart';
import 'package:bagdja_wallet/features/invoice/view/invoice_history_view.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_bloc.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_event.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_state.dart';
import 'package:bagdja_wallet/features/wallet/models/wallet_model.dart';
import 'package:bagdja_wallet/features/wallet/models/transaction_model.dart';
import 'package:bagdja_wallet/localization/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 1;

  final List<Widget> _pages = [
    const InvoiceHistoryView(),
    const _HomeTab(),
    const EscrowHistoryView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.receipt, size: 24),
              onPressed: () => setState(() => _selectedIndex = 0),
              color: _selectedIndex == 0 ? Colors.blue : Colors.grey,
              padding: EdgeInsets.zero,
            ),
            const SizedBox(width: 48),
            IconButton(
              icon: const Icon(Icons.account_balance_wallet, size: 24),
              onPressed: () => setState(() => _selectedIndex = 2),
              color: _selectedIndex == 2 ? Colors.blue : Colors.grey,
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: () => _showActionBottomSheet(context),
          shape: const CircleBorder(),
          backgroundColor: Colors.blue,
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: const _CustomFloatingActionButtonLocation(),
    );
  }

  void _showActionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ActionBottomSheet(),
    );
  }
}

class _CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  const _CustomFloatingActionButtonLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX = (scaffoldGeometry.scaffoldSize.width - scaffoldGeometry.floatingActionButtonSize.width) / 2;
    final double fabY = scaffoldGeometry.scaffoldSize.height - scaffoldGeometry.floatingActionButtonSize.height - 20;
    return Offset(fabX, fabY);
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

  const _LoadedState({
    required this.wallets,
    required this.selectedWallet,
    required this.transactions,
    required this.isLoadingTransactions,
    required this.hasMoreTransactions,
    required this.transactionError,
    required this.formatter,
  });

  @override
  State<_LoadedState> createState() => _LoadedStateState();
}

class _LoadedStateState extends State<_LoadedState> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(_onScroll);
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
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        children: [
          WalletsSection(
            wallets: widget.wallets,
            selectedWallet: widget.selectedWallet,
            formatter: widget.formatter,
          ),
          RecentMutation(
            transactions: widget.transactions,
            isLoading: widget.isLoadingTransactions,
            hasMore: widget.hasMoreTransactions,
            error: widget.transactionError,
            formatter: widget.formatter,
          ),
        ].withGap(8),
      ),
    );
  }
}
