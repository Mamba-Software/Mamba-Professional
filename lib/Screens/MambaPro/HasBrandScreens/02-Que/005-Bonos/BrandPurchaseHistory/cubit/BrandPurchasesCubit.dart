import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Data/DataService/Purchase/PurchaseDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/BonoRequest.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/BrandPurchaseHistory/models/PurchaseHistoryModel.dart';
import '../../../../../../../Data/DataService/Brand/BrandDataService.dart';
import '../../../../../../../Data/Models/Purchase.dart';
part 'BrandPurchasesState.dart';

class BrandPurchasesCubit extends Cubit<BrandPurchasesState> {
  final String brandId;

  BrandPurchasesCubit(this.brandId) : super(const BrandPurchasesInitial()) {
    getInitialBrandPurchases();
  }

  // Data Service
  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();
  final _purchaseDataService = PurchaseDataService();
  late StreamSubscription<QuerySnapshot> _subscription;
  // Lists
  List<PurchaseHistoryModel> purchasesHistoryObjects = [];
  List<Usuario> usersList = [];
  List<Brand> brandsList = [];
  List<Bono> bonosList = [];
  List<BonoRequest> bonoRequestsList = [];
  List<Purchase> purchasesList = [];

  final limit = 50;

  Future<void> getInitialBrandPurchases() async {
    try {
      // Set the State to Loading
      emit(const BrandPurchasesLoading());
      // Vars
      List<PurchaseHistoryModel> purchasesHistoryListsPurchases = [];
      List<PurchaseHistoryModel> purchasesHistoryListsRequests = [];
      // Get Last 50 Purchases
      purchasesList = await _purchaseDataService.getBrandFirstPurchasesLimit(brandId, limit);
      for (Purchase p in purchasesList) {
        // Get User
        Usuario user = usersList.firstWhere((element) => element.id == p.userId, orElse: () => Usuario());
        if (user.id == null) {
          user = await _userDataService.getUserCoverDetails(p.userId!);
        }
        usersList.add(user);
        // Get User
        Brand brand = brandsList.firstWhere((element) => element.id == p.brandId, orElse: () => Brand());
        if (brand.id == null) {
          brand = await _brandDataService.getBrandCoverDetails(p.brandId!);
        }
        brandsList.add(brand);
        // Get Bono
        Bono bono = bonosList.firstWhere((element) => element.id == p.bonoId, orElse: () => Bono());
        if (bono.id == null) {
          bono = await _brandDataService.getBonoInfo(p.brandId!, p.bonoId!);
        }
        bonosList.add(bono);
        // Build Purchase Object
        PurchaseHistoryModel obj = PurchaseHistoryModel(
            user: user,
            brand: brand,
            bono: bono,
            bonoReq: null,
            purchase: p,
            purchasedAt: p.purchasedAt!,
            purchaseStatus: p.directPurchase != null && p.directPurchase! ? PurchaseStatus.DIRECT : PurchaseStatus.CONFIRMED,
        );
        purchasesHistoryListsPurchases.add(obj);
      }
      // Open the Stream to Get Brand Upcoming Events
      _subscription = _brandDataService.getBonosRequestsFromBrand(brandId).listen((querySnapshot) async {
        List<DocumentSnapshot> documents = querySnapshot.docs;
        purchasesHistoryListsRequests = [];
        bonoRequestsList = documentsToBonosRequests(documents);
        for (BonoRequest req in bonoRequestsList) {
          // Get User
          Usuario user = usersList.firstWhere((element) => element.id == req.userId, orElse: () => Usuario());
          if (user.id == null) {
            user = await _userDataService.getUserCoverDetails(req.userId!);
          }
          usersList.add(user);
          // Get User
          Brand brand = brandsList.firstWhere((element) => element.id == req.brandId, orElse: () => Brand());
          if (brand.id == null) {
            brand = await _brandDataService.getBrandCoverDetails(req.brandId!);
          }
          brandsList.add(brand);
          // Get Bono
          Bono bono = bonosList.firstWhere((element) => element.id == req.bonoId, orElse: () => Bono());
          if (bono.id == null) {
            bono = await _brandDataService.getBonoInfo(req.brandId!, req.bonoId!);
          }
          bonosList.add(bono);
          // Build Purchase Object
          PurchaseHistoryModel obj = PurchaseHistoryModel(
              user: user,
              brand: brand,
              bono: bono,
              bonoReq: req,
              purchase: null,
              purchasedAt: req.timeRequested!,
              purchaseStatus: PurchaseStatus.TO_CONFIRM,
          );
          purchasesHistoryListsRequests.add(obj);
        }
        // Emit a new state with the list of `Events`.
        purchasesHistoryObjects = List.from(purchasesHistoryListsPurchases+purchasesHistoryListsRequests);
        // Order Notification List Descending Time
        purchasesHistoryObjects.sort((a,b) {
          var aDate =  a.purchasedAt.toDate();
          var bDate =  b.purchasedAt.toDate();
          return bDate.compareTo(aDate);
        });

        print("Brand Purchases New Data Finished");
        emit(BrandPurchasesLoaded(purchasesHistoryObjects));
      },
      onError: (e) {
        print("Brand Purchases Error"+e.toString());
        emit(BrandPurchasesError(e.toString()));
      },
      );
    } catch(e) {
      print("Brand Purchases Error"+e.toString());
      emit(BrandPurchasesError(e.toString()));
    }
  }

