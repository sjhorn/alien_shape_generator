import 'dart:typed_data';
import 'package:adaptive_breakpoints/adaptive_breakpoints.dart';
import 'package:alien_shape_generator/slider_with_keyboard_focus.dart';
import 'package:flutter/material.dart';
import 'dart:math' as Math;
import 'dart:ui' as ui;

import 'algo.dart';
import 'alien_painter.dart';
import 'save_and_share.dart';

void main() {
  runApp(MaterialApp(
      theme: ThemeData(brightness: Brightness.dark), home: MyHomePage()));
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool toggle = false;
  double _alienCount = 1;
  double _pixels = 6;
  bool _animate = false;
  bool _alternateDirection = false;
  double _startingOffset = 0.0;
  double _seedIncrement = 4;
  double _seedMultiplier = 4;
  Algo? _algo = algos[1];

  GlobalKey buttonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
  }

  Future<Uint8List> getImageData() async {
    Size size = Size(800, 800);
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final recorder = new ui.PictureRecorder();
    final canvas = new Canvas(recorder, rect);

    CustomPainter painter = getPainter();
    painter.paint(canvas, size);
    final picture = recorder.endRecording();
    final ui.Image img = await picture.toImage(800, 800);

    ByteData? data = await img.toByteData(format: ui.ImageByteFormat.png);
    return Uint8List.view(data!.buffer);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(title: Text("Alien Shape Generator")),
            floatingActionButton:
                Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              FloatingActionButton(
                onPressed: () =>
                    SaveAndShare.toGallery(context, getImageData()),
                child: const Icon(Icons.image),
                backgroundColor: Colors.green,
              ),
              SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                onPressed: () => SaveAndShare.save(context, getImageData()),
                child: const Icon(Icons.download),
                backgroundColor: Colors.green,
              ),
              SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                key: buttonKey,
                child: Icon(Icons.ios_share),
                onPressed: () =>
                    SaveAndShare.share(context, getImageData(), buttonKey),
                backgroundColor: Colors.blue,
              )
            ]),
            drawer: _isLargeScreen(context) ? null : _drawer(),
            body: _isLargeScreen(context)
                ? Row(children: [_drawer(), Expanded(child: _body())])
                : _body()));
  }

  Widget _body() {
    return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            child: Container(),
            painter: getPainter(),
          );
        });
  }

  Widget _drawer() {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: ListTile.divideTiles(
        context: context,
        tiles: <Widget>[
          Container(height: 30),
          ListTile(
              title: const Text("Number of pixels"),
              subtitle: SliderWithKeyboardFocus(
                autofocus: true,
                value: _pixels,
                min: 3,
                max: 13,
                divisions: 10,
                label: _pixels.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _pixels = value;
                  });
                },
              )),
          ListTile(
              title: const Text("Number of aliens"),
              subtitle: SliderWithKeyboardFocus(
                value: _alienCount,
                min: 1,
                max: 100,
                divisions: 100,
                label: _alienCount.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _alienCount = value;
                  });
                },
              )),
          ListTile(
              title: const Text("Starting offset"),
              subtitle: SliderWithKeyboardFocus(
                value: _startingOffset,
                min: 0,
                max: 100,
                divisions: 100,
                label: _startingOffset.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _startingOffset = value;
                  });
                },
              )),
          ListTile(
              title: const Text("Seed Increment"),
              subtitle: SliderWithKeyboardFocus(
                value: _seedIncrement,
                min: 1,
                max: 10,
                divisions: 10,
                label: _seedIncrement.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _seedIncrement = value;
                  });
                },
              )),
          ListTile(
              title: const Text("Seed Multipler"),
              subtitle: SliderWithKeyboardFocus(
                value: _seedMultiplier,
                min: 1,
                max: 10,
                divisions: 10,
                label: _seedMultiplier.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _seedMultiplier = value;
                  });
                },
              )),
          ListTile(
              title: const Text("Alogirithm"),
              subtitle: DropdownButton(
                  value: _algo,
                  items: algos
                      .map((Algo val) =>
                          DropdownMenuItem(value: val, child: Text(val.name)))
                      .toList(),
                  onChanged: (Algo? value) {
                    setState(() {
                      _algo = value;
                    });
                  })),
          SwitchListTile(
            title: const Text("Animate"),
            value: _animate,
            onChanged: (bool value) {
              setState(() {
                _animate = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text("Alternate Direction"),
            value: _alternateDirection,
            onChanged: (bool value) {
              setState(() {
                _alternateDirection = value;
              });
            },
          ),
        ],
      ).toList(),
    ));
  }

  CustomPainter getPainter() {
    return AlienPainter(
        toggle: _animate ? _animation.value > 0.5 : false,
        alienCount: _alienCount.toInt(),
        pixels: _pixels.toInt(),
        alternateDirection: _alternateDirection,
        startingOffset: _startingOffset.toInt(),
        seedIncrement: _seedIncrement.toInt(),
        seedMultiplier: Math.pow(10, _seedMultiplier).toInt(),
        algo: _algo == null ? algos[0] : _algo!);
  }

  bool _isLargeScreen(BuildContext context) =>
      getWindowType(context) >= AdaptiveWindowType.large;
  bool _isMediumScreen(BuildContext context) =>
      getWindowType(context) == AdaptiveWindowType.medium;
}
