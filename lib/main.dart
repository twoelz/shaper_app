import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:universal_io/io.dart' show Platform;
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'package:shaper_app/providers/config.dart';
import 'package:shaper_app/providers/network.dart';
import 'package:shaper_app/providers/client.dart';
import 'package:shaper_app/screens/config_info_screen.dart';
import 'package:shaper_app/screens/connect_screen.dart';
import 'package:shaper_app/screens/game_screen.dart';
// TODO: remove this import below (shared_preferences)
import 'package:shared_preferences/shared_preferences.dart';

// for navigation without context: start_
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// _end

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO remove clear here
  final pref = await SharedPreferences.getInstance();
  await pref.clear();

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
          child: (Platform.isAndroid || Platform.isIOS)
              ? MobileVersionApp()
              : RegularApp(),
        ),
      ),
    );
  }
}

class MobileVersionApp extends StatelessWidget {
  // const MyMobileMaterialApp({
  //   Key key,
  // }) : super(key: key);

  // it just adds a way to tap out of keyboard
  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(child: RegularApp());
  }
}

class RegularApp extends StatelessWidget {
  // const MyMaterialApp({
  //   Key key,
  // }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shaper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: (Platform.isAndroid || Platform.isIOS)
            // rescale text on Mobile version
            ? Theme.of(context).textTheme.apply(
                  fontSizeFactor: 0.8,
                  fontSizeDelta: 0.0,
                )
            // rescale text on Desktop version
            : Theme.of(context).textTheme.apply(
                  fontSizeFactor: 1.0,
                  fontSizeDelta: 0.0,
                ),
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
    );
  }
}
