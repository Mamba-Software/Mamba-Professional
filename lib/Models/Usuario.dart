// Model for a User in our App
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/Models/NotificationEvent.dart';

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
  int? gender;
  String? dateJoined;
  String? dateOfBirth;
  String? idioma;
  String? previousIdioma;
  String? brandID;
  List<RequestToBrand> requests = [];
  List<Brand> brands = [];

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
    this.gender,
    this.dateJoined,
    this.dateOfBirth,
    this.idioma,
    this.previousIdioma,
    this.brandID,
  });

  // Constructors

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
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('gender')) {
      this.gender = documentSnapshot.get("gender");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('dateJoined')) {
      this.dateJoined = documentSnapshot.get("dateJoined").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('dateOfBirth')) {
      this.dateOfBirth = documentSnapshot.get("dateOfBirth").toString();
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

  // Setters and Getters

  void set requestList(List<RequestToBrand> requestList) {
    this.requests = requestList;
  }

  List<RequestToBrand> get requestList {
    return requests;
  }

  void set setBrandList(List<Brand> brandList) {
    this.brands = brandList;
  }

  List<Brand> get getBrandList {
    return brands;
  }
}
