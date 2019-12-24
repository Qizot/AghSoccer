import 'dart:async';

import 'package:agh_soccer/src/bloc/auth_bloc/auth_bloc.dart';
import 'package:agh_soccer/src/bloc/auth_bloc/auth_event.dart';
import 'package:agh_soccer/src/bloc/login_bloc/login_event.dart';
import 'package:agh_soccer/src/bloc/login_bloc/login_state.dart';
import 'package:agh_soccer/src/resources/user_repository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';


class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  LoginBloc({
    @required this.userRepository,
    @required this.authenticationBloc,
  })  : assert(userRepository != null),
        assert(authenticationBloc != null);

  LoginState get initialState => LoginInitial();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginButtonPressed) {
      yield LoginLoading();

      try {
        final token = await userRepository.login(
          email: event.email,
          password: event.password,
        );

        authenticationBloc.add(LoggedIn(token: token));
        yield LoginInitial();
      } catch (error) {
        yield LoginFailure(error: error.toString().replaceAll("Exception: ", ""));
      }
    }
  }
}