
import 'package:agh_soccer/src/bloc/register_bloc/bloc.dart';
import 'package:agh_soccer/src/utilities/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class RegisterForm extends StatefulWidget {
  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final Validators validator = new Validators();


  @override
  Widget build(BuildContext context) {
    _onRegisterButtonPressed() {
      if (_formKey.currentState.validate()) {
        BlocProvider.of<RegisterBloc>(context).add(
          RegisterButtonPressed(
            email: _emailController.text.trim(),
            nickname: _nicknameController.text,
            password: _passwordController.text,
          ),
        );
      }
    }

    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is RegisterFailure) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (state is RegisterSuccess) {
          Navigator.of(context).pop();
        }
      },
      child: BlocBuilder<RegisterBloc, RegisterState>(
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Nazwa użytkownika'),
                  controller: _nicknameController,
                  validator: validator.validateNickname,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  controller: _emailController,
                  validator: (value) => validator.validateEmail(value.trim()),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Hasło'),
                  controller: _passwordController,
                  obscureText: true,
                  validator: validator.validatePassword
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Powtórz hasło'),
                  obscureText: true,
                  validator: (String value) {
                    if (value != _passwordController.text) {
                      return "Hasła nie są takie same";
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 15.0,
                ),
                SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                      onPressed:
                      state is! RegisterLoading ? _onRegisterButtonPressed : null,
                      child: Text('Zarejestruj konto'),
                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0))
                  ),
                ),
                Container(
                  child: state is RegisterLoading
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