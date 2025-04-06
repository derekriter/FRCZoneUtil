import 'package:flutter/material.dart';

import 'field.dart';
import 'loader.dart';

class HierarchyPanel extends StatelessWidget {
  const HierarchyPanel({super.key});

  @override
  Widget build(BuildContext context) {
    loadPackagedJSON("fields/Reefscape2025.json")
        .then((json) {
          print(FieldData.fromJSON(json));
        })
        .onError((err, _) {
          print(err);
        });

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(onPressed: () {}, child: Text("Save As")),
            ),
            Expanded(
              flex: 1,
              child: OutlinedButton(onPressed: () {}, child: Text("Open")),
            ),
          ],
        ),
      ],
    );
  }
}
