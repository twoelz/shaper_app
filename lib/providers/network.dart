import 'dart:async';
import 'dart:convert';
// TODO: try using dart:html to build a Web-WebSocket
// import 'dart:html' hide Platform;
import 'dart:io' as DartIO;
import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:universal_io/prefer_universal/io.dart' hide WebSocket;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:uuid/uuid.dart';

import 'package:shaper_app/main.dart';
import 'package:shaper_app/providers/config.dart';

// TODO: check if this cross-reference will not break things
import 'package:shaper_app/providers/client.dart';

import 'package:shaper_app/data/streams.dart';
import 'package:shaper_app/widgets/generic.dart';

Future<String> getPublicIP() async {
  try {
    const url = 'https://api.ipify.org';
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // The response body is the IP in plain text, so just
      // return it as-is.
      return response.body;
    } else {
      // The request failed with a non-200 code
      // The ipify.org API has a lot of guaranteed uptime
      // promises, so this shouldn't ever actually happen.
      print(response.statusCode);
      print(response.body);
      return null;
    }
  } catch (e) {
    // Request failed due to an error, most likely because
    // the phone isn't connected to the internet.
    print(e);
    return null;
  }
}

class NetworkMod with ChangeNotifier {
  ConfigMod configMod;

  // TODO: check if this cross-reference will not break things
  ClientMod clientMod;

  var channel;
  var connected = false;
  var internetConnected = false;
  var internetConnectionType = ''; // '' or wifi or mobile
  String publicIP;

  // // TODO: use vars below

  List<String> experimenters;
  List<String> experimentersValid;
  List<String> experimentersInvalid;
  var record = Map();

  String connectAttemptState = 'set';

  // choose host variables
  String previousIp;
  String previousPort;
  var chooseHost = false;
  List<String> multiHost = ['', ''];

  // TODO: check if below needed (not used now)
  var nameHost = '';

  // battery vars
  Battery _battery = Battery();
  BatteryState batteryState;
  var batteryStateSubscription;
  String batteryStateString;
  int batteryLevel;

  final uniqueId = Uuid().v4();

  Future<int> getBatteryLevel() async {
    return await _battery.batteryLevel;
  }

