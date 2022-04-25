import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';

class TextBody1 extends StatefulWidget {
  final String text;

  TextBody1({Key? key, required this.text}) : super(key: key);

  @override
  _TextBody1State createState() => new _TextBody1State();
}

class _TextBody1State extends State<TextBody1> {


  @override
  Widget build(BuildContext context) {
    return Text(
        widget.text,
        style: Theme.of(context).textTheme.bodyText1,
        textAlign: TextAlign.center
    );
  }
}