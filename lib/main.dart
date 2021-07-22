import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'alien.dart';
import 'dart:math' as Math;
import 'dart:ui' as ui;

import 'package:file_picker_cross/file_picker_cross.dart';
// import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'package:share_plus/share_plus.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

void main() {
  runApp(MyHomePage());
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
    return MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: SafeArea(
            child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(title: Text("Alien Shape Generator")),
          floatingActionButton:
              Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            FloatingActionButton(
              onPressed: () async {
                // Directory appDocDir = await getApplicationDocumentsDirectory();
                // File file = File("${appDocDir.path}/Example3.png");
                // await file.create();
                // await file.writeAsBytes(await getImageData(),
                //     flush: true);

                print("requesting permissions");
                //if (await Permission.storage.request().isGranted) {
                //print(await ImageGallerySaver.saveImage(await getImageData()));

                try {
                  FilePickerCross file = FilePickerCross(
                    await getImageData(),
                    type: FileTypeCross.image,
                  );
                  print(await file.exportToStorage(
                      fileName: "Example.png",
                      text: "Save the screenshot",
                      subject: "Alien Generator Screenshot"));
                } on FileSelectionCanceledError catch (e) {
                  print("Cancelled!!");
                }
                // } else {
                //   print("not granted...");
                // }
              },
              child: const Icon(Icons.download),
              backgroundColor: Colors.green,
            ),
            SizedBox(
              height: 10,
            ),
            FloatingActionButton(
              key: buttonKey,
              child: Icon(Icons.ios_share),
              onPressed: () async {
                Directory tempDir = await getTemporaryDirectory();
                File file = File("${tempDir.path}/Example3.png");
                await file.create();
                await file.writeAsBytes(await getImageData(), flush: true);
                Offset pos = ContextUtils.getOffsetFromContext(
                    buttonKey.currentContext!);
                print(pos);
                Share.shareFiles([file.path],
                    text: 'Alien Shapes',
                    sharePositionOrigin: Rect.fromLTWH(pos.dx, pos.dy, 1, 1));
                // final params = SaveFileDialogParams(sourceFilePath: file.path);
                // final filePath =
                //     await FlutterFileDialog.saveFile(params: params);
                //print(filePath);
              },
              backgroundColor: Colors.blue,
            )
          ]),
          drawer: Drawer(
              child: ListView(
            padding: EdgeInsets.zero,
            children: ListTile.divideTiles(
              context: context,
              tiles: <Widget>[
                Divider(),
                ListTile(
                    title: const Text("Number of pixels"),
                    subtitle: Slider(
                      activeColor: Colors.white,
                      inactiveColor: Colors.blueGrey,
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
                    subtitle: Slider(
                      activeColor: Colors.white,
                      inactiveColor: Colors.blueGrey,
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
                    subtitle: Slider(
                      activeColor: Colors.white,
                      inactiveColor: Colors.blueGrey,
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
                    subtitle: Slider(
                      activeColor: Colors.white,
                      inactiveColor: Colors.blueGrey,
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
                    subtitle: Slider(
                      activeColor: Colors.white,
                      inactiveColor: Colors.blueGrey,
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
                Divider(),
                ListTile(
                    title: const Text("Alogirithm"),
                    subtitle: DropdownButton(
                        value: _algo,
                        items: algos
                            .map((Algo val) => DropdownMenuItem(
                                value: val, child: Text(val.name)))
                            .toList(),
                        onChanged: (Algo? value) {
                          setState(() {
                            _algo = value;
                          });
                        })),
                Divider(),
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
          )),
          body: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  child: Container(),
                  painter: getPainter(),
                );
              }),
        )));
  }

  CustomPainter getPainter() {
    return Painter(
        toggle: _animate ? _animation.value > 0.5 : false,
        alienCount: _alienCount.toInt(),
        pixels: _pixels.toInt(),
        alternateDirection: _alternateDirection,
        startingOffset: _startingOffset.toInt(),
        seedIncrement: _seedIncrement.toInt(),
        seedMultiplier: Math.pow(10, _seedMultiplier).toInt(),
        algo: _algo == null ? algos[0] : _algo!);
  }
}

class Painter extends CustomPainter {
  late int alienCount;
  late bool toggle;
  late bool alternateDirection;
  int pixels;
  int startingOffset;
  int seedIncrement;
  int seedMultiplier;
  Algo algo;

  Painter(
      {this.toggle = true,
      this.alienCount = 1,
      this.alternateDirection = true,
      this.pixels = 3,
      this.startingOffset = 0,
      this.seedIncrement = 1,
      this.seedMultiplier = 10000,
      required this.algo});

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
    //List<Alien> aliens = [];
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
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class ContextUtils {
  // Takes a key, and in 1 frame, returns the size of the context attached to the key
  static void getFutureSizeFromGlobalKey(
      GlobalKey key, Function(Size size) callback) {
    Future.microtask(() {
      if (key.currentContext == null) return;
      Size size = getSizeFromContext(key.currentContext!);
      callback(size);
    });
  }

  // Shortcut to get the renderBox size from a context
  static Size getSizeFromContext(BuildContext context) {
    RenderBox rb = context.findRenderObject() as RenderBox;
    return rb.size;
  }

  // Shortcut to get the global position of a context
  static Offset getOffsetFromContext(BuildContext context, [Offset? offset]) {
    RenderBox rb = context.findRenderObject() as RenderBox;
    return rb.localToGlobal(offset ?? Offset.zero);
  }
}
