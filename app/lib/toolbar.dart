import 'package:flutter/material.dart';

class ToolbarPanel extends StatelessWidget {
  const ToolbarPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
