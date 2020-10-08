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

import 'package:shaper_app/providers/config.dart';

class NetworkMod with ChangeNotifier {
  ConfigMod configMod;
  var channel;
  var connected = false;

  // StreamController<Map<String, dynamic>> gameStreamController;
  final gameStreamController = StreamController<Map<String, dynamic>>();

  Future<void> closeGameStreamController() async {
    try {
      gameStreamController.close(); //Streams must be closed when not needed
    } on Exception catch (_) {
      print('could not close gameStreamController');
    }
  }

  @override
  void dispose() {
    closeGameStreamController();
    super.dispose();
  }

  NetworkMod() {
    // TODO: check if this is needed (and if not, what use this is)
  }

  void consume(message) {
    final Map<String, dynamic> data = json.decode(message);
    if (data.containsKey('game data')) {
      gameStreamController.sink.add(data);
    }

    // gameStreamController.sink.add(data);
    else if (data.containsKey('type')) {
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
    await channel.sink.add('{"action":"disconnect"}');
    await closeGameStreamController();
    await channel.sink.close(status.normalClosure);
    connected = false;
    channel = null;
    notifyListeners();
  }

  Future<void> connect(Function confirmConnectedCallback) async {
    if (connected) {
      print('connected already');
      return false;
    }

    print('not connected, will try to connect');

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
      if (myWebSocketChannel == 'IOWebSocketChannel') {
        await WebSocket.connect(myWebSocketAddress).then((ws) {
          channel = IOWebSocketChannel(ws);
          confirmConnectedCallback();
        });
      } else if (myWebSocketChannel == 'WebSocketChannel') {
        // await WebSocket.connect(myWebSocketAddress).then((ws) {
        //   print('CHROME connected!');
        //   // channel = WebSocketChannel(ws);
        //   ws.close();
        //   print('CHROME WS CLOSED. WILL TRY RECONNECT');
        //   // channel = WebSocketChannel.connect(Uri.parse(myWebSocketAddress));
        //   print('CHROME RECONNECTED');
        // });

        channel = WebSocketChannel.connect(Uri.parse(myWebSocketAddress));

        new Timer(const Duration(seconds: 2), () => confirmConnectedCallback());
      } else {
        print('Error! Unknown WebSocketChannel type: $myWebSocketChannel');
        connected = false;
        return false;
      }
    } catch (e) {
      print("Error! can not connect WebSocket " + e.toString());
      connected = false;
      return false;
    }
    notifyListeners();
    print('so far it seems to have connected. waiting for the callback now');
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
      print('server error: $e');
      connected = false;
      await channel.sink.close();
      channel = null;
      return false;
    }, cancelOnError: true);

    print('still connected?');
    print('connected: $connected');

    if (connected) {
      print('sending player name to server');
      // connected now. send name
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await channel.sink.add(prefs.getString('playerName'));
    }
    notifyListeners();
    return connected;
  }

  void sendChatMessageToServer(String message) async {
    await channel.sink.add('{"action":"chat", "chat":"$message"}');
  }
}
