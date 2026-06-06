import 'package:equatable/equatable.dart';
import 'package:bagdja_wallet/features/wallet/models/wallet_model.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class FetchWalletBalance extends WalletEvent {
  const FetchWalletBalance();
}

class SelectWallet extends WalletEvent {
  final WalletModel wallet;

  const SelectWallet(this.wallet);

  @override
  List<Object?> get props => [wallet];
}

class LoadMoreTransactions extends WalletEvent {
  const LoadMoreTransactions();
}
