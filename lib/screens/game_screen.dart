import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// import 'package:universal_io/io.dart' show Platform;
// import 'package:emoji_picker/emoji_picker.dart';

import 'package:shaper_app/frames/chat_frame.dart';

class GameScreen extends StatelessWidget {
  static const String id = '/Game';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
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
                    // child: EmojiPicker(
                    //   noRecentsStyle: emojiFallbackTextStyle(context),
                    //   rows: 2,
                    //   columns: 2,
                    //   buttonMode: ButtonMode.MATERIAL,
                    //   recommendKeywords: ["racing", "horse"],
                    //   numRecommended: 3,
                    //   onEmojiSelected: (emoji, category) {
                    //     print(emoji);
                    //   },
                    // ),
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

// TextStyle emojiFallbackTextStyle(ctx) {
//   if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
//     return TextStyle(
//         fontFamily: DefaultTextStyle.of(ctx).style.fontFamily,
//         fontFamilyFallback: ['EmojiOne']
//           ..addAll(DefaultTextStyle.of(ctx).style.fontFamilyFallback));
//   }
//   return TextStyle();
// }
