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
import 'package:mamba_castelldefels/Globals/Utils/Bonos/BonosUtils.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/BrandPurchaseHistory/models/PurchaseHistoryModel.dart';
import '../../../../../../../Data/DataService/Brand/BrandDataService.dart';
import '../../../../../../../Data/Models/Purchase.dart';
import '../../../../../../../Globals/GlobalVars.dart';
part 'BrandPurchasesState.dart';

class BrandPurchasesCubit extends Cubit<BrandPurchasesState> {
  final String brandId;

  BrandPurchasesCubit(this.brandId) : super(const BrandPurchasesInitial()) {
    getInitialBrandPurchases();
  }

  // Cubit State
  late BrandPurchasesLoaded loadedState;
  // Data Service
  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();
  final _purchaseDataService = PurchaseDataService();
  late StreamSubscription<QuerySnapshot> _subscription;
  // Utils
  final _bonosUtils = BonosUtils();
  // Lists
  List<PurchaseHistoryModel> purchasesHistoryObjects = [];
  List<Usuario> usersList = [];
  List<Brand> brandsList = [];
  List<Bono> bonosList = [];
  // Variables
  final limit = 50;
  bool allPurchasesFetched = false;
  DateTime lastFetchedPurchaseDate = DateTime.now();
  String lastFetchedPurchaseId = "";
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  DateTime dateJoinedBrand = DateTime.now();
  // Filters
  List<bool> filterByPurchaseStatus = [true, true, true];

