import 'package:equatable/equatable.dart';
import 'package:bagdja_wallet/features/escrow/models/escrow_record_model.dart';

class EscrowHistoryState extends Equatable {
  final List<EscrowRecordModel> mine;
  final int minePage;
  final bool mineHasMore;
  final bool isLoadingMine;
  final String mineQuery;

  final List<EscrowRecordModel> invited;
  final int invitedPage;
  final bool invitedHasMore;
  final bool isLoadingInvited;
  final String invitedQuery;

  final String error;

  const EscrowHistoryState({
    this.mine = const [],
    this.minePage = 1,
    this.mineHasMore = true,
    this.isLoadingMine = false,
    this.mineQuery = '',
    this.invited = const [],
    this.invitedPage = 1,
    this.invitedHasMore = true,
    this.isLoadingInvited = false,
    this.invitedQuery = '',
    this.error = '',
  });

  EscrowHistoryState copyWith({
    List<EscrowRecordModel>? mine,
    int? minePage,
    bool? mineHasMore,
    bool? isLoadingMine,
    String? mineQuery,
    List<EscrowRecordModel>? invited,
    int? invitedPage,
    bool? invitedHasMore,
    bool? isLoadingInvited,
    String? invitedQuery,
    String? error,
  }) {
    return EscrowHistoryState(
      mine: mine ?? this.mine,
      minePage: minePage ?? this.minePage,
      mineHasMore: mineHasMore ?? this.mineHasMore,
      isLoadingMine: isLoadingMine ?? this.isLoadingMine,
      mineQuery: mineQuery ?? this.mineQuery,
      invited: invited ?? this.invited,
      invitedPage: invitedPage ?? this.invitedPage,
      invitedHasMore: invitedHasMore ?? this.invitedHasMore,
      isLoadingInvited: isLoadingInvited ?? this.isLoadingInvited,
      invitedQuery: invitedQuery ?? this.invitedQuery,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [mine, minePage, mineHasMore, isLoadingMine, mineQuery, invited, invitedPage, invitedHasMore, isLoadingInvited, invitedQuery, error];
}
