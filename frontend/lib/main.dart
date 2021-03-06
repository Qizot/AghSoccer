import 'package:agh_soccer/src/bloc/auth_bloc/bloc.dart';
import 'package:agh_soccer/src/bloc/match_bloc/match_bloc.dart';
import 'package:agh_soccer/src/config/api_config.dart';
import 'package:agh_soccer/src/resources/match_repository.dart';
import 'package:agh_soccer/src/resources/user_repository.dart';
import 'package:agh_soccer/src/app.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';


class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print(error);
  }
}

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final userRepository = UserRepository();

  ApiConfig(apiUri: "http://192.168.0.101:8080/api", chatUri: "http://192.168.0.101:8080");

  runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>(
            create: (context) =>
             AuthenticationBloc(userRepository: userRepository)
              ..add(AppStarted())
          ),
          BlocProvider<MatchBloc>(
            create: (BuildContext context) => MatchBloc(matchRepository: MatchRepository()),
          ),
        ],
        child: App(userRepository: userRepository)
      ),
  );
}
