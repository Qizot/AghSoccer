import 'dart:async';

import 'package:agh_soccer/src/bloc/match_bloc/bloc.dart';
import 'package:agh_soccer/src/bloc/match_details_bloc/bloc.dart';
import 'package:agh_soccer/src/models/match.dart';
import 'package:agh_soccer/src/resources/match_repository.dart';
import 'package:agh_soccer/src/resources/user_repository.dart';
import 'package:agh_soccer/src/ui/match/match_details/chat/chat_view.dart';
import 'package:agh_soccer/src/ui/match/match_details/match_details_modal.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class MatchDetails extends StatefulWidget {
  final String matchId;
  // TODO: hide chat button if user is not a part of the lobby
  Match match;

  MatchDetails({@required Match match})
      : match = match,
        matchId = match.sId;

  State<MatchDetails> createState() => _MatchDetailsState();
}

class _MatchDetailsState extends State<MatchDetails> {
  final _headerTextStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.w600);

  final _normalText = TextStyle(fontSize: 15);

  final timeFormat = DateFormat.Hm();

  void _showMatchActions(context) {
    print(widget.match.toString());
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
              height: 210, child: MatchDetailsModal(match: widget.match));
        },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        )));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MatchDetailsBloc>(
      create: (context) => MatchDetailsBloc(
          userRepository: UserRepository(), matchRepository: MatchRepository())
        ..add(MatchDetailsInitialize(matchId: widget.matchId)),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          actions: <Widget>[
            Builder(
              builder: (context) => _actionButtons(context),
            )
          ],
        ),
        floatingActionButton: Builder(builder: (context) => _floatingButton(context)),
        body: BlocListener<MatchBloc, MatchState>(
          listener: (context, state) {
            if (state is MatchUpdated && state.matchId == widget.matchId) {
              BlocProvider.of<MatchDetailsBloc>(context)
                  .add(MatchDetailsRefresh());
            }
          },
          child: _detailsListener(child: _detailsBuilder()),
        ),
      ),
    );
  }

  Widget _detailsListener({Widget child}) {
    return BlocListener<MatchDetailsBloc, MatchDetailsState>(
        listener: (context, state) {
          if (state is MatchDetailsRefreshed) {
            setState(() {
              widget.match = state.match;
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
        child: child);
  }

  Widget _detailsBuilder() {
    return BlocBuilder<MatchDetailsBloc, MatchDetailsState>(
        builder: (context, state) {
      if (state is MatchDetailsRefreshLoading) {
        return Container(
          color: Colors.black,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return RefreshIndicator(
          child: _mainLayout(context),
          onRefresh: () async {
            BlocProvider.of<MatchDetailsBloc>(context)
                .add(MatchDetailsRefresh());
            return null;
          });
    });
  }

  Widget _actionButtons(context) {
    return StreamBuilder(
        stream: BlocProvider.of<MatchDetailsBloc>(context).isUserOwner$,
        builder: (context, AsyncSnapshot<bool> data) {
          if (data.hasData && data.data) {
            return IconButton(
              icon: Icon(Icons.dehaze),
              onPressed: () => _showMatchActions(context),
            );
          }
          return Container();
        });
  }

  Widget _chatButton(context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) {
                return ChatPage(matchId: widget.matchId, lobbyName: widget.match.name);
              },
              fullscreenDialog: true,
            ));
      },
      child: Icon(Icons.message, color: Colors.white),
      backgroundColor: Colors.blue,
    );
  }

  Widget _floatingButton(context) {
    return StreamBuilder(
        stream: BlocProvider.of<MatchDetailsBloc>(context).isUserEnrolled$,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data) {
              return _chatButton(context);
            } else {
              return Container();
            }
          }
          return Container();
        });
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
        child: Row(
          children: <Widget>[
            Icon(widget.match.isPrivate ? Icons.lock_outline : Icons.lock_open,
                color: widget.match.isPrivate ? Colors.amber : Colors.grey),
            SizedBox(
              width: 5.0,
            ),
            Text(widget.match.name, style: _headerTextStyle),
            SizedBox(width: 10),
            StreamBuilder(
                stream:
                    BlocProvider.of<MatchDetailsBloc>(context).isUserEnrolled$,
                builder: (context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data) {
                      return _leaveButton(context);
                    } else {
                      return _joinButton(context);
                    }
                  }
                  return Container();
                })
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
          Text(widget.match.description,
              style: _normalText, textAlign: TextAlign.justify)
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
            Text(DateFormat.yMMMMd("pl_PL").format(widget.match.startTime),
                style: _normalText),
            SizedBox(width: 10),
            Text(
                timeFormat.format(widget.match.startTime) +
                    " - " +
                    timeFormat.format(widget.match.endTime),
                style: _normalText)
          ],
        ));
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
              itemCount: widget.match.players.length,
              itemBuilder: (context, index) => ListTile(
                leading: Icon(Icons.account_circle, size: 50),
                title: Text(widget.match.players[index]),
                subtitle: Text("# ${index + 1}"),
              ),
            )
          ],
        ));
  }

  Widget _joinButton(context) {
    return FlatButton.icon(
      icon: Icon(Icons.add),
      label: Text("Dołącz"),
      color: Colors.green,
      onPressed: () async {
        if (widget.match.isPrivate) {
          final password = await _askForPassword(context);
          if (password != null) {
            BlocProvider.of<MatchDetailsBloc>(context)
                .add(MatchDetailsEnroll(password: password));
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
      barrierDismissible:
          true, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Wprowadź hasło'),
          content: Row(
            children: <Widget>[
              Expanded(
                  child: TextField(
                autofocus: true,
                decoration: InputDecoration(labelText: 'Hasło: '),
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
