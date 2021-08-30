// Class Model for a User
import 'dart:ui';

class Usuario {

  final String uid;
  bool? isTrainer;
  bool? isFirst;
  String? idioma;
  String? dateJoined;

  Usuario({ required this.uid, this.isTrainer, this.isFirst, this.idioma, this.dateJoined });

}