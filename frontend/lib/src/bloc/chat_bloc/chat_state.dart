
import 'package:agh_soccer/src/models/chat_message.dart';
import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object> get props => [];
}

class ChatUninitialized extends ChatState {}

class ChatConnected extends ChatState {}

class ChatDisconnected extends ChatState {}

class ChatSingleMessage extends ChatState {
  final ChatMessage message;

  ChatSingleMessage({this.message});

  @override
  List<Object> get props => [message.nickname, message.message, message.timestamp];

  @override
  String toString() => "ChatSingleMessage { message: $message }";
}

class ChatFetchedMessages extends ChatState {
  final List<ChatMessage> messages;

  ChatFetchedMessages({this.messages});

  @override
  List<Object> get props => [messages];

  @override
  String toString() => "ChatFetchedMessages { messages: $messages }";
}

class ChatError extends ChatState {
  final String error;

  ChatError({this.error});

  @override
  List<Object> get props => [error];

  @override
  String toString() => "ChatError { error: $error }";  
}