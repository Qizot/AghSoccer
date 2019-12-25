import 'package:agh_soccer/src/bloc/auth_bloc/auth_state.dart';
import 'package:agh_soccer/src/bloc/login_bloc/login_bloc.dart';
import 'package:agh_soccer/src/bloc/auth_bloc/auth_bloc.dart';
import 'package:agh_soccer/src/resources/user_repository.dart';
import 'package:agh_soccer/src/ui/login/login_form.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';


class LoginPage extends StatefulWidget {

  final UserRepository userRepository = new UserRepository();

  LoginPage({Key key}): super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showLoginPage = true;


  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: BlocProvider<LoginBloc>(
        create: (BuildContext context) => LoginBloc(
            authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
            userRepository: widget.userRepository
        ),
        child: BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            if (state is AuthenticationAuthenticated) {
              Navigator.of(context).pushReplacementNamed("/home");
            }
          },
          child: loginForm()
        ),
      ),
    );
  }

  Widget loginForm() {
    return SingleChildScrollView(
      child: Column(
          children: <Widget>[
            SizedBox(height: 20.0),
            Image(image: AssetImage("assets/soccer_pitch.png")),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: LoginForm(),
            ),
          ]
      ),
    );
  }

}