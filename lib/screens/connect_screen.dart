import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shaper_app/providers/config.dart';
import 'package:shaper_app/providers/network.dart';
import 'package:shaper_app/providers/client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectScreen extends StatelessWidget {
  static const String id = '/Connect';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(
//        title: Text(widget.title),
//      ),
      body: Column(children: [
        MyVerticallyConstrainedBox(
          maxHeight: 40,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people,
              size: Theme.of(context).textTheme.headline2.fontSize,
            ),
            Text(' Shaper', style: Theme.of(context).textTheme.headline3),
          ],
        ),
        MyVerticallyConstrainedBox(
          maxHeight: 10,
        ),
        MyConfigTable(),
        MyVerticallyConstrainedBox(
          maxHeight: 40,
        ),
        ConnectButtonRow(),
        MyVerticallyConstrainedBox(
          maxHeight: 40,
        ),
      ]),
    );
  }
}

class MyVerticallyConstrainedBox extends StatelessWidget {
  final double maxHeight;
  MyVerticallyConstrainedBox({this.maxHeight});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
          minHeight: 1,
        ),
        child: Container(),
      ),
    );
  }
}

class MyConfigTable extends StatelessWidget {
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

  final List<TableCell> emptyCells = [
    TableCell(
      child: Container(),
    ),
    TableCell(
      child: Container(),
    ),
    TableCell(
      child: Container(),
    ),
    TableCell(
      child: Container(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
        border: TableBorder.all(color: Colors.black26, width: 2),
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
              child: Row(
                children: [
                  Icon(Icons.perm_identity),
                  Text(' Name: '),
                  Text(context.watch<ConfigMod>().playerName,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
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
          context.watch<ConfigMod>().showNetConfig
              ? TableRow(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Row(
                      children: [
                        Icon(Icons.settings_ethernet),
                        Text(' IP: '),
                        Text(context.watch<ConfigMod>().ip,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
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
                ])
              : TableRow(children: emptyCells),
          context.watch<ConfigMod>().showNetConfig
              ? TableRow(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Row(
                      children: [
                        Icon(Icons.meeting_room),
                        Text(
                          ' PORT: ${context.watch<ConfigMod>().port}',
                        ),
                      ],
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
                ])
              : TableRow(children: emptyCells),
        ]);
  }
}

class ConnectButtonRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        children: [
          context.watch<NetworkMod>().connected
              ? DisconnectButton()
              : ConnectButton(),
          SizedBox(
            width: 150,
          ),
          AdvancedSettingsButton(),
          // TODO: Advanced Settings
        ]);
  }
}

class DisconnectButton extends StatelessWidget {
  void _disconnect(ctx) {
    Provider.of<ClientMod>(ctx, listen: false).disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: Colors.red,
      onPressed: () => _disconnect(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              "Disconnect",
            ),
          ),
        ],
      ),
    );
  }
}

class ConnectButton extends StatelessWidget {
  void _connect(ctx) {
    Provider.of<ClientMod>(ctx, listen: false).connect();
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: Colors.green,
      onPressed: () => _connect(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.login,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              "Connect",
            ),
          ),
        ],
      ),
    );
  }
}

class AdvancedSettingsButton extends StatelessWidget {
  void _advancedSettingsToggle(ctx) {
    Provider.of<ConfigMod>(ctx, listen: false).toggleShowNetConfig();
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: Colors.black26,
      onPressed: () => _advancedSettingsToggle(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: context.watch<ConfigMod>().showNetConfig
                ? Icon(
                    Icons.remove_circle,
                    color: Colors.white,
                  )
                : Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              "Settings",
            ),
          ),
        ],
      ),
    );
  }
}
