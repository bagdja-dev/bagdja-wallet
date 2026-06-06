import 'package:bagdja_wallet/shared/widgets/action_bottom_sheet.dart';
import 'package:bagdja_wallet/core/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithBottomNav extends StatelessWidget {
  final String appBarTitle;
  final Widget body;

  const ScaffoldWithBottomNav({
    super.key,
    required this.appBarTitle,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.receipt, size: 24),
              onPressed: () => context.goNamed(RouteName.invoiceHistory),
              color: GoRouterState.of(context).name == RouteName.invoiceHistory
                  ? Colors.blue
                  : Colors.grey,
              padding: EdgeInsets.zero,
            ),
            const SizedBox(width: 48),
            IconButton(
              icon: const Icon(Icons.account_balance_wallet, size: 24),
              onPressed: () => context.goNamed(RouteName.escrowHistory),
              color: GoRouterState.of(context).name == RouteName.escrowHistory
                  ? Colors.blue
                  : Colors.grey,
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: () => _showActionBottomSheet(context),
          shape: const CircleBorder(),
          backgroundColor: Colors.blue,
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: const _CustomFloatingActionButtonLocation(),
    );
  }

  void _showActionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ActionBottomSheet(),
    );
  }
}

class _CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  const _CustomFloatingActionButtonLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // Calculate position to be lower than default
    final double fabX = (scaffoldGeometry.scaffoldSize.width -
            scaffoldGeometry.floatingActionButtonSize.width) /
        2;
    final double fabY = scaffoldGeometry.scaffoldSize.height -
        scaffoldGeometry.floatingActionButtonSize.height -
        48;
    return Offset(fabX, fabY);
  }
}
