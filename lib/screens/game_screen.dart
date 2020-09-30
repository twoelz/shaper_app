import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shaper_app/frames/chat_frame.dart';

class GameScreen extends StatelessWidget {
  static const String id = '/Game';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Game Screen"),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.lightBlueAccent,
            ),
          ),
          Expanded(
            flex: 4,
            child: ChatFrame(),
            // child: Container(
            //   color: Colors.green,
            //   child: Text('Chat Screen'),
            // ),
          )
        ],
      ),
    );
  }
}
