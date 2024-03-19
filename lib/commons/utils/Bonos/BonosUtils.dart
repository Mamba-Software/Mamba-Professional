import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/data/LibraryModels/lColor.dart';
import 'package:mamba_castelldefels/data/Models/Bono.dart';
import 'package:mamba_castelldefels/data/Models/BonoRequest.dart';
import 'package:mamba_castelldefels/data/Models/Brand.dart';
import 'package:mamba_castelldefels/data/Models/Condition.dart';
import 'package:mamba_castelldefels/data/Models/Purchase.dart';
import 'package:mamba_castelldefels/events/crud_events/models/Event.dart';
import '../../../Data/LibraryModels/lDegradate.dart';

//BonosUtils Class is used to administrate all the bonos
class BonosUtils {
  final _lDegradate = lDegradate();
  final _lColor = lColor();
  final _brandDataService = BrandDataService();

  //Function to transform documents to bonos
  List<Bono> documentsToBonos(
      List<DocumentSnapshot> documents,
      int filterActive,
      int filterType,
      int orderByBonosNumber,
      int alphabeticOrder) {
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
      return a.title
          .toString()
          .toLowerCase()
          .compareTo(b.title.toString().toLowerCase());
    });
    inactiveBonos.sort((a, b) {
      return a.title
          .toString()
          .toLowerCase()
          .compareTo(b.title.toString().toLowerCase());
    });
    if (alphabeticOrder == 1) {
      activeBonos = List.from(activeBonos.reversed);
      inactiveBonos = List.from(inactiveBonos.reversed);
    }
    // Filter By
    if (filterActive == 0) {
      bonos.addAll(activeBonos);
      bonos.addAll(inactiveBonos);
    } else if (filterActive == 1) {
      // Active Selected
      bonos.addAll(activeBonos);
    } else if (filterActive == 2) {
      // Inactive Selected
      bonos.addAll(inactiveBonos);
    } else {
      // None Selected
    }
    // Filter By
    if (filterType == 0) {
      // Membresía/Bono Selected
    } else if (filterType == 1) {
      // Membresía Selected
      bonos.removeWhere((element) => element.isRecurrent == false);
    } else if (filterType == 2) {
      // Bono Selected
      bonos.removeWhere((element) => element.isRecurrent == true);
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
      BonoRequest bonoRequest =
          BonoRequest.fromObjectAllData(documents[i].id, documents[i]);
      bonosRequests.add(bonoRequest);
    }
    return bonosRequests;
  }

  List<Event> documentsToEvents(List<DocumentSnapshot> documents) {
    List<Event> events = [];
    for (int i = 0; i < documents.length; i++) {
      events.add(Event.fromObjectOnlyCoverData(documents[i].id, documents[i]));
    }
    return events;
  }

  //Function to transform documents to bonos
  List<Purchase> documentsToPurchasesUser(List<DocumentSnapshot> documents) {
    List<Purchase> userPurchases = [];
    for (int i = 0; i < documents.length; i++) {
      Purchase purchase =
          Purchase.fromObjectAllData(documents[i].id, documents[i]);
      Bono bono = Bono(id: purchase.bonoId);
      // Add Conditions of This purchase
      bono.setBrandId = purchase.brandId!;
      bono.setPurchaseId = documents[i].id;
      bono.setBonoPrice = purchase.price!.toDouble();
      bono.setBonoSessions = purchase.sessions!;
      bono.setConditionsData = Condition(
        expirationTime: documents[i].get("expirationTime"),
        cancelTime: documents[i].get("cancelTime"),
        weeklySessions: documents[i].get("weeklySessions"),
      );
      purchase.setPurchasedBono = bono;
      userPurchases.add(purchase);
    }
    return userPurchases;
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
    bonos.sort((a, b) {
      var aCompras = a.compras!;
      var bCompras = b.compras!;
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

  double getPurchasePrice(Brand brand, Bono bono, Condition condition) {
    double price = bono.price!;
    DateTime today = DateTime.now();
    brand.paymentTerms ??= 2;

    if (condition.expirationTime == 0 ||
        (condition.expirationTime != 30 &&
            condition.expirationTime != 60 &&
            condition.expirationTime != 90)) {
      return price;
    }

    DateTime dayOfNextMonths = today;
    DateTime fromDay = today;
    DateTime firstDayOfMonth = DateTime(today.year, today.month, 1);
    DateTime fifthDayOfMonth = DateTime(today.year, today.month, 15);

    if (brand.paymentTerms != 2) {
      if (today.day != 1) {
        if (condition.expirationTime == 30) {
          dayOfNextMonths = DateTime(today.year, today.month + 1, 1);
        } else if (condition.expirationTime == 60) {
          dayOfNextMonths = DateTime(today.year, today.month + 2, 1);
        } else if (condition.expirationTime == 90) {
          dayOfNextMonths = DateTime(today.year, today.month + 3, 1);
        }
        //Prorrateación
        if (brand.paymentTerms == 0) {
          fromDay = DateTime(today.year, today.month, today.day);
        }
        //Mitad y mitad
        if (brand.paymentTerms == 1) {
          if (today.isAfter(fifthDayOfMonth)) {
            fromDay = DateTime(today.year, today.month, 15);
          } else {
            fromDay = DateTime(today.year, today.month, 1);
          }
        }

        int daysSubscription =
            dayOfNextMonths.difference(firstDayOfMonth).inDays;
        int diferenceToNextSubscription =
            dayOfNextMonths.difference(fromDay).inDays;

        price = price / daysSubscription;

        price = price * diferenceToNextSubscription;
      }
    }
    String truncatedString =
        price.toStringAsFixed(2); // Convierte a string con 2 decimales.
    double truncatedPrice =
        double.parse(truncatedString); // Convierte el string de nuevo a double.

    return truncatedPrice;
  }

  int getExpirationTime(Brand brand, Condition condition) {
    int expirationDays = 0;
    DateTime today = DateTime.now();
    brand.paymentTerms ??= 2;

    if (condition.expirationTime == 0) {
      return 0;
    }

    if (condition.expirationTime != 30 &&
        condition.expirationTime != 60 &&
        condition.expirationTime != 90) {
      return condition.expirationTime!;
    }

    //Días exactos
    if (brand.paymentTerms == 2) {
      if (condition!.expirationTime == 30) {
        // Siguiente mes
        final nextMonthDate = DateTime(today.year, today.month + 1, today.day);
        expirationDays = nextMonthDate.difference(today).inDays;
      } else if (condition!.expirationTime == 60) {
        // Dos meses más adelante
        final twoMonthsLater = DateTime(today.year, today.month + 2, today.day);
        expirationDays = twoMonthsLater.difference(today).inDays;
      } else if (condition!.expirationTime == 90) {
        // Tres meses más adelante
        final threeMonthsLater =
            DateTime(today.year, today.month + 3, today.day);
        expirationDays = threeMonthsLater.difference(today).inDays;
      }
    }
    //Prorrateación o mitad y mitad
    else {
      final firstDayOfNextMonth = DateTime(today.year, today.month + 1, 1);
      expirationDays = firstDayOfNextMonth.difference(today).inDays + 1;

      if (condition.expirationTime == 60) {
        // Dos meses más adelante
        final twoMonthsLater = DateTime(firstDayOfNextMonth.year,
            firstDayOfNextMonth.month + 1, firstDayOfNextMonth.day);
        expirationDays = twoMonthsLater.difference(firstDayOfNextMonth).inDays +
            expirationDays +
            1;
      } else if (condition.expirationTime == 90) {
        // Tres meses más adelante
        final threeMonthsLater = DateTime(
            firstDayOfNextMonth.year,
            firstDayOfNextMonth.month + 2,
            firstDayOfNextMonth.day); //TODO SI CAMBIA EL ANY CUIDADO
        expirationDays =
            threeMonthsLater.difference(firstDayOfNextMonth).inDays +
                expirationDays +
                1;
      }
    }
    return expirationDays;
  }
}
