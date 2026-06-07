import 'package:bagdja_wallet/core/router.dart';
import 'package:bagdja_wallet/core/theme/app_colors.dart';
import 'package:bagdja_wallet/core/utils/widget_extensions.dart';
import 'package:bagdja_wallet/features/auth/bloc/auth_bloc.dart';
import 'package:bagdja_wallet/localization/main.dart';
import 'package:bagdja_wallet/shared/widgets/scaffold_with_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBottomNav(
      appBarTitle: '',
      body: Stack(
        children: [
          SafeArea(
            child: Align(
              alignment: AlignmentGeometry.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8.0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IntrinsicWidth(
                        child: SizedBox(
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => context.pushNamed(RouteName.home),
                                icon: const Icon(Icons.arrow_back),
                              ),
                              Text(context.tr('profile.title')),
                            ].withGap(4),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                            ),
                            builder: (ctx) {
                              return SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        context.tr('profile.logoutConfirm'),
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(context.tr('profile.logoutConfirmDescription')),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => Navigator.of(ctx).pop(),
                                              child: const Text('Batal'),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                              onPressed: () {
                                                context.read<AuthBloc>().add(LogoutRequested());
                                                Navigator.of(ctx).pop();
                                              },
                                              child: Text(context.tr('profile.logout')),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: IntrinsicWidth(
                          child: SizedBox(
                            child: Row(
                              children: [
                                Text(
                                  context.tr('profile.logout'),
                                  style: TextStyle(color: AppColors.error),
                                ),
                                Icon(Icons.logout, color: AppColors.error),
                              ].withGap(8),
                            ),
                          ),
                        ),
                      ),
                    ].withGap(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
