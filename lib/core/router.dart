import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_bloc.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_event.dart';
import 'package:bagdja_wallet/injection.dart';
import 'package:bagdja_wallet/features/auth/bloc/auth_bloc.dart';
import 'package:bagdja_wallet/features/auth/view/login_view.dart';
import 'package:bagdja_wallet/features/home/view/home_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouteName {
  static const String login = 'login';
  static const String home = 'home';
}

bool _isOAuthCallbackUri(Uri uri) {
  return uri.scheme == 'com.bagdja.wallet';
}

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(AuthBloc authBloc) {
    _subscription = authBloc.stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter create(AuthBloc authBloc) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/login',
      refreshListenable: _AuthRefreshNotifier(authBloc),
      routes: [
        GoRoute(
          path: '/login',
          name: RouteName.login,
          builder: (context, state) => const LoginView(),
        ),
        GoRoute(
          path: '/home',
          name: RouteName.home,
          builder: (context, state) => BlocProvider(
            create: (context) => sl<WalletBloc>()..add(const FetchWalletBalance()),
            child: const HomeView(),
          ),
        ),
      ],
      redirect: (context, state) {
        if (_isOAuthCallbackUri(state.uri)) {
          return '/login';
        }

        final isAuthenticated = authBloc.state is AuthAuthenticated;
        final location = state.matchedLocation;

        if (!isAuthenticated && location != '/login') {
          return '/login';
        }

        if (isAuthenticated && location == '/login') {
          return '/home';
        }

        return null;
      },
      errorBuilder: (context, state) {
        if (_isOAuthCallbackUri(state.uri)) {
          return const LoginView();
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Page Not Found')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.error?.toString() ?? 'Route not found'),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
