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
    // FutureBuilder<Conf> fetchConf = FutureBuilder<Conf>(
    //   future: readConfJson(),
    //   builder: (BuildContext context, AsyncSnapshot<Conf> snapshot) {
    //     confSaved = Conf("", List.empty(growable: true));
    //     print("Conf COnf CONf!");
    //     if (snapshot.hasData && snapshot.data != null) {
    //       confSaved = snapshot.data!;
    //     } else if (snapshot.hasError || snapshot.data == null) {
    //       // TODO: prompt to reset conf.json
    //     } else {}
    //     return Text("Foldest");
    //   },
    // );
    // fetchConf;
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