  void checkInternet(ConnectivityResult result) async {
    var connectionTypeChanged = false;
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      internetConnectionType = 'wifi';
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          internetConnected = true;
        }
      } on SocketException catch (_) {
        print('internet is not connected');
        internetConnected = false;
      }
    } else {
      var connectivityResult =
          result ?? await (Connectivity().checkConnectivity());

      if (connectivityResult == ConnectivityResult.none) {
        internetConnected = false;
      } else {
        internetConnected = true;
      }

      if (connectivityResult == ConnectivityResult.mobile) {
        if (!(internetConnectionType == 'mobile')) {
          internetConnectionType = 'mobile';
          connectionTypeChanged = true;
        }
      } else if (connectivityResult == ConnectivityResult.wifi) {
        if (!(internetConnectionType == 'wifi')) {
          internetConnectionType = 'wifi';
          connectionTypeChanged = true;
        }
      } else {
        internetConnectionType = '';
      }
    }
    if (internetConnected && (connectionTypeChanged || publicIP == null)) {
      publicIP = await getPublicIP();
    }
    notifyListeners();
  }

  NetworkMod() {
    if (Platform.isAndroid || Platform.isIOS || kIsWeb) {
      // TODO: subscribe to listen internet connectivity
      print('should subscribe to check internet');
    } else {
      Timer.periodic(
          const Duration(seconds: 10), (Timer t) => checkInternet(null));
    }
    // TODO: check if this is needed (and if not, what use this is)
    checkInternet(null);
    // Timer(const Duration(seconds: 1), () => findInternetServer());
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        batteryStateSubscription =
            battery.onBatteryStateChanged.listen((BatteryState state) {
          batteryState = state;
          batteryStateString = batteryState.toString().split('.').last;
          notifyListeners();
        });
      } catch (e) {
        print('could not listen to battery state changed');
        print(e);
      }
    }
  }

  @override
  void dispose() {
    print('NetworkMod dispose called');
    super.dispose();
    // TODO: check if this cancel works and if the subscription can be used again
    if (!Platform.isLinux) {
      try {
        batteryStateSubscription.cancel();
      } catch (e) {
        print('could not cancel subscription to listen battery state changed');
        print(e);
      }
    }
  }

  Future<void> closeGameStreamController() async {
    try {
      gameStreamController.close(); //Streams must be closed when not needed
    } on Exception catch (_) {
      print('could not close gameStreamController');
    }

    // reset
    gameStreamController = StreamController<Map<String, dynamic>>();
  }

  Future<void> closeChatMessageStreamController() async {
    try {
      chatMessageStreamController.close();
    } on Exception catch (_) {
      print('could not close chatMessageStreamController');
    }

    // reset
    chatMessageStreamController = StreamController<ChatMessage>();
  }

  void findInternetServer() {
    print('looking for server');
    // TODO: find the server
  }

  void consume(message) {
    final Map<String, dynamic> data = json.decode(message);
    if (data.containsKey('game data')) {
      gameStreamController.sink.add(data);
    } else if (data.containsKey('type')) {
      switch (data['type']) {
        //
        // When the user sends the "join" action, he provides a name.
        // Let's record it and as the player has a name, let's
        // broadcast the list of all the players to everyone
        //
        case 'configs':
          configMod.setServerConfigs(
            data['exp'],
            data['s_msg'],
            data['server'],
          );
          return;
        case 'accept player':
          print('player accepted: ${data['player']}');
          configMod.playerNumber = data['player'];
          return;
        case 'error':
          print(data['message']);
          return;
        case 'print':
          print(data['message']);
          return;
        default:
          print('invalid network data received: $data');
      }
    } else {
      print('invalid unknown data received: $data');
    }
  }

  void disconnect() async {
    print('disconnecting');

    try {
      await channel.sink.add('{"action":"disconnect"}');
    } catch (e) {
      print(e);
    }
    try {
      await closeChatMessageStreamController();
    } catch (e) {
      print(e);
    }
    try {
      await closeGameStreamController();
    } catch (e) {
      print(e);
    }
    try {
      await channel.sink.close(status.normalClosure);
    } catch (e) {
      print(e);
    }

    connected = false;
    channel = null;
    notifyListeners();
  }

  void nextAttempt() {
    print('nextAttempt - B4:$connectAttemptState');
    if (connectAttemptState == 'set') {
      connectAttemptState = 'private';
    } else if (connectAttemptState == 'private') {
      connectAttemptState = 'public';
    } else if (connectAttemptState == 'public') {
      connectAttemptState = 'done';
    }
    print('nextAttempt - After:$connectAttemptState');
  }

  Future<void> connect(Function confirmConnectedCallback,
      Function connectionFailedCallback) async {
    if (connected) {
      // TODO: do something about this error
      print('ERROR: should not try to connect. Connected already');
      return;
    }

    if (connectAttemptState == 'set') {
      await connectSet(confirmConnectedCallback, connectionFailedCallback);
    } else if (connectAttemptState == 'private') {
      await connectPrivate(confirmConnectedCallback, connectionFailedCallback);
    } else if (connectAttemptState == 'public') {
      await connectPublic(confirmConnectedCallback, connectionFailedCallback);
    } else if (connectAttemptState == 'done') {
      connectionFailedCallback();
      return;
    } else {
      print('invalid state for connectAttemptState: $connectAttemptState');
      throw Exception('Invalid state for connectAttemptState');
    }

    // await myWebSocketConnection(
    //     ip: ip,
    //     port: port,
    //     confirmConnectedCallback: confirmConnectedCallback,
    //     connectionFailedCallback: connectionFailedCallback);

    // notifyListeners();
  }

  Future<void> connectSet(Function confirmConnectedCallback,
      Function connectionFailedCallback) async {
    print('trying connectSet');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString('ip') ?? prefs.getString('defaultIp');
    await prefs.setString('ip', ip);
    String port = prefs.getString('port') ?? prefs.getString('defaultPort');
    await prefs.setString('port', port);

    previousIp = ip;
    previousPort = port;
    await myWebSocketConnection(
        ip: ip,
        port: port,
        confirmConnectedCallback: confirmConnectedCallback,
        connectionFailedCallback: connectionFailedCallback);
  }

  Future<void> connectPrivate(Function confirmConnectedCallback,
      Function connectionFailedCallback) async {
    print('trying connectPrivate');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!(prefs.containsKey('announceIpBin') ||
        prefs.containsKey('announceIpKey'))) {
      print("didn't find private bin and/or key");
      connectionFailedCallback();
      return;
    }

    final privateAnnounceUrl =
        'https://api.jsonbin.io/v3/b/${prefs.getString('announceIpBin')}/latest';
    print('privateAnnounceUrl: ${prefs.getString('announceIpKey')}');
    await http.get(privateAnnounceUrl, headers: {
      'X-Master-key': prefs.getString('announceIpKey')
    }).then((response) async {
      print('private bin response received');
      final Map<String, dynamic> responseJson = jsonDecode(response.body);
      print('responseJson from privateBin:');
      print(responseJson);
      if (responseJson.containsKey('record')) {
        final Map<String, dynamic> privateData = responseJson['record'];
        String myIp = privateData['ip'];
        String myPort = privateData['port'];
        if (myIp == publicIP) {
          print('connecting to local ip since running on same network');
          myIp = privateData['local ip'];
        }
        await myWebSocketConnection(
          ip: myIp,
          port: myPort,
          confirmConnectedCallback: confirmConnectedCallback,
          connectionFailedCallback: connectionFailedCallback,
        );
      } else {
        connectionFailedCallback();
      }
    }).catchError((e) {
      print('Error in accessing private bin: $e');
      connectionFailedCallback();
    });
  }

  // Future<void> connectPrivateProcess(Function confirmConnectedCallback,
  //     Function connectionFailedCallback) async {}

  Future<void> connectPublic(Function confirmConnectedCallback,
      Function connectionFailedCallback) async {
    print('trying connectPublic');
    experimenters = [];
    experimentersValid = [];
    experimentersInvalid = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final publicAnnounceUrl =
        'https://api.jsonbin.io/v3/b/${prefs.getString('publicBin')}/latest';
    print('publicAnnounceUrl: $publicAnnounceUrl');
    await http.get(
      publicAnnounceUrl,
      headers: {},
    ).then((response) async {
      print('public bin response received');
      var responseJson = jsonDecode(response.body);
      print('responseJson:');
      print(responseJson);
      record = responseJson['record'];
      experimenters = record.keys.toList();
      if (experimenters.length > 1) {
        // check each if active

        print('will start forEach experimenter');
        for (var i = 0; i < experimenters.length; i++) {
          String experimenter = experimenters[i];
          print(experimenter);
          String myIp = record[experimenter]['ip'];
          String myPort = record[experimenter]['port'];
          if (myIp == publicIP) {
            print('connecting to local ip since running on same network');
            myIp = record[experimenter]['local ip'];
          }
          print(
              'more than one. experimenter: $experimenter, ip:$myIp, port:$myPort');
          await myWebSocketCheckExperimenter(
            ip: myIp,
            port: myPort,
            confirmConnectedCallback: confirmConnectedCallback,
            connectionFailedCallback: connectionFailedCallback,
            experimenter: experimenter,
          );
        }
      }
    }).catchError((e) {
      connectionFailedCallback();
    });
  }

  Future<void> connectPublicProcess(Function confirmConnectedCallback,
      Function connectionFailedCallback) async {
    print('trying connectPublicProcess');
    experimenters = experimentersValid;
    experimentersValid = [];
    experimentersInvalid = [];

    // TODO: alert dialog to choose. right now it will choose the most recent one

    if (experimenters.length == 0) {
      print('no experimenters found');
      connectionFailedCallback();
    } else if (experimenters.length == 1) {
      var experimenter = experimenters[0];
      String ip = record[experimenter]['ip'];
      String port = record[experimenter]['port'];
      // if connection fails, connection attempts are done
      connectAttemptState = 'done';
      print('only one experiment. will try to connect now, no questions asked');
      previousIp = ip;
      previousPort = port;
      await myWebSocketConnection(
          ip: ip,
          port: port,
          confirmConnectedCallback: confirmConnectedCallback,
          connectionFailedCallback: connectionFailedCallback);
    } else {
      // more than 1 valid experimenters.
      // TODO: choice dialog to choose experiment. Right now it will just go with the more recent one.
      var chosenExperimenter = 0;
      for (var i = 1; i < experimenters.length; i++) {
        String experimenter = experimenters[i];
        if (DateTime(
          record[experimenter]['year'],
          record[experimenter]['month'],
          record[experimenter]['day'],
          record[experimenter]['hour'],
          record[experimenter]['minute'],
          record[experimenter]['second'],
        ).isBefore(DateTime(
          record[experimenters[chosenExperimenter]]['year'],
          record[experimenters[chosenExperimenter]]['month'],
          record[experimenters[chosenExperimenter]]['day'],
          record[experimenters[chosenExperimenter]]['hour'],
          record[experimenters[chosenExperimenter]]['minute'],
          record[experimenters[chosenExperimenter]]['second'],
        ))) {
          chosenExperimenter = i;
        }
      }
      String experimenter = experimenters[chosenExperimenter];
      String ip = record[experimenter]['ip'];
      String port = record[experimenter]['port'];
      // if connection fails, connection attempts are done
      connectAttemptState = 'done';
      previousIp = ip;
      previousPort = port;
      await myWebSocketConnection(
          ip: ip,
          port: port,
          confirmConnectedCallback: confirmConnectedCallback,
          connectionFailedCallback: connectionFailedCallback);
    }
  }

  Future<List<String>> getIpPortPrivateBin() async {
    return ['localhost', '500'];
  }

  Future<List<String>> getIpPortPublicBin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = 'not found';
    String port = 'not found';
    final publicAnnounceUrl =
        'https://api.jsonbin.io/v3/b/${prefs.getString('publicBin')}/latest';
    print('publicAnnounceUrl: $publicAnnounceUrl');

    var responseJsonReceived = false;
    var responseJson;

    try {
      final response = await http.get(
        publicAnnounceUrl,
        headers: {},
      );
      responseJson = jsonDecode(response.body);
      print('responseJson:');
      print(responseJson);
      responseJsonReceived = true;
    } on SocketException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    if (!responseJsonReceived) {
      // TODO: display a warning dialog
      print("Couldn't get server information online");
    } else {
      Map record = responseJson['record'];
      List<String> experimenters = record.keys.toList();

      // TODO: let the tasks run free and return on callback now
      if (experimenters.length > 1) {
        // check each if active
        List<String> validExperimenters = [];
        print('will start forEach experimenter');
        experimenters.forEach((experimenter) async {
          print(experimenter.toString());
          String myIp = record[experimenter]['ip'];
          String myPort = record[experimenter]['port'];
          print(
              'more than one. experimenter: $experimenter, ip:$myIp, port:$myPort');
          var connectionSuccess = false;
          print('will check for connection success. must wait');
          // TODO: FIX CALLBACKS
          connectionSuccess = await myWebSocketConnection(
              ip: myIp,
              port: myPort,
              confirmConnectedCallback: confirmConnected,
              connectionFailedCallback: confirmConnected);
          print('should have waited. success is $connectionSuccess');
          if (connectionSuccess) {
            print('connection success!');
            validExperimenters.add(experimenter);
            print('will close the channel');
            await channel.sink.close(status.normalClosure);
            print('will make channel = null');
            channel = null;
          } else {
            print('no success in connection...');
          }
        });
        print('should have now finished with each experimenter');

        experimenters = validExperimenters;
        print('valid experimenters = $experimenters');
      }
      if (experimenters.length < 1) {
        await showDialog(
            context: navigatorKey.currentContext,
            builder: (context) => AlertDialog(
                  title: Text('No game found.'),
                  content: Text(
                      'Check if the game is available with your game host.'),
                  actions: [
                    genericOkButton,
                  ],
                ));
        print('error: no experiments available');
      } else if (experimenters.length == 1) {
        // TODO: ALERT ANNOUNCING EXPERIMENTER
        ip = record[experimenters.first]['ip'];
        port = record[experimenters.first]['port'];
      } else {
        // TODO: DIALOG CHOOSING EXPERIMENTER
        chooseHost = true;
        multiHost = experimenters.toList();
        // TODO: reset multihost after connection

        // singleHost = experimenters.first;
        notifyListeners();
        // var response = await showDialog(
        //     context: navigatorKey.currentContext,
        //     builder: (context) => AlertDialog(
        //           title: Text('Game found'),
        //           content: Text('Host name is: $singleHost.'),
        //           actions: [
        //             genericOkButton,
        //           ],
        //         ));

        // TODO: return something that makes the program stop and wait for choice
        ip = record[experimenters.first]['ip'];
        port = record[experimenters.first]['port'];
      }

      // // flags
      // String ip = responseJson['record']['ip'];
      // String port = responseJson['record']['port'];
    }

    // PRINTED:
    // {record: {ip: 213.127.44.103,
    //           port: 8766},
    //  metadata: {id: 5f87b0d7302a837e95796d8b,
    //             private: true,
    //             createdAt: 2020-10-15T02:15:51.363Z,
    //             collectionId: 5f86fdea7243cd7e824f255d}}

    // String myUrl =

    print('public ip $ip, public port $port');
    return [ip, port];
  }

  Future<IOWebSocketChannel> getIOWebSocketChannel(DartIO.WebSocket ws) async {
    print('INSIDE getIOWebSocketChannel now');
    return IOWebSocketChannel(ws);
  }

  List<String> getAddressAndChannel(String ip, String port) {
    var myWebSocketAddress = 'error';
    var myWebSocketChannel = 'error';
    if (kIsWeb) {
      myWebSocketAddress = 'ws://$ip:$port';
      myWebSocketChannel = 'WebSocketChannel';
    } else if (Platform.isAndroid) {
      String androidIp;
      if (ip == 'localhost') {
        // android emulator use 10.0.2.2 as localhost alias.
        androidIp = '10.0.2.2';
      } else {
        androidIp = ip;
      }
      myWebSocketAddress = 'ws://$androidIp:$port';
      myWebSocketChannel = 'IOWebSocketChannel';
    } else if (Platform.isIOS || Platform.isMacOS) {
      print('Apple platforms are not implemented yet');
    } else if (Platform.isLinux || Platform.isWindows) {
      myWebSocketAddress = 'ws://$ip:$port';
      myWebSocketChannel = 'IOWebSocketChannel';
    } else {
      print('ERROR: Unknown platform');
    }
    return [myWebSocketAddress, myWebSocketChannel];
  }

  Future myWebSocketCheckExperimenter(
      {String ip,
      String port,
      Function confirmConnectedCallback,
      Function connectionFailedCallback,
      String experimenter}) async {
    print('inside myWebSocketCheckExperimenter-$ip-$port');

    var connectionError = '';

    List<String> addressAndChannel = getAddressAndChannel(ip, port);
    String myWebSocketAddress = addressAndChannel[0];
    String myWebSocketChannel = addressAndChannel[1];
    if (myWebSocketChannel == 'error') {
      return;
    }

    if (myWebSocketChannel == 'IOWebSocketChannel') {
      // var result;
      await DartIO.WebSocket.connect(
        '$myWebSocketAddress/',
      ).then((ws) async {
        print('ws connected and now will add experimenter and close ws');
        ws.close(status.normalClosure);
        experimentersValid.add(experimenter);
        if (experimenters.length ==
            experimentersInvalid.length + experimentersValid.length) {
          print('checked all experimenters');
          await connectPublicProcess(
              confirmConnectedCallback, connectionFailedCallback);
        }
      }).catchError((e) async {
        experimentersInvalid.add(experimenter);
        connectionError = e.toString();
        print('did not find experimenter $experimenter: $connectionError');
        if (experimenters.length ==
            experimentersInvalid.length + experimentersValid.length) {
          await connectPublicProcess(
              confirmConnectedCallback, connectionFailedCallback);
        }
      });
    } else if (myWebSocketChannel == 'WebSocketChannel') {
      // TODO: fix old implementation for WebClient
      connectionError = 'WebSocketChannel not implemented';
      print(connectionError);
    } else {
      connectionError =
          'Error! Unknown WebSocketChannel type: $myWebSocketChannel';
      print(connectionError);
      connected = false;
    }
  }

  Future myWebSocketConnection(
      {String ip,
      String port,
      Function confirmConnectedCallback,
      Function connectionFailedCallback}) async {
    print('inside myWebSocketConnection-$ip-$port');

    List<String> addressAndChannel = getAddressAndChannel(ip, port);
    String myWebSocketAddress = addressAndChannel[0];
    String myWebSocketChannel = addressAndChannel[1];
    if (myWebSocketChannel == 'error') {
      connectionFailedCallback();
      return;
    }

    var connectionError = '';

    // bool myWebSocketConnected;
    print(
        'inside myWebSocketConnection-$ip-$port  ___B4 Trying WebSocket.connect');

    print('myWebSocketAddress: $myWebSocketAddress');
    if (myWebSocketChannel == 'IOWebSocketChannel') {
      // var result;
      await DartIO.WebSocket.connect(
        '$myWebSocketAddress/',
      ).timeout(Duration(seconds: 5)).then((ws) async {
        print('ws connected and now will call confirmConnectedCallback');
        confirmConnectedCallback(ws, myWebSocketChannel);
      }).catchError((e) {
        print("Error connecting");
        connectionError = e.toString();
        print('error in connection attempt: $connectionError');
        connectionFailedCallback();
      });
    } else if (myWebSocketChannel == 'WebSocketChannel') {
      // TODO: fix old implementation for WebClient
      connectionError = 'WebSocketChannel not implemented';
      print(connectionError);
    } else {
      connectionError =
          'Error! Unknown WebSocketChannel type: $myWebSocketChannel';
      print(connectionError);
      connected = false;
    }

    print('GOT TO THE END OF myWebSocketConnection');
  }

  // ws argument not type defined so it accepts a html WebSocket or an io one
  Future<void> confirmConnected(ws, String myWebSocketChannel,
      Function clientStartListeningCallback) async {
    // set game variables
    connected = true;

    if (myWebSocketChannel == 'IOWebSocketChannel') {
      channel = IOWebSocketChannel(ws);
    } else {
      // TODO: add the web version
      print('BUG: web socket not implemented yet');
    }
    // start listening to server
    await channel.stream.listen((message) {
      consume(message);
    }, onDone: () {
      print('connection aborted');
      connected = false;
      return false;
    }, onError: (e) async {
      print('server error on channel.stream.listen: $e');
      disconnect();
      return false;
    }, cancelOnError: true);

    if (connected) {
      print('sending player name to server');
      // connected now. send name, uniqueId and version
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await channel.sink.add(jsonEncode(
          [prefs.getString('playerName'), uniqueId, configMod.version]));

      // TODO: listen later if confirm player is in?
      clientStartListeningCallback();
    }
    notifyListeners();
  }

  void sendChatMessageToServer(String message) async {
    await channel.sink.add('__chat__$message');
  }
}
