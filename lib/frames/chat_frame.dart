import 'package:flutter/material.dart';
import 'package:shaper_app/providers/client.dart';
import 'package:provider/provider.dart';
import 'package:shaper_app/providers/config.dart';

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
  ),
);

class ChatFrame extends StatelessWidget {
  final chatMessageTextController = TextEditingController();
  final chatFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          MessagesStream(),
          Container(
            decoration: kMessageContainerDecoration,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: chatMessageTextController,
                    autofocus: true,
                    focusNode: chatFocusNode,
                    onChanged: (value) {
                      print('changing chatMessageText to: $value');
                      context.read<ClientMod>().chatMessageText = value;
                    },
                    decoration: kMessageTextFieldDecoration,
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    print('CLEARING TEXT');
                    chatMessageTextController.clear();
                    context.read<ClientMod>().chatMessageStreamController.add(
                          ChatMessage(
                              text: context.read<ClientMod>().chatMessageText,
                              senderNumber:
                                  context.read<ConfigMod>().playerNumber,
                              senderName: context.read<ConfigMod>().playerName),
                        );
                    chatFocusNode.requestFocus();
                  },
                  child: Text(
                    'Send',
                    style: kSendButtonTextStyle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.senderNumber, this.senderName, this.text, this.isMe});

  final int senderNumber;
  final String senderName;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            senderName,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black54,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ChatMessage>(
      stream:
          context.select((ClientMod clientMod) => clientMod.chatMessageStream),
      builder: (context, snapshot) {
        print('starting build');
        if (!snapshot.hasData) {
          print('NO DATA');
          return Center(
              // child: CircularProgressIndicator(
              //   backgroundColor: Colors.lightBlueAccent,
              // ),
              );
        }
        print('before creating messages');

        var messages =
            context.select((ClientMod clientMod) => clientMod.chatMessages);

        messages.add(snapshot.data);

        List<MessageBubble> messageBubbles = [];
        for (var message in messages.reversed) {
          final messageText = message.text;
          final messageSenderNumber = message.senderNumber;
          final messageSenderName = message.senderName;
          final currentUser =
              context.select((ConfigMod configMod) => configMod.playerNumber);

          final messageBubble = MessageBubble(
            senderNumber: messageSenderNumber,
            senderName: messageSenderName,
            text: messageText,
            isMe: currentUser == messageSenderNumber,
          );

          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}
