import 'package:flutter/material.dart';

import 'conf.dart';

class Rule {
  String name;
  bool enable;
  String regex;
  int priority = -1; // default -1: lowest. 0: highest, 1: second highest
  /// in MB, default 0. TODO: Uint?
  int minSize = 0;

  /// in MB, default 0: no limit
  int maxSize = 0;
  int lastAccess = 30; // lastAccess day before today. default 30

  Rule(this.name, this.enable, this.regex,
      [this.minSize = 0,
      this.maxSize = 0,
      this.lastAccess = 30,
      this.priority = -1]);

  Rule.withMap(Map<String, dynamic> map)
      : name = map["name"],
        enable = map["enable"],
        regex = map["regex"] {
    minSize = map["minSize"] ?? 0; // if null then set to 0
    maxSize = map["maxSize"] ?? 0; // if null then set to 0
    lastAccess = map["lastAccess"] ?? 30;
    priority = map["priority"] ?? -1;
  }
}
