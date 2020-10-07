import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shaper_app/providers/config.dart';
import 'package:shaper_app/providers/network.dart';
import 'package:shaper_app/providers/client.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  void _setPlayerNameDefault(ctx) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Provider.of<ConfigMod>(ctx, listen: false)
        .setPlayerName(prefs.getString('defaultPlayerName'));
    _playerNameController.clear();
  }

  void _setIp(ctx) {
    Provider.of<ConfigMod>(ctx, listen: false).setIp(_ipController.text);
    _ipController.clear();
  }

  void _setIpDefault(ctx) async {
    print('setting IP default');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Provider.of<ConfigMod>(ctx, listen: false)
        .setIp(prefs.getString('defaultIp'));
    _ipController.clear();
  }

  void _setPort(ctx) {
    Provider.of<ConfigMod>(ctx, listen: false).setPort(_portController.text);
    _portController.clear();
  }

  void _setPortDefault(ctx) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Provider.of<ConfigMod>(ctx, listen: false)
        .setPort(prefs.getString('defaultPort'));
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
      body: Column(children: [
        Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
            border: TableBorder.all(),
            columnWidths: {
              0: FixedColumnWidth(180.0),
              1: FixedColumnWidth(160.0),
              2: FixedColumnWidth(80.0), //fixed to 100 width
              3: FixedColumnWidth(80.0),
            },
            children: [
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    'Player: ${context.watch<ConfigMod>().playerName}',
                    // textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: TextField(
                    controller: _playerNameController,
                    onSubmitted: (String value) => _setPlayerName(context),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'New name?',
                    ),
                  ),
                ),
                Container(
                  height: 44.0,
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                  child: RaisedButton(
                    onPressed: () => _setPlayerName(context),
                    child: Text(
                      "Change",
                    ),
                  ),
                ),
                Container(
                  height: 44.0,
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                  child: RaisedButton(
                    onPressed: () => _setPlayerNameDefault(context),
                    child: Text(
                      "Default",
                    ),
                  ),
                ),
              ]),
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    'IP: ${context.watch<ConfigMod>().ip}',
                    // textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: TextField(
                    controller: _ipController,
                    onSubmitted: (String value) => _setIp(context),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'New IP?',
                    ),
                  ),
                ),
                Container(
                  height: 44.0,
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                  child: RaisedButton(
                    onPressed: () => _setIp(context),
                    child: Text(
                      "Change",
                    ),
                  ),
                ),
                Container(
                  height: 44.0,
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                  child: RaisedButton(
                    onPressed: () => _setIpDefault(context),
                    child: Text(
                      "Default",
                    ),
                  ),
                ),
              ]),
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    'PORT: ${context.watch<ConfigMod>().port}',
                    // textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: TextField(
                    controller: _portController,
                    onSubmitted: (String value) => _setPort(context),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'New PORT?',
                    ),
                  ),
                ),
                Container(
                  height: 44.0,
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                  child: RaisedButton(
                    onPressed: () => _setPort(context),
                    child: Text(
                      "Change",
                    ),
                  ),
                ),
                Container(
                  height: 44.0,
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                  child: RaisedButton(
                    onPressed: () => _setPortDefault(context),
                    child: Text(
                      "Default",
                    ),
                  ),
                ),
              ]),
            ]),
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
              )
            ]),
      ]),
    );
  }
}
