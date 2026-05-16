import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pagame06/providers/game_provider.dart';
import 'package:pagame06/screens/home.dart';
import 'package:pagame06/utils/sounds.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('gameBox');
  await Sounds.initialize();

  await Flame.device.fullScreen();
  await Flame.device.setPortrait();

  runApp(
    ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thần Nông',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'MyFont',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightGreen.shade600,
          primary: Colors.green.shade800,
          secondary: Colors.blue.shade800,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
          },
        ),
      ),
      home: HomeScreen(),
    );
  }
}
