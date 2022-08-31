import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/BonoRequest.dart';

//BonosUtils Class is used to administrate all the bonos
class BonosUtils {

  //Function to transform documents to bonos
  List<Bono> documentsToBonos(List<DocumentSnapshot> documents, int ordenSelection) {
    List<Bono> bonos = [];
    for(int i = 0; i < documents.length; i++) {
      Bono bono = Bono.fromObjectAllData(documents[i].id, documents[i]);
      bonos.add(bono);
    }

    if(ordenSelection == 0) {
      bonos.sort((a, b) {
        if (b.isActive!) {
          return 1;
        }
        return -1;
      });
    }
    if(ordenSelection == 1) {
      bonos.sort((a, b) {
        if (b.isActive!) {
          return -1;
        }
        return 1;
      });
    }
    if(ordenSelection == 2) {
      bonos.sort((a, b) {
        if (b.isActive!) {
          return -1;
        }
        return 1;
      });
    }
    if(ordenSelection == 3) {
      bonos.sort((a, b) {
        if (b.isActive!) {
          return -1;
        }
        return 1;
      });
    }

    return bonos;
  }

  //Function to transform documents to bonos request
  List<BonoRequest> documentsToBonosRequests(List<DocumentSnapshot> documents) {
    List<BonoRequest> bonosRequests = [];
    for(int i = 0; i < documents.length; i++) {
      BonoRequest bonoRequest = BonoRequest.fromObjectAllData(documents[i].id, documents[i]);
      bonosRequests.add(bonoRequest);
    }
    return bonosRequests;
  }

}