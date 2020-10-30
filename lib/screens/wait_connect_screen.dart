import 'package:flutter/material.dart';

import 'package:shaper_app/widgets/layout.dart';

class WaitConnectScreen extends StatelessWidget {
  static const String id = '/WaitConnect';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          MyVerticalFlexConstrainBox(
            maxHeight: 200,
            minHeight: 5,
          ),
          CircularProgressIndicator(),
          SizedBox(
            height: 20,
          ),
          Text('Wait for Connection'),
          MyVerticalFlexConstrainBox(
            maxHeight: 200,
            minHeight: 5,
          ),
        ],
      )),
    );
  }
}
