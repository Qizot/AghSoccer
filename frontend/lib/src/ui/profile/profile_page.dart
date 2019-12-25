import 'package:agh_soccer/src/bloc/profile_bloc/profile_bloc.dart';
import 'package:agh_soccer/src/bloc/profile_bloc/profile_event.dart';
import 'package:agh_soccer/src/bloc/profile_bloc/profile_state.dart';
import 'package:agh_soccer/src/models/user.dart';
import 'package:agh_soccer/src/resources/user_repository.dart';
import 'package:agh_soccer/src/ui/profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:agh_soccer/src/bloc/auth_bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ProfilePage extends StatefulWidget {

  final UserRepository userRepository = new UserRepository();

  ProfilePage({Key key}) :  super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Profil"),
      ),
      body: BlocProvider<ProfileBloc>(
        create: (BuildContext context) => ProfileBloc(
            authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
            userRepository: widget.userRepository
        )..add(ProfileFetch()),
        child:  BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileFailure) {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: page(),
        ),
      ),
    );
  }

  Widget page() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return CircularProgressIndicator();
        }
        if (state is ProfileFetched) {
          return StreamBuilder(
            stream: BlocProvider.of<ProfileBloc>(context).user,
            builder: (context, AsyncSnapshot<User>snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              return SafeArea(child: ProfileView(user: snapshot.data));
            },
          );
        }
        if (state is ProfileFailure) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return Container();
      },
    );
  }



}