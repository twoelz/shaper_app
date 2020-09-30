import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shaper_app/main.dart';
import 'package:shaper_app/providers/network.dart';
import 'package:shaper_app/screens/game_screen.dart';

class ChatMessage {
  String text;
  String sender;
  DateTime messageTime;
  ChatMessage({this.text, this.sender, this.messageTime});
}

class ClientMod with ChangeNotifier {
  NetworkMod networkMod;

  // chat variables
  String chatMessageText;
  StreamController<ChatMessage> chatMessageStreamController =
      StreamController();
  Stream get chatMessageStream => chatMessageStreamController.stream;
  List<ChatMessage> chatMessages = [];

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
        print("DataReceived in Controller: " + data.toString());
      }, onDone: () {
        print("Task Done");
      }, onError: (error) {
        print("Some Error");
      });
      navigatorKey.currentState.pushNamed(GameScreen.id);
    }
  }

  void disconnect() {
    if (networkMod.connected) {
      networkMod.disconnect();
    }
  }
}
