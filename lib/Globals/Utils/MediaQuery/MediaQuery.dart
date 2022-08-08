import 'package:flutter/material.dart';


class MediaQueryUtils {


  double width(var context, double size)
  {
    return MediaQuery.of(context).size.width * size;
  }

  double height(var context, double size)
  {
    return MediaQuery.of(context).size.height * size;
  }

}