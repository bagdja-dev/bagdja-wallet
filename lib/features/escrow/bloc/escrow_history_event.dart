import 'package:equatable/equatable.dart';

abstract class EscrowHistoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchMineEscrows extends EscrowHistoryEvent {}
class LoadMoreMineEscrows extends EscrowHistoryEvent {}
class SearchMineEscrows extends EscrowHistoryEvent {
  final String query;
  SearchMineEscrows(this.query);
  @override
  List<Object?> get props => [query];
}

class FetchInvitedEscrows extends EscrowHistoryEvent {}
class LoadMoreInvitedEscrows extends EscrowHistoryEvent {}
class SearchInvitedEscrows extends EscrowHistoryEvent {
  final String query;
  SearchInvitedEscrows(this.query);
  @override
  List<Object?> get props => [query];
}
