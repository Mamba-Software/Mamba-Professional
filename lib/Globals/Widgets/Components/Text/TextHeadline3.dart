import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';

class TextHeadline3 extends StatefulWidget {
  final String text;

  TextHeadline3({Key? key, required this.text}) : super(key: key);

  @override
  _TextHeadline3State createState() => new _TextHeadline3State();
}

class _TextHeadline3State extends State<TextHeadline3> {


  @override
  Widget build(BuildContext context) {
    return Text(
        widget.text,
        style: Theme.of(context).textTheme.headline3!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center
    );
  }
}