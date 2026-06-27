import 'dart:async';

import 'package:bagdja_wallet/features/auth/bloc/auth_bloc.dart';
import 'package:bagdja_wallet/features/auth/view/login_view.dart';
import 'package:bagdja_wallet/features/home/view/home_view.dart';
import 'package:bagdja_wallet/features/invoice/view/invoice_history_view.dart';
import 'package:bagdja_wallet/features/escrow/view/escrow_history_view.dart';
import 'package:bagdja_wallet/features/escrow/view/create_escrow_invoice_view.dart';
import 'package:bagdja_wallet/features/escrow/view/escrow_detail_view.dart';
import 'package:bagdja_wallet/features/profile/view/profile_view.dart';
import 'package:bagdja_wallet/features/escrow/models/escrow_record_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouteName {
  static const String login = 'login';
  static const String home = 'home';
  static const String invoiceHistory = 'invoice-history';
  static const String escrowHistory = 'escrow-history';
  static const String escrowDetail = 'escrow-detail';
  static const String createEscrow = 'create-escrow';
  static const String profile = 'profile';
}

bool _isOAuthCallbackUri(Uri uri) {
  return uri.scheme == 'com.bagdja.wallet';
}

bool _isEscrowPaymentCallbackUri(Uri uri) {
  return uri.scheme == 'bagdja' && uri.host == 'escrow';
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
          builder: (context, state) => const HomeView(),
        ),
        GoRoute(
          path: '/invoice-history',
          name: RouteName.invoiceHistory,
          builder: (context, state) => const InvoiceHistoryView(),
        ),
        GoRoute(
          path: '/escrow-history',
          name: RouteName.escrowHistory,
          builder: (context, state) => const EscrowHistoryView(),
        ),
        GoRoute(
          path: '/escrow-detail',
          name: RouteName.escrowDetail,
          builder: (context, state) {
            final escrow = state.extra as EscrowRecordModel;
            return EscrowDetailView(escrow: escrow);
          },
        ),
        GoRoute(
          path: '/create-escrow',
          name: RouteName.createEscrow,
          builder: (context, state) => const CreateEscrowInvoiceView(),
        ),
        GoRoute(
          path: '/profile',
          name: RouteName.profile,
          builder: (context, state) => const ProfileView(),
        ),
      ],
      redirect: (context, state) {
        if (_isOAuthCallbackUri(state.uri)) {
          return '/login';
        }

        // Handle escrow payment deep link
        if (_isEscrowPaymentCallbackUri(state.uri)) {
          // Redirect to escrow history page
          return '/escrow-history';
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
