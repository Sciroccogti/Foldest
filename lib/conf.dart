import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:async';

import 'package:global_configuration/global_configuration.dart';

const String _confPath = "assets/cfg/conf.json";

class Rule {
  String name;
  String regex;
  String targetDir;
  int priority = -1; // default -1: lowest. 0: highest, 1: second highest
  int minSize = 0; // in MB, default 0. TODO: Uint?
  int maxSize = 0; // in MB, default 0: no limit
  int lastAccess = 30; // lastAccess day before today. default 30

  Rule(this.name, this.regex, this.targetDir,
      [this.minSize = 0,
      this.maxSize = 0,
      this.lastAccess = 30,
      this.priority = -1]);

  Rule.withMap(Map<String, dynamic> map)
      : name = map["name"],
        regex = map["regex"],
        targetDir = map["targetDir"] {
    minSize = map["minSize"] ?? 0; // if null then set to 0
    maxSize = map["maxSize"] ?? 0; // if null then set to 0
    lastAccess = map["lastAccess"] ?? 30;
    priority = map["priority"] ?? -1;
  }
}

class Conf {
  String operatingDir;
  bool enableTrash;
  int threshTrash;
  List<Rule> rulesList;

  Conf(this.operatingDir, this.rulesList,
      [this.enableTrash = false, this.threshTrash = 30]);

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

saveConf(Conf confTmp) {
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
    _ruleJson["regex"] = r.regex;
    _ruleJson["minSize"] = r.minSize;
    _ruleJson["maxSize"] = r.maxSize;
    _ruleJson["lastAccess"] = r.lastAccess;
    _ruleJson["targetDir"] = r.targetDir;
    _ruleJson["priority"] = r.priority;
    _rulesJson.add(_ruleJson);
  }
  _outJson["rules"] = _rulesJson;

  File _jsonFile = File(_confPath);
  _jsonFile.writeAsString(jsonEncode(_outJson));
}
