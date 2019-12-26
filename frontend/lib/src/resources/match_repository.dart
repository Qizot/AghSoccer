
import 'package:agh_soccer/src/models/create_edit_match.dart';
import 'package:agh_soccer/src/models/match.dart';
import 'package:agh_soccer/src/models/match_filter.dart';
import 'package:agh_soccer/src/resources/match_provider.dart';
import 'package:agh_soccer/src/resources/user_repository.dart';
import 'package:meta/meta.dart';

class MatchRepository {
  final UserRepository userRepository = new UserRepository();
  final MatchProvider matchProvider = new MatchProvider();

  Future<List<Match>> getMatches({@required MatchFilter filter}) {
    return matchProvider.getMatches(filter: filter);
  }

  Future<Match> getMatch({@required String matchId}) {
    return matchProvider.getMatch(matchId: matchId);
  }

  Future<Match> createMatch({@required CreateEditMatch match}) async {
    final token = await userRepository.getToken();
    return matchProvider.createMatch(match: match, token: token);
  }

  Future<void> deleteMatch({@required String matchId}) async {
    final token = await userRepository.getToken();
    return matchProvider.deleteMatch(matchId: matchId, token: token);
  }

  Future<void> updateMatch({@required String matchId, @required CreateEditMatch match}) async {
    final token = await userRepository.getToken();
    return matchProvider.updateMatch(matchId: matchId, match: match, token: token);
  }


}