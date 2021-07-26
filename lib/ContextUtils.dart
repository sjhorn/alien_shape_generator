import 'package:flutter/material.dart';

// https://blog.gskinner.com/archives/2020/09/flutter-tricks-widget-size-position.html
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
