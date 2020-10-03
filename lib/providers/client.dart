import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shaper_app/main.dart';
import 'package:shaper_app/providers/network.dart';
import 'package:shaper_app/screens/game_screen.dart';

class ChatMessage {
  String text;
  int senderNumber;
  String senderName;
  bool sameSender;
  ChatMessage({this.text, this.senderNumber, this.senderName, this.sameSender});
}

class ClientMod with ChangeNotifier {
  NetworkMod networkMod;

  // chat variables
  String chatMessageText;
  StreamController<ChatMessage> chatMessageStreamController =
      StreamController();
  Stream get chatMessageStream => chatMessageStreamController.stream;
  List<ChatMessage> _chatMessages = [];
  List<ChatMessage> get chatMessages => _chatMessages;

  @override
  void dispose() {
    chatMessageStreamController.close();
    chatMessageStreamController = StreamController();
    super.dispose();
  }

  // network methods
  void connect() async {
    bool connected = await networkMod.connect();
    if (connected) {
      networkMod.gameStreamController.stream.listen((data) {
        consumeGameData(data);
      }, onDone: () {
        print('Task Done');
      }, onError: (error) {
        print("Some Error");
      });
      navigatorKey.currentState.pushNamed(GameScreen.id);
    }
  }

  void consumeGameData(data) async {
    switch (data['game data']) {
      case 'chat message':
        chatMessageReceived(data);
        return;
      default:
        print('invalid game data received: $data');
    }
    return;
  }

  void chatMessageReceived(data) async {
    chatMessageStreamController.add(ChatMessage(
        text: data['chat message'],
        senderNumber: data['sender number'],
        senderName: data['sender name'],
        sameSender: data['same sender']));
    return;
  }

  void disconnect() {
    if (networkMod.connected) {
      networkMod.disconnect();
    }
  }

  void sendChatMessage() {
    if (chatMessageText != '') {
      networkMod.sendChatMessageToServer(chatMessageText);
      chatMessageText = '';
    }
  }
}
