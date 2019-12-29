import 'package:agh_soccer/src/bloc/match_bloc/match_bloc.dart';
import 'package:agh_soccer/src/bloc/match_bloc/match_event.dart';
import 'package:agh_soccer/src/bloc/match_bloc/match_state.dart';
import 'package:agh_soccer/src/models/match.dart';
import 'package:agh_soccer/src/models/match_filter.dart';
import 'package:agh_soccer/src/ui/match/create_edit_match_modal.dart';
import 'package:agh_soccer/src/ui/match/match_card.dart';
import 'package:agh_soccer/src/ui/match/match_details.dart';
import 'package:agh_soccer/src/ui/match/match_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MatchesPage extends StatefulWidget {

  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {

  List<Match> _matches = [];

  @override
  void initState() {
    BlocProvider.of<MatchBloc>(context).add(MatchFetchByFilter(filter: defaultFilter()));
    super.initState();
  }

  void _showFilter() {
    MatchBloc bloc = BlocProvider.of<MatchBloc>(context);
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BlocBuilder<MatchBloc, MatchState>(
            builder: (context, _) => SearchMatches(bloc: bloc)
          );
        },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        )));
  }


  MatchFilter defaultFilter() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day, 0,0,0);
    return MatchFilter(
      showPrivate: true,
      timeFrom: midnight,
      timeTo: midnight.add(Duration(days: 14))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("Rezerwacje"),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _showFilter(),
              )
            ],
          ),
          body: BlocListener<MatchBloc, MatchState>(
            listener: (context, state) {
              if (state is MatchFetchedByFilter) {
                setState(() {
                  _matches = state.matches;
                });
              }
              if (state is MatchInitial) {
                BlocProvider.of<MatchBloc>(context).add(MatchFetchByFilter(filter: defaultFilter()));
              }
              if (state is MatchCreated) {
                BlocProvider.of<MatchBloc>(context).add(MatchFetchByFilter(filter: defaultFilter()));
                Scaffold.of(context).hideCurrentSnackBar();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${state.message}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              if (state is MatchDeleted) {
                BlocProvider.of<MatchBloc>(context).add(MatchFetchByFilter(filter: defaultFilter()));

                Scaffold.of(context).hideCurrentSnackBar();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Pomyślnie usunięto mecz"),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: BlocBuilder<MatchBloc, MatchState>(
              builder: (context, state) {
                if (state is MatchLoading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return RefreshIndicator(
                  child: _matchesList(),
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
              Navigator.push(context, MaterialPageRoute(
                  builder: (BuildContext context) {
                    return _createMatchModal();
                  },
                  fullscreenDialog: true,
              ));
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.green,
          ),
    );
  }


  Widget _matchesList() {
    return ListView.builder(
        itemCount: _matches.length,
        itemBuilder: (context, index) {
          return GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => MatchDetails(match: _matches[index]))),
              child: MatchCard(match: _matches[index])
          );
        }
    );
  }

  Widget _createMatchModal() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Tworzenie meczu")
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
          child: SingleChildScrollView(child: CreateEditMatchModal(mode: CreateEditMatchMode.create)),
        ),
      )
    );
  }
}
