import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';

class CounterBadgeIcon extends StatefulWidget {
  final int counter;
  final Widget child;

  CounterBadgeIcon({Key? key, required this.counter, required this.child}) : super(key: key);

  @override
  _CounterBadgeIconState createState() => new _CounterBadgeIconState();
}

class _CounterBadgeIconState extends State<CounterBadgeIcon> {

  @override
  Widget build(BuildContext context) {
    final text = widget.counter.toString();
    final deltaFontSize = (text.length - 1) * 3.0;

    return widget.counter > 0 ? Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        Positioned(
          top: -2,
          right: 0,
          child: CircleAvatar(
            backgroundColor: Theme.of(context).accentColor,
            radius: 8,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10 - deltaFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ) : widget.child;
  }
}