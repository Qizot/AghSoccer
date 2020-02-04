

import 'dart:convert';

import 'package:agh_soccer/src/bloc/chat_bloc/chat_event.dart';
import 'package:agh_soccer/src/bloc/chat_bloc/chat_state.dart';
import 'package:agh_soccer/src/models/chat_message.dart';
import 'dart:core';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:bloc/bloc.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  IO.Socket socket;
  @override
  ChatState get initialState => ChatUninitialized();

  @override
  Stream<ChatState> mapEventToState(ChatEvent event) async* {
    if (event is ChatConnect && socket == null) {
      socket = IO.io('${event.url}/${event.matchId}?token=${event.token}', <String, dynamic>{
        'transports': ['websocket']
      });

      socket.on('connect', (_) {
        add(ChatIncomingConnect());
      });

      socket.on('message', (message) {
        add(ChatIncomingMessage(message: message));
      });

      socket.on('allMessages', (messages) {
        add(ChatIncomingMessagesList(messages: messages));
      });

      socket.on('error', (err) {
        String errStr = err as String;
        add(ChatIncomingError(error: errStr));
      });

      socket.on('errors', (err) {
        String errStr = err as String;
        add(ChatIncomingError(error: errStr));
      });

      socket.on('disconnect', (_) {
        add(ChatIncomingDisconnect());
      });
    }

    if (event is ChatIncoming) {
      yield* _mapIncomingEvents(event);
    }

    if (event is ChatDisconnect) {
      socket.disconnect();
      yield ChatDisconnected();
    }

    if (event is SendMessage) {
      socket.emit('send', event.message);
    }

    if (event is ChatFetchMessages) {
      socket.emit('getMessages');
    }
  }

  Stream<ChatState> _mapIncomingEvents(ChatIncoming event) async* {
    if (event is ChatIncomingConnect) {
      yield ChatConnected();
    }

    if (event is ChatIncomingDisconnect) {
      socket.close();
      yield ChatDisconnected();
    }

    if (event is ChatIncomingMessage) {
      yield ChatSingleMessage(message: ChatMessage.fromJson(event.message));
    }

    if (event is ChatIncomingMessagesList) {
      List jsonList = json.decode(event.messages.toString());
      yield ChatFetchedMessages(messages: jsonList.map((m) => new ChatMessage.fromJson(m)).toList());
    }
    if (event is ChatIncomingError) {
      yield ChatError(error: event.error);
    }
  }

  @override
  Future<void> close() async {
    socket?.close();
    socket?.destroy();
    await super.close();
  }
}