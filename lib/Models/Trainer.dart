// Class Model for a Trainer
class Trainer {

  String uid;
  String? name;
  String? email;
  int? gender;
  String? dateJoined;
  String? dateOfBirth;

  Trainer({required this.uid, this.name,  this.email, this.gender, this.dateJoined, this.dateOfBirth });

  toJson() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "gender": gender,
      "dateJoined": dateJoined,
      "dateOfBirth": dateOfBirth,
    };
  }

}