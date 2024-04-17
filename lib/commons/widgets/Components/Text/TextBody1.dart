import 'package:flutter/material.dart';

class TextBody1 extends StatefulWidget {
  final String text;

  const TextBody1({super.key, required this.text});

  @override
  _TextBody1State createState() => _TextBody1State();
}

class _TextBody1State extends State<TextBody1> {


  @override
  Widget build(BuildContext context) {
    return Text(
        widget.text,
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.center
    );
  }
}