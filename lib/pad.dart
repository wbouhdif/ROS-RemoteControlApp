import 'package:flutter/material.dart';
import 'dart:math';

class TrianglePainter extends CustomPainter {
  double sideSize;

  Color color;
  TrianglePainter({required this.sideSize, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double ySize = sideSize * cos(30 * pi / 180);
    double xSize = sideSize;

    double point0x = xSize / 2;
    double point0y = ySize / 2;

    double point1x = -xSize / 2;
    double point1y = ySize / 2;

    double point2x = 0;
    double point2y = -ySize / 2;

    Path path = Path();
    path.moveTo(point0x, point0y);
    path.lineTo(point1x, point1y);
    path.lineTo(point2x, point2y);
    path.lineTo(point0x, point0y);
    path.close();
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke);

    canvas.save();
    canvas.restore();
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.sideSize != sideSize;
  }
}

Widget triangle(double sideSize, Color color, double angle) {
  return Transform.rotate(
      angle: angle * pi / 180,
      child: CustomPaint(
        painter: TrianglePainter(
          color: color,
          sideSize: sideSize,
        ),
      ));
}


Widget circle(double diameter, Color? color) {
  return Container(
    width: diameter,
    height: diameter,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
    ),
  );
}

class DirectionPad extends StatefulWidget {
  final double diameter;
  final Function leftCallback, rightCallback, forwardCallback, backwardCallback;
  const DirectionPad(
      {Key? key,
        required this.diameter,
        required this.leftCallback,
        required this.rightCallback,
        required this.forwardCallback,
        required this.backwardCallback})
      : super(key: key);

  @override
  State<DirectionPad> createState() => _DirectionPadState();
}

class _DirectionPadState extends State<DirectionPad> {
  Widget horizontalBar(double longSize, double shortSize, Color color) {
    return Container(
        width: longSize,
        height: shortSize,
        decoration: BoxDecoration(
            color: color,
            border: Border.all(
              color: color,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(5))));
  }

  @override
  Widget build(BuildContext context) {
    double diameter = widget.diameter;
    double circleDiameter = diameter;
    double keyLongSize = diameter * 0.8;
    double keyShortSize = diameter * 0.25;
    double longMargin = (circleDiameter - keyLongSize) / 2;
    double shortMargin = (circleDiameter - keyShortSize) / 2;
    double triangleSize = diameter * 0.175;
    Color callbackColor = const Color(0x00000000).withOpacity(0.0);
    return Stack(
      children: [
        circle(circleDiameter, Colors.grey[300]),
        Positioned(
            left: longMargin,
            top: shortMargin,
            child: horizontalBar(keyLongSize, keyShortSize, Colors.grey[600]!)),
        Positioned(
            left: shortMargin,
            top: longMargin,
            child: horizontalBar(keyShortSize, keyLongSize, Colors.grey[600]!)),
        // Left Button
        Positioned(
            left: longMargin + keyLongSize / 6,
            top: shortMargin + keyShortSize / 2,
            child: triangle(triangleSize, Colors.grey[800]!, -90.0)),
        Positioned(
            left: longMargin + keyLongSize / 6 - triangleSize / 2,
            top: shortMargin + keyShortSize / 2 - triangleSize / 2,
            child: Listener(
                onPointerDown: (event) {
                  widget.leftCallback(-1);
                },
                onPointerUp: (event) {
                  widget.leftCallback(1);
                },
                child: Container(
                  width: triangleSize,
                  height: triangleSize,
                  color: callbackColor,
                ))),
        // Forward Button
        Positioned(
            left: diameter / 2,
            top: longMargin + keyLongSize / 6,
            child: triangle(triangleSize, Colors.grey[800]!, 0.0)),
        Positioned(
            left: diameter / 2 - triangleSize / 2,
            top: longMargin + keyLongSize / 6 - triangleSize / 2,
            child: Listener(
                onPointerDown: (event) {
                  widget.forwardCallback(-1);
                },
                onPointerUp: (event) {
                  widget.forwardCallback(1);
                },
                child: Container(
                    width: triangleSize,
                    height: triangleSize,
                    color: callbackColor))),
        // Backward Button
        Positioned(
            left: diameter / 2,
            top: longMargin + keyLongSize * 2 / 3 + keyLongSize / 6,
            child: triangle(triangleSize, Colors.grey[800]!, 180.0)),
        Positioned(
            left: diameter / 2 - triangleSize / 2,
            top: longMargin +
                keyLongSize * 2 / 3 +
                keyLongSize / 6 -
                triangleSize / 2,
            child: Listener(
                onPointerDown: (event) {
                  widget.backwardCallback(-1);
                },
                onPointerUp: (event) {
                  widget.backwardCallback(1);
                },
                child: Container(
                  width: triangleSize,
                  height: triangleSize,
                  color: callbackColor,
                ))),
        // Right Button
        Positioned(
            left: longMargin + keyLongSize * 2 / 3 + keyLongSize / 6,
            top: shortMargin + keyShortSize / 2,
            child: triangle(triangleSize, Colors.grey[800]!, 90.0)),
        Positioned(
            left: longMargin +
                keyLongSize * 2 / 3 +
                keyLongSize / 6 -
                triangleSize / 2,
            top: shortMargin + keyShortSize / 2 - triangleSize / 2,
            child: Listener(
                onPointerDown: (event) {
                  widget.rightCallback(-1);
                },
                onPointerUp: (event) {
                  widget.rightCallback(1);
                },
                child: Container(
                  width: triangleSize,
                  height: triangleSize,
                  color: callbackColor,
                ))),
      ],
    );
  }
}
