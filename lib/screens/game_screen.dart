import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shaper_app/frames/chat_frame.dart';
import 'package:shaper_app/frames/game_frame.dart';

class GameScreen extends StatelessWidget {
  static const String id = '/Game';
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          // appBar: AppBar(
          //   title: Text("Game Screen"),
          // ),
          resizeToAvoidBottomInset: true,
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
                    child: GameFrame(),
                    // child: Container(
                    //   color: Colors.lightBlueAccent,
                    // ),
                  ),
                  Expanded(
                    flex: 4,
                    child: ChatFrame(),
                  )
                ],
              );
            },
          )),
    );
  }
}
