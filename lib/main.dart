import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:shaper_app/providers/config.dart';
import 'package:shaper_app/providers/network.dart';
import 'package:shaper_app/providers/client.dart';
import 'package:shaper_app/screens/config_info_screen.dart';
import 'package:shaper_app/screens/connect_screen.dart';
import 'package:shaper_app/screens/game_screen.dart';

// for navigation without context: start_
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// _end

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setDefaults();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Set landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return ChangeNotifierProvider<ConfigMod>(
      create: (context) => ConfigMod(),
      lazy: false,
      child: ChangeNotifierProxyProvider<ConfigMod, NetworkMod>(
        create: (context) => NetworkMod(),
        lazy: false,
        update: (context, configMod, networkMod) =>
            networkMod..configMod = configMod,
        child: ChangeNotifierProxyProvider<NetworkMod, ClientMod>(
          create: (context) => ClientMod(),
          lazy: false,
          update: (context, networkMod, clientMod) =>
              clientMod..networkMod = networkMod,
          child: MaterialApp(
            title: 'Shaper',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            // for navigation without context: start_
            navigatorKey: navigatorKey,
            // _end
            initialRoute: ConnectScreen.id,
            routes: {
              ConnectScreen.id: (context) => ConnectScreen(),
              ConfigInfoScreen.id: (context) => ConfigInfoScreen(),
              GameScreen.id: (context) => GameScreen(),
            },
          ),
        ),
      ),
    );
  }
}
