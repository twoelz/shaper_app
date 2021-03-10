import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yaml/yaml.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:string_validator/string_validator.dart';

// import 'package:package_info/package_info.dart';
// import 'package:http/http.dart';
// import 'package:http/http.dart' as http;

class ConfigMod with ChangeNotifier {
  String ip = '';
  String port = '0';
  String playerName = '';
  int playerNumber = 0;
  bool debug = false;

  // Package info
  // String appName = '';
  // String packageName = '';
  String version = '';
  // String buildNumber = '';

  String privateBin = '';
  String privateKey = '';

  String publicBin = '';

  dynamic expMapString = '';
  dynamic sMsgMapString = '';

  Map<String, dynamic> expMap;
  Map<String, dynamic> sMsgMap;
  Map<String, dynamic> serverMap;

  int numPlayers = 2;
  // Map<String, String> shapes;

  Map<String, dynamic> shapes = {
    '0': 'transparent',
  };

  Map<String, dynamic> shapeColors = {
    '0': [0, 0, 0],
  };

  bool showNetConfig = false;

  void toggleShowNetConfig() {
    showNetConfig = !showNetConfig;
    notifyListeners();
  }

  void setServerConfigs(exp, sMsg, server) async {
    expMap = await json.decode(exp);
    expMapString = expMap.toString();
    sMsgMap = await json.decode(sMsg);
    sMsgMapString = sMsgMap.toString();
    serverMap = await json.decode(server);

    numPlayers = expMap['main']['number of players'];
    shapes.addAll(expMap['shapes']);
    shapeColors.addAll(expMap['colors']);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'announceIpBin', serverMap['network']['announce ip bin']);
    await prefs.setString(
        'announceIpKey', serverMap['network']['announce ip key']);

    print('PRIVATE IP BIN: ${serverMap['network']['announce ip bin']}');
    print('PRIVATE IP KEY: ${serverMap['network']['announce ip key']}');
    debug = serverMap['network']['debug'];

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

  void initialState() async {
    syncDataWithProvider();
    rootBundle.loadString('pubspec.yaml').then((String text) {
      Map yaml = loadYaml(text);
      // print(yaml['name']);
      // print(yaml['description']);
      // print(yaml['version']);
      // print(yaml['author']);
      // print(yaml['homepage']);
      // print(yaml['dependencies']);
      version = yaml['version'];
      notifyListeners();
    });

    // PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
    //   // appName = packageInfo.appName;
    //   // packageName = packageInfo.packageName;
    //   version = packageInfo.version;
    //   // buildNumber = packageInfo.buildNumber;
    //   notifyListeners();
    // });
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

Future setAnnouncedDefaults() async {
  print('got into setAnnounceDefaults');
  // network defaults
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // const String hardCodedPublicJsonBin defined at the end of file
  // change it if the accepted hardcoded Public Bin from server changed number

  // only use hardCoded if not previously set.
  // this allows overwrite of hardcoded bin after first connection to server
  String defaultPublicBin =
      prefs.getString('defaultPublicBin') ?? hardCodedPublicJsonBin;
  await prefs.setString('defaultPublicBin', defaultPublicBin);

  if (prefs.getString('publicBin') == null) {
    await prefs.setString('publicBin', defaultPublicBin);
  }

  // PRINTED:
  // {record: {ip: 213.127.44.103,
  //           port: 8766},
  //  metadata: {id: 5f87b0d7302a837e95796d8b,
  //             private: true,
  //             createdAt: 2020-10-15T02:15:51.363Z,
  //             collectionId: 5f86fdea7243cd7e824f255d}}

  // String myUrl =

  // String ip = prefs.getString('ip') ?? prefs.getString('defaultIp');
  // await prefs.setString('ip', ip);
  //
  // String port = prefs.getString('port') ?? prefs.getString('defaultPort');
  // await prefs.setString('port', port);
  //
  // // game defaults
  // await prefs.setString('defaultPlayerName', 'player');
  // String playerName =
  //     prefs.getString('playerName') ?? prefs.getString('defaultPlayerName');
  // await prefs.setString('playerName', playerName);
}

const String hardCodedPublicJsonBin = '5f8da6707243cd7e82510e39';
