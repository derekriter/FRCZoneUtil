import 'package:equatable/equatable.dart';

class Vector2d extends Equatable {
  num x;
  num y;

  Vector2d(this.x, this.y);

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
