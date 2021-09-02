import 'package:uuid/uuid.dart';

// Class Model for a Client
class Error {

  // Required Parameters
  String? uid;
  String title;
  String descripcion;
  int? stepsReproduce;

  Error({ required this.title, required this.descripcion, this.stepsReproduce});

  String? createUID(){
    var uuid = Uuid();
    this.uid = uuid.v1();
    return this.uid;
  }

  toJson() {
    return {
      "uid": uid,
      "title": title,
      "descripcion": descripcion,
      "stepsReproduce": stepsReproduce
    };
  }

}