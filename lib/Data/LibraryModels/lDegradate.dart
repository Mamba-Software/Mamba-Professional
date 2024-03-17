// This class represents the Object <Event> that will be showed in the Calendar Widget.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/commons/constants/GlobalVars.dart';

class lDegradate {
  String? id;
  String? name;
  String? hexa1;
  String? hexa2;

  lDegradate({
    this.id,
    this.name,
    this.hexa1,
    this.hexa2,
  });

  //////////////////// CONSTRUCTORS ///////////////////////////////////////////////////////////////////////////////////////////

  lDegradate.fromObjectAllData(
      String documentId, DocumentSnapshot documentSnapshot) {
    id = documentId;
    if ((documentSnapshot.data() as Map<String, dynamic>).containsKey('name')) {
      name = documentSnapshot.get("name").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('hexa1')) {
      hexa1 = documentSnapshot.get("hexa1").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('hexa2')) {
      hexa2 = documentSnapshot.get("hexa2").toString();
    }
  }

  lDegradate getlDegradate(String id) {
    return currentDegradates[int.parse(id)];
  }

  String getIdFromHexa(String hexa1, String hexa2) {
    return currentDegradates[currentDegradates.indexWhere(
            (element) => element.hexa1 == hexa1 && element.hexa2 == hexa2)]
        .id!;
  }

  //////////////////// SETTERS ///////////////////////////////////////////////////////////////////////////////////////////

  // Set Basic Data
  set setBasicData(lDegradate degradate) {
    id = degradate.id;
    name = degradate.name;
    hexa1 = degradate.hexa1;
    hexa2 = degradate.hexa2;
  }
}
