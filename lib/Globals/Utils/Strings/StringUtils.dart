import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';

// Text Styles contains all the TextStyles used in the App.
class StringUtils {

  String toCapitalized(String s) => s.length > 0 ?'${s[0].toUpperCase()}${s.substring(1)}':'';

  String capitalizedAllWords(String s) {
    var result = "";
    var arrayStrings = splitByChar(s, " ");
    for (var i=0; i<arrayStrings.length; i++) {
      String temp = toCapitalized(arrayStrings[i]);
      result += temp+" ";
    }
    return result.trim();
  }

  List<String> splitByChar(String string, String c) {
    return string.split(c);
  }

}
