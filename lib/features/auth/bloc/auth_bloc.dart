import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bagdja_wallet/features/auth/repositories/auth_repository.dart';

import 'package:bagdja_wallet/features/auth/models/user_model.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedIn = await authRepository.isLoggedIn();
    if (isLoggedIn) {
      final token = await authRepository.getAccessToken();
      emit(AuthAuthenticated(
        user: UserModel(
          userId: 'SSO_USER',
          username: 'bagdja_user',
          name: 'Bagdja User',
          token: token ?? '',
        ),
      ));
    } else {
      emit(AuthInitial());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login();
      emit(AuthAuthenticated(user: user));
    } on TimeoutException {
      emit(const AuthError(message: 'Login timeout. Silakan coba lagi.'));
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      if (message.contains('timeout') ||
          message.contains('dibatalkan') ||
          message.contains('cancelled')) {
        emit(AuthInitial());
        return;
      }
      emit(AuthError(message: message));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.logout();
    emit(AuthInitial());
  }
}
