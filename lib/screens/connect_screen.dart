import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:shaper_app/providers/config.dart';
import 'package:shaper_app/providers/network.dart';
import 'package:shaper_app/providers/client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shaper_app/widgets/layout.dart';

class ConnectScreen extends StatelessWidget {
  static const String id = '/Connect';

  @override
  Widget build(BuildContext context) {
    // // variable below to force rebuild when height changes
    // var listenToSize = MediaQuery.of(context).size;
    // print(listenToSize);
    // rebuildAllChildren(context);

    return Scaffold(
//      appBar: AppBar(
//        title: Text(widget.title),
//      ),
      body: ElevatedButtonTheme(
        data: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(padding: EdgeInsets.zero)),
        child: TextButtonTheme(
          data: TextButtonThemeData(
            style: TextButton.styleFrom(
              primary: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 15.0),
            ),
          ),
          child: Column(children: [
            MyVerticalFlexConstrainBox(
              maxHeight: 100,
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
            MyVerticalFlexConstrainBox(
              maxHeight: 10,
            ),
            MyHorizontalConstrainBox(
              child: MyConfigTable(),
              maxWidth: 560,
            ),
            // MyConfigTable(),
            MyVerticalFlexConstrainBox(
              maxHeight: 40,
            ),
            // SizedBox(
            //   height: 2,
            // ),
            ConnectButtonRow(),
            MyVerticalFlexConstrainBox(
              maxHeight: 80,
            ),
          ]),
        ),
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
    // variable below to force rebuild when height changes
    // var listenToHeight = MediaQuery.of(context).size.height;

    return Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
        border: TableBorder.all(color: Colors.black26, width: 2),
        columnWidths: {
          0: FlexColumnWidth(22),
          1: FlexColumnWidth(12),
          2: FlexColumnWidth(9),
          3: FlexColumnWidth(9),
        },
        children: [
          TableRow(children: [
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Row(
                children: [
                  Icon(Icons.perm_identity),
                  Flexible(
                    child: AutoSizeText(
                      context.watch<ConfigMod>().playerName,
                      maxLines: 1,
                      minFontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: AutoSizeTextField(
                controller: _playerNameController,
                onSubmitted: (String value) => _setPlayerName(context),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'New name?',
                ),
                minFontSize: 10,
              ),
            ),
            Container(
              height: 44.0,
              padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
              child: ElevatedButton(
                // style: ButtonStyle(padding: EdgeInsetsG),
                onPressed: () => _setPlayerName(context),
                child: AutoSizeText(
                  'change',
                  maxLines: 1,
                  minFontSize: 10,
                ),
              ),
            ),
            Container(
              height: 44.0,
              padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
              child: ElevatedButton(
                onPressed: () => _setPlayerNameDefault(context),
                child: AutoSizeText(
                  'default',
                  maxLines: 1,
                  minFontSize: 10,
                ),
              ),
            ),
          ]),
          context.watch<ConfigMod>().showNetConfig
              ? TableRow(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Row(
                      children: [
                        Icon(Icons.settings_ethernet),
                        Flexible(
                          child: AutoSizeText(
                            'IP: ${context.watch<ConfigMod>().ip}',
                            maxLines: 2,
                            minFontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: AutoSizeTextField(
                      controller: _ipController,
                      onSubmitted: (String value) => _setIp(context),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'New IP?',
                      ),
                      minFontSize: 10,
                    ),
                  ),
                  Container(
                    height: 44.0,
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                    child: ElevatedButton(
                      onPressed: () => _setIp(context),
                      child: AutoSizeText(
                        'change',
                        maxLines: 1,
                        minFontSize: 8,
                      ),
                    ),
                  ),
                  Container(
                    height: 44.0,
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                    child: ElevatedButton(
                      onPressed: () => _setIpDefault(context),
                      child: AutoSizeText(
                        'default',
                        maxLines: 1,
                        minFontSize: 8,
                      ),
                    ),
                  ),
                ])
              : TableRow(children: emptyCells),
          context.watch<ConfigMod>().showNetConfig
              ? TableRow(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Row(
                      children: [
                        Icon(Icons.meeting_room),
                        Flexible(
                          child: AutoSizeText(
                            'PORT: ${context.watch<ConfigMod>().port}',
                            maxLines: 2,
                            minFontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: AutoSizeTextField(
                      controller: _portController,
                      onSubmitted: (String value) => _setPort(context),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'New PORT?',
                      ),
                      minFontSize: 10,
                    ),
                  ),
                  Container(
                    height: 44.0,
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                    child: ElevatedButton(
                      onPressed: () => _setPort(context),
                      child: AutoSizeText(
                        'change',
                        maxLines: 1,
                        minFontSize: 8,
                      ),
                    ),
                  ),
                  Container(
                    height: 44.0,
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                    child: ElevatedButton(
                      onPressed: () => _setPortDefault(context),
                      child: AutoSizeText(
                        'default',
                        maxLines: 1,
                        minFontSize: 8,
                      ),
                    ),
                  ),
                ])
              : TableRow(children: emptyCells),
        ]);
  }
}

// class ShrinkText extends StatelessWidget {
//   final String text;
//   final TextStyle style;
//   ShrinkText({@required this.text, this.style});
//
//   @override
//   Widget build(BuildContext context) {
//     return FittedBox(
//         fit: BoxFit.scaleDown,
//         child: Text(
//           text,
//           style: style,
//         ));
//   }
// }

class ConnectButtonRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.start,

        // return Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     crossAxisAlignment: CrossAxisAlignment.baseline,
        children: [
          context.watch<NetworkMod>().connected
              ? DisconnectButton()
              : ConnectButton(),
          // SizedBox(
          //   width: 15,
          // ),
          MyHorizontalConstrainBox(
            maxWidth: 15,
          ),
          InternetStatusButton(),
          // SizedBox(
          //   width: 15
          // ),
          context.watch<NetworkMod>().batteryState == null
              ? SizedBox.shrink()
              : BatteryStatusButton(),
          MyHorizontalConstrainBox(
            // maxWidth: 50,
            maxWidth: 10,
            minWidth: 1,
          ),
          AdvancedSettingsButton(),
        ]);
  }
}

class DisconnectButton extends StatelessWidget {
  void _disconnect(ctx) {
    Provider.of<ClientMod>(ctx, listen: false).disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.red,
      ),
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
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.green,
      ),
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
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.black26,
      ),
      // color: Colors.black26,
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

