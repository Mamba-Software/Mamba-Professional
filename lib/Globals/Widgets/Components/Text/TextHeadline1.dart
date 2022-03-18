import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';

class TextHeadline1 extends StatefulWidget {
  final String text;

  TextHeadline1({Key? key, required this.text}) : super(key: key);

  @override
  _TextHeadline1State createState() => new _TextHeadline1State();
}

class _TextHeadline1State extends State<TextHeadline1> {


  @override
  Widget build(BuildContext context) {
    return Text(
        widget.text,
        style: Theme.of(context).textTheme.headline1!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center
    );
  }
}