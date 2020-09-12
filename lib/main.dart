import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:universal_io/io.dart' show Platform;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// generic channel, not initialized on any platform
var channel;

var connected = false;
var currentValue = 0;

void main() {
  print('hello');
  runApp(MyApp());
}

void connect() async {
  // TODO: change the address to a set up server

  if (kIsWeb) {
    print('hello from websocket trying to connect');
    channel = WebSocketChannel.connect(Uri.parse("ws://localhost:8765"));
  } else if (Platform.isAndroid) {
    // android emulator use 10.0.2.2 as localhost alias.
    channel = IOWebSocketChannel.connect("ws://10.0.2.2:8765");
  } else if (Platform.isIOS || Platform.isMacOS) {
    print('apple platforms are not implemented yet');
    return;
  } else if (Platform.isLinux || Platform.isWindows) {
    print('hello from win or linux build');
    channel = IOWebSocketChannel.connect("ws://localhost:8765");
  } else {
    print('WARNING: Unknown platform');
    return;
  }
  // ----ends here

  channel.sink.add("connected!");
  connected = true;
  channel.stream.listen((message) {
    print(message);
    consume(message);
  });
}

void consume(message) {
  final Map<String, dynamic> data = json.decode(message);
  if (data.containsKey('type')) {
    switch (data['type']) {
      //
      // When the user sends the "join" action, he provides a name.
      // Let's record it and as the player has a name, let's
      // broadcast the list of all the players to everyone
      //
      case 'state':
        currentValue = data['value'];
//         setState(() {
// //      _counter++;
//         });
    }
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Set landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return MaterialApp(
      title: 'UNT Meta Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'UNT Meta Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int player;
  var messageText = 'Get ready to login.';

  void _login() {
    connect();
    setState(() {
//      _counter++;
    });
  }

  void _plusClicked() {
    if (connected) {
      channel.sink.add('{"action":"plus"}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(
//        title: Text(widget.title),
//      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Get ready to login.',
            ),
            Text(
              'Current value: $currentValue',
            ),
            FlatButton(
              onPressed: _plusClicked,
              child: Text(
                "Add 1",
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _login,
        tooltip: 'login',
        child: Icon(Icons.person_add),
      ),
    );
  }
}
