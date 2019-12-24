import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();
}

class RegisterButtonPressed extends RegisterEvent {
  final String email;
  final String nickname;
  final String password;

  const RegisterButtonPressed({
    @required this.email,
    @required this.nickname,
    @required this.password,
  });

  @override
  List<Object> get props => [email, nickname, password];

  @override
  String toString() =>
      'RegisterButtonPressed { email: $email, nickname: $nickname password: $password }';
}