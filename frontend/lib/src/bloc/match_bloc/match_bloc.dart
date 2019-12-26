import 'dart:async';

import 'package:agh_soccer/src/bloc/match_bloc/match_event.dart';
import 'package:agh_soccer/src/bloc/match_bloc/match_state.dart';
import 'package:agh_soccer/src/resources/match_repository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';


class MatchBloc extends Bloc<MatchEvent, MatchState> {
  final MatchRepository matchRepository;

  MatchBloc({
    @required this.matchRepository,
  })  : assert(matchRepository != null);

  MatchState get initialState => MatchInitial();

  @override
  Stream<MatchState> mapEventToState(MatchEvent event) async* {

    if (event is MatchFetchById) {
      yield MatchLoading();
      try {
        final match = await matchRepository.getMatch(matchId: event.matchId);
        yield MatchFetchedById(match: match);
      } catch (error) {
        yield MatchFailure(error: error);
      }
    }

    if (event is MatchFetchByFilter) {
      yield MatchLoading();
      try {
        final matches = await matchRepository.getMatches(filter: event.filter);
        yield MatchFetchedByFilter(matches: matches, name: event.name);
      } catch (error) {
        print(error);
        yield MatchFailure(error: error);
      }
    }

    if (event is MatchCreate) {
      yield MatchCreateLoading();

      try {
        final match = await matchRepository.createMatch(match: event.match);
        yield MatchCreated(match: match);
      } catch (error) {
        yield MatchFailure(error: error);
      }
    }

    if (event is MatchUpdate) {
      yield MatchUpdateLoading();
      
      try {
        await matchRepository.updateMatch(matchId: event.matchId, match: event.match);
        yield MatchUpdated();
      } catch (error) {
        yield MatchFailure(error: error);
      }
    }

    if (event is MatchDelete) {
      yield MatchDeleteLoading();

      try {
        await matchRepository.deleteMatch(matchId: event.matchId);
        yield MatchDeleted();
      } catch (error) {
        yield MatchFailure(error: error);
      }
    }

  }

}