  Future<void> getInitialBrandPurchases() async {
    try {
      /// Set the State to Loading
      emit(const BrandPurchasesLoading());
      /// Vars
      List<BonoRequest> bonoRequestsList = [];
      List<Purchase> purchasesList = [];
      List<PurchaseHistoryModel> purchasesHistoryListsPurchases = [];
      List<PurchaseHistoryModel> purchasesHistoryListsRequests = [];
      int requiredPurchases = 10; // This is the number of purchases you want to ensure
      List<int> predefinedDays = [7, 14, 30, 90]; // List of predefined date ranges
      /// Fetch initial purchases
      purchasesList = await _purchaseDataService.getBrandFirstPurchasesLimit(brandId, limit);
      if (purchasesList.isNotEmpty) {
        lastFetchedPurchaseId = purchasesList.last.id!;
        lastFetchedPurchaseDate = purchasesList.last.purchasedAt!.toDate();
        if (purchasesList.length != limit) {
          allPurchasesFetched = true;
          print("allPurchasesFetched");
        }
      }
      /// Process the purchases list and build PurchaseHistoryModel objects.
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
        // After processing the list, add the new purchases to the existing list of purchases.
        purchasesHistoryListsPurchases.add(obj);
      }
      /// Choose Correct Iniital Date Range
      dateJoinedBrand = DateTime(
        int.parse(currentBrand.dateJoined!.split("-")[2]),
        int.parse(currentBrand.dateJoined!.split("-")[1]),
        int.parse(currentBrand.dateJoined!.split("-")[0]),
        0,
        0,
      );
      // Initialize startDate to the date of the oldest purchase in the list
      if (purchasesHistoryListsPurchases.isNotEmpty) {
        startDate = purchasesHistoryListsPurchases.last.purchasedAt.toDate();
      }
      // Try to find a smaller date range that includes at least `requiredPurchases` number of purchases
      for (int days in predefinedDays) {
        // Find the date `days` days ago
        DateTime dateDaysAgo = DateTime.now().subtract(Duration(days: days));
        // Count the purchases within this date range
        int countInRange = purchasesHistoryListsPurchases.takeWhile((purchase) => purchase.purchasedAt.toDate().isAfter(dateDaysAgo)).length;
        // If we have enough purchases in this date range, update `startDate` and break the loop
        if (countInRange >= requiredPurchases) {
          startDate = dateDaysAgo;
          break;
        }
      }
      // If we didn't find a suitable date range and there's no more data to fetch, set `startDate` to `dateJoinedBrand`
      if (startDate == purchasesHistoryListsPurchases.last.purchasedAt.toDate() && allPurchasesFetched) {
        startDate = dateJoinedBrand;
      }
      /// Open the Stream to Get Brand Requests
      _subscription = _brandDataService.getBonosRequestsFromBrand(brandId).listen((querySnapshot) async {
        List<DocumentSnapshot> documents = querySnapshot.docs;
        purchasesHistoryListsRequests = [];
        bonoRequestsList = _bonosUtils.documentsToBonosRequests(documents);
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
        // Check the Last Purchase
        List<PurchaseHistoryModel> filteredDateList = List.from(purchasesHistoryObjects);
        filteredDateList.removeWhere((element) {
          // Remove the ones before the start date or after the end date
          return element.purchasedAt.toDate().isBefore(startDate) || element.purchasedAt.toDate().isAfter(endDate);
        });
        /// Emit New Status
        print("Brand Purchases New Data Finished");
        loadedState = BrandPurchasesLoaded(
          startDate: startDate,
          endDate: endDate,
          dateJoinedBrand: dateJoinedBrand,
          purchasesHistoryObjects: filteredDateList,
          filterByPurchaseStatus: filterByPurchaseStatus,
        );
        emit(loadedState);
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

  Future<void> loadMoreBrandPurchases(String lastPurchaseId) async {
    try {
      print("Getting More Brand Purchases");
      // Vars
      List<PurchaseHistoryModel> purchasesHistoryListsPurchases = [];
      // Fetch more purchases ...
      // Get more purchases from the service.
      List<Purchase> morePurchases = await _purchaseDataService.getBrandMorePurchasesLimit(brandId, lastPurchaseId, limit);
      // Update the date of the last fetched purchase
      if (morePurchases.isNotEmpty) {
        lastFetchedPurchaseId = morePurchases.last.id!;
        lastFetchedPurchaseDate = morePurchases.last.purchasedAt!.toDate();
        if (morePurchases.length != limit) {
          allPurchasesFetched = true;
        }
      }
      // Handle The Object Creation Efficiently
      for (Purchase p in morePurchases) {
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
      // Emit a new state with the list of `Events`.
      purchasesHistoryObjects = List.from(purchasesHistoryObjects+purchasesHistoryListsPurchases);
      // Order Notification List Descending Time
      purchasesHistoryObjects.sort((a,b) {
        var aDate =  a.purchasedAt.toDate();
        var bDate =  b.purchasedAt.toDate();
        return bDate.compareTo(aDate);
      });
      // Filter the results by the current date range
      List<PurchaseHistoryModel> filteredDateList = purchasesHistoryObjects.where((element) {
        // Keep only the purchases within the date range
        DateTime purchasedAtDate = element.purchasedAt.toDate();
        return purchasedAtDate.isAfter(startDate) && purchasedAtDate.isBefore(endDate);
      }).toList();
      print("More Purchases Successfully Loaded");
      emit(
        loadedState.copyWith(
          purchasesHistoryObjects: filteredDateList,
        )
      );

    } catch(e) {
      print("Get More Brand Purchases Error: "+e.toString());
      emit(BrandPurchasesError(e.toString()));
    }
  }

  Future<void> updateDateRange(DateTime startDate, DateTime endDate) async {
    try {
      print("updateDateRange $startDate $endDate");
      this.startDate = startDate;
      this.endDate = endDate;
      // Filter purchasesHistoryObjects by the new date range ...
      List<PurchaseHistoryModel> filteredDateList = List.from(purchasesHistoryObjects);
      filteredDateList.removeWhere((element) {
        // Remove the ones before the start date or after the end date
        return element.purchasedAt.toDate().isBefore(startDate) || element.purchasedAt.toDate().isAfter(endDate);
      });
      // If the new endDate is after the date of the last fetched purchase, fetch more purchases
      if (startDate.isBefore(lastFetchedPurchaseDate) && allPurchasesFetched == false) {
        print("startDate isBefore lastFetchedPurchaseDate");
        await loadMoreBrandPurchases(lastFetchedPurchaseId);
      } else {
        // If the new endDate is before the date of the last fetched purchase, just emit the new state
        loadedState.copyWith(
          startDate: this.startDate,
          endDate: this.endDate,
          purchasesHistoryObjects: filteredDateList,
        );
        print("Date Range Successfully Updated");
      }
    } catch(e) {
      print("Update Date Range Error"+e.toString());
      emit(BrandPurchasesError(e.toString()));
    }
  }

  Future<void> onScrollMoreBrandPurchases() async {
    try {
      print("onScrollMoreBrandPurchases");
      // If the new endDate is after the date of the last fetched purchase, fetch more purchases
      if (allPurchasesFetched == false) {
        await loadMoreBrandPurchases(lastFetchedPurchaseId);
      }
    } catch(e) {
      print("Update Date Range Error"+e.toString());
      emit(BrandPurchasesError(e.toString()));
    }
  }

  Future<void> filterByPurchases(List<bool> filterByPurchaseStatus) async {
    try {
      print("filterByPurchaseStatus $filterByPurchaseStatus");
      this.filterByPurchaseStatus = filterByPurchaseStatus;
      // Filter purchasesHistoryObjects by the current date range...
      List<PurchaseHistoryModel> filteredDateList = List.from(purchasesHistoryObjects);
      filteredDateList.removeWhere((element) {
          // Remove the ones before the start date or after the end date
          return element.purchasedAt.toDate().isBefore(startDate) || element.purchasedAt.toDate().isAfter(endDate);
      });
      // Filter By Type Of Status
      // PurchaseStatus.CONFIRMED PurchaseStatus.DIRECT PurchaseStatus.TO_CONFIRM
      if (filterByPurchaseStatus[0] && filterByPurchaseStatus[1] && filterByPurchaseStatus[2]) {
        // All three Selected
        filteredDateList = filteredDateList;
      } else if (filterByPurchaseStatus[0] && filterByPurchaseStatus[1]) {
        filteredDateList.removeWhere((element) {
          if (element.purchaseStatus == PurchaseStatus.CONFIRMED || element.purchaseStatus == PurchaseStatus.DIRECT) {
            return false;
          } else {
            return true;
          }
        });
      } else if(filterByPurchaseStatus[0] && filterByPurchaseStatus[2]) {
        filteredDateList.removeWhere((element) {
          if (element.purchaseStatus == PurchaseStatus.CONFIRMED || element.purchaseStatus == PurchaseStatus.TO_CONFIRM) {
            return false;
          } else {
            return true;
          }
        });
      } else if(filterByPurchaseStatus[1] && filterByPurchaseStatus[2]) {
        filteredDateList.removeWhere((element) {
          if (element.purchaseStatus == PurchaseStatus.DIRECT || element.purchaseStatus == PurchaseStatus.TO_CONFIRM) {
            return false;
          } else {
            return true;
          }
        });
      } else if(filterByPurchaseStatus[0]) {
        filteredDateList.removeWhere((element) {
          if (element.purchaseStatus == PurchaseStatus.CONFIRMED) {
            return false;
          } else {
            return true;
          }
        });
      } else if(filterByPurchaseStatus[1]) {
        filteredDateList.removeWhere((element) {
          if (element.purchaseStatus == PurchaseStatus.DIRECT) {
            return false;
          } else {
            return true;
          }
        });
      } else if(filterByPurchaseStatus[2]) {
        filteredDateList.removeWhere((element) {
          if (element.purchaseStatus == PurchaseStatus.TO_CONFIRM) {
            return false;
          } else {
            return true;
          }
        });
      }
      emit(
        loadedState.copyWith(
          purchasesHistoryObjects: filteredDateList,
          filterByPurchaseStatus: this.filterByPurchaseStatus,
        ),
      );
      print("Status Filter Successfully Applied");
    } catch(e) {
      print("Update Date Range Error"+e.toString());
      emit(BrandPurchasesError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }

}

