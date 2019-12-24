import 'package:agh_soccer/src/bloc/auth_bloc/auth_bloc.dart';
import 'package:agh_soccer/src/bloc/auth_bloc/auth_event.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Witaj w AGH Soccer!'),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            _createHeader(),
            _createDrawerItem(
              icon: Icons.account_circle,
              text: "Twój profil",
              onTap: () => print("your profile clicked")
            ),
            _createDrawerItem(
              icon: Icons.av_timer,
              text: "Rezerwacje boiska",
              onTap: () => print("pitch reservations clicked")
            ),
            _createDrawerItem(
              icon: Icons.exit_to_app,
              text: "Wyloguj się",
              onTap: () => BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut()),
            ),
            Divider(),
          ],
        ),
      ),
      body: _welcome(),
    );
  }

  Widget _createHeader() {
    return DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage('assets/pitch_drawer.png'))),
        child: Stack(children: <Widget>[
          Positioned(
              bottom: 12.0,
              left: 16.0,
              child: Text("AGH Soccer",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500))),
        ]));
  }

  Widget _createDrawerItem(
      {IconData icon, String text, GestureTapCallback onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(text),
          )
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _welcome() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Witaj w AGH Soccer!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w600
            )
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Text(
              "Dzięki tej aplikacji możesz śledzić rezerwacje i organizować osoby do wspólnej gry na miasteczkowym boisku do piłki nożnej!",
              textAlign: TextAlign.center,
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Text(
              "Wyszukuj mecze, zbieraj osoby oraz baw się świetnie przy najpopularniejszym sporcie na świecie!",
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }


}
