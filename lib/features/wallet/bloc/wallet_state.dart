import 'package:equatable/equatable.dart';
import 'package:bagdja_wallet/shared/models/wallet_model.dart';
import 'package:bagdja_wallet/shared/models/transaction_model.dart';
import 'package:bagdja_wallet/shared/models/organization_model.dart';
import 'package:bagdja_wallet/shared/models/user_profile_model.dart';

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
  final List<OrganizationModel> organizations;
  final List<WalletOwner> walletOwners;
  final WalletOwner? selectedWalletOwner;
  final UserProfileModel? userProfile;
  final bool shouldShowTopUpModal;
  final String? topUpCurrency;
  final bool isActivatingWallet;

  const WalletLoaded(
    this.wallets, {
    this.selectedWallet,
    this.transactions = const [],
    this.transactionPage = 1,
    this.hasMoreTransactions = true,
    this.isLoadingTransactions = false,
    this.transactionError,
    this.organizations = const [],
    this.walletOwners = const [],
    this.selectedWalletOwner,
    this.userProfile,
    this.shouldShowTopUpModal = false,
    this.topUpCurrency,
    this.isActivatingWallet = false,
  });

  WalletLoaded copyWith({
    List<WalletModel>? wallets,
    WalletModel? selectedWallet,
    List<TransactionModel>? transactions,
    int? transactionPage,
    bool? hasMoreTransactions,
    bool? isLoadingTransactions,
    String? transactionError,
    List<OrganizationModel>? organizations,
    List<WalletOwner>? walletOwners,
    WalletOwner? selectedWalletOwner,
    UserProfileModel? userProfile,
    bool? shouldShowTopUpModal,
    String? topUpCurrency,
    bool? isActivatingWallet,
  }) {
    return WalletLoaded(
      wallets ?? this.wallets,
      selectedWallet: selectedWallet ?? this.selectedWallet,
      transactions: transactions ?? this.transactions,
      transactionPage: transactionPage ?? this.transactionPage,
      hasMoreTransactions: hasMoreTransactions ?? this.hasMoreTransactions,
      isLoadingTransactions: isLoadingTransactions ?? this.isLoadingTransactions,
      transactionError: transactionError ?? this.transactionError,
      organizations: organizations ?? this.organizations,
      walletOwners: walletOwners ?? this.walletOwners,
      selectedWalletOwner: selectedWalletOwner ?? this.selectedWalletOwner,
      userProfile: userProfile ?? this.userProfile,
      shouldShowTopUpModal: shouldShowTopUpModal ?? this.shouldShowTopUpModal,
      topUpCurrency: topUpCurrency ?? this.topUpCurrency,
      isActivatingWallet: isActivatingWallet ?? this.isActivatingWallet,
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
        organizations,
        walletOwners,
        selectedWalletOwner,
        userProfile,
        shouldShowTopUpModal,
        topUpCurrency,
        isActivatingWallet,
      ];
}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}
