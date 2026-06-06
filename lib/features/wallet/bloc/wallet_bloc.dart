import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_event.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_state.dart';
import 'package:bagdja_wallet/shared/repositories/wallet_repository.dart';
import 'package:bagdja_wallet/shared/models/organization_model.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository walletRepository;

  WalletBloc({required this.walletRepository}) : super(const WalletInitial()) {
    on<FetchWalletBalance>(_onFetchWalletBalance);
    on<FetchOrganizations>(_onFetchOrganizations);
    on<FetchUserProfile>(_onFetchUserProfile);
    on<SelectWallet>(_onSelectWallet);
    on<SelectWalletOwner>(_onSelectWalletOwner);
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
      
      // Create default personal owner
      final personalOwner = WalletOwner(
        id: 'personal',
        name: 'Personal',
        isPersonal: true,
      );
      
      emit(WalletLoaded(
        wallets,
        selectedWallet: selected,
        walletOwners: [personalOwner],
        selectedWalletOwner: personalOwner,
      ));
      
      // Fetch organizations and user profile
      add(const FetchOrganizations());
      add(const FetchUserProfile());
      
      if (selected != null) {
        add(const LoadMoreTransactions());
      }
    } catch (e) {
      emit(WalletError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onFetchUserProfile(
    FetchUserProfile event,
    Emitter<WalletState> emit,
  ) async {
    if (state is! WalletLoaded) return;

    try {
      final userProfile = await walletRepository.getMyProfile();

      // Use the latest state to avoid overwriting concurrent updates
      if (state is WalletLoaded) {
        emit((state as WalletLoaded).copyWith(userProfile: userProfile));
      }
    } catch (e) {
      // Just log error, don't fail the whole app
    }
  }

  Future<void> _onFetchOrganizations(
    FetchOrganizations event,
    Emitter<WalletState> emit,
  ) async {
    if (state is! WalletLoaded) return;

    try {
      final organizations = await walletRepository.getMyOrganizations();

      // Create wallet owners: Personal + Organizations
      final personalOwner = WalletOwner(
        id: 'personal',
        name: 'Personal',
        isPersonal: true,
      );

      final orgOwners = organizations
          .map((org) => WalletOwner(
                id: org.orgId,
                name: org.name,
                orgId: org.orgId, // Gunakan org.orgId (slug) untuk request
                isPersonal: false,
                logo: org.logo,
                description: org.description,
              ))
          .toList();

      final walletOwners = [personalOwner, ...orgOwners];

      if (state is WalletLoaded) {
        final currentState = state as WalletLoaded;
        final selectedOwner = currentState.selectedWalletOwner != null
            ? walletOwners.firstWhere(
                (owner) => owner.id == currentState.selectedWalletOwner!.id,
                orElse: () => personalOwner,
              )
            : personalOwner;

        emit(currentState.copyWith(
              organizations: organizations,
              walletOwners: walletOwners,
              selectedWalletOwner: selectedOwner,
            ));
      }
    } catch (e) {
      // Just log error, don't fail the whole app
    }
  }

  void _onSelectWallet(
    SelectWallet event,
    Emitter<WalletState> emit,
  ) {
    if (state is WalletLoaded) {
      final loadedState = state as WalletLoaded;
      emit(loadedState.copyWith(
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

  Future<void> _onSelectWalletOwner(
    SelectWalletOwner event,
    Emitter<WalletState> emit,
  ) async {
    if (state is! WalletLoaded) return;

    final loadedState = state as WalletLoaded;
    emit(loadedState.copyWith(
      selectedWalletOwner: event.owner,
      wallets: const [],
      selectedWallet: null,
      transactions: const [],
      transactionPage: 1,
      hasMoreTransactions: true,
      isLoadingTransactions: false,
      transactionError: null,
    ));

    try {
      final selectedOwner = event.owner;
      final wallets = selectedOwner.isPersonal
          ? await walletRepository.getMyWallet()
          : await walletRepository.getOrganizationWallets(
              selectedOwner.orgId ??
                  (throw Exception('Organization ID tidak ditemukan')),
            );

      final selectedWallet = wallets.isNotEmpty
          ? wallets.firstWhere((w) => w.isActive, orElse: () => wallets.first)
          : null;

      if (state is WalletLoaded) {
        final latest = state as WalletLoaded;
        emit(latest.copyWith(
          wallets: wallets,
          selectedWallet: selectedWallet,
        ));
      }

      if (selectedWallet != null) {
        add(const LoadMoreTransactions());
      }
    } catch (e) {
      if (state is WalletLoaded) {
        emit((state as WalletLoaded).copyWith(
          isLoadingTransactions: false,
          transactionError: e.toString().replaceAll('Exception: ', ''),
        ));
      }
    }
  }

  Future<void> _onLoadMoreTransactions(
    LoadMoreTransactions event,
    Emitter<WalletState> emit,
  ) async {
    if (state is! WalletLoaded) return;

    // Use the latest state snapshot for checks
    final checkState = state as WalletLoaded;

    if (checkState.isLoadingTransactions || !checkState.hasMoreTransactions) {
      return;
    }

    if (checkState.selectedWallet == null) return;

    // Mark loading using latest state
    emit((state as WalletLoaded).copyWith(isLoadingTransactions: true, transactionError: null));

    try {
      final currentState = state as WalletLoaded;
      final result = await walletRepository.getWalletTransactions(
        currency: currentState.selectedWallet!.currencyCode,
        page: currentState.transactionPage,
        ownerType: currentState.selectedWalletOwner?.isPersonal == true
            ? 'personal'
            : 'organization',
        organizationId: currentState.selectedWalletOwner?.orgId,
      );

      // Use the latest state after awaiting to append transactions safely
      if (state is! WalletLoaded) return;
      final latest = state as WalletLoaded;

      final newTransactions = [...latest.transactions, ...result.data];
      final hasMore = result.meta.currentPage < result.meta.totalPages;

      emit(latest.copyWith(
        transactions: newTransactions,
        transactionPage: latest.transactionPage + 1,
        hasMoreTransactions: hasMore,
        isLoadingTransactions: false,
      ));
    } catch (e) {
      if (state is WalletLoaded) {
        emit((state as WalletLoaded).copyWith(
          isLoadingTransactions: false,
          transactionError: e.toString().replaceAll('Exception: ', ''),
        ));
      }
    }
  }
}
