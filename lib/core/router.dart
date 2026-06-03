import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bagdja_wallet/features/auth/view/login_view.dart';
import 'package:bagdja_wallet/features/home/view/home_view.dart';

class RouteName {
  static const String login = 'login';
  static const String home = 'home';
}

bool _isOAuthCallbackUri(Uri uri) {
  return uri.scheme == 'com.bagdja.wallet';
}

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: RouteName.login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/home',
        name: RouteName.home,
        builder: (context, state) => const HomeView(),
      ),
    ],
    redirect: (context, state) {
      // OAuth callback deep link ditangani flutter_appauth (RedirectUriReceiverActivity),
      // bukan GoRouter — redirect ke login agar tidak muncul "Page Not Found".
      if (_isOAuthCallbackUri(state.uri)) {
        return '/login';
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
