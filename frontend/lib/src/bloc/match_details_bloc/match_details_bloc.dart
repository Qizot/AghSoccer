import 'dart:async';

import 'package:agh_soccer/src/bloc/match_details_bloc/match_details_event.dart';
import 'package:agh_soccer/src/bloc/match_details_bloc/match_details_state.dart';
import 'package:agh_soccer/src/models/match.dart';
import 'package:agh_soccer/src/models/user.dart';
import 'package:agh_soccer/src/resources/match_repository.dart';
import 'package:agh_soccer/src/resources/user_repository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';


class MatchDetailsBloc extends Bloc<MatchDetailsEvent, MatchDetailsState> {
  final MatchRepository matchRepository;
  final UserRepository userRepository;
  final BehaviorSubject<bool> isUserEnrolled$ = new BehaviorSubject<bool>();
  final BehaviorSubject<bool> isUserOwner$ = new BehaviorSubject<bool>();
  User _user;
  String matchId;


  MatchDetailsBloc({
    @required this.matchRepository,
    @required this.userRepository,
  })  : assert(matchRepository != null),
        assert(userRepository != null);

  String parseError(String error) {
    return error.replaceAll("Exception: ", "");
  }

  MatchDetailsState get initialState => MatchDetailsInitial();


  checkUserEnrollment(Match match) {
    if (_user == null || match == null) return;

    if (match.players.contains(_user.nickname)) {
      isUserEnrolled$.add(true);
    } else {
      isUserEnrolled$.add(false);
    }
  }

  @override
  Stream<MatchDetailsState> mapEventToState(MatchDetailsEvent event) async* {
    if (event is MatchDetailsInitialize) {
      yield MatchDetailsRefreshLoading();

      this.matchId = event.matchId;
      try {
        final match = await matchRepository.getMatch(matchId: matchId);
        _user = await userRepository.getProfile();
        checkUserEnrollment(match);
        isUserOwner$.add(_user.sId == match.ownerId);

        yield MatchDetailsRefreshed(match: match);
      } catch (error) {
        yield MatchDetailsFailure(message: parseError(error.toString()));
      }
    }

    if (event is MatchDetailsEnroll) {
      try {
        yield MatchDetailsRollLoading();

        final updatedMatch = await matchRepository.enroll(matchId: matchId, password: event.password);
        checkUserEnrollment(updatedMatch);
        yield MatchDetailsRefreshed(match: updatedMatch, message: "Zapisano do meczu");

      } catch (error) {
          yield MatchDetailsFailure(message: parseError(parseError(error.toString())));
      }
    }

    if (event is MatchDetailsDeroll) {
      try {
        yield MatchDetailsRollLoading();

        final updatedMatch = await matchRepository.deroll(matchId: matchId);
        checkUserEnrollment(updatedMatch);
        yield MatchDetailsRefreshed(match: updatedMatch, message: "Wypisano z meczu");

      } catch (error) {
        yield MatchDetailsFailure(message: parseError(error.toString()));
      }
    }

    if (event is MatchDetailsRefresh) {
      try {
        yield MatchDetailsRefreshLoading();

        final match = await matchRepository.getMatch(matchId: matchId);
        checkUserEnrollment(match);
        yield MatchDetailsRefreshed(match: match);
      } catch (error) {
        yield MatchDetailsFailure(message: parseError(error.toString()));
      }
    }

    if (event is MatchDetailsKickPlayer) {
      try {
        yield MatchDetailsKickLoading();

        final updatedMatch = await matchRepository.kickUser(matchId: matchId, nickname: event.nickname);
        checkUserEnrollment(updatedMatch);
        yield MatchDetailsRefreshed(match: updatedMatch, message: "Wyrzucono użytkownika ${event.nickname}");
      } catch (error) {
        yield MatchDetailsFailure(message: parseError(error.toString()));
      }
    }

  }

  void dispose() {
    isUserEnrolled$.close();
    isUserOwner$.close();
  }

}