import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_event.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_state.dart';
import 'package:bagdja_wallet/features/wallet/repositories/wallet_repository.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository walletRepository;

  WalletBloc({required this.walletRepository}) : super(const WalletInitial()) {
    on<FetchWalletBalance>(_onFetchWalletBalance);
    on<SelectWallet>(_onSelectWallet);
    on<LoadMoreTransactions>(_onLoadMoreTransactions);
  }

  Future<void> _onFetchWalletBalance(
    FetchWalletBalance event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());
    try {
      final wallets = await walletRepository.getMyWallet();
      final selected = wallets.isNotEmpty
          ? wallets.firstWhere((w) => w.isActive, orElse: () => wallets.first)
          : null;
      
      emit(WalletLoaded(wallets, selectedWallet: selected));
      
      if (selected != null) {
        add(const LoadMoreTransactions());
      }
    } catch (e) {
      emit(WalletError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onSelectWallet(
    SelectWallet event,
    Emitter<WalletState> emit,
  ) {
    if (state is WalletLoaded) {
      final loadedState = state as WalletLoaded;
      emit(WalletLoaded(
        loadedState.wallets,
        selectedWallet: event.wallet,
        transactions: const [],
        transactionPage: 1,
        hasMoreTransactions: true,
        isLoadingTransactions: false,
        transactionError: null,
      ));
      add(const LoadMoreTransactions());
    }
  }

  Future<void> _onLoadMoreTransactions(
    LoadMoreTransactions event,
    Emitter<WalletState> emit,
  ) async {
    if (state is! WalletLoaded) return;
    final currentState = state as WalletLoaded;
    
    if (currentState.isLoadingTransactions || !currentState.hasMoreTransactions) {
      return;
    }
    
    if (currentState.selectedWallet == null) return;

    emit(currentState.copyWith(isLoadingTransactions: true, transactionError: null));

    try {
      final result = await walletRepository.getWalletTransactions(
        currency: currentState.selectedWallet!.currencyCode,
        page: currentState.transactionPage,
      );

      final newTransactions = [...currentState.transactions, ...result.data];
      final hasMore = result.meta.currentPage < result.meta.totalPages;

      emit(currentState.copyWith(
        transactions: newTransactions,
        transactionPage: currentState.transactionPage + 1,
        hasMoreTransactions: hasMore,
        isLoadingTransactions: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isLoadingTransactions: false,
        transactionError: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
