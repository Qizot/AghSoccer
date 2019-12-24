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



//  @override
//  Widget build(BuildContext context) {
//    return BlocListener<AuthenticationBloc, AuthenticationState>(
//      listener: (_, state) {
//        print(state);
//        if (state is AuthenticationLoading) {
//          Navigator.pushNamed(context, "/");
//        }
//        if (state is AuthenticationAuthenticated) {
//          Navigator.pushNamed(context, "/home");
//        }
//        if (state is AuthenticationUnauthenticated) {
//          Navigator.pushNamed(context, "/login");
//        }
//      },
//      child: MaterialApp(
//        theme: ThemeData(
//          brightness: Brightness.dark,
//          primarySwatch: Colors.orange,
//          accentColor: Colors.blueGrey
//        ),
//        routes: {
//          "/": (context) => SplashPage(),
//          "/home": (context) => HomePage(),
//          "/login": (context) => LoginPage(userRepository: userRepository),
//          "/register": (context) => RegisterPage(userRepository: userRepository),
//        },
//        initialRoute: "/",
//
//      )
//    );
//  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.orange,
          accentColor: Colors.blueGrey
      ),
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationUninitialized) {
            return SplashPage();
          }
          if (state is AuthenticationAuthenticated) {
            return HomePage();
          }
          if (state is AuthenticationUnauthenticated) {
            return LoginPage(userRepository: userRepository);
          }
          if (state is AuthenticationLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return null;
        },
      ),
    );
  }
}