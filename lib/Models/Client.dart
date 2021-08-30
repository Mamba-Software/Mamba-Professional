// Class Model for a Client
class Client {

  // Required Parameters
  String uid;
  String? name;
  String? email;
  int? gender;
  String? dateJoined;

  // Optional Parameters

  Client({required this.uid, this.name,  this.email, this.gender, this.dateJoined });

  toJson() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "gender": gender,
      "dateJoined": dateJoined,
    };
  }

}