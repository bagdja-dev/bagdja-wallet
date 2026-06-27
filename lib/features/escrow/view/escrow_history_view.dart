import 'dart:async';

import 'package:bagdja_wallet/core/router.dart';
import 'package:bagdja_wallet/localization/main.dart';
import 'package:bagdja_wallet/features/escrow/bloc/escrow_history_bloc.dart';
import 'package:bagdja_wallet/features/escrow/bloc/escrow_history_event.dart';
import 'package:bagdja_wallet/features/escrow/bloc/escrow_history_state.dart';
import 'package:bagdja_wallet/features/escrow/widgets/escrow_item.dart';
import 'package:bagdja_wallet/features/escrow/widgets/escrow_search_bar.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_bloc.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_event.dart';
import 'package:bagdja_wallet/features/wallet/bloc/wallet_state.dart';
import 'package:bagdja_wallet/injection.dart';
import 'package:bagdja_wallet/shared/widgets/scaffold_with_bottom_nav.dart';
import 'package:bagdja_wallet/shared/widgets/action_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EscrowHistoryView extends StatefulWidget {
  const EscrowHistoryView({super.key});

  @override
  State<EscrowHistoryView> createState() => _EscrowHistoryViewState();
}

class _EscrowHistoryViewState extends State<EscrowHistoryView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  late EscrowHistoryBloc _historyBloc;
  final mineController = TextEditingController();
  final invitedController = TextEditingController();
  final mineScroll = ScrollController();
  final invitedScroll = ScrollController();
  Timer? _mineSearchTimer;
  Timer? _invitedSearchTimer;
  static const _searchDebounceMs = 500;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
    mineScroll.addListener(_onMineScroll);
    invitedScroll.addListener(_onInvitedScroll);
    mineController.addListener(_onMineTextChanged);
    invitedController.addListener(_onInvitedTextChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _mineSearchTimer?.cancel();
    _invitedSearchTimer?.cancel();
    mineController.dispose();
    invitedController.dispose();
    mineScroll.dispose();
    invitedScroll.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh data ketika app kembali ke foreground
      _refreshData();
    }
  }

  void _refreshData() {
    // Refresh tab yang sedang aktif
    if (_tabController.index == 0) {
      _historyBloc.add(FetchMineEscrows());
    } else {
      _historyBloc.add(FetchInvitedEscrows());
    }
  }

  void _onMineTextChanged() {
    _mineSearchTimer?.cancel();
    _mineSearchTimer = Timer(
      const Duration(milliseconds: _searchDebounceMs),
      () => _historyBloc.add(SearchMineEscrows(mineController.text)),
    );
  }

  void _onInvitedTextChanged() {
    _invitedSearchTimer?.cancel();
    _invitedSearchTimer = Timer(
      const Duration(milliseconds: _searchDebounceMs),
      () => _historyBloc.add(SearchInvitedEscrows(invitedController.text)),
    );
  }

  void _onMineScroll() {
    if (mineScroll.position.pixels >
        mineScroll.position.maxScrollExtent - 200) {
      _historyBloc.add(LoadMoreMineEscrows());
    }
  }

  void _onInvitedScroll() {
    if (invitedScroll.position.pixels >
        invitedScroll.position.maxScrollExtent - 200) {
      _historyBloc.add(LoadMoreInvitedEscrows());
    }
  }

  void _showActionBottomSheet(BuildContext outerContext, WalletLoaded state) {
    final walletBloc = outerContext.read<WalletBloc>();
    showModalBottomSheet(
      context: outerContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (innerContext) => ActionBottomSheet(
        onTopUpTap: () {
          Navigator.pop(innerContext);
          final currencyCode = state.selectedWallet?.currencyCode ?? 'IDR';
          walletBloc.add(ShowTopUpModal(currencyCode));
        },
        onCreateEscrowTap: () {
          Navigator.pop(innerContext);
          outerContext.pushNamed(RouteName.createEscrow);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _historyBloc = sl<EscrowHistoryBloc>();
    _historyBloc.add(FetchMineEscrows());
    return BlocProvider.value(
      value: _historyBloc,
      child: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          return ScaffoldWithBottomNav(
            appBarTitle: context.tr('home.escrowHistory'),
            onFloatingActionButtonTap: state is WalletLoaded
                ? () => _showActionBottomSheet(context, state)
                : null,
            body: SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, size: 24),
                                onPressed: () => context.goNamed(RouteName.home),
                              ),
                              Text(context.tr('home.escrowHistory')),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _refreshData,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    child: TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(text: context.tr('escrow.mine')),
                        Tab(text: context.tr('escrow.invited')),
                      ],
                    )
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [_buildMineTab(), _buildInvitedTab()],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMineTab() {
    return Column(
      children: [
        EscrowSearchBar(
          controller: mineController,
          onSearch: (q) => _historyBloc.add(SearchMineEscrows(q)),
        ),
        Expanded(
          child: BlocBuilder<EscrowHistoryBloc, EscrowHistoryState>(
            builder: (context, state) {
              if (state.isLoadingMine && state.mine.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.mine.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () async {
                    _historyBloc.add(FetchMineEscrows());
                  },
                  child: ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Center(child: Text('No escrows found')),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  _historyBloc.add(FetchMineEscrows());
                },
                child: ListView.builder(
                  controller: mineScroll,
                  itemCount: state.mine.length + (state.mineHasMore ? 1 : 0),
                  itemBuilder: (context, idx) {
                    if (idx >= state.mine.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final item = state.mine[idx];
                    return EscrowItem(model: item);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInvitedTab() {
    return Column(
      children: [
        EscrowSearchBar(
          controller: invitedController,
          onSearch: (q) => _historyBloc.add(SearchInvitedEscrows(q)),
        ),
        Expanded(
          child: BlocBuilder<EscrowHistoryBloc, EscrowHistoryState>(
            builder: (context, state) {
              if (state.isLoadingInvited && state.invited.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.invited.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () async {
                    _historyBloc.add(FetchInvitedEscrows());
                  },
                  child: ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Center(child: Text('No invitations found')),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  _historyBloc.add(FetchInvitedEscrows());
                },
                child: ListView.builder(
                  controller: invitedScroll,
                  itemCount:
                      state.invited.length + (state.invitedHasMore ? 1 : 0),
                  itemBuilder: (context, idx) {
                    if (idx >= state.invited.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final item = state.invited[idx];
                    return EscrowItem(model: item);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
