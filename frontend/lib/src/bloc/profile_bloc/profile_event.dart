import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileFetch extends ProfileEvent {}

class ProfileDelete extends ProfileEvent {}

