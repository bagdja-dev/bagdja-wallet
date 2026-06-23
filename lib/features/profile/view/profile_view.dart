import 'package:bagdja_wallet/core/theme/app_colors.dart';
import 'package:bagdja_wallet/core/utils/widget_extensions.dart';
import 'package:bagdja_wallet/features/auth/bloc/auth_bloc.dart';
import 'package:bagdja_wallet/localization/main.dart';
import 'package:bagdja_wallet/shared/widgets/scaffold_with_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                              Icon(Icons.arrow_back),
                              Text(context.tr('profile.title')),
                            ].withGap(8),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Trigger logout event via BLoC
                          context.read<AuthBloc>().add(LogoutRequested());
                        },
                        child: IntrinsicWidth(
                          child: SizedBox(
                            child: Row(
                              children: [
                                Text(
                                  context.tr('profile.logout'),
                                  style: TextStyle(color: AppColors.error),
                                ),
                                Icon(Icons.login, color: AppColors.error),
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
