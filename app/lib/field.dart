import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'math.dart';

class FieldPanel extends StatelessWidget {
  const FieldPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}

class FieldData extends Equatable {
  const FieldData({
    required this.imagePath,
    required this.fieldDimensions,
    String? displayName,
    this.fieldBoundingBox,
  }) : _displayName = displayName;

  final String imagePath;
  final Vector2d fieldDimensions;
  final String? _displayName;
  final List<Vector2d>? fieldBoundingBox;

  factory FieldData.fromJSON(Map<String, dynamic> json) {
    final imagePath = json["imagePath"];
    if (imagePath is! String) {
      throw FormatException(
        "Invalid JSON, required field 'imagePath' not of type String in $json",
      );
    }

    final fieldDimRaw = json["fieldDimensions"];
    if (fieldDimRaw is! Map<String, dynamic>) {
      throw FormatException(
        "Invalid JSON, required field 'fieldDimensions' not of type Vector2d "
        "in $json",
      );
    }
    late final Vector2d fieldDim;
    try {
      fieldDim = Vector2d.fromJSON(fieldDimRaw);
    } catch (_) {
      throw FormatException(
        "Invalid JSON, required field 'fieldDimensions' not of type Vector2d "
        "in $json",
      );
    }
    if (fieldDim.x <= 0 || fieldDim.y <= 0) {
      throw FormatException(
        "Invalid JSON, required field 'fieldDimensions' cannot have negative "
        "components in $json",
      );
    }

    final displayName = json["displayName"];
    if (displayName is! String?) {
      throw FormatException(
        "Invalid JSON, optional field 'displayName' not of type String in "
        "$json",
      );
    }

    final fieldBBRaw = json["fieldBoundingBox"];
    late final List<Vector2d>? fieldBoundingPoints;
    if (fieldBBRaw == null) {
      fieldBoundingPoints = null;
    } else if (fieldBBRaw is! Map<String, dynamic>) {
      throw FormatException(
        "Invalid JSON, optional field 'fieldBoundingBox' not of type "
        "{double x1, double y1, double x2, double y2} in $json",
      );
    } else {
      try {
        final fieldBB = _FieldBB.fromJSON(fieldBBRaw);

        fieldBoundingPoints = [
          Vector2d(min(fieldBB.x1, fieldBB.x2), max(fieldBB.y1, fieldBB.y2)),
          Vector2d(max(fieldBB.x1, fieldBB.x2), min(fieldBB.y1, fieldBB.y2)),
        ];
      } catch (_) {
        throw FormatException(
          "Invalid JSON, optional field 'fieldBoundingBox' is not of type "
          "{double x1, double y1, double x2, double y2} in $json",
        );
      }
    }

    return FieldData(
      imagePath: imagePath,
      fieldDimensions: fieldDim,
      displayName: displayName,
      fieldBoundingBox: fieldBoundingPoints,
    );
  }

  String get displayName => _displayName ?? imagePath; /*use imagePath if
  displayName is not provided*/

  @override
  List<Object?> get props => [
    imagePath,
    fieldDimensions,
    _displayName,
    fieldBoundingBox,
  ];

  @override
  bool? get stringify => true;
}

class _FieldBB {
  const _FieldBB({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  final double x1, y1, x2, y2;

  factory _FieldBB.fromJSON(Map<String, dynamic> json) {
    final x1 = json["x1"];
    if (x1 is! double) {
      throw FormatException(
        "Invalid JSON, required field 'x1' is not of type"
        " double",
      );
    }

    final y1 = json["y1"];
    if (y1 is! double) {
      throw FormatException(
        "Invalid JSON, required field 'y1' is not of type"
        " double",
      );
    }

    final x2 = json["x2"];
    if (x2 is! double) {
      throw FormatException(
        "Invalid JSON, required field 'x2' is not of type"
        " double",
      );
    }

    final y2 = json["y2"];
    if (y2 is! double) {
      throw FormatException(
        "Invalid JSON, required field 'y2' is not of type"
        " double",
      );
    }

    return _FieldBB(x1: x1, y1: y1, x2: x2, y2: y2);
  }
}
