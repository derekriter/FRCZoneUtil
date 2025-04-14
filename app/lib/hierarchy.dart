import 'package:flutter/material.dart';

class HierarchyPanel extends StatelessWidget {
  const HierarchyPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text("Hierarchy", style: headerStyle),
        Expanded(child: Placeholder()),
      ],
    );
  }
}
