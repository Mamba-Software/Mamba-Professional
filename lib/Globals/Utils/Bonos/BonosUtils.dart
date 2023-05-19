import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/LibraryModels/lColor.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/BonoRequest.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/Models/Condition.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import '../../../Data/LibraryModels/lDegradate.dart';
import '../../../Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/AddEditBono.dart';
import '../../Widgets/Components/Images/CircularImage.dart';

//BonosUtils Class is used to administrate all the bonos
class BonosUtils {

  final _lDegradate = lDegradate();
  final _lColor = lColor();
  final _brandDataService = BrandDataService();

  //Function to transform documents to bonos
  List<Bono> documentsToBonos(List<DocumentSnapshot> documents, int filterSelection, int orderByBonosNumber, int alphabeticOrder) {
    List<Bono> bonos = [];
    List<Bono> activeBonos = [];
    List<Bono> inactiveBonos = [];
    for (int i = 0; i < documents.length; i++) {
      Bono bono = Bono.fromObjectAllData(documents[i].id, documents[i]);
      if (bono.isActive!) {
        activeBonos.add(bono);
      } else {
        inactiveBonos.add(bono);
      }
    }
    // Order By
    activeBonos.sort((a, b) {
      return a.title.toString().toLowerCase().compareTo(b.title.toString().toLowerCase());
    });
    inactiveBonos.sort((a, b) {
      return a.title.toString().toLowerCase().compareTo(b.title.toString().toLowerCase());
    });
    if (alphabeticOrder == 1) {
      activeBonos = List.from(activeBonos.reversed);
      inactiveBonos = List.from(inactiveBonos.reversed);
    }
    // Filter By
    if (filterSelection == 0) {
      // Active/Inactive Selected
      if (orderByBonosNumber == 0) {
        bonos.addAll(activeBonos);
        bonos.addAll(inactiveBonos);
      } else {
        bonos.addAll(inactiveBonos);
        bonos.addAll(activeBonos);
      }
    } else if(filterSelection == 1) {
      // Active Selected
      bonos.addAll(activeBonos);
    } else if(filterSelection == 2) {
      // Inactive Selected
      bonos.addAll(inactiveBonos);
    } else {
      // None Selected
    }
    // Return List of Bonos
    return bonos;
  }

  //Function to transform documents to bonos request
  List<BonoRequest> documentsToBonosRequests(List<DocumentSnapshot> documents) {
    List<BonoRequest> bonosRequests = [];
    for (int i = 0; i < documents.length; i++) {
      BonoRequest bonoRequest = BonoRequest.fromObjectAllData(documents[i].id, documents[i]);
      bonosRequests.add(bonoRequest);
    }
    return bonosRequests;
  }

  //Function to transform documents to bonos
  List<Bono> documentsToBonosUser(List<DocumentSnapshot> documents, bool userBonos, bool seeActives) {
    List<Bono> bonos = [];
    for(int i = 0; i < documents.length; i++) {
      Bono bono = Bono.fromObjectAllData(documents[i].id, documents[i]);
      if (userBonos == false) {
        if (bono.isActive == seeActives) {
          bonos.add(bono);
        }
      } else {
        bonos.add(bono);
      }
    }
    // Remove Bonos that aren't from the Current Brand
    bonos.removeWhere((element) => element.brandId != currentBrand.id!);
    return bonos;
  }

  //Function to transform documents to bonos
  Bono? documentsToBonosMostBuys(List<DocumentSnapshot> documents) {
    Bono? mostBuys = Bono();
    List<Bono> bonos = [];
    for (int i = 0; i < documents.length; i++) {
      Bono bono = Bono.fromObjectAllData(documents[i].id, documents[i]);
      bonos.add(bono);
    }
    // Check which one has the most buys
    bonos.sort((a,b) {
      var aCompras =  a.compras!;
      var bCompras =  b.compras!;
      return aCompras.compareTo(bCompras);
    });
    if (bonos.isNotEmpty) {
      mostBuys = bonos[0];
    } else {
      mostBuys = null;
    }
    // Return Most Bought Bono
    return mostBuys;
  }


}
