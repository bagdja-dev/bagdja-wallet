part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

final class LoginRequested extends AuthEvent {
  const LoginRequested();
}

final class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
