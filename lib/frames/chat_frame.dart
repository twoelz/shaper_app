import 'package:flutter/material.dart';
import 'package:shaper_app/providers/client.dart';
import 'package:provider/provider.dart';

import 'package:universal_io/io.dart' show Platform;
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'package:shaper_app/providers/config.dart';
import 'package:shaper_app/data/streams.dart';

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  // fontSize: Theme.of(context).textTheme.body1.fontSize,
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

final chatMessageTextController = TextEditingController();
final chatFocusNode = FocusNode();

class ChatFrame extends StatelessWidget {
  void _sendChatMessage(ctx) {
    Provider.of<ClientMod>(ctx, listen: false).sendChatMessage();
    chatMessageTextController.clear();
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      chatFocusNode.requestFocus();
    } else {
      FocusScopeNode currentFocus = FocusScope.of(ctx);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) {
      // flutter_keyboard_visibility: makes sure chat gets focus
      // TODO: check if I have to dispose of onChange at any point
      // TODO: probably needs a subscribe and then cancel it?

      // OLD - NOT WORKING (KEYBOARDVISIBILITY REMOVED)
      // KeyboardVisibility.onChange.listen((bool visible) {
      //   if (visible) {
      //     chatFocusNode.requestFocus();
      //   }
      // });
      var keyboardVisibilityController = KeyboardVisibilityController();
      keyboardVisibilityController.onChange.listen((bool visible) {
        if (visible) {
          chatFocusNode.requestFocus();
        }
      });
    }
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          MessagesStream(),
          // EmojiPicker(
          //   rows: 3,
          //   columns: 7,
          //   buttonMode: ButtonMode.MATERIAL,
          //   recommendKeywords: ["racing", "horse"],
          //   numRecommended: 10,
          //   onEmojiSelected: (emoji, category) {
          //     print(emoji);
          //   },
          // ),
          Container(
            decoration: kMessageContainerDecoration,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: chatMessageTextController,
                    autofocus: (Platform.isLinux ||
                            Platform.isWindows ||
                            Platform.isMacOS)
                        ? true
                        : false,
                    focusNode: chatFocusNode,
                    onChanged: (value) {
                      context.read<ClientMod>().chatMessageText = value;
                    },
                    onSubmitted: (value) => _sendChatMessage(context),
                    style: emojiFallbackTextStyle(context),
                    decoration: kMessageTextFieldDecoration,
                  ),
                ),
                TextButton(
                  onPressed: () => _sendChatMessage(context),
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
  MessageBubble(
      {this.senderNumber,
      this.senderName,
      this.text,
      this.isMe,
      this.sameSender});

  final int senderNumber;
  final String senderName;
  final String text;
  final bool isMe;
  final bool sameSender;

  final List<Color> senderColors = [
    Colors.red[900],
    Colors.green[900],
    Colors.purple[800],
    Colors.indigo[900],
    Colors.pink[900],
    Colors.teal[900],
    Colors.blueGrey[900],
    Colors.brown[900],
    Colors.grey[900],
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: sameSender ? EdgeInsets.all(3.0) : EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
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
            // elevation: 3.0,
            color: isMe ? Colors.tealAccent : Colors.cyan[50],
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  (sameSender || isMe)
                      ?
                      // if same sender or own chat display nothing here
                      SizedBox.shrink()
                      :
                      // if not the same, shows sender info
                      Text(
                          'P${senderNumber + 1} $senderName',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                                  color: senderColors[
                                      senderNumber % senderColors.length])
                              .merge(emojiFallbackTextStyle(context)),
                        ),
                  Text(
                    text,
                    style: TextStyle(
                      color: Colors.black,
                    ).merge(emojiFallbackTextStyle(context)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

TextStyle emojiFallbackTextStyle(ctx) {
  // if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
  if (Platform.isLinux || Platform.isMacOS) {
    return TextStyle(
        fontFamily: DefaultTextStyle.of(ctx).style.fontFamily,
        fontFamilyFallback: ['EmojiOne']
          ..addAll(DefaultTextStyle.of(ctx).style.fontFamilyFallback));
  }
  return TextStyle();
}

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ChatMessage>(
      stream: chatMessageStreamController.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center();
        }
        List<ChatMessage> messages =
            context.select((ClientMod clientMod) => clientMod.chatMessages);

        if (messages.length == 0 || messages.last != snapshot.data) {
          messages.add(snapshot.data);
        }

        List<MessageBubble> messageBubbles = [];
        for (var message in messages.reversed) {
          final messageText = message.text;
          final messageSenderNumber = message.senderNumber;
          final messageSenderName = message.senderName;
          final currentUser =
              context.select((ConfigMod configMod) => configMod.playerNumber);
          final messageSameSender = message.sameSender;

          final messageBubble = MessageBubble(
            senderNumber: messageSenderNumber,
            senderName: messageSenderName,
            text: messageText,
            isMe: currentUser == messageSenderNumber,
            sameSender: messageSameSender,
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
