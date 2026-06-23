import 'package:get_it/get_it.dart';
import 'package:bagdja_wallet/core/network/api_client.dart';
import 'package:bagdja_wallet/features/auth/repositories/auth_repository.dart';
import 'package:bagdja_wallet/features/auth/bloc/auth_bloc.dart';
import 'package:bagdja_wallet/shared/repositories/wallet_repository.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_bloc.dart';
import 'package:bagdja_wallet/features/escrow/repositories/escrow_repository.dart';
import 'package:bagdja_wallet/features/escrow/bloc/escrow_bloc.dart';
import 'package:bagdja_wallet/features/escrow/bloc/escrow_history_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  final authRepository = AuthRepository(apiClient: sl());
  sl.registerSingleton<AuthRepository>(authRepository);

  await authRepository.initDeepLinks();

  sl.registerLazySingleton(() => WalletRepository(apiClient: sl()));
  sl.registerLazySingleton(() => EscrowRepository(apiClient: sl()));

  sl.registerLazySingleton(() => AuthBloc(authRepository: sl()));
  sl.registerLazySingleton(() => WalletBloc(walletRepository: sl()));
  sl.registerFactory(() => EscrowBloc(escrowRepository: sl()));
  sl.registerFactory(() => EscrowHistoryBloc(escrowRepository: sl()));
}
