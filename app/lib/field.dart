import 'dart:math';

import 'package:app/loader.dart';
import 'package:flutter/material.dart';

import 'math.dart';

class FieldPanel extends StatelessWidget {
  const FieldPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}

class FieldData {
  late final String imagePath;
  late final String displayName;
  late final Vector2d fieldDimensions;
  late final List<Vector2d> fieldBoundingBox;

  FieldData(String path) {
    loadJSON(path).then((data) {
      print(data);
    });

    _checkArgs(1, 1);
    imagePath = "imagePath";
    displayName = "displayName";
    fieldDimensions = Vector2d(1, 1);
    fieldBoundingBox = [Vector2d(0, 10), Vector2d(10, 0)];
  }

  FieldData.from(
    this.imagePath,
    this.displayName,
    double dimX,
    double dimY,
    double bbX1,
    double bbY1,
    double bbX2,
    double bbY2,
  ) {
    _checkArgs(dimX, dimY);
    fieldDimensions = Vector2d(dimX, dimY);

    fieldBoundingBox = [
      Vector2d(min(bbX1, bbX2), max(bbY1, bbY2)),
      Vector2d(max(bbX1, bbX2), min(bbY1, bbY2)),
    ];
  }

  void _checkArgs(double dimX, double dimY) {
    if (dimX <= 0 || dimY <= 0) throw Exception("Field dimension cannot <= 0");
  }
}
