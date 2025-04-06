import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

Future<String> loadPackagedString(String path) {
  try {
    return rootBundle.loadString(path);
  } catch (_) {
    return Future.error(FileSystemException("Failed to load file", path));
  }
}

Future<Map<String, dynamic>> loadPackagedJSON(String path) async {
  final raw = await loadPackagedString(path).onError((err, _) {
    if (err == null) {
      return Future.error(
        FileSystemException(
          "Failed to load text from "
          "file",
          path,
        ),
      );
    }
    return Future.error(err);
  });

  return jsonDecode(raw) as Map<String, dynamic>;
}
