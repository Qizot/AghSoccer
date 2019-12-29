import 'package:agh_soccer/src/models/create_edit_match.dart';
import 'package:agh_soccer/src/models/match_filter.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class MatchEvent extends Equatable {
  const MatchEvent();

  @override
  List<Object> get props => [];
}

class MatchResetAdding extends MatchEvent {}

class MatchFetchById extends MatchEvent {
  final String matchId;

  MatchFetchById({this.matchId});

  @override
  List<Object> get props => [matchId];

  @override
  String toString() =>
      'MatchFetchById { matchId: $matchId}';

}


class MatchFetchByFilter extends MatchEvent {
  final MatchFilter filter;
  final String name;
  MatchFetchByFilter({
    this.filter, this.name
  });


  @override
  List<Object> get props => [name, filter.timeFrom, filter.timeTo, filter.showPrivate];

  @override
  String toString() =>
      'MatchFetchByFilter { name: $name, timeFrom: ${filter.timeFrom}, timeTo: ${filter.timeTo}, showPrivate: ${filter.showPrivate}}';
}

class MatchCreate extends MatchEvent {
  final CreateEditMatch match;

  MatchCreate({
    @required String name,
    @required String description,
    @required String password,
    @required DateTime startTime,
    @required DateTime endTime
  }) : match = CreateEditMatch(name: name, description: description, password: password, startTime: startTime, endTime: endTime);

  @override
  List<Object> get props => match.props;

  @override
  String toString() =>
      'MatchCreate { name: ${match.name}, description: ${match.description}, password: ${match.password}, startTime: ${match.startTime}, endTime: ${match.endTime}';
}

class MatchUpdate extends MatchEvent {
  final CreateEditMatch match;
  final String matchId;

  MatchUpdate({
    @required String matchId,
    @required String name,
    @required String description,
    @required String password,
    @required DateTime startTime,
    @required DateTime endTime,
    bool changePassword
  }) : match = CreateEditMatch(name: name, description: description, password: password, startTime: startTime, endTime: endTime, changePassword: changePassword), matchId = matchId;

  @override
  List<Object> get props => match.props..insert(0, matchId);

  @override
  String toString() =>
      'MatchUpdate { matchId: $matchId, name: ${match.name}, description: ${match.description}, password: ${match.password}, startTime: ${match.startTime}, endTime: ${match.endTime}';
}

class MatchDelete extends MatchEvent {
  final String matchId;

  MatchDelete({this.matchId});

  @override
  List<Object> get props => [matchId];

  @override
  String toString() =>
      'MatchDelete { matchId: $matchId}';
}



