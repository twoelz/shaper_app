import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:shaper_app/providers/config.dart';
import 'package:shaper_app/providers/network.dart';
import 'package:shaper_app/providers/client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectScreen extends StatelessWidget {
  static const String id = '/Connect';

  // void rebuildAllChildren(BuildContext context) {
  //   print('rebuilding each children now');
  //   void rebuild(Element el) {
  //     el.markNeedsBuild();
  //     el.visitChildren(rebuild);
  //   }
  //
  //   (context as Element).visitChildren(rebuild);
  // }

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
              maxHeight: 40,
            ),
          ]),
        ),
      ),
    );
  }
}

class MyVerticalFlexConstrainBox extends StatelessWidget {
  MyVerticalFlexConstrainBox({this.maxHeight, this.minHeight, this.child});
  final Widget child;
  final double maxHeight;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    // observe: Flexible here!
    return Flexible(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
          minHeight: (minHeight != null) ? minHeight : 1,
        ),
        child: (child != null) ? child : Container(),
      ),
    );
  }
}

class MyHorizontalConstrainBox extends StatelessWidget {
  MyHorizontalConstrainBox({this.maxWidth, this.minWidth, this.child});
  final Widget child;
  final double maxWidth;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    // observe: not Flexible!
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        minWidth: (minWidth != null) ? minWidth : 1,
      ),
      child: Container(
        child: (child != null) ? child : Container(),
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
              // TODO: add buttons for different batterystates
              : Text('${context.watch<NetworkMod>().batteryState}'),
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
    return FlatButton(
      color: Theme.of(context).scaffoldBackgroundColor,
      onPressed: context.watch<NetworkMod>().internetConnected
          ? null
          : () => _checkInternet(context),
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
