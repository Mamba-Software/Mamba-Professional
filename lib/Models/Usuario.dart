// Model for a User in our App
class Usuario {

  String? id;
  String? email;
  String? name;
  String? imageUrl;
  bool? isFirst;
  bool? isTrainer;
  bool? isPrivate;
  int? gender;
  String? dateJoined;
  String? dateOfBirth;
  String? idioma;
  String? brandID; // UID of the user´s training brand.

  Usuario({
    this.id,
    this.email,
    this.name,
    this.imageUrl,
    this.isFirst,
    this.isTrainer,
    this.isPrivate,
    this.gender,
    this.dateJoined,
    this.dateOfBirth,
    this.idioma,
    this.brandID,
  });

  Map toMap(Usuario user) {
    var data = Map<String, dynamic>();
    data['email'] = user.email;
    data['name'] = user.name;
    data['imageUrl'] = user.imageUrl;
    data['isFirst'] = user.isFirst;
    data['isTrainer'] = user.isTrainer;
    data['isPrivate'] = user.isPrivate;
    data['gender'] = user.gender;
    data['dateJoined'] = user.dateJoined;
    data['dateOfBirth'] = user.dateOfBirth;
    data['idioma'] = user.idioma;
    data['brandID'] = user.brandID;
    return data;
  }

  Usuario.fromMap(Map<String, dynamic> mapData, String documentId) {
    this.id = documentId;
    this.email = mapData['email'].toString();
    this.name = mapData['name'].toString();
    this.imageUrl = mapData['imageUrl'].toString();
    this.isFirst = mapData['isFirst'];
    this.isTrainer = mapData['isTrainer'];
    this.isPrivate = mapData['isPrivate'];
    this.gender = mapData['gender'];
    this.dateJoined = mapData['dateJoined'].toString();
    this.dateOfBirth = mapData['dateOfBirth'].toString();
    this.idioma = mapData['idioma'].toString();
    this.brandID = mapData['brandID'].toString();
  }
}
