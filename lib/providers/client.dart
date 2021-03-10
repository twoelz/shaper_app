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

  // initialize game data
  List<int> previousChoices = [1, 2, 3, 4];
  List<int> currentChoices = [4, 3, 2, 1];

  ClientMod() {
    Timer(const Duration(milliseconds: 100), () => addClientModToNetworkMod());
    // Future.delayed(Duration(milliseconds: 100)).then((value) {
    //   addClientModToNetworkMod();
    // });
  }

  // TODO: this may be an anti-pattern: check alternatives (see below)
  // right now:- adding a reference for a lower provider model into a higher one
  //  possible alternative: 1) just sending callbacks (too much boilerplate), but safer
  //  or 2) alternatively using getIt and creating the models as services and passing them to provider as values
  //  (don't know how bad it is to mix Provider and getIt)
  //  or 3)
  //  I will however change this only if program breaks or serious performance issues for now
  void addClientModToNetworkMod() {
    networkMod.clientMod = this;
  }

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

  Future<void> connectionFailed() async {
    if (networkMod.connectAttemptState == 'done') {
      networkMod.connectAttemptState = 'set';
      navigatorKey.currentState.pop();
      navigatorKey.currentState.pushNamed(ConnectScreen.id);
      showDialog(
          context: navigatorKey.currentContext,
          builder: (context) => AlertDialog(
                title: Text("Connection Error"),
                content: Text('Could not connect to experiment.'),
              ));
      return;
    }
    networkMod.nextAttempt();
    networkMod.connect(confirmConnected, connectionFailed);
  }

  //set', 'private', 'public', 'done'

  Future<void> confirmConnected(ws, String myWebSocketChannel) async {
    print('running confirm Connected');
    navigatorKey.currentState.pop();
    await networkMod.confirmConnected(ws, myWebSocketChannel, startListening);
  }

  Future<void> startListening() async {
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

  void notifyDisconnect() async {
    // TODO: add message saying disconnected first
    navigatorKey.currentState.pop();
    navigatorKey.currentState.pushNamed(ConnectScreen.id);
  }

  void consumeGameData(data) async {
    switch (data['game data']) {
      case 'chat message':
        chatMessageReceived(data);
        return;
      default:
        print('invalid game data received: $data');
    }
  }

  void chatMessageReceived(data) async {
    chatMessageStreamController.add(ChatMessage(
        text: data['chat message'],
        senderNumber: data['sender number'],
        senderName: data['sender name'],
        sameSender: data['same sender']));
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
