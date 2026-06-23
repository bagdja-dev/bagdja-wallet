import 'package:flutter_bloc/flutter_bloc.dart';
import 'escrow_history_event.dart';
import 'escrow_history_state.dart';
import 'package:bagdja_wallet/features/escrow/repositories/escrow_repository.dart';

class EscrowHistoryBloc extends Bloc<EscrowHistoryEvent, EscrowHistoryState> {
  final EscrowRepository escrowRepository;

  EscrowHistoryBloc({required this.escrowRepository}) : super(const EscrowHistoryState()) {
    on<FetchMineEscrows>(_onFetchMine);
    on<LoadMoreMineEscrows>(_onLoadMoreMine);
    on<SearchMineEscrows>(_onSearchMine);

    on<FetchInvitedEscrows>(_onFetchInvited);
    on<LoadMoreInvitedEscrows>(_onLoadMoreInvited);
    on<SearchInvitedEscrows>(_onSearchInvited);
  }

  Future<void> _onFetchMine(FetchMineEscrows event, Emitter<EscrowHistoryState> emit) async {
    emit(state.copyWith(isLoadingMine: true, error: ''));
    try {
      final res = await escrowRepository.getMyEscrows(page: 1, size: 20, search: state.mineQuery.isEmpty ? null : state.mineQuery);
      emit(state.copyWith(mine: res.data, minePage: 2, mineHasMore: res.meta.page < res.meta.totalPages, isLoadingMine: false));
    } catch (e) {
      emit(state.copyWith(isLoadingMine: false, error: e.toString()));
    }
  }

  Future<void> _onLoadMoreMine(LoadMoreMineEscrows event, Emitter<EscrowHistoryState> emit) async {
    if (!state.mineHasMore || state.isLoadingMine) return;
    emit(state.copyWith(isLoadingMine: true));
    try {
      final res = await escrowRepository.getMyEscrows(page: state.minePage, size: 20, search: state.mineQuery.isEmpty ? null : state.mineQuery);
      final combined = [...state.mine, ...res.data];
      emit(state.copyWith(mine: combined, minePage: state.minePage + 1, mineHasMore: res.meta.page < res.meta.totalPages, isLoadingMine: false));
    } catch (e) {
      emit(state.copyWith(isLoadingMine: false, error: e.toString()));
    }
  }

  Future<void> _onSearchMine(SearchMineEscrows event, Emitter<EscrowHistoryState> emit) async {
    emit(state.copyWith(mineQuery: event.query, minePage: 1, mineHasMore: true));
    add(FetchMineEscrows());
  }

  Future<void> _onFetchInvited(FetchInvitedEscrows event, Emitter<EscrowHistoryState> emit) async {
    emit(state.copyWith(isLoadingInvited: true, error: ''));
    try {
      final res = await escrowRepository.getInvitedEscrows(page: 1, size: 20, search: state.invitedQuery.isEmpty ? null : state.invitedQuery);
      emit(state.copyWith(invited: res.data, invitedPage: 2, invitedHasMore: res.meta.page < res.meta.totalPages, isLoadingInvited: false));
    } catch (e) {
      emit(state.copyWith(isLoadingInvited: false, error: e.toString()));
    }
  }

  Future<void> _onLoadMoreInvited(LoadMoreInvitedEscrows event, Emitter<EscrowHistoryState> emit) async {
    if (!state.invitedHasMore || state.isLoadingInvited) return;
    emit(state.copyWith(isLoadingInvited: true));
    try {
      final res = await escrowRepository.getInvitedEscrows(page: state.invitedPage, size: 20, search: state.invitedQuery.isEmpty ? null : state.invitedQuery);
      final combined = [...state.invited, ...res.data];
      emit(state.copyWith(invited: combined, invitedPage: state.invitedPage + 1, invitedHasMore: res.meta.page < res.meta.totalPages, isLoadingInvited: false));
    } catch (e) {
      emit(state.copyWith(isLoadingInvited: false, error: e.toString()));
    }
  }

  Future<void> _onSearchInvited(SearchInvitedEscrows event, Emitter<EscrowHistoryState> emit) async {
    emit(state.copyWith(invitedQuery: event.query, invitedPage: 1, invitedHasMore: true));
    add(FetchInvitedEscrows());
  }
}
