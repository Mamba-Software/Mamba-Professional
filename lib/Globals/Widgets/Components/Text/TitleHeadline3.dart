import 'package:flutter/material.dart';

class TitleHeadline3 extends StatefulWidget {
  final String text;

  const TitleHeadline3({super.key, required this.text});

  @override
  _TitleHeadline3State createState() => _TitleHeadline3State();
}

class _TitleHeadline3State extends State<TitleHeadline3> {


  @override
  Widget build(BuildContext context) {
    return Text(
        widget.text,
        style: Theme.of(context).textTheme.displaySmall!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center
    );
  }
}