import 'dart:async';

import 'package:app/hierarchy.dart';
import 'package:app/properties.dart';
import 'package:app/toolbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'constants.dart';
import 'data.dart';
import 'field.dart';
import 'loader.dart';

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
  String _selectedMap = mapLocations[0]; /*default to first in list*/
  MapState _mapState = MapState.none;
  MapData? _mapData;

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

  void toggleZoneVisibility(int index) {
    if (index < 0 || index >= _zones.length) {
      throw ArgumentError.value(index, "Argument out of bounds of array");
    }

    _zones[index].isVisible = !_zones[index].isVisible;
    notifyListeners();
  }

  void setSelectedMap(String val) {
    if (!mapLocations.contains(val)) {
      throw ArgumentError.value(
        val,
        "Cannot set selectedMap to non-existant map",
      );
    }

    final bool updateDisplay = _selectedMap != val;
    _selectedMap = val;
    loadMapData();
    notifyListeners();
  }

  void setMapLoading() {
    _mapState = MapState.loading;
    _mapData = null;
    notifyListeners();
  }

  void setMapError() {
    _mapState = MapState.error;
    _mapData = null;
    notifyListeners();
  }

  void setMapSuccess(MapData data) {
    _mapState = MapState.success;
    _mapData = data;
    notifyListeners();
  }

  void loadMapData({bool first = false}) {
    if (first) {
      _mapState = MapState.loading;
      _mapData = null;
    } else if (_mapState != MapState.loading) {
      setMapLoading();
    }

    loadPackagedJSON(_selectedMap)
        .then((json) {
          try {
            MapData.fromJSON(json)
                .then((MapData data) {
                  setMapSuccess(data);
                })
                .onError((err, _) {
                  print(err);

                  setMapError();
                });
          } catch (err) {
            print(err);

            setMapError();
          }
        })
        .onError((err, _) {
          print(err);

          setMapError();
        });
  }

  MapState get mapState => _mapState;
  bool get hasMapData => _mapData != null;
  MapData? get mapData => _mapData;

  List<Zone> get zones => _zones;
  String get selectedMap => _selectedMap;
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (appState.mapState == MapState.none) {
      appState.loadMapData(first: true);
    }

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
