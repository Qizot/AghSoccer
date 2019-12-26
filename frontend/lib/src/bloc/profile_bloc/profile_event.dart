import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileFetch extends ProfileEvent {}

class ProfileDelete extends ProfileEvent {}

