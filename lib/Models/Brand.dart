// Model for a Brand in our App
import 'package:cloud_firestore/cloud_firestore.dart';

class Brand {

  String? id;
  String? adminID;
  String? logoUrl;
  String? name;
  String? description;
  String? dateJoined;
  String? placeId;
  String? address;
  double? latitude;
  double? longitude;
  var workShift;
  int? maxMembers;
  // Sector
  // Disponibilitat
  // Preus
  // Xarxes Socials
  // TOP 10 FOTOS

  Brand({
    this.id,
    this.adminID,
    this.logoUrl,
    this.name,
    this.description,
    this.dateJoined,
    this.placeId,
    this.address,
    this.latitude,
    this.longitude,
    this.workShift,
    this.maxMembers,
  });

  Map toMap(Brand brand) {
    var data = Map<String, dynamic>();
    data['id'] = brand.id;
    data['adminID'] = brand.adminID;
    data['logoUrl'] = brand.logoUrl;
    data['name'] = brand.name;
    data['description'] = brand.description;
    data['dateJoined'] = brand.dateJoined;
    data['placeId'] = brand.placeId;
    data['address'] = brand.address;
    data['latitude'] = brand.latitude;
    data['longitude'] = brand.longitude;
    data['workShift'] = brand.workShift;
    data['maxMembers'] = brand.maxMembers;
    return data;
  }

  Brand.fromMap(Map<String, dynamic> mapData, String documentId) {
    this.id = documentId;
    this.adminID = mapData['adminID'].toString();
    this.logoUrl = mapData['logoUrl'].toString();
    this.name = mapData['name'].toString();
    this.description = mapData['description'].toString();
    this.dateJoined = mapData['dateJoined'].toString();
    this.placeId = mapData['placeId'].toString();
    this.address = mapData['address'].toString();
    this.latitude = mapData['latitude'];
    this.longitude = mapData['longitude'];
    this.workShift = mapData['workShift'];
    this.maxMembers = mapData['maxMembers'];
  }

  Brand.fromObject(DocumentSnapshot documentSnapshot, String documentId) {
    this.id = documentId;
    this.adminID = documentSnapshot.get("adminID").toString();
    this.logoUrl = documentSnapshot.get("logoUrl").toString();
    this.name = documentSnapshot.get("name").toString();
    this.description = documentSnapshot.get("description").toString();
    this.dateJoined = documentSnapshot.get("dateJoined").toString();
    this.placeId = documentSnapshot.get("placeId").toString();
    this.address = documentSnapshot.get("address").toString();
    this.latitude = documentSnapshot.get("latitude");
    this.longitude = documentSnapshot.get("longitude");
    this.workShift = documentSnapshot.get("workShift");
    this.maxMembers = documentSnapshot.get("maxMembers");
  }
}
