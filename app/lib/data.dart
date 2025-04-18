import 'dart:ui';

import 'package:equatable/equatable.dart';

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
