import 'dart:math' as Math;
import 'dart:core';

import 'package:flutter/material.dart';

const List<MaterialColor> colorOptions = <MaterialColor>[
  Colors.lightBlue,
  Colors.red,
  Colors.yellow,
  Colors.brown,
  Colors.pink,
  Colors.green,
  Colors.purple,
  Colors.deepOrange,
  Colors.amber,
  Colors.indigo,
  Colors.lightGreen,
  Colors.cyan,
  Colors.teal,
  Colors.lime,
  Colors.blue,
  Colors.orange,
  Colors.deepPurple,
  Colors.blueGrey,
];

class Algo {
  final String name;
  final double Function(num) function;
  const Algo(this.name, this.function);
}

List<Algo> algos = [
  Algo("Random Function", (num i) => Math.Random(i.toInt()).nextDouble()),
  Algo("Tangent", Math.tan),
  Algo("Cosine", Math.cos),
  Algo("Sine", Math.sin),
  Algo("ATangent", Math.atan),
  Algo("Square Root", Math.sqrt),
  Algo("Wildcard of all", (num i) {
    return algos[Math.Random(i.toInt()).nextInt(6)].function(i);
  }),
];

class Alien {
  int logicalSize = 6;
  int seed;
  int seedIncrement = 9;
  int seedMultiplier = 10000;
  Algo? algo = algos[0];

  late List<Color> pixels;

  Alien(
      {this.seed = 1,
      this.logicalSize = 3,
      this.seedIncrement = 1,
      this.seedMultiplier = 10000,
      this.algo,
      colorOrdinal = 0}) {
    Color color = colorOptions[
        (colorOrdinal + algos.indexOf(algo!)) % colorOptions.length];
    pixels = List.filled(logicalSize * logicalSize, Colors.transparent);

    for (var x = 0; x < logicalSize; x++)
      for (var y = 0; y < logicalSize / 2; y++) {
        pixels[x + y * logicalSize] =
            pixels[x + (logicalSize - 1 - y) * logicalSize] =
                pixelChoice() > 0.5 ? color : Colors.transparent;
      }
  }

  double pixelChoice() {
    Algo toRun = algo != null ? algo! : algos[0];
    double x = toRun.function(seed) * seedMultiplier;
    seed += seedIncrement;
    return x - x.floor();
  }

  void drawInvader(bool reflectX, bool reflectY, Canvas canvas, int width,
      int offsetX, int offsetY) {
    int spacing = width ~/ 12;
    double scale = ((width - spacing * 2) / logicalSize).floorToDouble();

    int square = logicalSize * logicalSize - 1;
    for (var x = 0; x < logicalSize; x++)
      for (var y = 0; y < logicalSize; y++) {
        Color pixel = pixels[
            reflectX ? x * logicalSize + y : square - (x * logicalSize + y)];
        if (pixel != Colors.transparent) {
          Paint paint = new Paint()
            ..color = pixel
            ..isAntiAlias = false
            ..style = PaintingStyle.fill;

          if (reflectY) {
            canvas.drawRect(
                Rect.fromLTWH(
                    (y * scale).ceilToDouble() + offsetX + spacing,
                    (x * scale).ceilToDouble() + offsetY + spacing,
                    scale,
                    scale),
                paint);
          } else {
            canvas.drawRect(
                Rect.fromLTWH(
                    (x * scale).ceilToDouble() + offsetX + spacing,
                    (y * scale).ceilToDouble() + offsetY + spacing,
                    scale,
                    scale),
                paint);
          }
        }
      }
  }
}
