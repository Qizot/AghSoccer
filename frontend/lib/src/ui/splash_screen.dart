import 'package:agh_soccer/src/bloc/auth_bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationAuthenticated) {
          Navigator.of(context).pushReplacementNamed("/home");
        }
        if (state is AuthenticationUnauthenticated) {
          if (state.message != null) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            Navigator.of(context).pushReplacementNamed("/login");
          }
        }
      },
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationUninitialized) {
            return Center(child: Text("AGH Soccer"));
          }
          if (state is AuthenticationServerNotResponding) {
            return RefreshIndicator(
              onRefresh: () async {
                  BlocProvider.of<AuthenticationBloc>(context).add(AppStarted());
              },
              child: ListView(children: <Widget>[
                SizedBox(height: 200),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                        "Nie udało nam się połączyć z serwerem.\n\n Spróbuj ponownie za jakiś czas...",
                        style: TextStyle(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center)
                  ],
                ),
              ]),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    ));
  }
}
