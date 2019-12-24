import 'package:agh_soccer/src/bloc/login_bloc/login_bloc.dart';
import 'package:agh_soccer/src/bloc/auth_bloc/auth_bloc.dart';
import 'package:agh_soccer/src/bloc/register_bloc/register_bloc.dart';
import 'package:agh_soccer/src/resources/user_repository.dart';
import 'package:agh_soccer/src/ui/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';


class LoginPage extends StatefulWidget {

  final UserRepository userRepository;

  LoginPage({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showLoginPage = true;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      body: MultiBlocProvider(
        providers: [
          BlocProvider<LoginBloc>(
            create: (BuildContext context) => LoginBloc(
                authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
                userRepository: widget.userRepository
            ),
          ),
          BlocProvider<RegisterBloc>(
            create: (BuildContext context) => RegisterBloc(
              authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
              userRepository: widget.userRepository,
            ),
          ),
        ],
        child: loginForm(),
      ),
    );
  }

  Widget loginForm() {
    return ListView(
        children: <Widget>[
          SizedBox(height: 20.0),
          Image(image: AssetImage("assets/soccer_pitch.png")),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: LoginForm(),
          ),
        ]
    );
  }

  Widget registerForm() {
    ListView(
        children: <Widget>[
          SizedBox(height: 20.0),
          Image(image: AssetImage("assets/soccer_pitch.png")),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text("This should be a register form"),
          ),
        ]
    );
  }
}