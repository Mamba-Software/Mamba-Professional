// Model for a User in our App
import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {

  String? id;
  String? notificationToken;
  String? email;
  String? name;
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
  String? brandID; // UID of the user´s training brand.

  Usuario({
    this.id,
    this.notificationToken,
    this.email,
    this.name,
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

  Map toMap(Usuario user) {
    var data = Map<String, dynamic>();
    data['notificationToken'] = user.notificationToken;
    data['email'] = user.email;
    data['name'] = user.name;
    data['nick'] = user.nick;
    data['imageUrl'] = user.imageUrl;
    data['noImageUrl'] = user.noImageUrl;
    data['isFirst'] = user.isFirst;
    data['isTrainer'] = user.isTrainer;
    data['isPrivate'] = user.isPrivate;
    data['isAdmin'] = user.isAdmin;
    data['gender'] = user.gender;
    data['dateJoined'] = user.dateJoined;
    data['dateOfBirth'] = user.dateOfBirth;
    data['idioma'] = user.idioma;
    data['previousIdioma'] = user.previousIdioma;
    data['brandID'] = user.brandID;
    return data;
  }

  Usuario.fromMap(Map<String, dynamic> mapData, String documentId) {
    this.id = documentId;
    this.notificationToken = mapData['notificationToken'].toString();
    this.email = mapData['email'].toString();
    this.name = mapData['name'].toString();
    this.nick = mapData['nick'].toString();
    this.imageUrl = mapData['imageUrl'].toString();
    this.noImageUrl = mapData['noImageUrl'].toString();
    this.isFirst = mapData['isFirst'];
    this.isTrainer = mapData['isTrainer'];
    this.isPrivate = mapData['isPrivate'];
    this.isAdmin = mapData['isAdmin'];
    this.gender = mapData['gender'];
    this.dateJoined = mapData['dateJoined'].toString();
    this.dateOfBirth = mapData['dateOfBirth'].toString();
    this.idioma = mapData['idioma'].toString();
    this.previousIdioma = mapData['previousIdioma'].toString();
    this.brandID = mapData['brandID'].toString();
  }

  Usuario.fromObject(DocumentSnapshot documentSnapshot, String documentId) {
    this.id = documentId;
    this.notificationToken = documentSnapshot.get("notificationToken").toString();
    this.email = documentSnapshot.get("email").toString();
    this.name = documentSnapshot.get("name").toString();
    this.nick = documentSnapshot.get("nick").toString();
    this.imageUrl = documentSnapshot.get("imageUrl").toString();
    this.noImageUrl = documentSnapshot.get("noImageUrl").toString();
    this.isFirst = documentSnapshot.get("isFirst");
    this.isTrainer = documentSnapshot.get("isTrainer");
    this.isPrivate = documentSnapshot.get("isPrivate");
    this.isAdmin = documentSnapshot.get("isAdmin");
    this.gender = documentSnapshot.get("gender");
    this.dateJoined = documentSnapshot.get("dateJoined").toString();
    this.dateOfBirth = documentSnapshot.get("dateOfBirth").toString();
    this.idioma = documentSnapshot.get("idioma").toString();
    this.previousIdioma = documentSnapshot.get("previousIdioma").toString();
    this.brandID = documentSnapshot.get("brandID").toString();
  }
}
