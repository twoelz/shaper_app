import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shaper_app/providers/network.dart';
import 'package:shaper_app/widgets/layout.dart';

class WaitConnectScreen extends StatelessWidget {
  static const String id = '/WaitConnect';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
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
            WaitForConnection(),
            MyVerticalFlexConstrainBox(
              maxHeight: 200,
              minHeight: 5,
            ),
          ],
        )),
      ),
    );
  }
}

class WaitForConnection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return (!context.watch<NetworkMod>().chooseHost)
        ? Text('Wait for Connection')
        : Text('Multiple Hosts: ${context.watch<NetworkMod>().multiHost}');
  }
}
