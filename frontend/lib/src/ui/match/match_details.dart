


import 'package:agh_soccer/src/bloc/match_details_bloc/match_details_bloc.dart';
import 'package:agh_soccer/src/bloc/match_details_bloc/match_details_event.dart';
import 'package:agh_soccer/src/bloc/match_details_bloc/match_details_state.dart';
import 'package:agh_soccer/src/models/match.dart';
import 'package:agh_soccer/src/resources/match_repository.dart';
import 'package:agh_soccer/src/resources/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class MatchDetails extends StatefulWidget {
  final String matchId;

  MatchDetails({this.matchId});

  State<MatchDetails> createState() => _MatchDetailsState();
}

class _MatchDetailsState extends State<MatchDetails> {
  Match match;

  final _headerTextStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600
  );

  final _normalText = TextStyle(
    fontSize: 15
  );

  final timeFormat = DateFormat.Hm();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MatchDetailsBloc>(
      create: (context) => MatchDetailsBloc(
          userRepository: UserRepository(),
          matchRepository: MatchRepository())
        ..add(MatchDetailsInitialize(matchId: widget.matchId)),
      child: Scaffold(
        appBar: AppBar(),
        body: BlocListener<MatchDetailsBloc, MatchDetailsState>(
            listener: (context, state) {
              if (state is MatchDetailsRefreshed) {
                setState(() {
                  match = state.match;
                });
                if (state.message != null) {
                  Scaffold.of(context).hideCurrentSnackBar();
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${state.message}'),
                      backgroundColor: Colors.green,
                    ),
                  );

                }
              }

              if (state is MatchDetailsFailure) {
                Scaffold.of(context).hideCurrentSnackBar();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: BlocBuilder<MatchDetailsBloc, MatchDetailsState>(
              builder: (context, state) {
                print("BUILDER: " + state.toString());
                if (state is MatchDetailsRefreshLoading) {
                  return Container(
                    color: Colors.black,
                    child: Center(
                      child: CircularProgressIndicator()
                    ),
                  );
                }
                return RefreshIndicator(
                  child: _mainLayout(context),
                  onRefresh: () async  {
                    BlocProvider.of<MatchDetailsBloc>(context).add(MatchDetailsRefresh());
                    return null;
                  }
                );
              }
            ),
          ),
        ),
    );
  }

  Widget _mainLayout(context) {
    return Container(
      color: Colors.black,
      child: ListView(
        children: <Widget>[
          _gradientImage(context),
          SizedBox(height: 30),
          _when(),
          _description(),
          _players(),
        ],
      ),
    );
  }


  Widget _gradientImage(context) {
    return Stack(children: <Widget>[
      Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage(
              'assets/match_details.png',
            ),
          ),
        ),
        height: 200.0,
      ),
      Container(
        height: 200.0,
        decoration: BoxDecoration(
            color: Colors.white,
            gradient: LinearGradient(
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
                colors: [
                  Colors.grey.withOpacity(0.0),
                  Colors.black,
                ],
                stops: [
                  0.0,
                  1.0
                ])),
      ),
      Positioned(
        bottom: 20,
        left: 20,
        child:  Row(
          children: <Widget>[
            Icon(
                match.isPrivate
                    ? Icons.lock_outline
                    : Icons.lock_open,
                color: match.isPrivate ? Colors.amber : Colors.grey),
            SizedBox(
              width: 5.0,
            ),
            Text(match.name, style: _headerTextStyle),
            SizedBox(
              width: 10
            ),
            StreamBuilder(
              stream: BlocProvider.of<MatchDetailsBloc>(context).isUserEnrolled$,
              builder: (context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data) {
                    return _leaveButton(context);
                  } else {
                    return _joinButton(context);
                  }
                }
                return Container();
              }
            )
          ],
        ),
      )
    ]);
  }

  Widget _description() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Opis: ", style: _headerTextStyle, textAlign: TextAlign.left),
          SizedBox(height: 10),
          Text(match.description, style: _normalText, textAlign: TextAlign.justify)
        ],
      ),
    );
  }

  Widget _when() {
    initializeDateFormatting();

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: <Widget>[
          Text("Kiedy: ", style: _headerTextStyle),
          SizedBox(width: 10),
          Icon(Icons.date_range),
          Text(DateFormat.yMMMMd("pl_PL").format(match.startTime), style: _normalText),
          SizedBox(width: 10),
          Text(timeFormat.format(match.startTime) + " - " + timeFormat.format(match.endTime), style: _normalText)
        ],
      )
    );
  }

  Widget _players() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: <Widget>[
          Text("Uczestnicy: ", style: _headerTextStyle),
          ListView.builder(
            key: Key("players"),
            shrinkWrap: true,
            itemCount: match.players.length,
            itemBuilder: (context, index) =>
              ListTile(
                leading: Icon(Icons.account_circle, size: 50),
                title: Text(match.players[index]),
                subtitle: Text("# ${index + 1}"),
              ),
          )
        ],
      )
    );
  }

  Widget _joinButton(context) {
    return FlatButton.icon(
      icon: Icon(Icons.add),
      label: Text("Dołącz"),
      color: Colors.green,
      onPressed: () async {
        if (match.isPrivate) {
          final password = await _askForPassword(context);
          if (password != null) {
            BlocProvider.of<MatchDetailsBloc>(context).add(MatchDetailsEnroll(password: password));
          }
        } else {
          BlocProvider.of<MatchDetailsBloc>(context).add(MatchDetailsEnroll());
        }
      },
    );
  }

  Widget _leaveButton(context) {
    return FlatButton.icon(
      icon: Icon(Icons.exit_to_app),
      label: Text("Opuść"),
      color: Colors.red,
      onPressed: () {
        BlocProvider.of<MatchDetailsBloc>(context).add(MatchDetailsDeroll());
      },
    );
  }

  Future<String> _askForPassword(BuildContext context) async {
    String password = '';
    return showDialog<String>(
      context: context,
      barrierDismissible: true, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Wprowadź hasło'),
          content: Row(
            children: <Widget>[
              Expanded(
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                        labelText: 'Hasło: '),
                    obscureText: true,
                    onChanged: (value) {
                      password = value;
                    },
                  ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(password);
              },
            ),
          ],
        );
      },
    );
  }

}