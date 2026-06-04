import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_event.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_state.dart';
import 'package:bagdja_wallet/features/wallet/repositories/wallet_repository.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository walletRepository;

  WalletBloc({required this.walletRepository}) : super(const WalletInitial()) {
    on<FetchWalletBalance>(_onFetchWalletBalance);
  }

  Future<void> _onFetchWalletBalance(
    FetchWalletBalance event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());
    try {
      final wallet = await walletRepository.getMyWallet();
      emit(WalletLoaded(wallet));
    } catch (e) {
      emit(WalletError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
