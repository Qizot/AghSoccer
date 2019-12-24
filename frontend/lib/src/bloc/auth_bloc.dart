import 'package:agh_soccer/src/models/user_token.dart';
import "package:rxdart/rxdart.dart";
import "package:shared_preferences/shared_preferences.dart";

class AuthorizationBloc {
  String _tokenString = "";
  final PublishSubject _isSessionValid = PublishSubject<bool>();
  Observable<bool> get isSessionValid => _isSessionValid.stream;
  void dispose() {
    _isSessionValid.close();
  }

  void restoreSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _tokenString = prefs.get("token");
    if (_tokenString != null && _tokenString.length > 0) {
      _isSessionValid.sink.add(true);
    } else {
      _isSessionValid.sink.add(false);
    }
  }

  void openSession(UserToken token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token.token);
    await prefs.setString("refreshToken", token.refreshToken);
    _tokenString = token.token;
    _isSessionValid.sink.add(true);
  }

  void closeSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
    prefs.remove("refreshToken");
    _isSessionValid.sink.add(false);
  }
}

final authBloc = AuthorizationBloc();
