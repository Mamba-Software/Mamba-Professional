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

  List<RequestToBrand> requestsList = [];
  List<Brand> brandsList = [];
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
  });

  //////////////////// CONSTRUCTORS ///////////////////////////////////////////////////////////////////////////////////////////

  Usuario.fromObjectAllData(String documentId, DocumentSnapshot documentSnapshot) {
    this.id = documentId;
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('notificationToken')) {
      this.notificationToken = documentSnapshot.get("notificationToken").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('email')) {
      this.email = documentSnapshot.get("email").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('name')) {
      this.name = documentSnapshot.get("name").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('firstName')) {
      this.firstName = documentSnapshot.get("firstName").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('lastName')) {
      this.lastName = documentSnapshot.get("lastName").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('nick')) {
      this.nick = documentSnapshot.get("nick").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('imageUrl')) {
      this.imageUrl = documentSnapshot.get("imageUrl").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('noImageUrl')) {
      this.noImageUrl = documentSnapshot.get("noImageUrl").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isFirst')) {
      this.isFirst = documentSnapshot.get("isFirst");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isTrainer')) {
      this.isTrainer = documentSnapshot.get("isTrainer");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isPrivate')) {
      this.isPrivate = documentSnapshot.get("isPrivate");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isAdmin')) {
      this.isAdmin = documentSnapshot.get("isAdmin");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isDark')) {
      this.isDark = documentSnapshot.get("isDark");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('gender')) {
      this.gender = documentSnapshot.get("gender");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('dateJoined')) {
      this.dateJoined = documentSnapshot.get("dateJoined").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('dateOfBirth')) {
      this.dateOfBirth = documentSnapshot.get("dateOfBirth").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('testGroup')) {
      this.testGroup = documentSnapshot.get("testGroup").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('idioma')) {
      this.idioma = documentSnapshot.get("idioma").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('brandID')) {
      this.brandID = documentSnapshot.get("brandID").toString();
    }
  }

  Usuario.fromObjectOnlyCoverData(String documentId, DocumentSnapshot documentSnapshot) {
    this.id = documentId;
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('name')) {
      this.name = documentSnapshot.get("name").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('firstName')) {
      this.firstName = documentSnapshot.get("firstName").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('lastName')) {
      this.lastName = documentSnapshot.get("lastName").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('nick')) {
      this.nick = documentSnapshot.get("nick").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('imageUrl')) {
      this.imageUrl = documentSnapshot.get("imageUrl").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('noImageUrl')) {
      this.noImageUrl = documentSnapshot.get("noImageUrl").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isTrainer')) {
      this.isTrainer = documentSnapshot.get("isTrainer");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isPrivate')) {
      this.isPrivate = documentSnapshot.get("isPrivate");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('notificationToken')) {
      this.notificationToken = documentSnapshot.get("notificationToken").toString();
    }
  }

  //////////////////// SETTERS ///////////////////////////////////////////////////////////////////////////////////////////

  // Set Basic Data
  set setBasicData(Usuario user) {
    this.name = user.name;
    this.firstName = user.firstName;
    this.lastName = user.lastName;
    this.nick = user.nick;
    this.email = user.email;
    this.imageUrl = user.imageUrl;
    this.noImageUrl = user.noImageUrl;
    this.isTrainer = user.isTrainer;
    this.isPrivate = user.isPrivate;
    this.isFirst = user.isFirst;
    this.isAdmin = user.isAdmin;
    this.isDark = user.isDark;
    this.notificationToken = user.notificationToken;
    this.gender = user.gender;
    this.dateJoined = user.dateJoined;
    this.dateOfBirth = user.dateOfBirth;
    this.testGroup = user.testGroup;
    this.idioma = user.idioma;
    this.brandID = user.brandID;
  }

  // Requests
  set setRequestList(List<RequestToBrand> requestList) {
    this.requestsList = requestList;
  }

  // Brands
  set setBrandList(List<Brand> brandList) {
    this.brandsList = brandList;
  }

  // Events
  set setEventsList(List<Event> eventsList) {
    this.eventsList = eventsList;
  }
}
