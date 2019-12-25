import 'package:agh_soccer/src/bloc/auth_bloc/auth_bloc.dart';
import 'package:agh_soccer/src/bloc/auth_bloc/auth_state.dart';
import 'package:agh_soccer/src/resources/user_repository.dart';
import 'package:agh_soccer/src/ui/home/home_page.dart';
import 'package:agh_soccer/src/ui/login/login_page.dart';
import 'package:agh_soccer/src/ui/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

//  @override
//  Widget build(BuildContext context) {
//
//    return MaterialApp(
//      theme: ThemeData(
//          brightness: Brightness.dark,
//          primarySwatch: Colors.orange,
//          accentColor: Colors.blueGrey
//      ),
//      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
//        builder: (context, state) {
//          if (state is AuthenticationUninitialized) {
//            return SplashPage();
//          }
//          if (state is AuthenticationAuthenticated) {
//            return HomePage();
//          }
//          if (state is AuthenticationUnauthenticated) {
//            print("this should render login page");
//            return LoginPage(userRepository: userRepository);
//          }
//          if (state is AuthenticationLoading) {
//            return Center(
//              child: CircularProgressIndicator(),
//            );
//          }
//          return null;
//        },
//      ),
//    );
//  }
}