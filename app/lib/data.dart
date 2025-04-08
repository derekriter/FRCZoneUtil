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
  Zone({
    required this.name,
    required this.id,
    required this.points,
    required this.color,
  });

  String name;
  int id;
  List<Vector2d> points;
  Color color;

  @override
  List<Object?> get props => [name, id, points, color];

  @override
  bool? get stringify => true;
}
