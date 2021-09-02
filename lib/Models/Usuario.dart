// Class Model for a User
import 'dart:ui';

class Usuario {

  final String uid;
  bool? isTrainer;
  bool? isFirst;
  String? dateJoined;
  String? idioma;
  String? previousIdioma;


  Usuario({required this.uid, this.isTrainer, this.isFirst, this.dateJoined, this.idioma, this.previousIdioma});

}