import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bagdja_wallet/core/router.dart';
import 'package:bagdja_wallet/core/theme/app_colors.dart';
import 'package:bagdja_wallet/features/auth/bloc/auth_bloc.dart';
import 'package:bagdja_wallet/injection.dart' as di;
import 'package:bagdja_wallet/core/config/settings.dart';
import 'package:bagdja_wallet/core/network/api_client.dart';
import 'package:bagdja_wallet/localization/main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Settings.init();
  await di.init();

  final authBloc = di.sl<AuthBloc>();
  final apiClient = di.sl<ApiClient>();
  final router = AppRouter.create(authBloc);

  runApp(MyApp(authBloc: authBloc, apiClient: apiClient, router: router));
}

class MyApp extends StatefulWidget {
  final AuthBloc authBloc;
  final ApiClient apiClient;
  final GoRouter router;

  const MyApp({
    super.key,
    required this.authBloc,
    required this.apiClient,
    required this.router,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<void>? _unauthorizedSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.authBloc.add(const CheckAuthStatus());
    });

    // Listen for unauthorized events from API client
    _unauthorizedSubscription = widget.apiClient.onUnauthorized.listen((_) {
      widget.authBloc.add(const LogoutRequested());
    });
  }

  @override
  void dispose() {
    _unauthorizedSubscription?.cancel();
    widget.apiClient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.authBloc),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            current is AuthAuthenticated ||
            (previous is AuthAuthenticated && current is AuthInitial),
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            widget.router.goNamed(RouteName.home);
          } else if (state is AuthInitial) {
            widget.router.goNamed(RouteName.login);
          }
        },
        child: MaterialApp.router(
          title: 'Bagdja Wallet',
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            AppLocalizationsDelegate(),
          ],
          supportedLocales: Main.supportedLocales,
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.background,
            primaryColor: AppColors.primary,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              error: AppColors.error,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              centerTitle: true,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            useMaterial3: true,
          ),
          routerConfig: widget.router,
        ),
      ),
    );
  }
}
