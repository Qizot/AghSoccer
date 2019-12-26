import 'package:agh_soccer/src/resources/user_repository.dart';
import 'package:agh_soccer/src/ui/home/home_page.dart';
import 'package:agh_soccer/src/ui/login/login_page.dart';
import 'package:agh_soccer/src/ui/splash_screen.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  final UserRepository userRepository;

  App({Key key, @required this.userRepository}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.orange,
          accentColor: Colors.blueGrey
      ),
      routes: {
        "/": (context) => SplashPage(),
        "/login": (context) => LoginPage(),
        "/home": (context) => HomePage(),
      },
      initialRoute: "/",
    );
  }
}