import 'package:agh_soccer/src/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';

class HomeBloc {
  logoutUser() {
    authBloc.closeSession();
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  HomeBloc bloc = HomeBloc();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: bloc.logoutUser,
          child: Text(
            "Logout",
            style: TextStyle(color: Colors.white),
          ),
          color: Colors.blue,
        ),
      ),
    );
  }
}
