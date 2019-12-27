import 'package:agh_soccer/src/bloc/match_bloc/match_bloc.dart';
import 'package:agh_soccer/src/bloc/match_bloc/match_event.dart';
import 'package:agh_soccer/src/bloc/match_bloc/match_state.dart';
import 'package:agh_soccer/src/bloc/match_details_bloc/match_details_state.dart';
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
      timeTo: midnight.add(Duration(days: 3))
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
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${state.message}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: BlocBuilder<MatchBloc, MatchState>(
              builder: (context, state) {
                if (state is MatchInitial) {
                  BlocProvider.of<MatchBloc>(context).add(MatchFetchByFilter(filter: defaultFilter()));
                }
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
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(child: CreateEditMatchModal()),
      )
    );
  }
}
