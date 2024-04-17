import 'package:flutter/widgets.dart';

extension BuildContextX on BuildContext { 
  
  Size get size => MediaQuery.sizeOf(this);
  
}
