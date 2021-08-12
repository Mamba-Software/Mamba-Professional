import 'package:flutter/material.dart';

final textFromInputDecoration = InputDecoration(
    labelStyle: TextStyle(color: Color(0xFF200758)),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF200758), width: 2.5),
      borderRadius: BorderRadius.circular(13.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF200758), width: 2.5),
      borderRadius: BorderRadius.circular(13.0),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 2.5),
      borderRadius: BorderRadius.circular(13.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 2.5),
      borderRadius: BorderRadius.circular(13.0),
    ),
  );