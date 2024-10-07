import 'dart:io';
import 'package:flutter/foundation.dart';

mixin CheckerMixin {
  bool isAllowedEvent(DateTime eventDate) {
    
    return eventDate.isAfter(DateTime.now());
  }

}
