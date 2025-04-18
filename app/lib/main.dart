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
  final List<Zone> _zones = [];
  String _selectedMap = mapLocations[0]; /*default to first in list*/
  MapState _mapState = MapState.none;
  MapData? _mapData;
  int? _selectedZone; //null means no field is selected

  void addZone(Zone z) {
    _zones.add(z);
    notifyListeners();
  }

  void removeZone(int index) {
    _zones.removeAt(index);

    if (_selectedZone != null) {
      if (index == _selectedZone) {
        _selectedZone = null;
      } else if (index < _selectedZone!) {
        _selectedZone = _selectedZone! - 1;
      }
    }

    notifyListeners();
  }

  void toggleZoneVisibility(int index) {
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

    _selectedMap = val;
    loadMapData();

    notifyListeners();
  }

  void loadMapData({bool first = false}) {
    if (first) {
      _mapState = MapState.loading;
      _mapData = null;
    } else if (_mapState != MapState.loading) {
      _setMapLoading();
    }

    loadPackagedJSON(_selectedMap)
        .then((json) {
          try {
            MapData.fromJSON(json)
                .then((MapData data) {
                  _setMapSuccess(data);
                })
                .onError((err, _) {
                  print(err);

                  _setMapError();
                });
          } catch (err) {
            print(err);

            _setMapError();
          }
        })
        .onError((err, _) {
          print(err);

          _setMapError();
        });
  }

  void selectZone(int zone) {
    _selectedZone = zone;
    notifyListeners();
  }

  void setZoneName(int index, String name) {
    _zones[index].name = name;
    notifyListeners();
  }

  void setZoneColor(int index, Color col) {
    _zones[index].color = col;
    notifyListeners();
  }

  void setZonePoint(int zone, int point, {double? x, double? y}) {
    if (x == null && y == null) {
      return;
    }

    final prev = _zones[zone].points[point];
    _zones[zone].points[point] = Vector2d(x ?? prev.x, y ?? prev.y);
    notifyListeners();
  }

  void addZonePoint(int zone, Vector2d point) {
    _zones[zone].points.add(point);
    notifyListeners();
  }

  void removeZonePoint(int zone, int point) {
    _zones[zone].points.removeAt(point);
    notifyListeners();
  }

  void resetWithNewZones(List<Zone> zones) {
    _selectedZone = null;
    _zones.clear();
    _zones.addAll(zones);
    notifyListeners();
  }

  List<Zone> get zones => _zones;
  String get selectedMap => _selectedMap;
  MapState get mapState => _mapState;
  bool get hasMapData => _mapData != null;
  MapData? get mapData => _mapData;
  bool get hasSelectedZone => _selectedZone != null;
  int? get selectedZone => _selectedZone;

  void _setMapLoading() {
    _mapState = MapState.loading;
    _mapData = null;
    notifyListeners();
  }

  void _setMapError() {
    _mapState = MapState.error;
    _mapData = null;
    notifyListeners();
  }

  void _setMapSuccess(MapData data) {
    _mapState = MapState.success;
    _mapData = data;
    notifyListeners();
  }
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
