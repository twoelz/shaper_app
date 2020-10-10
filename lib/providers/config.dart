import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:string_validator/string_validator.dart';

class ConfigMod with ChangeNotifier {
  String ip = '';
  String port = '0';
  String playerName = '';
  int playerNumber = 0;

  dynamic expMapString = '';
  dynamic sMsgMapString = '';

  Map<String, dynamic> expMap;
  Map<String, dynamic> sMsgMap;

  bool showNetConfig = false;

  void toggleShowNetConfig() {
    print('running toggleShowNetConfig in ConfigMod');
    showNetConfig = !showNetConfig;
    print('new showNetConfig setting: $showNetConfig');
    notifyListeners();
  }

  void setServerConfigs(exp, sMsg) async {
    expMap = await json.decode(exp);
    expMapString = expMap.toString();
    sMsgMap = await json.decode(sMsg);
    sMsgMapString = sMsgMap.toString();
    notifyListeners();
  }

  void setPlayerName(String newPlayerName) async {
    if (newPlayerName == null) {
      return;
    }

    newPlayerName = newPlayerName.trim();
    if (newPlayerName == playerName) {
      return;
    }

    if (newPlayerName == '') {
      print('invalid player name');
      return;
    }

    playerName = newPlayerName;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('playerName', playerName);
    notifyListeners();
    print('ip now is $ip');
  }

  void setIp(String newIp) async {
    if (newIp == null) {
      return;
    }
    newIp = newIp.trim();
    if (newIp == ip) {
      return;
    }

    if (newIp == 'localhost') {
      // do nothing
    } else if (newIp == '' || !isIP(newIp)) {
      print('invalid IP');
      return;
      // ip = prefs.getString('defaultIp');
    }

    ip = newIp;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ip', ip);
    notifyListeners();
  }

  void setPort(String newPort) async {
    if (newPort == null) {
      return;
    }

    newPort = newPort.trim();

    if (!isInt(newPort)) {
      print('invalid PORT');
      return;
    }
    // int intNewPort = int.parse(newPort);
    //
    // if (intNewPort == port) {
    //   return;
    // }

    if (newPort == port) {
      return;
    }
    port = newPort;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('port', port);
    notifyListeners();
  }

  ConfigMod() {
    initialState();
  }

  void initialState() {
    syncDataWithProvider();
  }

  Future syncDataWithProvider() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ip = prefs.getString('ip');
    try {
      port = prefs.getString('port');
    } catch (e) {
      print(e);
      port = prefs.getInt('port').toString();
    }
    playerName = prefs.getString('playerName');
    notifyListeners();
  }
}

Future setDefaults() async {
  // network defaults
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('defaultIp', 'localhost');
  await prefs.setString('defaultPort', '8765');

  String ip = prefs.getString('ip') ?? prefs.getString('defaultIp');
  await prefs.setString('ip', ip);

  String port = prefs.getString('port') ?? prefs.getString('defaultPort');
  await prefs.setString('port', port);

  // game defaults
  await prefs.setString('defaultPlayerName', 'player');
  String playerName =
      prefs.getString('playerName') ?? prefs.getString('defaultPlayerName');
  await prefs.setString('playerName', playerName);
}
