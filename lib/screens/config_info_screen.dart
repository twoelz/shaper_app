import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shaper_app/providers/config.dart';

class ConfigInfoScreen extends StatelessWidget {
  static const String id = '/ConfigInfo';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TODO: When AppBar is removed, add a SafeArea child here.
        title: Text("Config Info Screen"),
      ),
      body: Center(
        child: Column(
          children: [
            Text(context.watch<ConfigMod>().expMapString),
            SizedBox(
              height: 40,
            ),
            RaisedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Go back!'),
            ),
            SizedBox(
              height: 40,
            ),
            Text('Test'),
            SizedBox(
              height: 40,
            ),
            RaisedButton(
              onPressed: () {
                print(context.read<ConfigMod>().expMapString);
              },
              child: Text('Print info!'),
            ),
          ],
        ),
      ),
    );
  }
}
