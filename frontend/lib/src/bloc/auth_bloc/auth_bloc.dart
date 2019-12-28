
import 'package:agh_soccer/src/bloc/auth_bloc/auth_event.dart';
import 'package:agh_soccer/src/bloc/auth_bloc/auth_state.dart';
import 'package:agh_soccer/src/resources/auth_provider.dart';
import 'package:agh_soccer/src/resources/user_repository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;

  AuthenticationBloc({@required this.userRepository})
      : assert(userRepository != null);

  @override
  AuthenticationState get initialState => AuthenticationUninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event,
      ) async* {
    if (event is AppStarted) {
      yield AuthenticationLoading();

      bool serverIsResponding = false;
      try {
        await AuthProvider().ping();
        serverIsResponding = true;
      } catch (error) {
        yield AuthenticationServerNotResponding(message: error.toString().replaceAll("Exception: ", ""));
      }

      if (await userRepository.hasToken() && serverIsResponding) {
        final refreshToken = await userRepository.getRefreshToken();

        try {
          await userRepository.refreshToken(refreshToken);
          yield AuthenticationAuthenticated();
        } catch(error) {

          yield AuthenticationUnauthenticated();
        }
      } else if (serverIsResponding) {
        yield AuthenticationUnauthenticated();
      }
    }

    if (event is LoggedIn) {
      yield AuthenticationLoading();
      await userRepository.persistToken(event.token);
      yield AuthenticationAuthenticated();
    }

    if (event is LoggedOut) {
      yield AuthenticationLoading();
      await userRepository.deleteToken();
      yield AuthenticationUnauthenticated();
    }
  }
}