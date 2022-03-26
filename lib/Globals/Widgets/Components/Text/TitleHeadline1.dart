import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';

class TitleHeadline1 extends StatefulWidget {
  final String text;

  TitleHeadline1({Key? key, required this.text}) : super(key: key);

  @override
  _TitleHeadline1State createState() => new _TitleHeadline1State();
}

class _TitleHeadline1State extends State<TitleHeadline1> {


  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      style: Theme.of(context).textTheme.headline1!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center
    );
  }
}