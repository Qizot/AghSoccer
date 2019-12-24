import 'dart:async';

import 'package:agh_soccer/src/bloc/auth_bloc/auth_bloc.dart';
import 'package:agh_soccer/src/bloc/auth_bloc/auth_event.dart';
import 'package:agh_soccer/src/bloc/register_bloc/register_event.dart';
import 'package:agh_soccer/src/bloc/register_bloc/register_state.dart';
import 'package:agh_soccer/src/models/user_token.dart';
import 'package:agh_soccer/src/resources/user_repository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';


class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  RegisterBloc({
    @required this.userRepository,
    @required this.authenticationBloc,
  })  : assert(userRepository != null),
        assert(authenticationBloc != null);

  RegisterState get initialState => RegisterInitial();

  @override
  Stream<RegisterState> mapEventToState(RegisterEvent event) async* {
    if (event is RegisterButtonPressed) {
      yield RegisterLoading();

      try {
        await userRepository.register(
          email: event.email,
          nickname: event.nickname,
          password: event.password,
        );

        UserToken token = await userRepository.login(email: event.email, password: event.password);

        // authenticationBloc.add(LoggedIn(token: token));
        yield RegisterInitial();
      } catch (error) {
        yield RegisterFailure(error: error.toString().replaceAll("Exception: ", ""));
      }
    }
  }
}