import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data.dart';

const List<String> mapLocations = [
  "res/Reefscape2025.json",
  "res/Crescendo2024.json",
];
const int defaultMap = 0; /*default to first map in list*/
const String appTitle = "FRC Zone Utility";
final ColorScheme colorScheme = ColorScheme.fromSeed(
  seedColor: Color.fromRGBO(0, 118, 40, 1.0),
);
const int jsonDoubleDecimalPlaces = 6; /*how many decimal places to use when
saving a double as json*/
const double mapPolygonWeight = 3;
const int mapPolygonAlpha = 64;
const double mapPolygonRadius = 5;
final Zone defaultNewZone = Zone(
  name: "NewZone",
  color: Colors.grey,
  points: [Vector2d(0, 0), Vector2d(0, 3), Vector2d(2.598, 1.5)],
);
final Pattern zoneNameAllowPattern = RegExp(
  r'[a-zA-Z0-9!@#$%^&*()-_=+\[\]{}\\|;:,.<>/?~` ]',
);
final int zoneColorChooserColumns = 3;
final List<Color> zoneColorChooserOptions = [
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.teal,
  Colors.blue,
  Colors.deepPurple,
  Colors.pink,
  Colors.grey,
];
final TextInputFormatter doubleFormatter = TextInputFormatter.withFunction((
  TextEditingValue oldValue,
  TextEditingValue newValue,
) {
  if (newValue.text.isEmpty) {
    return newValue; //allow deleting field
  }

  try {
    double.parse(newValue.text);
    //use new value
    return newValue;
  } catch (_) {
    //discard invalid value and use old one
    return oldValue;
  }
});
const String defaultSaveName = "map.json";
