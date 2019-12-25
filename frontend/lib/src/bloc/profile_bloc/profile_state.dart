import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileFetched extends ProfileState {}

class ProfileFailure extends ProfileState {
  final String error;

  const ProfileFailure({@required this.error});

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'ProfileFailure { error: $error }';
}