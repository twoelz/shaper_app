import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shaper_app/providers/config.dart';
import 'package:shaper_app/providers/network.dart';
import 'package:shaper_app/providers/client.dart';

class ConnectScreen extends StatelessWidget {
  static const String id = '/Connect';

  final _playerNameController = TextEditingController();
  final _ipController = TextEditingController();
  final _portController = TextEditingController();

  void _setPlayerName(ctx) {
    Provider.of<ConfigMod>(ctx, listen: false)
        .setPlayerName(_playerNameController.text);
    _playerNameController.clear();
  }

  void _setIp(ctx) {
    Provider.of<ConfigMod>(ctx, listen: false).setIp(_ipController.text);
    _ipController.clear();
  }

  void _setPort(ctx) {
    Provider.of<ConfigMod>(ctx, listen: false).setPort(_portController.text);
    _portController.clear();
  }

  void _connect(ctx) {
    Provider.of<ClientMod>(ctx, listen: false).connect();
  }

  void _disconnect(ctx) {
    Provider.of<NetworkMod>(ctx, listen: false).disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(
//        title: Text(widget.title),
//      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              children: [
                Text(
                  'Player: ${context.watch<ConfigMod>().playerName}',
                ),
                SizedBox(
                  width: 30.0,
                ),
                Container(
                  width: 200.0,
                  child: TextField(
                    controller: _playerNameController,
                    onSubmitted: (String value) => _setPlayerName(context),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'New name?',
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () => _setPlayerName(context),
                  child: Text(
                    "Change Player Name",
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              children: [
                Text(
                  'IP: ${context.watch<ConfigMod>().ip}',
                ),
                SizedBox(
                  width: 30.0,
                ),
                Container(
                  width: 200.0,
                  child: TextField(
                    controller: _ipController,
                    onSubmitted: (String value) => _setIp(context),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'New IP?',
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () => _setIp(context),
                  child: Text(
                    "Change IP",
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              children: [
                Text(
                  'PORT: ${context.watch<ConfigMod>().port}',
                ),
                SizedBox(
                  width: 30.0,
                ),
                Container(
                  width: 200.0,
                  child: TextField(
                    controller: _portController,
                    onSubmitted: (String value) => _setPort(context),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'New PORT?',
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () => _setPort(context),
                  child: Text(
                    "Change PORT",
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              children: [
                FlatButton(
                  onPressed: () => _connect(context),
                  child: Text(
                    "Connect",
                  ),
                ),
                SizedBox(
                  width: 150,
                ),
                FlatButton(
                  onPressed: () => _disconnect(context),
                  child: Text(
                    "Disconnect",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
