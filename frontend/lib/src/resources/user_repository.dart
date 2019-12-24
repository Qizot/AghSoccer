import 'package:agh_soccer/src/resources/auth_provider.dart';
import "auth_provider.dart";

class Repository {
  final AuthProvider authProvider = AuthProvider();
  Future<String> login(String email, String password) => authProvider.login(email: email, password: password);
}