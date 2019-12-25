import 'package:agh_soccer/src/bloc/profile_bloc/profile_bloc.dart';
import 'package:agh_soccer/src/bloc/profile_bloc/profile_event.dart';
import 'package:agh_soccer/src/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileView extends StatelessWidget {
  final User user;

  ProfileView({Key key, this.user}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: userInfo(),
            ),
            decoration: BoxDecoration(
              color: Colors.black26
            ),
          ),
        ),
        deleteAccountButton(context),
      ],
    );
  }

  Widget userInfo() {
    return Column(
      children: <Widget>[
        Text(
            user.nickname,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 20.0,
        ),
        Text(
          user.email,
          style: TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7)
          ),
          textAlign: TextAlign.center,

        )
      ],
    );
  }

  Widget deleteAccountButton(context) {
    return RaisedButton(
        onPressed: () => showAlertDialog(context),
        child: Text('Usuń konto'),
        color: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0))
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Anuluj"),
      onPressed:  () => Navigator.of(context).pop(),
    );
    Widget continueButton = FlatButton(
      child: Text("Usuń"),
      color: Colors.red,
      onPressed:  () {
        BlocProvider.of<ProfileBloc>(context).add(ProfileDelete());
        Navigator.of(context).pushNamedAndRemoveUntil("/login", ModalRoute.withName("/home"));
      }
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Czy na pewno chcesz usunąć konto?"),
      content: Text("Operacji tej nie da się anulować przez co bezpowrotnie stracisz swoje dotychczasowe konto."),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}