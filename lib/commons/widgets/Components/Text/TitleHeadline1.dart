import 'package:flutter/material.dart';

class TitleHeadline1 extends StatefulWidget {
  final String text;

  const TitleHeadline1({super.key, required this.text});

  @override
  _TitleHeadline1State createState() => _TitleHeadline1State();
}

class _TitleHeadline1State extends State<TitleHeadline1> {


  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      style: Theme.of(context).textTheme.displayLarge!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center
    );
  }
}