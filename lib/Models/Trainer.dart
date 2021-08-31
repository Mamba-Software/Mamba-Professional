// Class Model for a Trainer
class Trainer {

  String uid;
  String? name;
  String? email;
  int? gender;
  bool? isPrivate;
  String? dateJoined;
  String? dateOfBirth;

  Trainer({required this.uid, this.name,  this.email, this.gender, this.isPrivate, this.dateJoined, this.dateOfBirth });

  toJson() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "gender": gender,
      "isPrivate": isPrivate,
      "dateJoined": dateJoined,
      "dateOfBirth": dateOfBirth,
    };
  }

}