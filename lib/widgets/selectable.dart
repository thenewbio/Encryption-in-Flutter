import 'package:flutter/material.dart';

class Selectable extends StatelessWidget {
  final String name;
  final TextAlign align;

  const Selectable(
      {Key? key, required this.name, this.align = TextAlign.center})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      name,
      textAlign: align,
      showCursor: true,
      cursorWidth: 2,
      cursorColor: Colors.red,
      cursorRadius: const Radius.circular(5),
    );
  }
}
