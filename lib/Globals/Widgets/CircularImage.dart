import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';

class CircularImage extends StatefulWidget {
  final double? size;
  final double? borderWidth;
  final String? image;
  final File? file;
  final Color? color;

  CircularImage({Key? key, this.size, this.borderWidth, this.image, this.file, this.color}) : super(key: key);

  @override
  _CircularImageState createState() => new _CircularImageState();
}

class _CircularImageState extends State<CircularImage> {


  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        Container(
          width: widget.size,
          height: widget.size,
          child: Center(
            child: Container(
              width: widget.size! * 0.20,
              height: widget.size! * 0.20,
              child: Center(
                child: CircularProgressIndicator(
                  color: widget.color == null ? Styles.mainColor : widget.color!,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
        ),
        Container(
            width: widget.size,
            height: widget.size,
            decoration: new BoxDecoration(
                border: Border.all(
                  width: widget.borderWidth == null ? 3 : widget.borderWidth!,
                  color: widget.color == null ? Styles.mainColor : widget.color!,
                  style: BorderStyle.solid,
                ),
                shape: BoxShape.circle,
                image: new DecorationImage(
                  fit: BoxFit.cover,
                  image: widget.file != null ? FileImage(widget.file!) : NetworkImage(widget.image!) as ImageProvider,
                )
            )
        )
      ],
    );
  }
}