import 'package:agh_soccer/src/bloc/match_bloc/match_bloc.dart';
import 'package:agh_soccer/src/bloc/match_bloc/match_state.dart';
import 'package:agh_soccer/src/resources/match_repository.dart';
import 'package:agh_soccer/src/ui/match/match_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MatchesPage extends StatefulWidget {
  final MatchBloc bloc = MatchBloc(matchRepository: MatchRepository());

  State<MatchesPage> createState() => _MatchesPageState();


}

class _MatchesPageState extends State<MatchesPage>  {

  void _showFilter(context, MatchBloc bloc) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SearchMatches(bloc: bloc);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.0),
          )
        )
    );
  }

  @override
  void dispose() async {
    await widget.bloc.close();
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
            body: Container(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Add your onPressed code here!
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.green,
          ),
        )
    );
  }

}
