import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foldest/rule.dart';
import 'package:foldest/widgets/drawer.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:global_configuration/global_configuration.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:foldest/conf.dart';
import 'package:permission_handler/permission_handler.dart';

const double _buttonWidth = 80;
const double _buttonHeight = 40;
const Size _buttonSize = Size(_buttonWidth, _buttonHeight);

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static Conf confTmp = Conf.withGlobalConfiguration();

  @override
  Widget build(BuildContext context) {
    print("build: confTmp.threshTrash is \"${confTmp.threshTrash}\"");
    bool isReset = true;

    List<Widget> buildListTiles() {
      List<Widget> _listTiles = [
        ListTile(
          title: TextFormField(
            controller: TextEditingController(text: confTmp.operatingDir),
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Operating Folder",
                labelStyle: TextStyle(fontSize: 24)),
            validator: (String? value) {
              if (value == null || !Directory(value).existsSync()) {
                return "Failed to verify the folder";
              } else {
                confTmp.operatingDir = value;
                return null;
              }
            },
            autovalidateMode: AutovalidateMode.always,
          ),
          trailing: IconButton(
              onPressed: () async {
                confTmp.operatingDir =
                    await selectPath() ?? confTmp.operatingDir;
                setState(() {});
              },
              icon: const Icon(Icons.folder_open)),
          horizontalTitleGap: 33,
        ),
        Divider(),
        ListTile(
          leading: const Icon(Icons.delete),
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
          trailing: Switch(
            value: confTmp.enableTrash,
            onChanged: (bool value) {
              setState(() {
                confTmp.enableTrash = value;
              });
            },
          ),
        ),
        ListTile(
          contentPadding: EdgeInsetsDirectional.only(
              start: 58, end: 85), // 54: Icon, 85: Switch
          // leading: Icon(Icons.date_range),
          title: TextFormField(
            controller:
                TextEditingController(text: confTmp.threshTrash.toString()),
            enabled: confTmp.enableTrash,
            decoration: const InputDecoration(
              icon: Icon(Icons.date_range),
              border: OutlineInputBorder(),
              labelText: "Threshold",
              suffixText: "days",
            ),
            autovalidateMode: AutovalidateMode.always,
            validator: (String? value) {
              int threshTmp;
              if (value != null) {
                threshTmp = int.tryParse(value) ?? -1;
                if (threshTmp >= 0) {
                  if (threshTmp != confTmp.threshTrash) {}
                  return null;
                }
              }
              return "Threshold should be natural number";
            },
            onFieldSubmitted: (String value) {
              print(value);
              setState(() {
                confTmp.threshTrash = int.tryParse(value) ?? -1;
              });
            },
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
        Divider(),
      ];

      _listTiles.addAll(ruleCards());

      return _listTiles;
    }

    return Scaffold(
      body: Center(
        child: Column(children: [
          Expanded(
            child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(20.0),
                children: buildListTiles()),
          ),
          ButtonBar(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    confTmp.rulesList.add(Rule("", true, ""));
                  });
                },
                child: const Text("Add Rule"),
                style: TextButton.styleFrom(
                  fixedSize: _buttonSize,
                ),
              ),
              OutlinedButton(
                onPressed: null,
                child: const Text("Reset"),
                style: OutlinedButton.styleFrom(
                  fixedSize: _buttonSize,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  String appPath = "";
                  if (Platform.isAndroid) {
                    appPath =
                        (await getExternalStorageDirectory())?.path ?? appPath;
                  }
                  saveConf(confTmp, appPath);
                },
                child: const Text("Save"),
                style: ElevatedButton.styleFrom(
                  fixedSize: _buttonSize,
                ),
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

  /// prompt the FilesystemPicker to select a folder
  Future<String?> selectPath() async {
    Directory rootPath;
    if (Platform.isLinux || Platform.isMacOS) {
      rootPath = await getDownloadsDirectory() ?? Directory("/");
    } else if (Platform.isAndroid) {
      rootPath = Directory("/storage/emulated/0");
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
    return newPath;
  }

  List<Card> ruleCards() {
    List<Card> listCards = List.empty(growable: true);
    for (int i = 0; i < confTmp.rulesList.length; i++) {
      listCards.add(Card(
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsetsDirectional.all(10),
              title: TextField(
                controller: TextEditingController(text: confTmp.rulesList[i].name),
                decoration: const InputDecoration(
                  icon: Icon(Icons.rule_folder),
                  border: OutlineInputBorder(),
                  labelText: "Name",
                ),
                onChanged: (String value) {
                  if (value.isNotEmpty && value != confTmp.rulesList[i].name) {
                    setState(() {
                      confTmp.rulesList[i].name = value;
                    });
                  }
                },
              ),
              trailing: Switch(
                value: confTmp.rulesList[i].enable,
                onChanged: (bool value) {
                  setState(() {
                    confTmp.rulesList[i].enable = value;
                  });
                },
              ),
            ),
            ListTile(
              contentPadding:
                  const EdgeInsetsDirectional.only(start: 54, end: 80),
              title: TextField(
                controller: TextEditingController(text: confTmp.rulesList[i].regex),
                enabled: confTmp.rulesList[i].enable,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.code),
                  border: OutlineInputBorder(),
                  labelText: "Regular Expression",
                  hintText: "*.pdf,*.docx",
                  helperText: "Pattern that describes target files of the rule",
                  helperStyle: TextStyle(fontSize: 10, height: 0.2),
                ),
                onChanged: (String value) {
                  if (value.isNotEmpty && value != confTmp.rulesList[i].regex) {
                    confTmp.rulesList[i].regex = value;
                  }
                },
              ),
            ),
            ListTile(
              contentPadding: EdgeInsetsDirectional.only(start: 54, end: 80),
              title: TextFormField(
                controller: TextEditingController(text: confTmp.rulesList[i].minSize.toString()),
                enabled: confTmp.rulesList[i].enable,
                decoration: const InputDecoration(
                  icon: Icon(IconData(0xe744, fontFamily: "iconfont")),
                  border: OutlineInputBorder(),
                  labelText: "Min File Size",
                  helperText: "",
                  helperStyle: TextStyle(fontSize: 10, height: 0.2),
                  suffixText: "MB",
                ),
                autovalidateMode: AutovalidateMode.always,
                validator: (String? value) {
                  int minSize;
                  if (value != null) {
                    minSize = int.tryParse(value) ?? -1;
                  } else {
                    return "minSize should be integer";
                  }
                  if (minSize >= 0 &&
                      (confTmp.rulesList[i].maxSize == 0 || confTmp.rulesList[i].maxSize >= minSize)) {
                    confTmp.rulesList[i].minSize = minSize;
                    return null;
                  } else {
                    return "minSize should smaller than maxSize";
                  }
                },
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            ListTile(
              contentPadding: EdgeInsetsDirectional.only(start: 54, end: 80),
              title: TextFormField(
                controller: TextEditingController(text: confTmp.rulesList[i].maxSize.toString()),
                enabled: confTmp.rulesList[i].enable,
                decoration: const InputDecoration(
                  icon: Icon(
                    IconData(0xe743, fontFamily: "iconfont"),
                  ),
                  border: OutlineInputBorder(),
                  labelText: "Max File Size",
                  helperText: "Set 0 as infinity",
                  helperStyle: TextStyle(fontSize: 10, height: 0.2),
                  suffixText: "MB",
                ),
                autovalidateMode: AutovalidateMode.always,
                validator: (String? value) {
                  int maxSize;
                  if (value != null) {
                    maxSize = int.tryParse(value) ?? -1;
                  } else {
                    return "maxSize should be integer";
                  }
                  if (maxSize == 0 || maxSize >= confTmp.rulesList[i].minSize) {
                    confTmp.rulesList[i].maxSize = maxSize;
                    return null;
                  } else {
                    return "maxSize should larger than minSize, or 0 as infinity";
                  }
                },
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            ListTile(
              contentPadding: EdgeInsetsDirectional.only(start: 54, end: 80),
              title: TextFormField(
                controller:
                    TextEditingController(text: confTmp.rulesList[i].lastAccess.toString()),
                enabled: confTmp.rulesList[i].enable,
                decoration: const InputDecoration(
                  icon: Icon(Icons.date_range),
                  border: OutlineInputBorder(),
                  labelText: "Threshold",
                  helperText: "Only arrange files not used for threshold days",
                  helperStyle: TextStyle(fontSize: 10, height: 0.2),
                  suffixText: "days",
                ),
                autovalidateMode: AutovalidateMode.always,
                validator: (String? value) {
                  int lastAccess;
                  if (value != null) {
                    lastAccess = int.tryParse(value) ?? -1;
                    if (lastAccess >= 0) {
                      confTmp.rulesList[i].lastAccess = lastAccess;
                      return null;
                    }
                  }
                  return "Threshold should be natural number";
                },
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
      ));
    }
    return listCards;
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
