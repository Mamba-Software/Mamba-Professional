import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mamba/commons/mixins/platform.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';

// Text Styles contains all the TextStyles used in the App.
class ImageUtils with PlatformMixin{

  Future<File?> pickImage() async {
    // Pick Image
    ImagePicker imagePicker = ImagePicker();
    XFile? compressedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 800,
      imageQuality: 75,
    );
    if (isAndroid) {
      // Check if Lost Data in Android
      final LostDataResponse response = await ImagePicker().retrieveLostData();
      if (response.file != null) {
        // Return Recovered Image
        return response.file as File?;
      }
    }
    // Return Image Picked Compressed
    return File(compressedImage!.path);
  }

  Future<List<File>?> pickMultipleImage() async {
    List<File>? result = [];
    // Pick Images
    ImagePicker imagePicker = ImagePicker();
    List<XFile>? compressedImages = await imagePicker.pickMultiImage(
      maxWidth: 600,
      maxHeight: 800,
      imageQuality: 75,
    );
    if (isAndroid) {
      // Check if Lost Data in Android
      final LostDataResponse response = await ImagePicker().retrieveLostData();
      if (response.file != null) {
        // Return Recovered Images
        for (var i = 0; i < response.files!.length; i++) {
          result.add(File(response.files![i].path));
        }
        return result;
      }
    }
    // Return Images Picked Compressed
    for (var i=0; i<compressedImages.length; i++) {
      result.add(File(compressedImages[i].path));
    }
    return result;
  }

  Future<File> urlToFile(String imageUrl) async {
    // generate random number.
    var rng = Random();
    // get temporary directory of device.
    Directory tempDir = await getTemporaryDirectory();
    // get temporary path from temporary directory.
    String tempPath = tempDir.path;
    // create a new file in temporary path with random file name.
    File file = File('$tempPath${rng.nextInt(100)}.jpeg');
    // call http.get method and pass imageUrl into it to get response.
    http.Response response = await http.get(Uri.parse(imageUrl));
    // write bodyBytes received in response to file.
    await file.writeAsBytes(response.bodyBytes);
    // now return the file which is created with random name in
    // temporary directory and image bytes from response is written to // that file.
    return file;
  }

  Future<String> getImageFileSize(File file, int decimals) async {
    int bytes = await file.length();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

}
