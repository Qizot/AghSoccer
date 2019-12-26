import 'package:agh_soccer/src/models/match.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class MatchState extends Equatable {
  const MatchState();

  @override
  List<Object> get props => [];
}

class MatchInitial extends MatchState {}

class MatchLoading extends MatchState {}

class MatchCreateLoading extends MatchState {}

class MatchUpdateLoading extends MatchState {}

class MatchDeleteLoading extends MatchState {}

class MatchFetchedById extends MatchState {
  final Match match;

  MatchFetchedById({this.match});

  @override
  List<Object> get props => match.props;

  @override
  String toString() => 'MatchFetchedById { error: $match }';
}

class MatchFetchedByFilter extends MatchState {
  final List<Match> matches;
  final String name;

  MatchFetchedByFilter({this.matches, this.name});

  @override
  List<Object> get props => matches;

  @override
  String toString() => 'MatchFetchedByFilter { name: $name, matches: $matches }';
}

class MatchCreated extends MatchState {
  final Match match;

  MatchCreated({this.match});

  @override
  List<Object> get props => match.props;

  @override
  String toString() => 'MatchCreated { match: $match}';

}

class MatchDeleted extends MatchState {}

class MatchUpdated extends MatchState {}

class MatchFailure extends MatchState {
  final String error;

  const MatchFailure({@required this.error});

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'MatchFailure { error: $error }';
}