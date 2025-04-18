import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants.dart' as constants;
import 'constants.dart';
import 'data.dart';
import 'main.dart';

class FieldPanel extends StatelessWidget {
  const FieldPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final ThemeData theme = Theme.of(context);

    final boldDimension = theme.textTheme.bodyMedium!.copyWith(
      fontWeight: FontWeight.bold,
    );

    late final Widget map;
    switch (appState.mapState) {
      case MapState.none:
        map = Text(
          "If you are seeing this text long enough to be able to "
          "read it, something went wrong.",
        );
        break;

      case MapState.loading:
        map = Text("Loading...");
        break;

      case MapState.error:
        map = Text("Error");
        break;

      case MapState.success:
        map = CustomPaint(
          foregroundPainter: MapDisplay(
            mapState: () => appState.mapState,
            hasMapData: () => appState.hasMapData,
            mapData: () => appState.mapData,
            zones: () => appState.zones,
          ),
          child: SizedBox.expand() /*use SizedBox to expand CustomPaint to size
          of containing area. Hacky solution but it works*/,
        );
        break;
    }

    late final Widget dimensionLabel;
    if (!appState.hasMapData) {
      dimensionLabel = Text("WxH: -x-");
    } else {
      final data = appState.mapData!;
      dimensionLabel = Text.rich(
        TextSpan(
          children: [
            TextSpan(text: "WxH: "),
            TextSpan(
              text: "${data.fieldDimensions.x}x${data.fieldDimensions.y}",
              style: boldDimension,
            ),
          ],
        ),
        style: theme.textTheme.bodyMedium,
      );
    }

