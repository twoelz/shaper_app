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
    print('HELLO FROM NETWORKMODEL');
  }

  void consume(message) {
    final Map<String, dynamic> data = json.decode(message);
    gameStreamController.sink.add(data);
    if (data.containsKey('type')) {
      switch (data['type']) {
        //
        // When the user sends the "join" action, he provides a name.
        // Let's record it and as the player has a name, let's
        // broadcast the list of all the players to everyone
        //
        case 'configs':
          print('nothing here');
          configMod.setServerConfigs(data['exp'], data['s_msg']);
          return;
        case 'greeting':
          print(data['greeting']);
          return;
        case 'print':
          print(data['message']);
          return;
        default:
          gameStreamController.sink.add(data);
      }
    }
  }

  void disconnect() async {
    closeGameStreamController();
    print('disconnect stuff here');
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

    // ----ends here

    print('did error occur yet?');

    channel.sink.add(prefs.getString('playerName'));

    print('or we got it here?');

    connected = true;

    gameStreamController = StreamController<Map<String, dynamic>>();

    channel.stream.listen((message) {
      consume(message);
      print('CONNECTED YEAH!');
    }, onDone: () {
      print('connecting aborted');
      connected = false;
    }, onError: (e) {
      print('server error: $e');
      connected = false;
    });

    print('perhaps now');
    return connected;
  }
}
