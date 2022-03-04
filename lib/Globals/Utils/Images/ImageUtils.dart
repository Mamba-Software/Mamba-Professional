import 'dart:io';
import 'package:image_picker/image_picker.dart';

// Text Styles contains all the TextStyles used in the App.
class ImageUtils {

  Future<File?> pickImage() async {
    // Pick Image
    ImagePicker imagePicker = ImagePicker();
    XFile? compressedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 800,
      imageQuality: 75,
    );
    // Check if Lost Data in Android
    final LostDataResponse response = await ImagePicker().retrieveLostData();
    if (response.file != null) {
      // Return Recovered Image
      return response.file as File?;
    }
    // Return Image Picked Compressed
    return File(compressedImage!.path);
  }

  Future<List<File>?> pickMultipleImage() async {
    List<File>? result = [];
    // Pick Images
    ImagePicker imagePicker = ImagePicker();
    List<XFile>? compressedImages = await imagePicker.pickMultiImage(
      maxWidth: 500,
      maxHeight: 700,
      imageQuality: 50,
    );
    // Check if Lost Data in Android
    final LostDataResponse response = await ImagePicker().retrieveLostData();
    if (response.file != null) {
      // Return Recovered Images
      for (var i=0; i<response.files!.length; i++) {
        result.add(File(response.files![i].path));
      }
      return result;
    }
    // Return Images Picked Compressed
    for (var i=0; i<compressedImages!.length; i++) {
      result.add(File(compressedImages[i].path));
    }
    return result;
  }

}
