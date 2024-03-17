import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/app/style/Styles.dart';

class CircularImage extends StatefulWidget {
  final double? size;
  final double? borderWidth;
  final String? image;
  final File? file;
  final Color? color;

  const CircularImage(
      {super.key,
      this.size,
      this.borderWidth,
      this.image,
      this.file,
      this.color});

  @override
  _CircularImageState createState() => _CircularImageState();
}

class _CircularImageState extends State<CircularImage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: Center(
            child: SizedBox(
              width: widget.size! * 0.20,
              height: widget.size! * 0.20,
              child: Center(
                child: CircularProgressIndicator(
                  color: widget.color == null
                      ? Theme.of(context).colorScheme.secondary
                      : widget.color!,
                  strokeWidth: widget.borderWidth == null
                      ? 1
                      : widget.borderWidth! * 1.5,
                ),
              ),
            ),
          ),
        ),
        Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
                border: Border.all(
                  width: widget.borderWidth == null ? 0 : widget.borderWidth!,
                  color:
                      widget.color == null ? Styles.mainColor : widget.color!,
                  style: widget.borderWidth == null
                      ? BorderStyle.none
                      : BorderStyle.solid,
                ),
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: widget.file != null
                      ? FileImage(widget.file!)
                      : CachedNetworkImageProvider(widget.image!)
                          as ImageProvider,
                )))
      ],
    );
  }
}
