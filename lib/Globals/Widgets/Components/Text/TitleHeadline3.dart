import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';

class TitleHeadline3 extends StatefulWidget {
  final String text;

  TitleHeadline3({Key? key, required this.text}) : super(key: key);

  @override
  _TitleHeadline3State createState() => new _TitleHeadline3State();
}

class _TitleHeadline3State extends State<TitleHeadline3> {


  @override
  Widget build(BuildContext context) {
    return Text(
        widget.text,
        style: Theme.of(context).textTheme.headline3!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center
    );
  }
}