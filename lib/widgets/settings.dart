import 'package:flutter/material.dart';
import 'package:foldest/widgets/drawer.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:foldest/conf.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void selectPath() async {
    Directory rootPath = await getDownloadsDirectory() ?? Directory("/");
    final path = await FilesystemPicker.open(
      title: 'Select a folder',
      context: context,
      rootDirectory: rootPath,
      fsType: FilesystemType.folder,
      pickText: 'Arrange this folder',
      folderIconColor: Colors.teal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Future<Conf> confReading = readConfJson();
    Conf conf;

    FutureBuilder<Conf> FetchConf = FutureBuilder<Conf> (
      future: confReading,
      builder: (BuildContext context, AsyncSnapshot<Conf> snapshot) {
        String operatingDir = "waiting...";

        if (snapshot.hasData && snapshot.data != null) {
          conf = snapshot.data!;
          operatingDir = conf.operatingDir;

        } else if (snapshot.hasError || snapshot.data == null) {
        } else {
        }
        return Center(
          child: Text(operatingDir),
        );
      },
    );

    return Scaffold(
      body: Center(
        child: Column(children: [
          const Text("SettingsPage!"),
          FetchConf,
        ]),
      ),
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      drawer: MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: selectPath,
        tooltip: 'Select operating folder',
        child: const Icon(Icons.folder_open),
      ),
    );
  }
}
