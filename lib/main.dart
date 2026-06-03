import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bagdja_wallet/core/router.dart';
import 'package:bagdja_wallet/core/theme/app_colors.dart';
import 'package:bagdja_wallet/features/auth/bloc/auth_bloc.dart';
import 'package:bagdja_wallet/injection.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  final authBloc = di.sl<AuthBloc>();
  final router = AppRouter.create(authBloc);

  runApp(MyApp(authBloc: authBloc, router: router));
}

class MyApp extends StatefulWidget {
  final AuthBloc authBloc;
  final GoRouter router;

  const MyApp({
    super.key,
    required this.authBloc,
    required this.router,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.authBloc.add(const CheckAuthStatus());
    });
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
