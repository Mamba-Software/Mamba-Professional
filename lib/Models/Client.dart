// Class Model for a Client
class Client {

  // Required Parameters
  String uid;
  String? name;
  String? email;

  // Optional Parameters

  Client({required this.uid, this.name,  this.email});

  toJson() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
    };
  }

}