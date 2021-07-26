import 'package:flutter/material.dart';
import 'dart:math' as Math;
import 'algo.dart';
import 'alien.dart';

class AlienPainter extends CustomPainter {
  final int alienCount;
  final bool toggle;
  final bool alternateDirection;
  final int pixels;
  final int startingOffset;
  final int seedIncrement;
  final int seedMultiplier;
  final Algo algo;

  AlienPainter({
    required this.algo,
    this.toggle = true,
    this.alienCount = 1,
    this.alternateDirection = true,
    this.pixels = 3,
    this.startingOffset = 0,
    this.seedIncrement = 1,
    this.seedMultiplier = 10000,
  });

  @override
  bool operator ==(Object other) =>
      other is AlienPainter &&
      other.alienCount == alienCount &&
      other.toggle == toggle &&
      other.alternateDirection == alternateDirection &&
      other.pixels == pixels &&
      other.startingOffset == startingOffset &&
      other.seedIncrement == seedIncrement &&
      other.seedMultiplier == seedMultiplier &&
      other.algo == algo;

  @override
  int get hashCode => hashValues(alienCount, toggle, alternateDirection, pixels,
      startingOffset, seedIncrement, seedMultiplier, algo);

  int fitSquares(double x, double y, int n) {
    double sx, sy;

    double px = (Math.sqrt(n * x / y)).ceilToDouble();
    if ((px * y / x).floor() * px < n) {
      sx = y / (px * y / x).ceil();
    } else {
      sx = x / px;
    }

    double py = Math.sqrt(n * y / x).ceilToDouble();
    if ((py * x / y).floor() * py < n) {
      sy = x / (x * py / y).ceil();
    } else {
      sy = y / py;
    }

    return Math.max(sx, sy).toInt();
  }

  @override
  void paint(Canvas canvas, Size size) {
    int itemWidth = fitSquares(size.width, size.height, alienCount);
    int columns = Math.min(size.width ~/ itemWidth, alienCount);
    int rows = (alienCount - 1) ~/ columns + 1;
    int centeringX = (size.width - columns * itemWidth) ~/ 2;
    int centeringY = (size.height - rows * itemWidth) ~/ 2;

    for (int i = 0; i < alienCount; i += 1) {
      Alien(
          seed: i + startingOffset,
          logicalSize: pixels,
          colorOrdinal: i ~/ columns,
          seedIncrement: seedIncrement,
          seedMultiplier: seedMultiplier,
          algo: algo)
        ..drawInvader(
            toggle,
            alternateDirection ? i ~/ columns % 2 == 0 : false,
            canvas,
            itemWidth,
            (i % columns * itemWidth) + centeringX,
            (i ~/ columns * itemWidth) + centeringY);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
