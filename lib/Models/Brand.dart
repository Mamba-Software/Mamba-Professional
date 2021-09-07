// Model for a Brand in our App
class Brand {

  String? id;
  String? adminID;
  String? logoUrl;
  String? name;
  String? description;
  String? dateJoined;
  // Ubicació
  // Sector
  // Disponibilitat
  // Preus
  // Xarxes Socials
  // TOP 10 FOTOS

  List<String>? idiomas;

  Brand({
    this.id,
    this.adminID,
    this.logoUrl,
    this.name,
    this.description,
    this.dateJoined,
  });

  Map toMap(Brand brand) {
    var data = Map<String, dynamic>();
    data['id'] = brand.id;
    data['adminID'] = brand.adminID;
    data['logoUrl'] = brand.logoUrl;
    data['name'] = brand.name;
    data['description'] = brand.description;
    data['dateJoined'] = brand.dateJoined;
    return data;
  }

  Brand.fromMap(Map<String, dynamic> mapData, String documentId) {
    this.id = documentId;
    this.adminID = mapData['adminID'].toString();
    this.logoUrl = mapData['logoUrl'].toString();
    this.name = mapData['name'].toString();
    this.description = mapData['description'].toString();
    this.dateJoined = mapData['dateJoined'].toString();
  }
}
