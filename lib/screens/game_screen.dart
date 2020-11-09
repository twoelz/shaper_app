import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shaper_app/frames/chat_frame.dart';

class GameScreen extends StatelessWidget {
  static const String id = '/Game';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // TODO: When AppBar is removed, add a SafeArea child here.
          title: Text("Game Screen"),
        ),
        body: OrientationBuilder(
          builder: (context, orientation) {
            return Flex(
              direction: (orientation == Orientation.portrait)
                  ? Axis.vertical
                  : Axis.horizontal,
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
                )
              ],
            );
          },
        ));
  }
}
