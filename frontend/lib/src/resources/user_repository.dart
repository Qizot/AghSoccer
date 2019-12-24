import 'package:agh_soccer/src/models/user_token.dart';
import 'package:agh_soccer/src/resources/auth_provider.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "auth_provider.dart";

class UserRepository {
  final AuthProvider authProvider = AuthProvider();

  Future<UserToken> login({@required String email, @required String password}) async {
    UserToken token = await authProvider.login(email: email, password: password);
    await persistToken(token);
    return token;
  }

  Future<void> register({@required String email, @required String nickname, @required String password})
    => authProvider.register(email: email, nickname: nickname, password: password);

  Future<UserToken> refreshToken(String refreshToken) async {
    UserToken token = await authProvider.refreshToken(refreshToken: refreshToken);
    await persistToken(token);
    return token;
  }

  Future<void> persistToken(UserToken token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token.token);
    await prefs.setString("refreshToken", token.refreshToken);
  }

  Future<void> deleteToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
    prefs.remove("refreshToken");
  }

  Future<bool> hasToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return  prefs.containsKey("token");
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return  prefs.get("token");
  }

}