class InternetStatusButton extends StatelessWidget {
  void _checkInternet(ctx) {
    Provider.of<NetworkMod>(ctx, listen: false).checkInternet(null);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      onPressed: () => _checkInternet(context),
      // onPressed: context.watch<NetworkMod>().internetConnected
      //     ? null
      //     : () => _checkInternet(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: context.watch<NetworkMod>().internetConnected
                ? context.watch<NetworkMod>().internetConnectionType == 'wifi'
                    ? Icon(
                        // should be a symbol representing wifi
                        Icons.wifi,
                        color: Colors.black26,
                      )
                    : Icon(
                        // should be a symbol representing mobile / cellular
                        Icons.signal_cellular_alt,
                        color: Colors.black26,
                      )
                : Icon(
                    // should be a symbol representing disconnected
                    Icons.wifi_off,
                    color: Colors.black26,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: context.watch<NetworkMod>().internetConnected
                ? context.watch<NetworkMod>().internetConnectionType == 'wifi'
                    ? Text("WiFi OK")
                    : Text('mobile data')
                : Text("No internet"),
          ),
        ],
      ),
    );
  }
}

class BatteryStatusButton extends StatelessWidget {
  Future<int> _getBatteryLevel(ctx) async {
    final int batteryLevel =
        await Provider.of<NetworkMod>(ctx, listen: false).getBatteryLevel();
    return batteryLevel;
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      onPressed: () async {
        final int batteryLevel = await _getBatteryLevel(context);
        showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            content: Text('Battery: $batteryLevel%'),
            actions: <Widget>[
              FlatButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child:
                context.watch<NetworkMod>().batteryStateString == 'discharging'
                    ? Icon(
                        // should be a symbol representing battery alert
                        Icons.battery_alert,
                        color: Colors.black26,
                      )
                    : context.watch<NetworkMod>().batteryStateString == 'full'
                        ? Icon(
                            // should be a symbol representing battery full
                            Icons.battery_full,
                            color: Colors.black26,
                          )
                        : Icon(
                            // should be a symbol representing battery charging
                            Icons.battery_charging_full,
                            color: Colors.black26,
                          ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: context.watch<NetworkMod>().batteryStateString ==
                      'discharging'
                  ? Text('discharging')
                  : context.watch<NetworkMod>().batteryStateString == 'full'
                      ? Text("full")
                      : Text('charging')),
        ],
      ),
    );
  }
}
