import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:universal_io/io.dart' show Platform;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:uuid/uuid.dart';

import 'package:shaper_app/providers/config.dart';
import 'package:shaper_app/data/streams.dart';

class NetworkMod with ChangeNotifier {
  ConfigMod configMod;
  var channel;
  var connected = false;
  var internetConnected = false;
  var internetConnectionType = 'wifi'; // either wifi or mobile

  // TODO: use vars below
  var lookingForPublicServerAnnouncement = false;
  var lookingForPrivateServerAnnouncement = false;
  var stopLookingForPublicServerAnnouncement = false;
  var stopLookingForPrivateServerAnnouncement = false;

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

  NetworkMod() {
    if (Platform.isAndroid || Platform.isIOS || kIsWeb) {
      // TODO: subscribe to listen internet connectivity
      print('should subscribe to check internet');
    } else {
      Timer(const Duration(seconds: 10), () => checkInternet(null));
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

  void findInternetServer() {
    print('looking for server');
    // TODO: find the server
  }

  void checkInternet(ConnectivityResult result) async {
    // try {
    //   final result = await InternetAddress.lookup('google.com');
    //   if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
    //     internetConnected = true;
    //     print('internet is connected');
    //   }
    // } on SocketException catch (_) {
    //   print('internet is not connected');
    //   internetConnected = false;
    // }

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      internetConnectionType = 'wifi';
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          internetConnected = true;
          print('internet is connected');
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
        internetConnectionType = 'mobile';
      } else if (connectivityResult == ConnectivityResult.wifi) {
        internetConnectionType = 'wifi';
      }
    }

    notifyListeners();
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
          configMod.setServerConfigs(data['exp'], data['s_msg']);
          return;
        case 'accept player':
          print('player accepted: ${data['player']}');
          configMod.playerNumber = data['player'];
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

  Future<void> connect(Function confirmConnectedCallback,
      Function connectionFailedCallback) async {
    // Wakelock.enable();

    if (connected) {
      print('connected already');
      return false;
    }

    // TODO: change the address to a set up server

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String ip = prefs.getString('ip') ?? prefs.getString('defaultIp');
    await prefs.setString('ip', ip);

    String port = prefs.getString('port') ?? prefs.getString('defaultPort');
    await prefs.setString('port', port);

    String myWebSocketChannel;
    String myWebSocketAddress;

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
      return false;
    } else if (Platform.isLinux || Platform.isWindows) {
      myWebSocketAddress = 'ws://$ip:$port';
      myWebSocketChannel = 'IOWebSocketChannel';
    } else {
      print('ERROR: Unknown platform');
      return false;
    }

    try {
      print('myWebSocketAddress: $myWebSocketAddress');
      if (myWebSocketChannel == 'IOWebSocketChannel') {
        await WebSocket.connect(
          '$myWebSocketAddress/',
        ).then((ws) {
          channel = IOWebSocketChannel(ws);
          confirmConnectedCallback();
        }).catchError((e) {
          print("Error connecting"); // Finally, callback fires.
          connectionFailedCallback(e);
          return;
        });

        print("SHOULD NOT PRINT THIS");

        // await WebSocket.connect(myWebSocketAddress).then((ws) {
        //   channel = IOWebSocketChannel(ws);
        //   confirmConnectedCallback();
        // });

        // channel = IOWebSocketChannel.connect(myWebSocketAddress);
        // Timer(const Duration(seconds: 5), () => confirmConnectedCallback());
      } else if (myWebSocketChannel == 'WebSocketChannel') {
        //  WebSocket.connect(myWebSocketAddress).then((ws) {
        //   // channel = WebSocketChannel(ws);
        //   ws.close();
        //   print('CHROME WS CLOSED. WILL TRY RECONNECT');
        //   // channel = WebSocketChannel.connect(Uri.parse(myWebSocketAddress));
        //   print('CHROME RECONNECTED');
        // });

        channel = WebSocketChannel.connect(Uri.parse(myWebSocketAddress));

        Timer(const Duration(seconds: 2), () => confirmConnectedCallback());
      } else {
        print('Error! Unknown WebSocketChannel type: $myWebSocketChannel');
        connected = false;
        return false;
      }
    } catch (e) {
      print("Error! cannot connect WebSocket " + e.toString());
      connected = false;
      // throw (e);
      return false;
    }
    notifyListeners();
  }

  Future<bool> confirmConnected() async {
    // set game variables
    connected = true;

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
      // connected now. send name
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await channel.sink
          .add(jsonEncode([prefs.getString('playerName'), uniqueId]));
    }
    notifyListeners();
    return connected;
  }

  void sendChatMessageToServer(String message) async {
    await channel.sink.add('__chat__$message');
  }
}
