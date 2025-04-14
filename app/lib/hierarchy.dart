import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data.dart';
import 'main.dart';

class HierarchyPanel extends StatelessWidget {
  const HierarchyPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final ThemeData theme = Theme.of(context);
    final headerStyle = theme.textTheme.titleMedium;
    final zoneNameStyle = theme.textTheme.headlineSmall;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text("Hierarchy", style: headerStyle),
        Expanded(
          child: ListView.separated(
            itemCount: appState.getZoneCount(),
            separatorBuilder: (BuildContext context, int i) {
              return SizedBox(height: 5);
            },
            itemBuilder: (BuildContext context, int i) {
              final Zone z = appState.getZone(i);
              return Container(
                color: z.color,
                child: Row(
                  children: [
                    Expanded(
                      child: Text("${z.name} : ${z.id}", style: zoneNameStyle),
                    ),
                    IconButton(
                      icon: Icon(
                        appState.getZone(i).isVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        appState.toggleZoneVisiblity(i);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: theme.colorScheme.error),
                      onPressed: () {
                        appState.removeZone(i);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          color: theme.colorScheme.primaryContainer,
          child: Row(
            children: [
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    int maxId = 0;
                    List<Zone> zones = appState.getZonesCopy();
                    for (Zone z in zones) {
                      maxId = max(maxId, z.id);
                    }

                    //add default zone
                    appState.addZone(
                      Zone(
                        name: "NewZone",
                        id: maxId + 1,
                        points: [
                          Vector2d(0, 0),
                          Vector2d(0, 3),
                          Vector2d(2.598, 1.5),
                        ],
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
