// This class represents the Object <Event> that will be showed in the Calendar Widget.
import 'dart:ui';
import 'package:flutter/material.dart';

class Event {
  int? id;
  String? title;
  DateTime? start;
  double? duration;
  String? placeId;
  int? members;
  Color? backgroundColor = Colors.green;

  Event(int? id, String? title, DateTime? start, double? duration, String? placeId, int? members) {
    this.id = id;
    this.title = title;
    this.start = start;
    this.duration = duration;
    this.placeId = placeId;
    this.members = members;
  }

  updateEvent({int? id, String? title, DateTime? start, double? duration, String? placeId, int? members}) {
    this.id = id;
    this.title = title;
    this.start = start;
    this.duration = duration;
    this.placeId = placeId;
    this.members = members;
  }
}
