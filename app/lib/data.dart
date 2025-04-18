import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Vector2d extends Equatable {
  Vector2d(this.x, this.y);

  num x;
  num y;

  factory Vector2d.fromJSON(Map<String, dynamic> json) {
    final x = json["x"];
    if (x is! num) {
      throw FormatException(
        "Invalid JSON, required field 'x' not of type num in $json",
      );
    }

    final y = json["y"];
    if (y is! num) {
      throw FormatException(
        "Invalid JSON, required field 'y' not of type num in $json",
      );
    }

    return Vector2d(x, y);
  }

  @override
  List<Object?> get props => [x, y];

  @override
  bool? get stringify => true;
}

class Zone extends Equatable {
  Zone({required this.name, required this.points, required this.color})
    : isVisible = true;

  String name;
  List<Vector2d> points;
  Color color;
  bool isVisible;

  factory Zone.fromJSON(Map<String, dynamic> json) {
    final name = json["name"];
    if (name is! String) {
      throw FormatException(
        "Invalid JSON, required field 'name' not of type String in $json",
      );
    }

    final color = json["color"];
    if (color is! List<dynamic>) {
      throw FormatException(
        "Invalid JSON, required field 'color' not of type List<num> in $json",
      );
    }
    if (color.length != 3) {
      throw FormatException(
        "Invalid JSON, required field 'color' must have exactly 3 elements in"
        " $json",
      );
    }
    for (dynamic elem in color) {
      if (elem is! num) {
        throw FormatException(
          "Invalid JSON, required field 'color' not of type List<num> in $json",
        );
      }
    }
    final parsedColor = Color.fromRGBO(
      (color[0] as num).toInt(),
      (color[1] as num).toInt(),
      (color[2] as num).toInt(),
      1,
    );

    final points = json["points"];
    if (points is! List<dynamic>) {
      throw FormatException(
        "Invalid JSON, required field 'points' not of type List<num> in $json",
      );
    }
    if (points.length < 2) {
      throw FormatException(
        "Invalid JSON, required field 'points' must have at least 2 elements"
        " in $json",
      );
    }
    if (points.length % 2 != 0) {
      throw FormatException(
        "Invalid JSON, required field 'points' must have a length that is a "
        "multiple of 2 in $json",
      );
    }
    final parsedPoints = List<Vector2d>.generate((points.length / 2).toInt(), (
      int i,
    ) {
      final x = points[i * 2];
      final y = points[i * 2 + 1];

      if (x is! num || y is! num) {
        throw FormatException(
          "Invalid JSON, required field 'points' not of type List<num> in "
          "$json",
        );
      }

      return Vector2d(x, y);
    });

    return Zone(name: name, color: parsedColor, points: parsedPoints);
  }

  String toJSON() {
    late final String pArr;
    if (points.isNotEmpty) {
      final p = StringBuffer();
      for (Vector2d v in points) {
        /*only write 6 decimal places*/
        p.write("${v.x.toStringAsFixed(7)}, ${v.y.toStringAsFixed(7)}, ");
      }

      /*cut off last space and comma*/
      pArr = p.toString().substring(0, p.length - 2);
    } else {
      pArr = "";
    }

    final int argb = color.toARGB32();
    final int r = (argb >> 16) & 0xFF;
    final int g = (argb >> 8) & 0xFF;
    final int b = argb & 0xFF;

    return '{"name": "$name", "color": [$r, $g, $b], "points": [$pArr]}';
  }

  @override
  List<Object?> get props => [name, points, color, isVisible];

  @override
  bool? get stringify => true;
}