  /*

  Future<void> getMoreBrandEvents(String eventId, List<Usuario> _brandTrainers) async {
    try {
      print("Getting More Brand Events");
      // Set the State to Loading
      String brandId = currentBrand.id!;
      // Get Last 100 Finished Events
      List<Event> moreFinishedEvents = await _eventDataService.getBrandMoreCompletedEventsLimit(brandId, eventId, limit*2);
      // Add The Trainers to the Event
      List<Usuario> eventTrainers = [];
      for (Event evt in moreFinishedEvents) {
        for (Usuario trainer in _brandTrainers) {
          int index =  trainer.eventsList.indexWhere((element) => element.id == evt.id);
          if (index != -1) {
            eventTrainers.add(trainer);
          }
        }
        evt.setUserList = eventTrainers;
        eventTrainers = [];
      }
      finishedEventsList = List.from(moreFinishedEvents+finishedEventsList);
      List<Event> finalList = List.from(finishedEventsList+upcomingEventsList);
      // Order Notification List Descending Time
      finalList.sort((a,b) {
        var aDate =  DateTime(
          int.parse(a.year!),
          int.parse(a.month!),
          int.parse(a.day!),
          int.parse(a.hour!),
          int.parse(a.minute!),
        );
        var bDate =  DateTime(
          int.parse(b.year!),
          int.parse(b.month!),
          int.parse(b.day!),
          int.parse(b.hour!),
          int.parse(b.minute!),
        );
        return aDate.compareTo(bDate);
      });
      emit(BrandPurchasesLoaded(finalList));
    } catch(e) {
      print("More Brand Events Error"+e.toString());
      emit(BrandPurchasesError(e.toString()));
    }
  }

   */

  /*

  Future<void> updateBrandEvent(String eventId, List<Usuario> _brandTrainers) async {
    try {
      print("Update Brand Event");
      // Set the State to Loading
      String brandId = currentBrand.id!;
      // Get Last 100 Finished Events
      Event event = await _eventDataService.getSingleEvent(eventId);
      // Add The Trainers to the Event
      List<Usuario> eventTrainers = [];
      for (Usuario trainer in _brandTrainers) {
        int index = trainer.eventsList.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          eventTrainers.add(trainer);
        }
      }
      event.setUserList = eventTrainers;
      // Remove From Finished List First and Add Again
      finishedEventsList.removeWhere((element) => element.id == eventId);
      finishedEventsList.add(event);
      List<Event> finalList = List.from(finishedEventsList+upcomingEventsList);
      // Order Notification List Descending Time
      finalList.sort((a,b) {
        var aDate =  DateTime(
          int.parse(a.year!),
          int.parse(a.month!),
          int.parse(a.day!),
          int.parse(a.hour!),
          int.parse(a.minute!),
        );
        var bDate =  DateTime(
          int.parse(b.year!),
          int.parse(b.month!),
          int.parse(b.day!),
          int.parse(b.hour!),
          int.parse(b.minute!),
        );
        return aDate.compareTo(bDate);
      });
      emit(BrandPurchasesLoaded(finalList));
      print("Event $eventId Successfully Updated");
    } catch(e) {
      print("Delete Brand Event Error"+e.toString());
      emit(BrandPurchasesError(e.toString()));
    }
  }

  Future<void> deleteBrandEvent(String eventId) async {
    try {
      print("Delete More Brand Events");
      finishedEventsList.removeWhere((element) => element.id == eventId);
      List<Event> finalList = List.from(finishedEventsList+upcomingEventsList);
      // Order Notification List Descending Time
      finalList.sort((a,b) {
        var aDate =  DateTime(
          int.parse(a.year!),
          int.parse(a.month!),
          int.parse(a.day!),
          int.parse(a.hour!),
          int.parse(a.minute!),
        );
        var bDate =  DateTime(
          int.parse(b.year!),
          int.parse(b.month!),
          int.parse(b.day!),
          int.parse(b.hour!),
          int.parse(b.minute!),
        );
        return aDate.compareTo(bDate);
      });
      emit(BrandPurchasesLoaded(finalList));
      print("Event $eventId Successfully Deleted");
    } catch(e) {
      print("Delete Brand Event Error"+e.toString());
      emit(BrandPurchasesError(e.toString()));
    }
  }

   */

  @override
  Future<void> close() {
    //print('LO CIERRO');
    _subscription.cancel();
    return super.close();
  }

  /*
  TODO: FUTURE FILTER FERLO PER AQUI
  Future<void> filterEvents(int filterSelection, List<Usuario> _selectedTrainers) async {
    try {
      print("Filtering Events ...");
      List<Event> finalList = List.from(finishedEventsList+upcomingEventsList);
      /// Check Filter Selection for Type of Event
      if (filterSelection == 0) {
        // Show Both Private and Group Events
      } else if(filterSelection == 1) {
        // Show Only Group Events
        finalList.removeWhere((element) => element.isPrivate == true);
      } else if(filterSelection == 2) {
        // Show Only Private Events
        finalList.removeWhere((element) => element.isPrivate == false);
      }
      emit(BrandEventsLoaded(finalList));
    } catch(e) {
      print("Filter Brand Events Error"+e.toString());
      emit(BrandEventsError(e.toString()));
    }
  }
   */

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
