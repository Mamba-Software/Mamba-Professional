// Model for a Brand in our App
import 'package:cloud_firestore/cloud_firestore.dart';

class Brand {

  String? id;
  String? adminID;
  String? logoUrl;
  String? name;
  String? description;
  String? dateJoined;
  String? baseLocation;
  int? numberClients;
  int? numberTrainers;
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
    this.baseLocation,
    this.numberClients,
    this.numberTrainers,
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
    data['baseLocation'] = brand.baseLocation;
    data['numberClients'] = brand.numberClients;
    data['numberTrainers'] = brand.numberTrainers;
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
    this.baseLocation = mapData['baseLocation'].toString();
    this.numberClients = mapData['numberClients'];
    this.numberTrainers = mapData['numberTrainers'];
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
    this.baseLocation = documentSnapshot.get("baseLocation").toString();
    this.numberClients = documentSnapshot.get("numberClients");
    this.numberTrainers = documentSnapshot.get("numberTrainers");
    this.workShift = documentSnapshot.get("workShift");
    this.maxMembers = documentSnapshot.get("maxMembers");
  }
}
