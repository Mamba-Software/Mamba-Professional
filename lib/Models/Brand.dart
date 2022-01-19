// Model for a Brand in our App
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';

class Brand {

  String? id;
  String? adminID;
  String? logoUrl;
  String? name;
  String? description;
  String? dateJoined;
  String? groupRoomId;
  String? baseLocation;
  int? numberClients;
  int? numberTrainers;
  var workShift;
  int? maxMembers;
  // Subcollections
  List<Usuario> users = [];

  Brand({
    this.id,
    this.adminID,
    this.logoUrl,
    this.name,
    this.description,
    this.dateJoined,
    this.groupRoomId,
    this.baseLocation,
    this.numberClients,
    this.numberTrainers,
    this.workShift,
    this.maxMembers,
  });

  Brand.setData(String documentId, DocumentSnapshot documentSnapshot) {
    this.id = documentId;
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('adminID')) {
      this.adminID = documentSnapshot.get("adminID").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('logoUrl')) {
      this.logoUrl = documentSnapshot.get("logoUrl").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('name')) {
      this.name = documentSnapshot.get("name").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('description')) {
      this.description = documentSnapshot.get("description").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('dateJoined')) {
      this.dateJoined = documentSnapshot.get("dateJoined").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('groupRoomId')) {
      this.groupRoomId = documentSnapshot.get("groupRoomId").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('baseLocation')) {
      this.baseLocation = documentSnapshot.get("baseLocation").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('numberClients')) {
      this.numberClients = documentSnapshot.get("numberClients");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('numberTrainers')) {
      this.numberTrainers = documentSnapshot.get("numberTrainers");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('workShift')) {
      this.workShift = documentSnapshot.get("workShift");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('maxMembers')) {
      this.maxMembers = documentSnapshot.get("maxMembers");
    }
  }

  void setCoverData(String documentId, DocumentSnapshot documentSnapshot) {
    this.id = documentId;
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('name')) {
      this.name = documentSnapshot.get("name").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('logoUrl')) {
      this.logoUrl = documentSnapshot.get("logoUrl").toString();
    }
  }

  void setUsers(QuerySnapshot usersSnapshot) {
    List<Usuario> users = [];
    for (int i = 0; i < usersSnapshot.docs.length; i++) {
      Usuario user = Usuario();
      user.setCoverData(
        usersSnapshot.docs[i].id,
        usersSnapshot.docs[i]
      );
      users.add(user);
    }
    this.users = users;
  }
}
