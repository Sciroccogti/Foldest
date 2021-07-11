import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foldest/widgets/drawer.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:global_configuration/global_configuration.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:foldest/conf.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static Conf confSaved = Conf.withGlobalConfiguration();
  Conf confTmp = confSaved;
  static String selectedDir = confSaved.operatingDir;

  @override
  Widget build(BuildContext context) {
    print("build: confTmp.operatingDir is \"${confTmp.operatingDir}\"");
    bool isReset = true;

    return Scaffold(
      body: Center(
        child: Column(children: [
          Expanded(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(20.0),
              children: [
                ListTile(
                  title: TextField(
                    controller: TextEditingController(text: selectedDir),
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "operating folder",
                        labelStyle: TextStyle(fontSize: 24)),
                    onSubmitted: (String value) async {
                      selectedDir = value;
                      verifyPath();
                    },
                  ),
                  trailing: IconButton(
                      onPressed: selectPath,
                      icon: const Icon(Icons.folder_open)),
                ),
                Divider(),
                SwitchListTile(
                  title: const Text("TrashBin"),
                  subtitle: const Text.rich(
                    TextSpan(children: <TextSpan>[
                      TextSpan(text: "Trash files not used for "),
                      TextSpan(
                          text: "threshold",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: " days."),
                    ]),
                  ),
                  value: confTmp.enableTrash,
                  onChanged: (bool value) {
                    setState(() {
                      confTmp.enableTrash = value;
                    });
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsetsDirectional.only(
                      start: 50, end: 68), // 68: the width of Icon
                  leading: Text("Threshold"),
                  title: TextField(
                    controller: TextEditingController(
                        text: confTmp.threshTrash.toString()),
                    enabled: confTmp.enableTrash,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      suffixText: "days",
                    ),
                    onSubmitted: (String value) async {
                      int threshTmp = int.tryParse(value) ?? -1;
                      if (threshTmp >= 0) {
                        confTmp.threshTrash = threshTmp;
                      }
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                Divider(),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsetsDirectional.all(10),
                        leading: Text("name"),
                        title: TextField(
                          controller: TextEditingController(
                              text: confTmp.threshTrash.toString()),
                          enabled: confTmp.enableTrash,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (String value) async {
                            // TODO
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          ButtonBar(
            children: [
              OutlinedButton(
                onPressed: null,
                child: const Text("Reset"),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20)),
              ),
              ElevatedButton(
                onPressed: () {
                  saveConf(confTmp);
                },
                child: const Text("Save"),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20)),
              ),
            ],
          ),
        ]),
      ),
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      drawer: MyDrawer(),
    );
  }

  void verifyPath() {
    if (!Directory(selectedDir).existsSync()) {
      setState(() {
        _falseDirDialog();
      });
    } else {
      setState(() {
        confTmp.operatingDir = selectedDir;
        print("verified!");
      });
    }
  }

  /// prompt the FilesystemPicker to select a folder
  void selectPath() async {
    Directory rootPath;
    if (Platform.isLinux || Platform.isMacOS) {
      rootPath = await getDownloadsDirectory() ?? Directory("/");
    } else {
      rootPath = await getExternalStorageDirectory() ?? Directory("/");
    }
    // null if not selected
    final newPath = await FilesystemPicker.open(
      title: 'Select a folder',
      context: context,
      rootDirectory: rootPath,
      fsType: FilesystemType.folder,
      pickText: 'Arrange this folder',
      folderIconColor: Colors.teal,
      requestPermission: () async => await requestPermission(),
    );
    if (newPath != null) {
      selectedDir = newPath;
      verifyPath();
    }
  }

  /// prompt a Dialog to reset or select the Dir
  Future<void> _falseDirDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Failed to verify the folder'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('You should check the path, or select by file browser')
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Select'),
              onPressed: () {
                Navigator.of(context).pop();
                selectPath();
              },
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Reset Path'))
          ],
        );
      },
    );
  }
}

Future<bool> requestPermission() async {
  bool isGranted = false;
  if (Platform.isAndroid) {
    if (await Permission.storage.request().isGranted &&
        await Permission.manageExternalStorage.request().isGranted) {
      isGranted = true;
    } else {
      final isShown = await Permission.storage.shouldShowRequestRationale &&
          await Permission.manageExternalStorage.shouldShowRequestRationale;
      if (isShown || await Permission.storage.isPermanentlyDenied) {
        openAppSettings();
      }
      isGranted = await Permission.storage.request().isGranted;
    }
  } else {
    // other platforms don't need permission
    isGranted = true;
  }
  return isGranted;
}
