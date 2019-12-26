import 'package:agh_soccer/src/bloc/match_bloc/match_bloc.dart';
import 'package:agh_soccer/src/bloc/match_bloc/match_event.dart';
import 'package:agh_soccer/src/bloc/match_bloc/match_state.dart';
import 'package:agh_soccer/src/models/match.dart';
import 'package:agh_soccer/src/models/match_filter.dart';
import 'package:agh_soccer/src/resources/match_repository.dart';
import 'package:agh_soccer/src/ui/match/match_card.dart';
import 'package:agh_soccer/src/ui/match/match_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MatchesPage extends StatefulWidget {
  final MatchBloc bloc = MatchBloc(matchRepository: MatchRepository());

  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {

  List<Match> _matches = [];

  void _showFilter(context, MatchBloc bloc) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SearchMatches(bloc: bloc);
        },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        )));
  }

  @override
  void dispose() {
    super.dispose();
    widget.bloc.close();
  }

  MatchFilter defaultFilter() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day, 0,0,0);
    return MatchFilter(
      showPrivate: true,
      timeFrom: midnight,
      timeTo: midnight.add(Duration(days: 3))
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MatchBloc>.value(
        value: widget.bloc,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("Rezerwacje"),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _showFilter(context, widget.bloc),
              )
            ],
          ),
          body: BlocListener<MatchBloc, MatchState>(
            listener: (context, state) {
              print("listener: " + state.toString());
              if (state is MatchFetchedByFilter) {
                setState(() {
                  _matches = state.matches;
                });
              }
              if (state is MatchInitial) {
                BlocProvider.of<MatchBloc>(context).add(MatchFetchByFilter(filter: defaultFilter()));
              }
            },
            child: BlocBuilder<MatchBloc, MatchState>(
              builder: (context, state) {
                if (state is MatchInitial) {
                  BlocProvider.of<MatchBloc>(context).add(MatchFetchByFilter(filter: defaultFilter()));
                }
                return RefreshIndicator(
                  child: ListView.builder(
                      itemCount: _matches.length,
                      itemBuilder: (context, index) {
                        return MatchCard(match: _matches[index]);
                      }
                  ),
                  onRefresh: () async  {
                    BlocProvider.of<MatchBloc>(context).add(MatchFetchByFilter(filter: defaultFilter()));
                    return null;
                  },
                );
              },

            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Add your onPressed code here!
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.green,
          ),
        ));
  }
}