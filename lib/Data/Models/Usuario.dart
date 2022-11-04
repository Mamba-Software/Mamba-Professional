// Model for a User in our App
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Notifications/NotificationEvent.dart';

import 'Brand.dart';
import 'RequestToBrand.dart';

class Usuario {

  String? id;
  String? notificationToken;
  String? email;
  String? name;
  String? firstName;
  String? lastName;
  String? nick;
  String? imageUrl;
  String? noImageUrl;
  bool? isFirst;
  bool? isTrainer;
  bool? isPrivate;
  bool? isAdmin;
  bool? isDark;
  int? gender;
  String? dateJoined;
  String? dateOfBirth;
  String? testGroup;
  String? idioma;
  String? brandID;
  String? sessions;
  bool? active;
  String? dateJoinedBrand;
  Timestamp? lastEventAt;

  List<RequestToBrand> requestsList = [];
  List<Brand> brandsList = [];
  int brandRole = 0;
  List<Event> eventsList = [];

  Usuario({
    this.id,
    this.notificationToken,
    this.email,
    this.name,
    this.firstName,
    this.lastName,
    this.nick,
    this.imageUrl,
    this.noImageUrl,
    this.isFirst,
    this.isTrainer,
    this.isPrivate,
    this.isAdmin,
    this.isDark,
    this.gender,
    this.dateJoined,
    this.dateOfBirth,
    this.testGroup,
    this.idioma,
    this.brandID,
    this.sessions,
    this.active,
    this.dateJoinedBrand,
  });

  //////////////////// CONSTRUCTORS ///////////////////////////////////////////////////////////////////////////////////////////

  Usuario.fromObjectAllData(String documentId, DocumentSnapshot documentSnapshot) {
    id = documentId;
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('notificationToken')) {
      notificationToken = documentSnapshot.get("notificationToken").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('email')) {
      email = documentSnapshot.get("email").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('name')) {
      name = documentSnapshot.get("name").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('firstName')) {
      firstName = documentSnapshot.get("firstName").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('lastName')) {
      lastName = documentSnapshot.get("lastName").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('nick')) {
      nick = documentSnapshot.get("nick").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('imageUrl')) {
      imageUrl = documentSnapshot.get("imageUrl").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('noImageUrl')) {
      noImageUrl = documentSnapshot.get("noImageUrl").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isFirst')) {
      isFirst = documentSnapshot.get("isFirst");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isTrainer')) {
      isTrainer = documentSnapshot.get("isTrainer");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isPrivate')) {
      isPrivate = documentSnapshot.get("isPrivate");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isAdmin')) {
      isAdmin = documentSnapshot.get("isAdmin");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isDark')) {
      isDark = documentSnapshot.get("isDark");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('gender')) {
      gender = documentSnapshot.get("gender");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('dateJoined')) {
      dateJoined = documentSnapshot.get("dateJoined").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('dateOfBirth')) {
      dateOfBirth = documentSnapshot.get("dateOfBirth").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('testGroup')) {
      testGroup = documentSnapshot.get("testGroup").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('idioma')) {
      idioma = documentSnapshot.get("idioma").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('brandID')) {
      brandID = documentSnapshot.get("brandID").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('sessions')) {
      sessions = documentSnapshot.get("sessions").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('dateJoinedBrand')) {
      dateJoinedBrand = documentSnapshot.get("dateJoinedBrand").toString();
    }
  }

  Usuario.fromObjectOnlyCoverData(String documentId, DocumentSnapshot documentSnapshot) {
    id = documentId;
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('name')) {
      name = documentSnapshot.get("name").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('firstName')) {
      firstName = documentSnapshot.get("firstName").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('lastName')) {
      lastName = documentSnapshot.get("lastName").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('nick')) {
      nick = documentSnapshot.get("nick").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('imageUrl')) {
      imageUrl = documentSnapshot.get("imageUrl").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('noImageUrl')) {
      noImageUrl = documentSnapshot.get("noImageUrl").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isTrainer')) {
      isTrainer = documentSnapshot.get("isTrainer");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isPrivate')) {
      isPrivate = documentSnapshot.get("isPrivate");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('notificationToken')) {
      notificationToken = documentSnapshot.get("notificationToken").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('sessions')) {
      sessions = documentSnapshot.get("sessions").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('role')) {
      brandRole = documentSnapshot.get("role");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('dateJoinedBrand')) {
      dateJoinedBrand = documentSnapshot.get("dateJoinedBrand").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('lastEventAt')) {
      lastEventAt = documentSnapshot.get("lastEventAt");
    }
  }

  //////////////////// SETTERS ///////////////////////////////////////////////////////////////////////////////////////////

  // Set Basic Data
  set setBasicData(Usuario user) {
    name = user.name;
    firstName = user.firstName;
    lastName = user.lastName;
    nick = user.nick;
    email = user.email;
    imageUrl = user.imageUrl;
    noImageUrl = user.noImageUrl;
    isTrainer = user.isTrainer;
    isPrivate = user.isPrivate;
    isFirst = user.isFirst;
    isAdmin = user.isAdmin;
    isDark = user.isDark;
    notificationToken = user.notificationToken;
    gender = user.gender;
    dateJoined = user.dateJoined;
    dateOfBirth = user.dateOfBirth;
    testGroup = user.testGroup;
    idioma = user.idioma;
    brandID = user.brandID;
    sessions = user.sessions;
    active = user.active;
    dateJoinedBrand = user.dateJoinedBrand;
  }

  // Requests
  set setRequestList(List<RequestToBrand> requestList) {
    requestsList = requestList;
  }

  // Brands
  set setBrandList(List<Brand> brandList) {
    brandsList = brandList;
  }

  // Brands
  set setBrandRole(int role) {
    brandRole = role;
  }

  // Events
  set setEventsList(List<Event> eventsList) {
    this.eventsList = eventsList;
  }
}
