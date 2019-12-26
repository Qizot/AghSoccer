import 'package:agh_soccer/src/bloc/auth_bloc/auth_bloc.dart';
import 'package:agh_soccer/src/bloc/auth_bloc/auth_event.dart';
import 'package:agh_soccer/src/config/api_config.dart';
import 'package:agh_soccer/src/resources/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:agh_soccer/src/app.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';


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

  ApiConfig(apiUri: "http://192.168.0.105:8080/api");

  runApp(
    BlocProvider<AuthenticationBloc>(
      create: (context) {
        return AuthenticationBloc(userRepository: userRepository)
          ..add(AppStarted());
      },
      child: App(userRepository: userRepository),
    ),
  );
}
