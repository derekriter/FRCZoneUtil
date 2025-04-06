import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'loader.dart';
import 'math.dart';

class FieldPanel extends StatefulWidget {
  const FieldPanel({super.key});

  @override
  State<FieldPanel> createState() => _FieldPanelState();
}

class _FieldPanelState extends State<FieldPanel> {
  var displayState = _FieldDisplayState.none;
  FieldData? fieldData;

  @override
  Widget build(BuildContext context) {
    if (displayState == _FieldDisplayState.none) {
      loadPackagedJSON("res/Reefscape2025.json")
          .then((json) {
            try {
              fieldData = FieldData.fromJSON(json);

              setState(() {
                displayState = _FieldDisplayState.success;
              });
            } catch (err) {
              print(err);

              setState(() {
                displayState = _FieldDisplayState.error;
                fieldData = null;
              });
            }
          })
          .onError((err, _) {
            print(err);

            setState(() {
              displayState = _FieldDisplayState.error;
              fieldData = null;
            });
          });

      setState(() {
        displayState = _FieldDisplayState.loading;
        fieldData = null;
      });
    }

    switch (displayState) {
      case _FieldDisplayState.loading:
        return Text("Loading...");

      case _FieldDisplayState.error:
        return Text("Error");

      case _FieldDisplayState.success:
        assert(fieldData != null);
        return Image.asset(fieldData!.imagePath); /*can't figure out a way to
         check if the image can be loaded, just pray*/

      case _FieldDisplayState.none:
        return Placeholder();
    }
  }
}

enum _FieldDisplayState { loading, error, success, none }

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
        "{num x1, num y1, num x2, num y2} in $json",
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
          "{num x1, num y1, num x2, num y2} in $json",
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

  final num x1, y1, x2, y2;

  factory _FieldBB.fromJSON(Map<String, dynamic> json) {
    final x1 = json["x1"];
    if (x1 is! num) {
      throw FormatException(
        "Invalid JSON, required field 'x1' is not of type"
        " num",
      );
    }

    final y1 = json["y1"];
    if (y1 is! num) {
      throw FormatException(
        "Invalid JSON, required field 'y1' is not of type"
        " num",
      );
    }

    final x2 = json["x2"];
    if (x2 is! num) {
      throw FormatException(
        "Invalid JSON, required field 'x2' is not of type"
        " num",
      );
    }

    final y2 = json["y2"];
    if (y2 is! num) {
      throw FormatException(
        "Invalid JSON, required field 'y2' is not of type"
        " num",
      );
    }

    return _FieldBB(x1: x1, y1: y1, x2: x2, y2: y2);
  }
}
