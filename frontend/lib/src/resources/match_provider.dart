import 'dart:convert';

import 'package:agh_soccer/src/config/api_config.dart';
import 'package:agh_soccer/src/models/create_edit_match.dart';
import 'package:agh_soccer/src/models/match.dart';
import 'package:agh_soccer/src/models/match_filter.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart';

class MatchProvider {

  static final headers = {
    "Content-Type": "application/json"
  };

  Map<String, String> headersWithToken({String token}) {
    return MatchProvider.headers..putIfAbsent("Authorization", () => "Bearer " + token);
  }

  Exception serverError(Response res) {
    return Exception("Błąd serwera: " + jsonDecode(res.body)["message"]);
  }

  Exception queryEror(Response res) {
    return Exception("Błąd zapytania: " + jsonDecode(res.body)["message"]);
  }

  Future<Match> getMatch({@required String matchId}) async {

    final res = await get(ApiConfig.instance.apiUri + "/matches/" + matchId);

    if (res.statusCode == 200) {
      return Match.fromJson(jsonDecode(res.body));
    }
    if (res.statusCode == 404) {
      throw Exception("Nie znaleziono meczu");
    }
    throw Exception("Błąd serwera: " + res.body);
  }

  Future<List<Match>> getMatches({@required MatchFilter filter}) async {

    print(filter.toJson());
    final res = await post(ApiConfig.instance.apiUri + "/matches/filter",
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode(filter.toJson())
    );

    switch (res.statusCode) {
      case 200: {
        List responseJson = json.decode(res.body);
        return responseJson.map((m) => new Match.fromJson(m)).toList();
      }
      case 400: {
        throw queryEror(res);
      }
      default: {
        throw serverError(res);
      }
    }
  }

  Future<Match> createMatch({@required CreateEditMatch match, @required String token}) async {

    final res = await post(ApiConfig.instance.apiUri + "/matches",
        headers: headersWithToken(token: token),
        body: jsonEncode(match.toJson())
    );

    switch(res.statusCode) {
      case 201: {
        return Match.fromJson(jsonDecode(res.body)["data"]);
      }
      case 400: {
        throw Exception("Nie udało się stworzyć meczu: " + jsonDecode(res.body)["message"]);
      }
      default: {
        throw serverError(res);
      }
    }
  }

  Future<void> deleteMatch({@required String matchId, String token}) async {
    final res = await delete(ApiConfig.instance.apiUri + "/matches/" + matchId);

    switch(res.statusCode) {
      case 200: {
        return;
      }
      case 403: {
        throw Exception("Użytkownik nie jest twórcą meczu");
      }
      default: {
        throw Exception("Błąd serwera: " + jsonDecode(res.body)["message"]);
      }
    }
  }

  Future<void> updateMatch({@required String matchId, @required CreateEditMatch match, @required String token}) async {

    final res = await patch(ApiConfig.instance.apiUri + "/matches/" + matchId,
        headers: headersWithToken(token: token),
        body: jsonEncode(match.toJson())
    );

    switch (res.statusCode) {
      case 200: {
        return;
      }
      case 400: {
        throw Exception("Nie udało się zaktualizować meczu: " + jsonDecode(res.body)["message"]);
      }
      case 403: {
        throw Exception("Użytkownik nie jest twórcą meczu");
      }
      default: {
        throw serverError(res);
      }
    }
  }

  Future<Match> enroll({@required String matchId, @required String token, String password}) async {
    final res = await post(ApiConfig.instance.apiUri + "/matches/" + matchId + "/enroll",
        headers: headersWithToken(token: token),
        body: jsonEncode(
            password == null ? {} : {"password": password }
        )
    );

    final jsonResponse = jsonDecode(res.body);

    switch (res.statusCode) {
      case 200: {
        return Match.fromJson(jsonResponse["data"]);
      }
      case 400: {
        throw Exception("Użytkownik jest już dołączył do meczu");
      }
      case 403: {
        throw Exception("Niepoprawne hasło");
      }
      default: {
        throw serverError(res);
      }
    }
  }

  Future<Match> deroll({@required String matchId, @required String token}) async {
    final res = await post(ApiConfig.instance.apiUri + "/matches/" + matchId + "/deroll",
        headers: headersWithToken(token: token),
        body: jsonEncode({})
    );

    final jsonResponse = jsonDecode(res.body);

    switch (res.statusCode) {
      case 200: {
        return Match.fromJson(jsonResponse["data"]);
      }
      case 400: {
        throw Exception("Użytkownik nie jest zapisany na mecz");
      }
      default: {
        throw serverError(res);
      }
    }
  }

  Future<Match> kickUser({@required String matchId, @required String nickname, @required String token}) async {
    final res = await post(ApiConfig.instance.apiUri + "/matches/" + matchId + "/kick",
        headers: headersWithToken(token: token),
        body: jsonEncode({
          "user": nickname
        })
    );

    final jsonResponse = jsonDecode(res.body);
    switch (res.statusCode) {
      case 200: {
        return Match.fromJson(jsonResponse["data"]);
      }
      case 400: {
        throw Exception("Podany użytkownik nie jest zapisany na mecz: $nickname");
      }
      case 403: {
        throw Exception("Tylko twórca meczy może wyrzucać innych użytkowników");
      }
      default: {
        throw serverError(res);
      }
    }
  }

}