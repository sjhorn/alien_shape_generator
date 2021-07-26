import 'package:flutter/material.dart';

class SliderWithKeyboardFocus extends StatefulWidget {
  final ValueChanged<double>? onChanged;
  final double value;
  final bool autofocus;
  final double min;
  final double max;
  final int? divisions;
  final String? label;

  SliderWithKeyboardFocus({
    Key? key,
    required this.value,
    required this.onChanged,
    this.autofocus = false,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
  });

  @override
  _SliderWithKeyboardFocusState createState() =>
      _SliderWithKeyboardFocusState();
}

class _SliderWithKeyboardFocusState extends State<SliderWithKeyboardFocus> {
  late Slider _slider;
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _slider = Slider(
        autofocus: widget.autofocus,
        focusNode: focusNode,
        // activeColor: Colors.white,
        // inactiveColor: Colors.blueGrey,
        value: widget.value,
        min: widget.min,
        max: widget.max,
        divisions: widget.divisions,
        label: widget.label,
        onChanged: (double value) {
          focusNode.requestFocus();
          if (widget.onChanged != null) widget.onChanged!(value);
        });
    return _slider;
  }
}
