import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'data.dart';
import 'main.dart';

class PropertiesPanel extends StatelessWidget {
  const PropertiesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);

    late final String headerText;
    late final Widget content;
    if (!appState.hasSelectedZone) {
      headerText = "Properties";
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text("Select a zone to view its properties.")],
      );
    } else {
      final Zone zone = appState.zones[appState.selectedZone!];

      headerText = "Properties > ${zone.name}";

      final nameController = TextEditingController()..text = zone.name;

      content = Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name", style: theme.textTheme.labelLarge),
                    TextField(
                      controller: nameController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(
                            r'[a-zA-Z0-9!@#$%^&*()-_=+\[\]{}\\|;:,.<>/?~` ]',
                          ),
                        ),
                      ],
                      onSubmitted: (String newVal) {
                        appState.setZoneName(appState.selectedZone!, newVal);
                      },
                      onTapOutside: (_) {
                        appState.setZoneName(
                          appState.selectedZone!,
                          nameController.text,
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              SizedBox(
                width: 100,
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  children:
                      [
                        Colors.red,
                        Colors.orange,
                        Colors.yellow,
                        Colors.green,
                        Colors.blue,
                        Colors.purple,
                        Colors.pink,
                      ].map((Color col) {
                        return InkWell(
                          onTap: () {
                            appState.setZoneColor(appState.selectedZone!, col);
                          },
                          child: Container(color: col, width: 10, height: 10),
                        );
                      }).toList(),
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        Container(
          color: theme.colorScheme.primaryContainer,
          padding: EdgeInsets.all(4),
          child: Row(children: [Text(headerText)]),
        ),
        Expanded(child: content),
      ],
    );
  }
}
