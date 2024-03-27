import 'package:flutter/cupertino.dart';
import 'package:mamba/commons/managers/language_manager.dart';

// Text Styles contains all the TextStyles used in the App.
class StringUtils {
  String toCapitalized(String s) =>
      s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '';

  String undoCapitalized(String s) =>
      s.isNotEmpty ? '${s[0].toLowerCase()}${s.substring(1)}' : '';

  String capitalizedAllWords(String s) {
    var result = "";
    var arrayStrings = splitByChar(s, " ");
    for (var i = 0; i < arrayStrings.length; i++) {
      String temp = toCapitalized(arrayStrings[i]);
      result += "$temp ";
    }
    return result.trim();
  }

  List<String> splitByChar(String string, String c) {
    return string.split(c);
  }

  String splitCommonName(String name) {
    List<String> aux = name.split(" ");
    return aux[0];
  }

  String greetingMessage(BuildContext context) {
    var timeNow = DateTime.now().hour;
    if (timeNow <= 12) {
      return context.l10n.goodMorningGreeting;
    } else if ((timeNow > 12) && (timeNow <= 20)) {
      return context.l10n.goodAfternoonGreeting;
    } else {
      return context.l10n.goodNightGreeting;
    }
  }

  // Gets a double and returns a String Duration to be shown
  durationToString(double duration) {
    String temp = "";
    temp = duration.toStringAsFixed(2);
    var hour = temp.split(".")[0];
    var min = temp.split(".")[1];
    return "${hour}h ${min}m ";
  }

  // Gets two ints and returns a String in format hh:mm
  hourMinutesToString(int hour, int minutes) {
    String hourSt = hour.toString();
    String minuteSt;
    if (minutes < 10) {
      minuteSt = "0$minutes";
    } else {
      minuteSt = minutes.toString();
    }
    return "$hourSt:${minuteSt}h";
  }
}
