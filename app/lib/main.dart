import 'package:app/field.dart';
import 'package:app/hierarchy.dart';
import 'package:app/properties.dart';
import 'package:app/toolbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'data.dart';

void main() async {
  //Set window title
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.setTitle("FRC Zone Utility");

  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: "FRC Zone Utility",
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color.fromRGBO(0, 118, 40, 1.0),
          ),
        ),
        home: const HomePage(),
      ),
    );
  }
}

class AppState extends ChangeNotifier {
  final List<Zone> _zones = [
    Zone(
      name: "Zone1",
      id: 0,
      points: [Vector2d(0, 0), Vector2d(0, 8.0518), Vector2d(17.54823, 8.0518)],
      color: Colors.blue,
    ),
    Zone(
      name: "Zone2",
      id: 3,
      points: [Vector2d(3, 2), Vector2d(11, 6), Vector2d(1, 7)],
      color: Colors.orange,
    ),
  ];

  void addZone(Zone z) {
    _zones.add(z);
    notifyListeners();
  }

  void removeZone(int index) {
    if (index < 0 || index >= _zones.length) {
      throw ArgumentError.value(index, "Argument out of bounds of array");
    }

    _zones.removeAt(index);
    notifyListeners();
  }

  Zone getZone(int index) {
    if (index < 0 || index >= _zones.length) {
      throw ArgumentError.value(index, "Argument out of bounds of array");
    }

    return _zones[index];
  }

  List<Zone> getZonesCopy() {
    return List<Zone>.from(_zones);
  }

  int getZoneCount() {
    return _zones.length;
  }

  void toggleZoneVisiblity(int index) {
    if (index < 0 || index >= _zones.length) {
      throw ArgumentError.value(index, "Argument out of bounds of array");
    }

    _zones[index].isVisible = !_zones[index].isVisible;
    notifyListeners();
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [ToolbarPanel(), Expanded(child: HierarchyPanel())],
            ),
          ),
          Expanded(
            flex: 7,
            child: Column(
              children: [
                Expanded(flex: 6, child: FieldPanel()),
                Expanded(flex: 4, child: PropertiesPanel()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
