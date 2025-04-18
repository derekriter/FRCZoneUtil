import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'constants.dart' as constants;
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

      content = Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Name", style: theme.textTheme.labelLarge),
                      TextField(
                        controller: nameController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            constants.zoneNameAllowPattern,
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
                    crossAxisCount: constants.zoneColorChooserColumns,
                    shrinkWrap: true,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    children:
                        constants.zoneColorChooserOptions.map((Color col) {
                          return InkWell(
                            onTap: () {
                              appState.setZoneColor(
                                appState.selectedZone!,
                                col,
                              );
                            },
                            child: Container(color: col, width: 10, height: 10),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
            Text(
              "Points (${zone.points.length})",
              style: theme.textTheme.labelLarge,
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: false,
                itemCount: zone.points.length,
                itemBuilder: (BuildContext context, int i) {
                  final xController =
                      TextEditingController()
                        ..text = zone.points[i].x.toString();
                  final yController =
                      TextEditingController()
                        ..text = zone.points[i].y.toString();
                  final hasDeleteButtons = zone.points.length > 3;

                  return Row(
                    children: [
                      Text(i.toString(), style: theme.textTheme.labelLarge),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: xController,
                          inputFormatters: [constants.doubleFormatter],
                          onSubmitted:
                              (String newVal) =>
                                  _setPointX(i, appState, newVal),
                          onTapOutside:
                              (_) => _setPointX(i, appState, xController.text),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: yController,
                          inputFormatters: [constants.doubleFormatter],
                          onSubmitted:
                              (String newVal) =>
                                  _setPointY(i, appState, newVal),
                          onTapOutside:
                              (_) => _setPointY(i, appState, yController.text),
                        ),
                      ),
                      SizedBox(width: 10),
                      if (hasDeleteButtons)
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: theme.colorScheme.error,
                          ),
                          onPressed: () {
                            appState.removeZonePoint(appState.selectedZone!, i);
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Container(
              color: theme.colorScheme.primaryContainer,
              child: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  appState.addZonePoint(appState.selectedZone!, Vector2d(0, 0));
                },
              ),
            ),
          ],
        ),
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

  void _setPointX(int pointIndex, AppState appState, String newVal) {
    if (newVal.isEmpty) {
      appState.setZonePoint(appState.selectedZone!, pointIndex, x: 0);
      return;
    }

    try {
      appState.setZonePoint(
        appState.selectedZone!,
        pointIndex,
        x: double.parse(newVal),
      );
    } catch (err) {
      print(err);
    }
  }

  void _setPointY(int pointIndex, AppState appState, String newVal) {
    if (newVal.isEmpty) {
      appState.setZonePoint(appState.selectedZone!, pointIndex, y: 0);
      return;
    }

    try {
      appState.setZonePoint(
        appState.selectedZone!,
        pointIndex,
        y: double.parse(newVal),
      );
    } catch (err) {
      print(err);
    }
  }
}
