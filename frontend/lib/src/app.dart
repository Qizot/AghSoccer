import 'package:agh_soccer/src/resources/user_repository.dart';
import 'package:agh_soccer/src/ui/home/home_page.dart';
import 'package:agh_soccer/src/ui/login/login_page.dart';
import 'package:agh_soccer/src/ui/match/matches_page.dart';
import 'package:agh_soccer/src/ui/profile/profile_page.dart';
import 'package:agh_soccer/src/ui/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class App extends StatelessWidget {
  final UserRepository userRepository;

  App({Key key, @required this.userRepository}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      supportedLocales: [
        const Locale('pl', 'PL')
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.orange,
          accentColor: Colors.blueGrey
      ),
      routes: {
        "/": (context) => SplashPage(),
        "/login": (context) => LoginPage(),
        "/home": (context) => HomePage(),
        "/profile": (context) => ProfilePage(),
        "/matches": (context) => MatchesPage(),
      },
      initialRoute: "/",
    );
  }
}