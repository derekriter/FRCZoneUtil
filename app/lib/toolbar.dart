import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data.dart';
import 'main.dart';

class ToolbarPanel extends StatelessWidget {
  const ToolbarPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: OutlinedButton(
            onPressed: () async {
              if (appState.zones.isEmpty) {
                _displayAlert(
                  context: context,
                  title: "What were you hoping to accomplish?",
                  body: "You can't save nothing. Try actually using the app",
                );
                return;
              }

              final buff = StringBuffer("[\n");
              for (int i = 0; i < appState.zones.length; i++) {
                Zone z = appState.zones[i];
                /*4 space indents*/
                buff.write("    ${z.toJSON()}");

                if (i == appState.zones.length - 1) {
                  buff.write("\n]\n");
                } else {
                  buff.write(",\n");
                }
              }

              String? outputFile = await FilePicker.platform.saveFile(
                fileName: "map.json" /*suggested filename*/,
              );
              if (outputFile == null) {
                /*users closed file picker*/
                return;
              }

              final file = File(outputFile);
              /*writeAsString automatically opens and closes the file*/
              file.writeAsString(buff.toString(), mode: FileMode.write);
            },
            child: Text("Save As"),
          ),
        ),
        Expanded(
          flex: 1,
          child: OutlinedButton(onPressed: () {}, child: Text("Open")),
        ),
      ],
    );
  }

  void _displayAlert({
    required BuildContext context,
    String? title,
    String? body,
  }) {
    showDialog<void>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: title == null ? null : Text(title),
            content: body == null ? null : Text(body),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
    );
  }
}
