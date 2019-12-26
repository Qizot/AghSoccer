import 'dart:async';

import 'package:agh_soccer/src/bloc/auth_bloc/auth_bloc.dart';
import 'package:agh_soccer/src/bloc/auth_bloc/auth_event.dart';
import 'package:agh_soccer/src/bloc/profile_bloc/profile_event.dart';
import 'package:agh_soccer/src/bloc/profile_bloc/profile_state.dart';
import 'package:agh_soccer/src/models/user.dart';
import 'package:agh_soccer/src/resources/user_repository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';


class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  final _user = BehaviorSubject<User>();

  Stream<User> get user  => _user.stream;


  ProfileBloc({
    @required this.userRepository,
    @required this.authenticationBloc,
  })  : assert(userRepository != null),
        assert(authenticationBloc != null);

  ProfileState get initialState => ProfileInitial();

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    if (event is ProfileFetch) {
      yield ProfileLoading();

      try {

        final user = await userRepository.getProfile(authenticationBloc);
        _user.add(user);

        yield ProfileFetched();
      } catch (error) {
        print("during fetch");
        print(error);
        yield ProfileFailure(error: error.toString().replaceAll("Exception: ", "Dupa "));
      }
    }
    if (event is ProfileDelete) {
      try {
        await userRepository.deleteAccount(authenticationBloc);
        authenticationBloc.add(LoggedOut());
      } catch (error) {
        print("during delete");
        print(error);
        yield ProfileFailure(error: error.toString().replaceAll("Exception: ", "Kutas "));
      }
    }
  }

  void dispose() {
    _user.close();
  }
}