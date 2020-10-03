import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:universal_io/io.dart' show Platform;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shaper_app/providers/config.dart';

class NetworkMod with ChangeNotifier {
  ConfigMod configMod;
  var channel;
  var connected = false;

  StreamController<Map<String, dynamic>> gameStreamController;

  void closeGameStreamController() {
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
    closeGameStreamController();
    await channel.sink.add('{"action":"disconnect"}');
    await channel.sink.close();
    connected = false;
  }

  Future<bool> connect() async {
    if (connected) {
      return false;
    }

    // TODO: change the address to a set up server

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String ip = prefs.getString('ip') ?? prefs.getString('defaultIp');
    await prefs.setString('ip', ip);

    int port = prefs.getInt('port') ?? prefs.getInt('defaultPort');
    await prefs.setInt('port', port);

    // connect to WebSocket according to platform
    try {
      if (kIsWeb) {
        channel = WebSocketChannel.connect(Uri.parse("ws://$ip:$port"));
      } else if (Platform.isAndroid) {
        String androidIp;
        if (ip == 'localhost') {
          // android emulator use 10.0.2.2 as localhost alias.
          androidIp = '10.0.2.2';
        } else {
          androidIp = ip;
        }
        channel = IOWebSocketChannel.connect("ws://$androidIp:$port");
      } else if (Platform.isIOS || Platform.isMacOS) {
        print('Apple platforms are not implemented yet');
        return false;
      } else if (Platform.isLinux || Platform.isWindows) {
        channel = IOWebSocketChannel.connect("ws://$ip:$port");
      } else {
        print('ERROR: Unknown platform');
        return false;
      }
    } catch (e) {
      print("Error! can not connect WS connectWs " + e.toString());
      return false;
    }

    // connected now. send name
    channel.sink.add(prefs.getString('playerName'));

    // set game variables
    connected = true;
    gameStreamController = StreamController<Map<String, dynamic>>();

    // start listening to server
    channel.stream.listen((message) {
      consume(message);
    }, onDone: () {
      print('connection aborted');
      connected = false;
    }, onError: (e) {
      print('server error: $e');
      connected = false;
    });

    return connected;
  }

  void sendChatMessageToServer(String message) async {
    await channel.sink.add('{"action":"chat", "chat":"$message"}');
  }
}
