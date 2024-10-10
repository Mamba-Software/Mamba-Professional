import 'dart:io';
import 'package:flutter/foundation.dart';

mixin CheckerMixin {
  bool isAllowed(var context, DateTime doneAt, String typeOfCreation) {
    return true;
  }
}
