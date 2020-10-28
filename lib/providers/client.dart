import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shaper_app/main.dart';
import 'package:shaper_app/providers/network.dart';
import 'package:shaper_app/screens/connect_screen.dart';
import 'package:shaper_app/screens/wait_connect_screen.dart';
import 'package:shaper_app/screens/game_screen.dart';
import 'package:shaper_app/data/streams.dart';
// import 'package:string_validator/string_validator.dart';

class ClientMod with ChangeNotifier {
  NetworkMod networkMod;

  // chat variables
  String chatMessageText;

  // Stream get chatMessageStream => chatMessageStreamController.stream;
  List<ChatMessage> _chatMessages = [];
  List<ChatMessage> get chatMessages => _chatMessages;

  // network methods
  void connect() async {
    navigatorKey.currentState.pushNamed(WaitConnectScreen.id);
    await networkMod.connect(confirmConnected, connectionFailed);
  }

  Future<void> connectionFailed(e) async {
    print('running connection Failed');
    print('$e');
    navigatorKey.currentState.pop();
    navigatorKey.currentState.pushNamed(ConnectScreen.id);
    showDialog(
        context: navigatorKey.currentContext,
        builder: (context) => AlertDialog(
              title: Text("Connection Error"),
              content: Text("$e"),
            ));
  }

  Future<void> confirmConnected() async {
    print('running confirm Connected');
    navigatorKey.currentState.pop();
    final bool connected = await networkMod.confirmConnected();
    if (!connected) {
      return;
    }
    print('start listening');
    gameStreamController.stream.listen((data) {
      consumeGameData(data);
    }, onDone: () {
      print('Task Done');
      return;
    }, onError: (error) {
      print("Error in consumeGameData: $error");
      disconnect();
      return;
    }, cancelOnError: true);
    print('moving navigator now');
    // TODO: check if it has a gameID, if yes, check if same ID, if not, reset chat data

    navigatorKey.currentState.pushNamed(GameScreen.id);
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
