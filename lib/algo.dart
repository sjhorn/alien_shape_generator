import 'dart:math' as Math;

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
