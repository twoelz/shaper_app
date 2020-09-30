import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:string_validator/string_validator.dart';

class ConfigMod with ChangeNotifier {
  String ip = '';
  int port = 0;
  String playerName = '';

  dynamic expMapString = '';
  dynamic sMsgMapString = '';

  Map<String, dynamic> expMap;
  Map<String, dynamic> sMsgMap;

  void setServerConfigs(exp, sMsg) async {
    expMap = await json.decode(exp);
    expMapString = expMap.toString();
    sMsgMap = await json.decode(sMsg);
    sMsgMapString = sMsgMap.toString();
    notifyListeners();
  }

  void setPlayerName(String newPlayerName) async {
    newPlayerName = newPlayerName.trim();
    if (newPlayerName == playerName) {
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    playerName = newPlayerName;
    if (playerName == '') {
      playerName = prefs.getString('defaultPlayerName');
    }
    await prefs.setString('playerName', playerName);

    notifyListeners();
  }

  void setIp(String newIp) async {
    newIp = newIp.trim();
    if (newIp == ip) {
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    ip = newIp;

    if (ip == 'localhost') {
      // do nothing
    } else if (ip == '' || !isIP(ip)) {
      ip = prefs.getString('defaultIp');
    }

    await prefs.setString('ip', ip);
    notifyListeners();
  }

  void setPort(String newPort) async {
    newPort = newPort.trim();

    if (!isInt(newPort)) {
      print('invalid PORT');
      return;
    }
    int intNewPort = int.parse(newPort);

    if (intNewPort == port) {
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    port = intNewPort;

    await prefs.setInt('port', port);
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
    port = prefs.getInt('port');
    playerName = prefs.getString('playerName');
    notifyListeners();
  }
}

Future setDefaults() async {
  // network defaults
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('defaultIp', 'localhost');
  await prefs.setInt('defaultPort', 8765);

  String ip = prefs.getString('ip') ?? prefs.getString('defaultIp');
  await prefs.setString('ip', ip);

  int port = prefs.getInt('port') ?? prefs.getInt('defaultPort');
  await prefs.setInt('port', port);

  // game defaults
  await prefs.setString('defaultPlayerName', 'player');
  String playerName =
      prefs.getString('playerName') ?? prefs.getString('defaultPlayerName');
  await prefs.setString('playerName', playerName);
}