    return Column(
      children: [
        Expanded(child: map),
        Container(
          color: theme.colorScheme.primaryContainer,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                color: theme.colorScheme.secondaryContainer,
                padding: EdgeInsets.all(2),
                child: dimensionLabel,
              ),
              SizedBox(width: 30),
              DropdownButton(
                value: appState.selectedMap,
                items:
                    mapLocations.map((String val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(MapData.getDisplayNameFromPath(val)),
                      );
                    }).toList(),
                onChanged: (String? val) {
                  if (val == null) return;
                  appState.setSelectedMap(val);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MapDisplay extends CustomPainter {
  const MapDisplay({
    required this.mapState,
    required this.hasMapData,
    required this.mapData,
    required this.zones,
  });

  final MapState Function() mapState;
  final bool Function() hasMapData;
  final MapData? Function() mapData;
  final List<Zone> Function() zones;

  @override
  void paint(Canvas canvas, Size size) {
    //guarantee that the canvas doesn't draw outside of its bounds
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (mapState() != MapState.success || !hasMapData()) return;

    final MapData data = mapData()!;
    if (data.image == null || data.imageAspectRatio == null) return;

    /*
      imageBB = bounding box of the map in screen pixels relative to the canvas
      pixelConvFactor = conversion factor from raw image pixels to screen pixels
     */
    final (bb: imageBB, convFactor: pixelConvFactor) = _drawMap(
      canvas,
      size,
      data,
    );

    //the bounding box of the field in raw pixels relative to the map
    late final Rect fieldRawPixels;
    if (data.fieldBoundingBox != null) {
      Vector2d lb = data.fieldBoundingBox![0];
      Vector2d rt = data.fieldBoundingBox![1];
      fieldRawPixels = Rect.fromLTRB(
        lb.x.toDouble(),
        rt.y.toDouble(),
        rt.x.toDouble(),
        lb.y.toDouble(),
      );
    } else {
      fieldRawPixels = Rect.fromLTWH(
        0,
        0,
        data.imageWidth!.toDouble(),
        data.imageHeight!.toDouble(),
      );
    }
    //the bounding box of the field in screen pixels, relative to the canvas
    final Rect fieldPixels = Rect.fromLTWH(
      fieldRawPixels.left * pixelConvFactor + imageBB.left,
      fieldRawPixels.top * pixelConvFactor + imageBB.top,
      fieldRawPixels.width * pixelConvFactor,
      fieldRawPixels.height * pixelConvFactor,
    );
    //converts screen pixels to meters
    final Vector2d meterConvFactor = Vector2d(
      fieldPixels.width / data.fieldDimensions.x,
      fieldPixels.height / data.fieldDimensions.y,
    );

    for (Zone z in zones()) {
      if (!z.isVisible) continue;

      _drawZone(canvas, size, z, fieldPixels, meterConvFactor);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  ({Rect bb, double convFactor}) _drawMap(
    Canvas canvas,
    Size size,
    MapData data,
  ) {
    ui.Image map = data.image!;
    double aspectRatio = data.imageAspectRatio!;

    late final Size imageSize;
    late final double factor;
    if (size.width / aspectRatio <= size.height) {
      //scale to width of container
      imageSize = Size(size.width, size.width / aspectRatio);
      factor = size.width / data.imageWidth!;
    } else {
      //scale to height of container
      imageSize = Size(size.height * aspectRatio, size.height);
      factor = size.height / data.imageHeight!;
    }
    Rect imageBB = Rect.fromLTWH(
      (size.width - imageSize.width) / 2,
      (size.height - imageSize.height) / 2,
      imageSize.width,
      imageSize.height,
    );

    canvas.drawImageRect(
      map,
      Rect.fromLTWH(
        0,
        0,
        data.imageWidth!.toDouble(),
        data.imageHeight!.toDouble(),
      ),
      imageBB,
      Paint(),
    );

    return (bb: imageBB, convFactor: factor);
  }

  void _drawZone(
    Canvas canvas,
    Size size,
    Zone z,
    Rect fieldBB,
    Vector2d meterConvFactor,
  ) {
    if (z.points.isEmpty) return;

    final polygonStroke =
        Paint()
          ..color = z.color
          ..strokeWidth = constants.mapPolygonWeight
          ..style = PaintingStyle.stroke;
    final polygonFill =
        Paint.from(polygonStroke)
          ..style = PaintingStyle.fill
          ..color = polygonStroke.color.withAlpha(constants.mapPolygonAlpha);
    final pointStyle = Paint.from(polygonStroke)..style = PaintingStyle.fill;

    final path = Path();
    bool isFirst = true;
    for (final p in z.points) {
      canvas.drawCircle(
        Offset(
          fieldBB.left + p.x.toDouble() * meterConvFactor.x,
          fieldBB.bottom - p.y.toDouble() * meterConvFactor.y,
        ),
        constants.mapPolygonRadius,
        pointStyle,
      );

      if (isFirst) {
        path.moveTo(
          fieldBB.left + p.x.toDouble() * meterConvFactor.x,
          fieldBB.bottom - p.y.toDouble() * meterConvFactor.y,
        );
        isFirst = false;
        continue;
      }

      path.lineTo(
        fieldBB.left + p.x.toDouble() * meterConvFactor.x,
        fieldBB.bottom - p.y.toDouble() * meterConvFactor.y,
      );
    }
    //add line back to starting point
    path.lineTo(
      fieldBB.left + z.points[0].x.toDouble() * meterConvFactor.x,
      fieldBB.bottom - z.points[0].y.toDouble() * meterConvFactor.y,
    );

    canvas.drawPath(path, polygonFill);
    canvas.drawPath(path, polygonStroke);
  }
}

enum MapState { none, loading, error, success }

class MapData extends Equatable {
  const MapData({
    required this.imagePath,
    required this.fieldDimensions,
    this.fieldBoundingBox,
    this.image,
  });

  final String imagePath;
  final Vector2d fieldDimensions;
  final List<Vector2d>? fieldBoundingBox;
  final ui.Image? image;

  //hacky way to make an async factory
  static Future<MapData> fromJSON(Map<String, dynamic> json) async {
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
        final fieldBB = _MapBB.fromJSON(fieldBBRaw);

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

    Image imgWidget = Image.asset(imagePath);
    ui.Image? img;
    bool hasRun = false;
    imgWidget.image
        .resolve(ImageConfiguration())
        .addListener(
          ImageStreamListener((ImageInfo info, bool _) {
            img = info.image;
            hasRun = true;
          }),
        );

    //hacky way to wait for listener, probably a better way to do it, IDK
    while (!hasRun) {
      await Future.delayed(const Duration(milliseconds: 1));
    }

    return Future<MapData>.value(
      MapData(
        imagePath: imagePath,
        fieldDimensions: fieldDim,
        fieldBoundingBox: fieldBoundingPoints,
        image: img,
      ),
    );
  }

  static String getDisplayNameFromPath(String imgPath) {
    if (imgPath.isEmpty) return "";

    int start = imgPath.lastIndexOf("/");
    start++; /*moves forward by one if found, sets to zero if not found*/

    int end = imgPath.lastIndexOf(".");
    if (end == -1 || end < start) end = imgPath.length;

    return imgPath.substring(start, end);
  }

  String get displayName => getDisplayNameFromPath(imagePath);
  int? get imageWidth => image?.width;
  int? get imageHeight => image?.height;
  double? get imageAspectRatio {
    if (imageWidth == null || imageHeight == null) return null;

    return imageWidth! / imageHeight!;
  }

  @override
  List<Object?> get props => [
    imagePath,
    fieldDimensions,
    fieldBoundingBox,
    image,
  ];

  @override
  bool? get stringify => true;
}

class _MapBB {
  const _MapBB({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  final num x1, y1, x2, y2;

  factory _MapBB.fromJSON(Map<String, dynamic> json) {
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

    return _MapBB(x1: x1, y1: y1, x2: x2, y2: y2);
  }
}
