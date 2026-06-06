import 'package:equatable/equatable.dart';
import 'package:bagdja_wallet/features/wallet/models/wallet_model.dart';
import 'package:bagdja_wallet/features/wallet/models/transaction_model.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {
  const WalletInitial();
}

class WalletLoading extends WalletState {
  const WalletLoading();
}

class WalletLoaded extends WalletState {
  final List<WalletModel> wallets;
  final WalletModel? selectedWallet;
  final List<TransactionModel> transactions;
  final int transactionPage;
  final bool hasMoreTransactions;
  final bool isLoadingTransactions;
  final String? transactionError;

  const WalletLoaded(
    this.wallets, {
    this.selectedWallet,
    this.transactions = const [],
    this.transactionPage = 1,
    this.hasMoreTransactions = true,
    this.isLoadingTransactions = false,
    this.transactionError,
  });

  WalletLoaded copyWith({
    List<WalletModel>? wallets,
    WalletModel? selectedWallet,
    List<TransactionModel>? transactions,
    int? transactionPage,
    bool? hasMoreTransactions,
    bool? isLoadingTransactions,
    String? transactionError,
  }) {
    return WalletLoaded(
      wallets ?? this.wallets,
      selectedWallet: selectedWallet ?? this.selectedWallet,
      transactions: transactions ?? this.transactions,
      transactionPage: transactionPage ?? this.transactionPage,
      hasMoreTransactions: hasMoreTransactions ?? this.hasMoreTransactions,
      isLoadingTransactions: isLoadingTransactions ?? this.isLoadingTransactions,
      transactionError: transactionError ?? this.transactionError,
    );
  }

  @override
  List<Object?> get props => [
        wallets,
        selectedWallet,
        transactions,
        transactionPage,
        hasMoreTransactions,
        isLoadingTransactions,
        transactionError,
      ];
}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}
