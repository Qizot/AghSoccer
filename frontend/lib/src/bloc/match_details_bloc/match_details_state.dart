import 'package:agh_soccer/src/models/match.dart';
import 'package:equatable/equatable.dart';

abstract class MatchDetailsState extends Equatable {
  const MatchDetailsState();

  @override
  List<Object> get props => [];
}

class MatchDetailsInitial extends MatchDetailsState {}

class MatchDetailsSuccess extends MatchDetailsState {
  final String message;

  MatchDetailsSuccess({this.message});

  @override
  List<Object> get props => [message];

  @override
  String toString() => "MatchDetailsSuccess { message: $message }";
}

class MatchDetailsFailure extends MatchDetailsState {
  final String message;

  MatchDetailsFailure({this.message});

  @override
  List<Object> get props => [message];

  @override
  String toString() => "MatchDetailsFailure { message: $message }";
}

class MatchDetailsRefreshed extends MatchDetailsState {
  final Match match;
  final String message;
  MatchDetailsRefreshed({this.match, this.message});

  @override
  List<Object> get props => [match, message];

  @override
  String toString() => "MatchDetailsRefreshed { match: ${match.toString()}, message: $message }";
}

class MatchDetailsRollLoading extends MatchDetailsState {}

class MatchDetailsRefreshLoading extends MatchDetailsState {}

class MatchDetailsKickLoading extends MatchDetailsState {}
