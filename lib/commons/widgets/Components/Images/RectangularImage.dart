import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:shimmer/shimmer.dart';

class RectangularImage extends StatefulWidget {
  final double? height;
  final double? width;
  final double? borderWidth;
  final double? borderRadius;
  final String? image;
  final File? file;
  final Color? color;
  final BoxFit? fit;

  const RectangularImage(
      {super.key,
      this.height,
      this.width,
      this.borderWidth,
      this.borderRadius,
      this.image,
      this.file,
      this.color,
      this.fit});

  @override
  _RectangularImageState createState() => _RectangularImageState();
}

class _RectangularImageState extends State<RectangularImage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Shimmer.fromColors(
          baseColor: AppColors.grey,
          highlightColor: AppColors.grey.withOpacity(0.5),
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: const Center(),
          ),
        ),
        Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
                border: Border.all(
                  width: widget.borderWidth == null ? 0 : widget.borderWidth!,
                  color: widget.color == null
                      ? AppColors.mainColor
                      : widget.color!,
                  style: widget.borderWidth == null
                      ? BorderStyle.none
                      : BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(
                    widget.borderRadius == null ? 0.0 : widget.borderRadius!),
                image: DecorationImage(
                  fit: widget.fit == null ? BoxFit.cover : BoxFit.contain,
                  image: widget.file != null
                      ? FileImage(widget.file!)
                      : CachedNetworkImageProvider(widget.image!)
                          as ImageProvider,
                )))
      ],
    );
  }
}
