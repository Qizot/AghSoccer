import 'dart:convert';

import 'package:agh_soccer/src/models/user.dart';
import 'package:agh_soccer/src/models/user_token.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class AuthProvider {

  final api = "http://192.168.0.105:8080/api";

  Future<UserToken> login({
    @required String email,
    @required String password,
  }) async {
    Response res = await post(api + "/login", headers: {
      "Content-Type": "application/json"
    }, body: jsonEncode({
      "email": email,
      "password": password
    }));

    if (res.statusCode == 200) {
      return UserToken.fromJson(jsonDecode(res.body));
    } else {
      String message = "";
      if (res.statusCode == 404 || res.statusCode == 400) {
        message = "Nieprawidłowe dane logowania";
      } else {
        message = "Błąd serwera";
      }

      throw Exception(message);
    }
  }

  Future<UserToken> refreshToken({@required String refreshToken}) async {
    Response res = await post(api + "/token", headers: {
      "Content-Type": "application/json"
    }, body: jsonEncode({
      "refreshToken": refreshToken
    }));

    if (res.statusCode == 200) {
      return UserToken.fromJson(jsonDecode(res.body));
    } else {
      throw Exception(jsonDecode(res.body)["message"]);
    }
  }

  Future<void> register({@required String email, @required String nickname, @required String password}) async {
    Response res = await post(api + "/register", headers: {
      "Content-Type": "application/json"
    }, body: jsonEncode({
      "email": email,
      "nickname": nickname,
      "password": password
    }));

    if (res.statusCode == 201) {
      return UserToken.fromJson(jsonDecode(res.body));
    } else {
      throw Exception(jsonDecode(res.body)["message"]);
    }
  }

  Future<User> getProfile({@required String token}) async {
    Response res = await get(api + "/me", headers: {
      "Content-Type": "application-json",
      "Authorization": "Bearer " + token
    });

    if (res.statusCode == 200) {
      return User.fromJson(jsonDecode(res.body));
    } else {
      throw Exception(jsonDecode(res.body)["message"]);
    }
  }

  Future<void> deleteAccount({@required String token}) async {
    Response res = await delete(api + "/me", headers: {
      "Content-Type": "application-json",
      "Authorization": "Bearer " + token
    });

    if (res.statusCode == 200) {
      return User.fromJson(jsonDecode(res.body));
    } else {
      throw Exception(jsonDecode(res.body)["message"]);
    }
  }
}
