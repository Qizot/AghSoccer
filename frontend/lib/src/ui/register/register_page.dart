import 'package:agh_soccer/src/bloc/auth_bloc/auth_bloc.dart';
import 'package:agh_soccer/src/bloc/register_bloc/register_bloc.dart';
import 'package:agh_soccer/src/resources/user_repository.dart';
import 'package:agh_soccer/src/ui/register/register_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class RegisterPage extends StatefulWidget {

  final UserRepository userRepository = new UserRepository();

  RegisterPage({Key key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool showRegisterPage = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Rejestracja"),
      ),
      body: BlocProvider<RegisterBloc>(
        create: (BuildContext context) => RegisterBloc(
            authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
            userRepository: widget.userRepository
        ),
        child: registerForm(),
      ),
    );
  }


  Widget registerForm() {
    return ListView(
        children: <Widget>[
          SizedBox(height: 20.0),
          Image(
            height: 200,
            image: AssetImage("assets/uncle_sam.png")
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: RegisterForm(),
          ),
        ]
    );
  }
}