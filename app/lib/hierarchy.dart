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
    final zoneNameStyle = theme.textTheme.bodyLarge;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 10),
        Text("Zones", style: headerStyle),
        Expanded(
          child:
              appState.zones.isEmpty
                  ? Center(
                    child: Text("Press the + button below to create a zone"),
                  )
                  : ListView.separated(
                    itemCount: appState.zones.length,
                    separatorBuilder: (BuildContext context, int i) {
                      return SizedBox(height: 5);
                    },
                    itemBuilder: (BuildContext context, int i) {
                      final Zone z = appState.zones[i];
                      final isSelected = appState.selectedZone == i;

                      late final Decoration? outline;
                      if (isSelected) {
                        outline = BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.outline,
                            width: 3,
                          ),
                        );
                      } else {
                        outline = null;
                      }

                      return InkWell(
                        onTap: () {
                          appState.selectZone(i);
                        },
                        child: Container(
                          color: z.color,
                          foregroundDecoration: outline,
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(z.name, style: zoneNameStyle),
                              ),
                              IconButton(
                                icon: Icon(
                                  appState.zones[i].isVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  appState.toggleZoneVisibility(i);
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: theme.colorScheme.error,
                                ),
                                onPressed: () {
                                  appState.removeZone(i);
                                },
                              ),
                            ],
                          ),
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
                    //add default zone
                    appState.addZone(
                      Zone(
                        name: "NewZone",
                        points: [
                          Vector2d(0, 0),
                          Vector2d(0, 3),
                          Vector2d(2.598, 1.5),
                        ],
                        color: Colors.grey,
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
