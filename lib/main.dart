import 'package:flutter/material.dart';
import 'package:foldest/widgets/home.dart';
import 'package:foldest/widgets/settings.dart';
import 'package:global_configuration/global_configuration.dart';

void main() async {
  runApp(const MyApp());
  await GlobalConfiguration().loadFromAsset("conf");
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Foldest", // used by the OS task switcher
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: <String, WidgetBuilder>{
        "/home": (BuildContext ctx) => const HomePage(),
        "/settings": (BuildContext ctx) => const SettingsPage(),
      },
    );
  }
}
