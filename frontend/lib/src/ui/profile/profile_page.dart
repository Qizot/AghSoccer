import 'package:agh_soccer/src/bloc/profile_bloc/profile_bloc.dart';
import 'package:agh_soccer/src/bloc/profile_bloc/profile_event.dart';
import 'package:agh_soccer/src/bloc/profile_bloc/profile_state.dart';
import 'package:agh_soccer/src/models/user.dart';
import 'package:agh_soccer/src/resources/user_repository.dart';
import 'package:agh_soccer/src/ui/profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:agh_soccer/src/bloc/auth_bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ProfileAction { update, delete }

class ProfilePage extends StatefulWidget {
  final UserRepository userRepository = new UserRepository();

  ProfilePage({Key key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (BuildContext context) => ProfileBloc(
          authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
          userRepository: widget.userRepository)
        ..add(ProfileFetch()),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Profil"),
          actions: <Widget>[
            Builder(
              builder: (context) => actionButton(context),
            )
          ],
        ),
        body: BlocListener<ProfileBloc, ProfileState>(
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
            builder: (context, AsyncSnapshot<User> snapshot) {
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

  Widget actionButton(context) {
    return PopupMenuButton<ProfileAction>(
      onSelected: (ProfileAction action) {
        switch (action) {
          case ProfileAction.update:
            break;
          case ProfileAction.delete:
            {
              showAlertDialog(context);
              break;
            }
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<ProfileAction>>[
//        const PopupMenuItem<ProfileAction>(
//          value: ProfileAction.update,
//          child: ListTile(
//            leading: Icon(Icons.create),
//            title: Text("Edytuj profil"),
//          ),
//        ),
        const PopupMenuItem<ProfileAction>(
          value: ProfileAction.delete,
          child: ListTile(
            leading: Icon(Icons.delete_forever, color: Colors.red),
            title: Text("Usuń konto", style: TextStyle(color: Colors.red)),
          ),
        ),
      ],
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Anuluj"),
      onPressed: () => Navigator.of(context).pop(),
    );
    Widget continueButton = FlatButton(
        child: Text("Usuń"),
        color: Colors.red,
        onPressed: () {
          BlocProvider.of<ProfileBloc>(context).add(ProfileDelete());
          Navigator.of(context)
              .pushNamedAndRemoveUntil("/login", ModalRoute.withName("/home"));
        });
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Czy na pewno chcesz usunąć konto?"),
      content: Text(
          "Operacji tej nie da się anulować przez co bezpowrotnie stracisz swoje dotychczasowe konto."),
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
