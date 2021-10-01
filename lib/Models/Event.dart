// This class represents the Object <Event> that will be showed in the Calendar Widget.
import 'dart:ui';
import 'package:flutter/material.dart';

class Event {
  int? id;
  String? title;
  Color? backgroundColor = Colors.green;
  DateTime? start;
  DateTime? end;

  Event(int? id, String? title, DateTime? start, DateTime? end) {
    this.id = id;
    this.title = title;
    this.start = start;
    this.end = end;
  }

  updateEvent({int? id, String? title, DateTime? start, DateTime? end}) {
    this.id = id;
    this.title = title;
    this.start = start;
    this.end = end;
  }

  eventToString() {
    print(
        "Event --- ID:${this.id}; TITLE:${this.title}; START:${this.start.toString()}; END:${this.end.toString()};");
  }
}
