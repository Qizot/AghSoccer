


import 'package:agh_soccer/src/bloc/match_bloc/match_event.dart';
import 'package:agh_soccer/src/bloc/match_bloc/match_state.dart';
import 'package:agh_soccer/src/models/match.dart';
import 'package:agh_soccer/src/ui/match/create_edit_match_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agh_soccer/src/bloc/match_bloc/match_bloc.dart';

class MatchDetailsModal extends StatelessWidget {
  Match match;

  MatchDetailsModal({this.match});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MatchBloc, MatchState>(
      listener: (context, state) {
        if (state is MatchDeleted) {
          Navigator.of(context).popUntil(ModalRoute.withName("/matches"));
        }
      },
      child: Column(
        children: <Widget>[
          Container(
            height: 50,
            child: Center(child: Text("Zarządzaj meczem", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)))
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.create, size: 30),
            title: Text("Edytuj"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (BuildContext context) {
                  return _editMatchModal();
                },
                fullscreenDialog: true,
              ));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.delete_forever, size: 30, color: Colors.red),
            title: Text("Usuń", style: TextStyle(color: Colors.red)),
            onTap: () => _showDeleteMatchDialog(context),
          )
        ],
      ),
    );
  }

  void _showDeleteMatchDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Anuluj"),
      onPressed:  () => Navigator.of(context).pop(),
    );
    Widget continueButton = FlatButton(
        child: Text("Usuń"),
        color: Colors.red,
        onPressed:  () {
          BlocProvider.of<MatchBloc>(context).add(MatchDelete(matchId: match.sId));
          Navigator.of(context).pop();
        }
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Czy na pewno chcesz usunąć mecz?"),
      content: Text("Operacja ta jest trwała i nie da się jej cofnąć. Zastanów się dwa razy."),
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

  Widget _editMatchModal() {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text("Edycja meczu")
        ),
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            // Box decoration takes a gradient
            gradient: LinearGradient(
              // Where the linear gradient begins and ends
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              // Add one stop for each color. Stops should increase from 0 to 1
              stops: [0.1, 0.2, 0.5, 0.9],
              colors: [
                // Colors are easy thanks to Flutter's Colors class.
                Colors.black,
                Colors.black87,
                Colors.black54,
                Colors.black38,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
            child: SingleChildScrollView(child: CreateEditMatchModal(match: match, mode: CreateEditMatchMode.edit)),
          ),
        )
    );
  }

}