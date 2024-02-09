// This class represents the Object <Location>.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Location {
  String? id;
  String? brandID;
  String? placeId;
  bool? isBaseLocation;
  String? description;
  String? street;
  String? streetNumber;
  String? city;
  String? zipCode;
  double? latitude;
  double? longitude;
  Set<Marker>? markers = <Marker>{};
  CameraPosition initialPosition =
      const CameraPosition(target: LatLng(26.8206, 30.8025));

  Location(
      {this.id,
      this.brandID,
      this.placeId,
      this.isBaseLocation,
      this.description,
      this.street,
      this.streetNumber,
      this.city,
      this.zipCode,
      this.latitude,
      this.longitude});

  //////////////////// CONSTRUCTORS ///////////////////////////////////////////////////////////////////////////////////////////

  Location.fromObjectAllData(
      String documentId, DocumentSnapshot documentSnapshot) {
    id = documentId;
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('brandID')) {
      brandID = documentSnapshot.get("brandID").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('placeId')) {
      placeId = documentSnapshot.get("placeId").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('isBaseLocation')) {
      isBaseLocation = documentSnapshot.get("isBaseLocation");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('description')) {
      description = documentSnapshot.get("description").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('street')) {
      street = documentSnapshot.get("street").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('streetNumber')) {
      streetNumber = documentSnapshot.get("streetNumber").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>).containsKey('city')) {
      city = documentSnapshot.get("city").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('zipCode')) {
      zipCode = documentSnapshot.get("zipCode").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('latitude')) {
      latitude = documentSnapshot.get("latitude");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('longitude')) {
      longitude = documentSnapshot.get("longitude");
    }
  }

  Location.fromObjectOnlyCoverData(
      String documentId, DocumentSnapshot documentSnapshot) {
    id = documentId;
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('description')) {
      description = documentSnapshot.get("description").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('latitude')) {
      latitude = documentSnapshot.get("latitude");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('longitude')) {
      longitude = documentSnapshot.get("longitude");
    }
  }

  //////////////////// SETTERS ///////////////////////////////////////////////////////////////////////////////////////////

}
