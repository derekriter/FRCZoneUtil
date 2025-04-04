import 'dart:convert';

import 'package:flutter/services.dart';

Future<dynamic> loadJSON(String path) async {
  String raw = await rootBundle.loadString(path);
  return jsonDecode(raw);
}
