import 'package:flutter/material.dart';
import 'package:foldest/widgets/drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: const Center(
          child: Text("Hello, world!"),
        ),
        appBar: AppBar(
          title: const Text('Home'),
        ),
        drawer: MyDrawer(),
    );
  }
}
