import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:async';

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
}

/// Read Conf from `assets/conf.json`
///
/// Should judge whether operatingDir is ""
/// async constructor is not allowed
Future<Conf> readConfJson() async {
  // read json into String TODO: AssetBundle?
  String jsonString = await rootBundle.loadString("assets/conf.json");
  // json to List or Map
  final jsonMap = jsonDecode(jsonString);
  // store json List or Map
  List<Rule> rules = List.empty(growable: true);
  for (Map<String, dynamic> map in jsonMap["rules"]) {
    rules.add(Rule.withMap(map));
  }

  String operatingDir = jsonMap["operatingDir"] ?? "";
  bool trashEnable = jsonMap["trash"]["enable"] ?? false;
  int trashThresh = jsonMap["trash"]["thresh"] ?? 30;
  Conf conf = Conf(operatingDir, rules, trashEnable, trashThresh);
  return conf;
}
