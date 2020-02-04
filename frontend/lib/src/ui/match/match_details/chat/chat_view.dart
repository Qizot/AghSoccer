import 'package:agh_soccer/src/bloc/chat_bloc/bloc.dart';
import 'package:agh_soccer/src/config/api_config.dart';
import 'package:agh_soccer/src/models/chat_message.dart';
import 'package:agh_soccer/src/models/user.dart';
import 'package:agh_soccer/src/resources/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatPage extends StatefulWidget {
  final String matchId;

  ChatPage({@required String matchId}) : matchId = matchId;

  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _inputController = TextEditingController();
  User currentUser;
  List<ChatMessage> messages;

  TextStyle _nicknameStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16.0);
  TextStyle _messageStyle = TextStyle(color: Colors.white54, fontSize: 10.0);

  @override
  void initState() {
    messages = [ChatMessage(nickname: "Qizot", message: "Co tam wariacie, gramy w gałe?")];
    UserRepository().getProfile().then((profile) => setState(() { currentUser = profile;}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatBloc>(
        create: (context) {
          final uri = ApiConfig.instance.chatUri;
          final matchId = widget.matchId;
          return ChatBloc()..add(ChatConnect(url: uri, matchId: matchId));
        },
        child: Scaffold(
            appBar: AppBar(backgroundColor: Colors.black),
            body: BlocListener<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatConnected) {
                  print("CONNECTED WITH SOCKET");
                }
                if (state is ChatFetchedMessages) {
                  setState(() {
                    messages = state.messages;
                  });
                }
                if (state is ChatSingleMessage) {
                  setState(() {
                    messages.insert(0, state.message);
                  });
                }
              },
              child: _body(),
            )));
  }

  Widget _body() {
    return BlocBuilder<ChatBloc, ChatState>(builder: (context, state) {
      if (state is ChatUninitialized) {
        return Container(
          color: Colors.black,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return Column(
        children: <Widget>[
          _messages(context),
          _input(context)
        ],
      );
    });
  }

  Widget _messages(context) {
    return Expanded(
      child: ListView.builder(
        reverse: true,
        itemCount: messages.length,
        itemBuilder: (context, idx) {
          final message = messages[idx];
          return message.nickname == currentUser.nickname ? 
            _currentUserMessage(message) : _otherUserMessage(message);
        }
      ),
    );
  }



  Widget _otherUserMessage(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(msg.nickname, style: _nicknameStyle),
                  SizedBox(height: 5),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      child: Text(msg.message, style: _messageStyle),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(15)
                    ),
                  )
                ],
              )
          ),
          SizedBox(width: 50)
        ],
      ),
    );
  }

  Widget _currentUserMessage(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          SizedBox(width: 50),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(msg.nickname, style: _nicknameStyle, textAlign: TextAlign.end,),
                  SizedBox(height: 5),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      child: Text(msg.message, style: _messageStyle),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(15)
                    ),
                  )
                ],
              )
          ),

        ],
      ),
    );
  }

  Widget _input(context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 75,
        child: Row(
          children: <Widget>[
            Expanded(
                child: TextField(
                    maxLength: 200,
                    maxLines: 3,
                    autocorrect: true,
                    controller: _inputController,
                    style: TextStyle(fontSize: 20, color: Colors.black),
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(20.0),
                        ),
                      ),
                    )),
                flex: 5),
            SizedBox(width: 8),
            Column(
              children: <Widget>[
                SizedBox(height: 10),
                ClipOval(
                  child: Material(
                    color: Colors.blue, // button color
                    child: InkWell(
                      splashColor: Colors.red, // inkwell color
                      child:
                          SizedBox(width: 42, height: 42, child: Icon(Icons.near_me)),
                      onTap: () {
                        BlocProvider.of<ChatBloc>(context).add(SendMessage(message: _inputController.text));
                        _inputController.clear();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
