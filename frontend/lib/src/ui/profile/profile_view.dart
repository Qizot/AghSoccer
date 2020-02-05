import 'package:agh_soccer/src/models/match.dart';
import 'package:agh_soccer/src/models/user.dart';
import 'package:agh_soccer/src/ui/match/match_card.dart';
import 'package:agh_soccer/src/ui/match/match_details/match_details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agh_soccer/src/bloc/match_bloc/bloc.dart';

class ProfileView extends StatefulWidget {
  final User user;

  ProfileView({this.user});

  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  List<Match> matches = [];

  @override
  void initState() {
    BlocProvider.of<MatchBloc>(context).add(MatchFetchListByIds(ids: widget.user.matchesPlayed));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage(
                'assets/billy.jpeg',
              ),
            ),
          ),
          height: 300.0,
        ),
        SizedBox(
          width: double.infinity,
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _userInfo(),
            ),
            decoration: BoxDecoration(
              color: Colors.black26
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: Center(
            child: Text("Twoje mecze", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          )
        ),
        _matches(context)
      ],
    );
  }

  Widget _userInfo() {
    return Column(
      children: <Widget>[
        Text(
            widget.user.nickname,
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
          widget.user.email,
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

  Widget _matches(context) {
    return BlocListener<MatchBloc, MatchState>(
      listener: (context, state) {
        if (state is MatchFetchedListByIds) {
          setState(() {
            matches = state.matches;
          });
        }
      },
      child: SizedBox(
          height: 400,
          child: ListView.builder(
          itemCount: matches.length,
          itemBuilder: (context, idx) {
            return GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => MatchDetails(match: matches[idx]))),
                child: MatchCard(match: matches[idx])
            );
          }
        ),
      ),
    );
  }
}