import 'package:equatable/equatable.dart';
import 'package:bagdja_wallet/features/wallet/models/wallet_model.dart';

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

  const WalletLoaded(this.wallets);

  @override
  List<Object?> get props => [wallets];
}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}
