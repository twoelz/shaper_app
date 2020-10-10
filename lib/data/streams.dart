import 'dart:async';

// data
class ChatMessage {
  final String text;
  final int senderNumber;
  final String senderName;
  final bool sameSender;
  ChatMessage({this.text, this.senderNumber, this.senderName, this.sameSender});
}

// stream controllers will be instances
var gameStreamController = StreamController<Map<String, dynamic>>();
var chatMessageStreamController = StreamController<ChatMessage>();
