import 'package:equatable/equatable.dart';

abstract class MatchDetailsEvent extends Equatable {
  const MatchDetailsEvent();

  @override
  List<Object> get props => [];
}

class MatchDetailsInitialize extends MatchDetailsEvent {
  final String matchId;

  MatchDetailsInitialize({this.matchId});

  @override
  List<Object> get props => [matchId];

  @override
  String toString() => "MatchDetailsInitialize { matchId: $matchId }";
}

class MatchDetailsEnroll extends MatchDetailsEvent {
  final String password;

  MatchDetailsEnroll({this.password});

  @override
  List<Object> get props => [password];

  @override
  String toString() => "MatchDetailsEnroll { password: $password }";

}

class MatchDetailsDeroll extends MatchDetailsEvent {}

class MatchDetailsKickPlayer extends MatchDetailsEvent {
  final String nickname;

  MatchDetailsKickPlayer({this.nickname});

  @override
  List<Object> get props => [nickname];

  String toString() => "MatchDetailsKickPlayer { nickname: $nickname }";
}

class MatchDetailsRefresh extends MatchDetailsEvent {}




