import 'package:agh_soccer/src/bloc/login_bloc/bloc.dart';
import 'package:agh_soccer/src/ui/register/register_page.dart';
import 'package:agh_soccer/src/utilities/fade_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  static GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _onLoginButtonPressed() {
      BlocProvider.of<LoginBloc>(context).add(
        LoginButtonPressed(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }

    _onRegisterButtonPressed() {
      Navigator.push(context, FadeRoute(page: RegisterPage()));
    }



    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  controller: _emailController,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Hasło'),
                  controller: _passwordController,
                  obscureText: true,
                ),
                SizedBox(
                  height: 15.0,
                ),
                SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed:
                    state is! LoginLoading ? _onLoginButtonPressed : null,
                    child: Text('Zaloguj się'),
                    shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0))
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      _onRegisterButtonPressed();
                    },
                    child: Text("Zarejestruj się"),
                    shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0))
                  ),
                ),
                Container(
                  child: state is LoginLoading
                      ? CircularProgressIndicator()
                      : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}