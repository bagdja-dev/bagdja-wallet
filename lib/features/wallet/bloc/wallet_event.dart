import 'package:equatable/equatable.dart';
import 'package:bagdja_wallet/shared/models/wallet_model.dart';
import 'package:bagdja_wallet/shared/models/organization_model.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class FetchWalletBalance extends WalletEvent {
  const FetchWalletBalance();
}

class FetchOrganizations extends WalletEvent {
  const FetchOrganizations();
}

class FetchUserProfile extends WalletEvent {
  const FetchUserProfile();
}

class SelectWallet extends WalletEvent {
  final WalletModel wallet;

  const SelectWallet(this.wallet);

  @override
  List<Object?> get props => [wallet];
}

class SelectWalletOwner extends WalletEvent {
  final WalletOwner owner;

  const SelectWalletOwner(this.owner);

  @override
  List<Object?> get props => [owner];
}

class LoadMoreTransactions extends WalletEvent {
  const LoadMoreTransactions();
}
