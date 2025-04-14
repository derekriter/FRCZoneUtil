import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'data.dart';
import 'loader.dart';

class FieldPanel extends StatefulWidget {
  const FieldPanel({super.key});

  @override
  State<FieldPanel> createState() => _FieldPanelState();
}

class _FieldPanelState extends State<FieldPanel> {
  FieldDisplayState _displayState = FieldDisplayState.none;
  FieldData? _fieldData;
  final List<Zone> _zones = [
    Zone(
      name: "test",
      id: 0,
      points: [Vector2d(0, 0), Vector2d(0, 8.0518), Vector2d(17.54823, 8.0518)],
      color: Colors.blue,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (displayState == FieldDisplayState.none) {
      loadPackagedJSON("res/Reefscape2025.json")
          .then((json) {
            try {
              FieldData.fromJSON(json)
                  .then((FieldData data) {
                    setDisplaySuccess(data);
                  })
                  .onError((err, _) {
                    print(err);

                    setDisplayError();
                  });
            } catch (err) {
              print(err);

              setDisplayError();
            }
          })
          .onError((err, _) {
            print(err);

            setDisplayError();
          });

      setDisplayLoading();
    }

    switch (_displayState) {
      case FieldDisplayState.none:
        return Placeholder();

      case FieldDisplayState.loading:
        return Text("Loading...");

      case FieldDisplayState.error:
        return Text("Error");

      case FieldDisplayState.success:
        return CustomPaint(
          foregroundPainter: FieldDisplay(
            getZones: () => zones,
            getHasData: () => hasData,
            getFieldData: () => fieldData,
            getDisplayState: () => displayState,
          ),
          child: SizedBox.expand() /*use SizedBox to expand CustomPaint to size
          of containing area. Hacky solution but it works*/,
        );
    }
  }

  void setDisplayNone() {
    setState(() {
      _displayState = FieldDisplayState.none;
      _fieldData = null;
    });
  }

  void setDisplayLoading() {
    setState(() {
      _displayState = FieldDisplayState.loading;
      _fieldData = null;
    });
  }

  void setDisplayError() {
    setState(() {
      _displayState = FieldDisplayState.error;
      _fieldData = null;
    });
  }

  void setDisplaySuccess(FieldData data) {
    setState(() {
      _displayState = FieldDisplayState.success;
      _fieldData = data;
    });
  }

  FieldDisplayState get displayState => _displayState;

  bool get hasData => _fieldData != null;

  FieldData? get fieldData => _fieldData;

  List<Zone> get zones => _zones;
}

class FieldDisplay extends CustomPainter {
  const FieldDisplay({
    required this.getZones,
    required this.getHasData,
    required this.getFieldData,
    required this.getDisplayState,
  });

  final List<Zone> Function() getZones;
  final bool Function() getHasData;
  final FieldData? Function() getFieldData;
  final FieldDisplayState Function() getDisplayState;

  @override
  void paint(Canvas canvas, Size size) {
    //guarantee that the canvas doesn't draw outside of its bounds
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (getDisplayState() != FieldDisplayState.success || !getHasData()) return;

    final FieldData data = getFieldData()!;
    if (data.image == null || data.imageAspectRatio == null) return;

    final (bb: imageBB, convFactor: pixelConvFactor) = _drawMap(
      canvas,
      size,
      data,
    );

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
    final Rect fieldPixels = Rect.fromLTWH(
      fieldRawPixels.left * pixelConvFactor + imageBB.left,
      fieldRawPixels.top * pixelConvFactor + imageBB.top,
      fieldRawPixels.width * pixelConvFactor,
      fieldRawPixels.height * pixelConvFactor,
    );
    final Vector2d meterConvFactor = Vector2d(
      fieldPixels.width / data.fieldDimensions.x,
      fieldPixels.height / data.fieldDimensions.y,
    );

    for (Zone z in getZones()) {
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
    FieldData data,
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
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;
    final polygonFill =
        Paint.from(polygonStroke)
          ..style = PaintingStyle.fill
          ..color = polygonStroke.color.withAlpha(64);
    final pointStyle = Paint.from(polygonStroke)..style = PaintingStyle.fill;

    final path = Path();
    bool isFirst = true;
    for (final p in z.points) {
      canvas.drawCircle(
        Offset(
          fieldBB.left + p.x.toDouble() * meterConvFactor.x,
          fieldBB.bottom - p.y.toDouble() * meterConvFactor.y,
        ),
        5,
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

enum FieldDisplayState { none, loading, error, success }

class FieldData extends Equatable {
  const FieldData({
    required this.imagePath,
    required this.fieldDimensions,
    String? displayName,
    this.fieldBoundingBox,
    this.image,
  }) : _displayName = displayName;

  final String imagePath;
  final Vector2d fieldDimensions;
  final String? _displayName;
  final List<Vector2d>? fieldBoundingBox;
  final ui.Image? image;

  //hacky way to make an async factory
  static Future<FieldData> fromJSON(Map<String, dynamic> json) async {
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

    return Future<FieldData>.value(
      FieldData(
        imagePath: imagePath,
        fieldDimensions: fieldDim,
        displayName: displayName,
        fieldBoundingBox: fieldBoundingPoints,
        image: img,
      ),
    );
  }

  String get displayName => _displayName ?? imagePath; /*use imagePath if
  displayName is not provided*/
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
    _displayName,
    fieldBoundingBox,
    image,
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
