// This class represents the Object <Location>.
import 'package:cloud_firestore/cloud_firestore.dart';

class Location {
  String? id;
  String? brandID;
  String? placeId;
  String? description;
  String? street;
  String? streetNumber;
  String? city;
  String? zipCode;
  double? latitude;
  double? longitude;

  Location({
    this.id,
    this.brandID,
    this.placeId,
    this.description,
    this.street,
    this.streetNumber,
    this.city,
    this.zipCode,
    this.latitude,
    this.longitude,
  });

  Location.fromMap(Map<String, dynamic> mapData, String documentId) {
    this.id = documentId;
    this.brandID = mapData['brandID'].toString();
    this.placeId = mapData['placeId'].toString();
    this.description = mapData['description'].toString();
    this.street = mapData['street'].toString();
    this.streetNumber = mapData['streetNumber'].toString();
    this.city = mapData['city'].toString();
    this.zipCode = mapData['zipCode'].toString();
    this.latitude = mapData['latitude'];
    this.longitude = mapData['longitude'];
  }


  Location.fromObject(DocumentSnapshot documentSnapshot, String documentId) {
    this.id = documentId;
    this.brandID = documentSnapshot.get("brandID").toString();
    this.placeId = documentSnapshot.get("placeId").toString();
    this.description = documentSnapshot.get("description").toString();
    this.street = documentSnapshot.get("street").toString();
    this.streetNumber = documentSnapshot.get("streetNumber").toString();
    this.city = documentSnapshot.get("city").toString();
    this.zipCode = documentSnapshot.get("zipCode").toString();
    this.latitude = documentSnapshot.get("latitude");
    this.longitude = documentSnapshot.get("longitude");
  }
}
