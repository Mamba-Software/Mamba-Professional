// This class represents the Object <Event> that will be showed in the Calendar Widget.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/commons/constants/GlobalVars.dart';

class lColor {
  String? id;
  String? name;
  String? hexa;

  lColor({
    this.id,
    this.name,
    this.hexa,
  });

  //////////////////// CONSTRUCTORS ///////////////////////////////////////////////////////////////////////////////////////////

  lColor.fromObjectAllData(
      String documentId, DocumentSnapshot documentSnapshot) {
    id = documentId;
    if ((documentSnapshot.data() as Map<String, dynamic>).containsKey('name')) {
      name = documentSnapshot.get("name").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>).containsKey('hexa')) {
      hexa = documentSnapshot.get("hexa").toString();
    }
  }

  lColor getlColor(String id) {
    return currentColors[int.parse(id)];
  }

  String getIdFromHexa(String hexa) {
    return currentColors[
            currentColors.indexWhere((element) => element.hexa == hexa)]
        .id!;
  }

  //////////////////// SETTERS ///////////////////////////////////////////////////////////////////////////////////////////

  // Set Basic Data
  set setBasicData(lColor color) {
    id = color.id;
    name = color.name;
    hexa = color.hexa;
  }
}
