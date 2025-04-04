import 'package:app/field.dart';
import 'package:flutter/material.dart';

class HierarchyPanel extends StatelessWidget {
  const HierarchyPanel({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: OutlinedButton(
                onPressed: () {
                  FieldData("fields/Reefscape2025.json");
                },
                child: Text("Open"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
