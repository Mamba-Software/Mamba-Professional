// Model for a User in our App
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/data/Models/RequestToBrand.dart';
import 'package:mamba/events/crud_events/models/Event.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@immutable
@JsonSerializable()
class Usuario extends Equatable {
  @JsonKey(defaultValue: '')
  String? id;
  @JsonKey(defaultValue: '')
  String? notificationToken;
  @JsonKey(defaultValue: '')
  String? email;
  @JsonKey(defaultValue: '')
  String? name;
  @JsonKey(defaultValue: '')
  String? firstName;
  @JsonKey(defaultValue: '')
  String? lastName;
  @JsonKey(defaultValue: '')
  String? nick;
  @JsonKey(defaultValue: '')
  String? imageUrl;
  @JsonKey(defaultValue: '')
  String? noImageUrl;
  @JsonKey(defaultValue: false)
  bool? isFirst;
  @JsonKey(defaultValue: false)
  bool? isTrainer;
  @JsonKey(defaultValue: false)
  bool? isPrivate;
  @JsonKey(defaultValue: false)
  bool? freeSession;
  @JsonKey(defaultValue: false)
  bool? isAdmin;
  @JsonKey(defaultValue: false)
  bool? isDark;
  @JsonKey(defaultValue: 0)
  int? gender;
  @JsonKey(defaultValue: '')
  String? dateJoined;
  @JsonKey(defaultValue: '')
  String? dateOfBirth;
  @JsonKey(defaultValue: '')
  String? testGroup;
  @JsonKey(defaultValue: '')
  String? idioma;
  @JsonKey(defaultValue: '')
  String? brandID;
  @JsonKey(defaultValue: '')
  String? sessions;
  @JsonKey(defaultValue: false)
  bool? active;
  @JsonKey(fromJson: _fromJsonTimestamp, toJson: _toJsonTimestamp)
  Timestamp? lastEventAt;
  @JsonKey(defaultValue: '')
  String? purchaseId = "";

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<RequestToBrand> requestsList = [];
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<Brand> brandsList = [];
  @JsonKey(defaultValue: 0)
  int brandRole = 0;
  @JsonKey(includeFromJson: false, includeToJson: false)
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
    this.freeSession,
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
    this.purchaseId,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) =>
      _$UsuarioFromJson(json);

  factory Usuario.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final json = doc.data() ?? <String, dynamic>{};
    json['id'] = doc.id;
    return _$UsuarioFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UsuarioToJson(this);

  //////////////////// CONSTRUCTORS ///////////////////////////////////////////////////////////////////////////////////////////

  Usuario.fromObjectAllData(
      String documentId, DocumentSnapshot documentSnapshot) {
    id = documentId;
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('notificationToken')) {
      notificationToken = documentSnapshot.get("notificationToken").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('email')) {
      email = documentSnapshot.get("email").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>).containsKey('name')) {
      name = documentSnapshot.get("name").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('firstName')) {
      firstName = documentSnapshot.get("firstName").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('lastName')) {
      lastName = documentSnapshot.get("lastName").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>).containsKey('nick')) {
      nick = documentSnapshot.get("nick").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('imageUrl')) {
      imageUrl = documentSnapshot.get("imageUrl").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('noImageUrl')) {
      noImageUrl = documentSnapshot.get("noImageUrl").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('isFirst')) {
      isFirst = documentSnapshot.get("isFirst");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('isTrainer')) {
      isTrainer = documentSnapshot.get("isTrainer");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('isPrivate')) {
      isPrivate = documentSnapshot.get("isPrivate");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('isAdmin')) {
      isAdmin = documentSnapshot.get("isAdmin");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('isDark')) {
      isDark = documentSnapshot.get("isDark");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('gender')) {
      gender = documentSnapshot.get("gender");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('dateJoined')) {
      dateJoined = documentSnapshot.get("dateJoined").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('dateOfBirth')) {
      dateOfBirth = documentSnapshot.get("dateOfBirth").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('testGroup')) {
      testGroup = documentSnapshot.get("testGroup").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('idioma')) {
      idioma = documentSnapshot.get("idioma").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('brandID')) {
      brandID = documentSnapshot.get("brandID").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('sessions')) {
      sessions = documentSnapshot.get("sessions").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('purchaseId')) {
      purchaseId = documentSnapshot.get("purchaseId").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('freeSession')) {
      freeSession = documentSnapshot.get("freeSession");
    }
  }

  Usuario.fromObjectOnlyCoverData(
      String documentId, DocumentSnapshot documentSnapshot) {
    id = documentId;
    if ((documentSnapshot.data() as Map<String, dynamic>).containsKey('name')) {
      name = documentSnapshot.get("name").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('firstName')) {
      firstName = documentSnapshot.get("firstName").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('lastName')) {
      lastName = documentSnapshot.get("lastName").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>).containsKey('nick')) {
      nick = documentSnapshot.get("nick").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('imageUrl')) {
      imageUrl = documentSnapshot.get("imageUrl").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('noImageUrl')) {
      noImageUrl = documentSnapshot.get("noImageUrl").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('isTrainer')) {
      isTrainer = documentSnapshot.get("isTrainer");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('isPrivate')) {
      isPrivate = documentSnapshot.get("isPrivate");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('notificationToken')) {
      notificationToken = documentSnapshot.get("notificationToken").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('sessions')) {
      sessions = documentSnapshot.get("sessions").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>).containsKey('role')) {
      brandRole = documentSnapshot.get("role");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('lastEventAt')) {
      lastEventAt = documentSnapshot.get("lastEventAt");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('gender')) {
      gender = documentSnapshot.get("gender");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('dateJoined')) {
      dateJoined = documentSnapshot.get("dateJoined").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('dateOfBirth')) {
      dateOfBirth = documentSnapshot.get("dateOfBirth").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('purchaseId')) {
      purchaseId = documentSnapshot.get("purchaseId").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('freeSession')) {
      freeSession = documentSnapshot.get("freeSession");
    }
  }

  static final empty = Usuario(
    id: '',
    email: '',
    name: '',
    firstName: '',
    lastName: '',
    gender: 0,
    imageUrl: '',
  );

  // Custom fromJson method for Timestamp
  static Timestamp? _fromJsonTimestamp(dynamic json) {
    return json == null
        ? null
        : Timestamp.fromMillisecondsSinceEpoch(json as int);
  }

  // Custom toJson method for Timestamp
  static int? _toJsonTimestamp(Timestamp? timestamp) {
    return timestamp?.millisecondsSinceEpoch;
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
    freeSession = user.freeSession;
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

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        firstName,
        lastName,
        gender,
        imageUrl,
      ];
}
