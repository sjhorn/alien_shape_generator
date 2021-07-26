import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'package:share_plus/share_plus.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

import 'ContextUtils.dart';

class SaveAndShare {
  static String _getName() {
    DateTime now = DateTime.now();
    return "AlientShape_${(now.millisecond)}.png";
  }

  static Future<File> _toFile(Future<Uint8List> imageData) async {
    Directory tempDir = await getTemporaryDirectory();
    File file = File("${tempDir.path}/${_getName()}");
    await file.create();
    return await file.writeAsBytes(await imageData, flush: true);
  }

  static _alert(BuildContext context, String message) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        // title: const Text('AlertDialog Tilte'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Ok'),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  static save(BuildContext context, Future<Uint8List> imageData) async {
    String fileName = _getName();
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      // On mobile present the permission dialog
      if (!await Permission.storage.request().isGranted) {
        _alert(context, "Failed to gain permssions to save file");
        return;
      }

      File file = await _toFile(imageData);
      final params = SaveFileDialogParams(sourceFilePath: file.path);
      await FlutterFileDialog.saveFile(params: params);
    } else {
      try {
        FilePickerCross file = FilePickerCross(
          await imageData,
          type: FileTypeCross.image,
        );
        await file.exportToStorage(
            fileName: fileName,
            text: "Save the screenshot",
            subject: "Alien Generator Screenshot");
      } on FileSelectionCanceledError catch (e) {
        _alert(context, "Cancelled without saving the file");
      }
    }
    _alert(context, "Sucessfully saved file to $fileName");
  }

  static share(BuildContext context, Future<Uint8List> imageData,
      GlobalKey buttonKey) async {
    Offset pos = ContextUtils.getOffsetFromContext(buttonKey.currentContext!);
    File file = await _toFile(imageData);
    Share.shareFiles([file.path],
        text: 'Alien Shapes',
        sharePositionOrigin: Rect.fromLTWH(pos.dx, pos.dy, 1, 1));
  }

  static toGallery(BuildContext context, Future<Uint8List> imageData) async {
    await ImageGallerySaver.saveImage(await imageData, name: _getName());
  }
}

class DateFormat {}
