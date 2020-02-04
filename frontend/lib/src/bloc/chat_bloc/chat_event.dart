

import 'package:agh_soccer/src/models/user_token.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class ChatConnect extends ChatEvent {
  final String url;
  final String matchId;

  ChatConnect({this.url, this.matchId});

  @override
  List<Object> get props => [url, matchId];

  @override
  String toString() => 'ChatConnect { url: $url, matchId: $matchId }';
}

class ChatDisconnect extends ChatEvent {
  @override
  String toString() => 'ChatDisconnect { }';
}

class SendMessage extends ChatEvent {
  final String message;

  SendMessage({this.message});

    @override
  List<Object> get props => [message];

  @override
  String toString() => 'SendMessage { message: $message }';
}

class ChatFetchMessages extends ChatEvent {
  @override
  String toString() => 'ChatFetchMessages {}';
}



///////// INCOMING EVENTS /////////////
// Used as transition phase in socket's
// callbacks
///////////////////////////////////////
class ChatIncoming extends ChatEvent {}

class ChatIncomingConnect extends ChatIncoming {}
class ChatIncomingDisconnect extends ChatIncoming {}

class ChatIncomingMessage extends ChatIncoming {
  final dynamic message;
  
  ChatIncomingMessage({this.message});

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'ChatIncomingMessage { message: $message }';
}

class ChatIncomingError extends ChatIncoming {
  final String error;

  ChatIncomingError({this.error});

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'ChatIncomingError { error: $error }';
}

class ChatIncomingMessagesList extends ChatIncoming {
  final dynamic messages;

  ChatIncomingMessagesList({this.messages});

  @override
  List<Object> get props => [messages];

  @override
  String toString() => 'ChatIncomingMessagesList { }';
}

