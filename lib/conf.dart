import 'dart:io';
import 'dart:convert';

import 'package:global_configuration/global_configuration.dart';
import 'package:foldest/rule.dart';
import 'package:path_provider/path_provider.dart';

const String _confPath = "assets/cfg/conf.json";

class Conf {
  String operatingDir;
  bool enableTrash;
  int threshTrash;
  List<Rule> rulesList;

  // Conf(this.operatingDir, this.rulesList,
  //     [this.enableTrash = false, this.threshTrash = 30]);

  /// deep copy
  Conf(Conf confIn)
      : operatingDir = confIn.operatingDir,
        rulesList = List.empty(growable: true),
        enableTrash = confIn.enableTrash,
        threshTrash = confIn.threshTrash {
    rulesList.addAll(confIn.rulesList);
  }

  Conf.withGlobalConfiguration()
      : operatingDir = "",
        rulesList = List.empty(growable: true),
        enableTrash = false,
        threshTrash = 30 {
    Map<String, dynamic> appConfig = GlobalConfiguration().appConfig;
    operatingDir = appConfig["operatingDir"] ?? "";
    for (Map<String, dynamic> map in appConfig["rules"]) {
      rulesList.add(Rule.withMap(map));
    }

    enableTrash = appConfig["trash"]["enable"] ?? false;
    threshTrash = appConfig["trash"]["thresh"] ?? 30;
  }
}

/// save conf to conf.json and re-read to GlobalConfiguration
saveConf(Conf confTmp, String appPath) {
  Map<String, dynamic> _outJson = {};

  _outJson["operatingDir"] = confTmp.operatingDir;
  _outJson["trash"] = {
    "enable": confTmp.enableTrash,
    "thresh": confTmp.threshTrash
  };

  List<Map<String, dynamic>> _rulesJson = List.empty(growable: true);
  for (Rule r in confTmp.rulesList) {
    Map<String, dynamic> _ruleJson = {};
    _ruleJson["name"] = r.name;
    _ruleJson["enable"] = r.enable;
    _ruleJson["regex"] = r.regex;
    _ruleJson["minSize"] = r.minSize;
    _ruleJson["maxSize"] = r.maxSize;
    _ruleJson["lastAccess"] = r.lastAccess;
    _ruleJson["priority"] = r.priority;
    _rulesJson.add(_ruleJson);
  }
  _outJson["rules"] = _rulesJson;

  File _jsonFile = File(appPath + _confPath);
  if (!_jsonFile.existsSync()) {
    _jsonFile.createSync(recursive: true);
  }
  _jsonFile.writeAsString(jsonEncode(_outJson));
}
