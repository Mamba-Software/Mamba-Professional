import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/data/DataService/Purchase/PurchaseDataService.dart';
import 'package:mamba_castelldefels/data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/data/Models/Bono.dart';
import 'package:mamba_castelldefels/data/Models/BonoRequest.dart';
import 'package:mamba_castelldefels/data/Models/Brand.dart';
import 'package:mamba_castelldefels/data/Models/Purchase.dart';
import 'package:mamba_castelldefels/data/Models/Usuario.dart';
import 'package:mamba_castelldefels/commons/constants/GlobalVars.dart';
import 'package:mamba_castelldefels/commons/utils/Bonos/BonosUtils.dart';
import 'package:mamba_castelldefels/screens/MambaPro/HasBrandScreens/02-Que/007%20-%20Purchases/models/PurchaseHistoryModel.dart';
part 'UserPurchasesState.dart';

class UserPurchasesCubit extends Cubit<UserPurchasesState> {
  final String userId;
  final String brandId;
  final String? purchaseGroupId;

  UserPurchasesCubit(this.userId, this.brandId, this.purchaseGroupId)
      : super(const UserPurchasesInitial()) {
    fetchInitialUserPurchases();
  }

  // Cubit State
  late UserPurchasesLoaded loadedState;
  // Data Service
  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();
  final _purchaseDataService = PurchaseDataService();
  late StreamSubscription<QuerySnapshot> _subscriptionPurchases;
  late StreamSubscription<QuerySnapshot> _subscriptionBonoRequests;
  // Utils
  final _bonosUtils = BonosUtils();
  // Lists
  List<PurchaseHistoryModel> purchasesHistoryObjects = [];
  List<PurchaseHistoryModel> purchasesHistoryObjectsPurchases = [];
  List<PurchaseHistoryModel> purchasesHistoryObjectsRequests = [];
  List<Usuario> usersList = [];
  List<Brand> brandsList = [];
  List<Bono> bonosList = [];
  // Variables
  bool allPurchasesFetched = false;
  DateTime lastFetchedPurchaseDate = DateTime.now();
  String lastFetchedPurchaseId = "";
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  DateTime dateJoinedBrand = DateTime.now();
  // Filters
  bool orderByDescending = true;
  // Filters
  List<bool> filterByPurchaseStatus = [true, true, true];
  List<bool> filterByActivePurchases = [true, true];

  ///////////////////// DATA FETCHING

  /// FETCH INITIAL BRAND
  Future<void> fetchInitialUserPurchases() async {
    try {
      print("Brand Initial Fetch");

      /// Set the State to Loading
      emit(const UserPurchasesLoading());

      /// Lists
      List<Purchase> purchasesList = [];
      List<PurchaseHistoryModel> purchasesHistoryListsPurchases = [];

      /// Fetch initial purchases
      purchasesList = await _purchaseDataService.getBrandUserPurchases(
          userId, brandId, startDate, endDate, true);
      if (purchasesList.isNotEmpty) {
        lastFetchedPurchaseId = purchasesList.last.id!;
        lastFetchedPurchaseDate = purchasesList.last.purchasedAt!.toDate();
      }

      /// Process the purchases list and build PurchaseHistoryModel objects.
      for (Purchase p in purchasesList) {
        if (purchaseGroupId == null ||
            purchaseGroupId == '' ||
            p.purchaseGroupId == purchaseGroupId) {
          // Get User
          Usuario user = usersList.firstWhere(
              (element) => element.id == p.userId,
              orElse: () => Usuario());
          if (user.id == null) {
            user = await _userDataService.getUserCoverDetails(p.userId!);
          }
          usersList.add(user);
          // Get User
          Brand brand = brandsList.firstWhere(
              (element) => element.id == p.brandId,
              orElse: () => Brand());
          if (brand.id == null) {
            brand = await _brandDataService.getBrandCoverDetails(p.brandId!);
          }
          brandsList.add(brand);
          // Get Bono
          Bono bono = bonosList.firstWhere((element) => element.id == p.bonoId,
              orElse: () => Bono());
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
            purchaseStatus: p.directPurchase != null && p.directPurchase!
                ? PurchaseStatus.DIRECT
                : PurchaseStatus.CONFIRMED,
          );
          // After processing the list, add the new purchases to the existing list of purchases.
          purchasesHistoryListsPurchases.add(obj);
        }
      }

      /// Date Time Definition
      int threshold = 10;
      startDate = DateTime.now();
      endDate = DateTime.now();
      dateJoinedBrand = DateTime(
        int.parse(currentBrand.dateJoined!.split("-")[2]),
        int.parse(currentBrand.dateJoined!.split("-")[1]),
        int.parse(currentBrand.dateJoined!.split("-")[0]),
        0,
        0,
      );
      // Determine the start date based on the number of documents fetched
      if (purchasesList.length < threshold) {
        startDate = dateJoinedBrand; // Fetch from dateJoinedBrand
      } else {
        List<int> durations = [7, 14, 30, 90];
        for (int duration in durations) {
          startDate = endDate.subtract(Duration(days: duration));
          List<Purchase> purchasesListTemp = List.from(purchasesList);
          purchasesListTemp.removeWhere((element) {
            return element.purchasedAt!.toDate().isBefore(startDate) ||
                element.purchasedAt!.toDate().isAfter(endDate);
          });
          if (purchasesListTemp.length >= threshold) break;
        }
      }
      // Define the Past Purchases to the Global Object
      purchasesHistoryObjectsPurchases =
          List.from(purchasesHistoryListsPurchases);
      purchasesHistoryObjects = List.from(purchasesHistoryListsPurchases);
      openBrandRequestsStream();
      openPurchasesStream();
    } catch (e) {
      print("Brand Purchases Error$e");
      emit(UserPurchasesError(e.toString()));
    }
  }

  /// FETCH MORE BRAND
  Future<List<PurchaseHistoryModel>> fetchMoreUserPurchases(
      String lastPurchaseId) async {
    try {
      print("Getting More Brand Purchases");
      // Vars
      List<PurchaseHistoryModel> purchasesHistoryListsPurchases = [];
      // Fetch more purchases with the new dates
      List<Purchase> morePurchases =
          await _purchaseDataService.getBrandUserPurchases(
              userId, brandId, startDate, lastFetchedPurchaseDate);
      // Update the date of the last fetched purchase
      if (morePurchases.isNotEmpty) {
        lastFetchedPurchaseId = morePurchases.last.id!;
        lastFetchedPurchaseDate = morePurchases.last.purchasedAt!.toDate();
      } else {
        allPurchasesFetched = true;
        print("allPurchasesFetched");
      }
      // Handle The Object Creation Efficiently
      for (Purchase p in morePurchases) {
        if (purchaseGroupId == null ||
            purchaseGroupId == '' ||
            p.purchaseGroupId == purchaseGroupId) {
          // Get User
          Usuario user = usersList.firstWhere(
              (element) => element.id == p.userId,
              orElse: () => Usuario());
          if (user.id == null) {
            user = await _userDataService.getUserCoverDetails(p.userId!);
          }
          usersList.add(user);
          // Get User
          Brand brand = brandsList.firstWhere(
              (element) => element.id == p.brandId,
              orElse: () => Brand());
          if (brand.id == null) {
            brand = await _brandDataService.getBrandCoverDetails(p.brandId!);
          }
          brandsList.add(brand);
          // Get Bono
          Bono bono = bonosList.firstWhere((element) => element.id == p.bonoId,
              orElse: () => Bono());
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
            purchaseStatus: p.directPurchase != null && p.directPurchase!
                ? PurchaseStatus.DIRECT
                : PurchaseStatus.CONFIRMED,
          );
          purchasesHistoryListsPurchases.add(obj);
        }
      }
      // Emit a new state with the list of `Events`.
      purchasesHistoryObjects =
          List.from(purchasesHistoryObjects + purchasesHistoryListsPurchases);
      // Change the order of the List
      if (orderByDescending) {
        purchasesHistoryObjects.sort((a, b) {
          var aDate = a.purchasedAt.toDate();
          var bDate = b.purchasedAt.toDate();
          return bDate.compareTo(aDate);
        });
      } else {
        purchasesHistoryObjects.sort((a, b) {
          var aDate = a.purchasedAt.toDate();
          var bDate = b.purchasedAt.toDate();
          return aDate.compareTo(bDate);
        });
      }
      // Filter the results by the current date range
      List<PurchaseHistoryModel> filteredDateList =
          List.from(purchasesHistoryObjects);
      filteredDateList.removeWhere((element) {
        // Remove the ones before the start date or after the end date
        return element.purchasedAt.toDate().isBefore(startDate) ||
            element.purchasedAt.toDate().isAfter(endDate);
      });
      return filteredDateList;
    } catch (e) {
      print("Get More Brand Purchases Error: $e");
      emit(UserPurchasesError(e.toString()));
      return [];
    }
  }

  /// OPEN BONO REQUEST STREAM
  Future<void> openBrandRequestsStream() async {
    try {
      /// Open the Stream to Get Brand Requests
      _subscriptionBonoRequests =
          _brandDataService.getBonosRequestsFromBrand(brandId).listen(
        (querySnapshot) async {
          List<DocumentSnapshot> documents = querySnapshot.docs;
          List<PurchaseHistoryModel> purchasesHistoryListsRequests = [];
          List bonoRequestsList =
              _bonosUtils.documentsToBonosRequests(documents);
          for (BonoRequest req in bonoRequestsList) {
            // Only consider if it is from this user Id
            if (req.userId == userId) {
              // Get User
              Usuario user = usersList.firstWhere(
                  (element) => element.id == req.userId,
                  orElse: () => Usuario());
              if (user.id == null) {
                user = await _userDataService.getUserCoverDetails(req.userId!);
              }
              usersList.add(user);
              // Get User
              Brand brand = brandsList.firstWhere(
                  (element) => element.id == req.brandId,
                  orElse: () => Brand());
              if (brand.id == null) {
                brand =
                    await _brandDataService.getBrandCoverDetails(req.brandId!);
              }
              brandsList.add(brand);
              // Get Bono
              Bono bono = bonosList.firstWhere(
                  (element) => element.id == req.bonoId,
                  orElse: () => Bono());
              if (bono.id == null) {
                bono = await _brandDataService.getBonoInfo(
                    req.brandId!, req.bonoId!);
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
          }
          // Emit a new state with the list of `Events`.
          purchasesHistoryObjects = List.from(
              purchasesHistoryObjectsPurchases + purchasesHistoryListsRequests);
          // Change the order of the List
          if (orderByDescending) {
            purchasesHistoryObjects.sort((a, b) {
              var aDate = a.purchasedAt.toDate();
              var bDate = b.purchasedAt.toDate();
              return bDate.compareTo(aDate);
            });
          } else {
            purchasesHistoryObjects.sort((a, b) {
              var aDate = a.purchasedAt.toDate();
              var bDate = b.purchasedAt.toDate();
              return aDate.compareTo(bDate);
            });
          }
          // Check the Last Purchase
          List<PurchaseHistoryModel> filteredDateList =
              List.from(purchasesHistoryObjects);
          filteredDateList.removeWhere((element) {
            // Remove the ones before the start date or after the end date
            if (endDate.day == element.purchasedAt.toDate().day &&
                endDate.month == element.purchasedAt.toDate().month &&
                endDate.year == element.purchasedAt.toDate().year) {
              endDate = DateTime.now();
              return false;
            }
            return element.purchasedAt.toDate().isBefore(startDate) ||
                element.purchasedAt.toDate().isAfter(endDate);
          });

          /// Emit New Status
          loadedState = UserPurchasesLoaded(
            startDate: startDate,
            endDate: endDate,
            dateJoinedBrand: dateJoinedBrand,
            purchasesHistoryObjects: filteredDateList,
            orderByDescending: orderByDescending,
            filterByPurchaseStatus: filterByPurchaseStatus,
            filterByActivePurchases: filterByActivePurchases,
            forceRebuild: false,
          );
          emit(loadedState);
          // Filter New Bono Request
          filterBy(filterByPurchaseStatus, filterByActivePurchases);
        },
        onError: (e) {
          print("Brand Requests Error$e");
          emit(UserPurchasesError(e.toString()));
        },
      );
    } catch (e) {
      print("Brand Purchases Error$e");
      emit(UserPurchasesError(e.toString()));
    }
  }

  /// OPEN NEW PURCHASE REQUESTS
  Future<void> openPurchasesStream() async {
    try {
      print("Stream PURCHASES");
      _subscriptionPurchases = _userDataService
          .getUserBrandPurchasesStream(userId, brandId)
          .skip(1)
          .listen(
        (querySnapshot) async {
          print("Stream PURCHASES New Data");
          for (var change in querySnapshot.docChanges) {
            print(change.type);
            print(querySnapshot.docChanges.length);
            if (change.type == DocumentChangeType.added) {
              print("purchase added");
              // Fetch the Purchase
              Purchase p =
                  Purchase.fromObjectAllData(change.doc.id, change.doc);
              // If the new purchase is inside current date that should have been fetched
              if (p.purchasedAt!.toDate().isAfter(lastFetchedPurchaseDate)) {
                // Get User
                Usuario user = usersList.firstWhere(
                    (element) => element.id == p.userId,
                    orElse: () => Usuario());
                if (user.id == null) {
                  user = await _userDataService.getUserCoverDetails(p.userId!);
                }
                usersList.add(user);
                // Get User
                Brand brand = brandsList.firstWhere(
                    (element) => element.id == p.brandId,
                    orElse: () => Brand());
                if (brand.id == null) {
                  brand =
                      await _brandDataService.getBrandCoverDetails(p.brandId!);
                }
                brandsList.add(brand);
                // Get Bono
                Bono bono = bonosList.firstWhere(
                    (element) => element.id == p.bonoId,
                    orElse: () => Bono());
                if (bono.id == null) {
                  bono = await _brandDataService.getBonoInfo(
                      p.brandId!, p.bonoId!);
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
                  purchaseStatus: p.directPurchase != null && p.directPurchase!
                      ? PurchaseStatus.DIRECT
                      : PurchaseStatus.CONFIRMED,
                );
                // Emit a new state with the list of `Events`.
                purchasesHistoryObjectsPurchases.add(obj);
                purchasesHistoryObjects =
                    List.from(purchasesHistoryObjectsPurchases);
                // Change the order of the List
                if (orderByDescending) {
                  purchasesHistoryObjects.sort((a, b) {
                    var aDate = a.purchasedAt.toDate();
                    var bDate = b.purchasedAt.toDate();
                    return bDate.compareTo(aDate);
                  });
                } else {
                  purchasesHistoryObjects.sort((a, b) {
                    var aDate = a.purchasedAt.toDate();
                    var bDate = b.purchasedAt.toDate();
                    return aDate.compareTo(bDate);
                  });
                }

                /// Emit New Status
                print("Stream PURCHASES Finished");
                emit(loadedState = loadedState.copyWith(
                    purchasesHistoryObjects: purchasesHistoryObjects));
                // Filter New Purchase
                filterBy(filterByPurchaseStatus, filterByActivePurchases);
              }
            } else if (change.type == DocumentChangeType.modified) {
              print("purchase modified");
              // Fetch the Purchase
              Purchase p =
                  Purchase.fromObjectAllData(change.doc.id, change.doc);
              // If the new purchase is inside current date that should have been fetched
              int index = purchasesHistoryObjects
                  .indexWhere((element) => element.purchase!.id == p.id);
              // Build Purchase Object
              PurchaseHistoryModel obj = PurchaseHistoryModel(
                user: purchasesHistoryObjects[index].user,
                brand: purchasesHistoryObjects[index].brand,
                bono: purchasesHistoryObjects[index].bono,
                bonoReq: null,
                purchase: p,
                purchasedAt: p.purchasedAt!,
                purchaseStatus: p.directPurchase != null && p.directPurchase!
                    ? PurchaseStatus.DIRECT
                    : PurchaseStatus.CONFIRMED,
              );
              // Remove the old object
              purchasesHistoryObjects.removeAt(index);
              purchasesHistoryObjects.insert(index, obj);

              /// Emit New Status
              emit(loadedState = loadedState.copyWith(
                  purchasesHistoryObjects: purchasesHistoryObjects));
              // Filter New Bono Request
              filterBy(filterByPurchaseStatus, filterByActivePurchases);
            } else if (change.type == DocumentChangeType.removed) {
              print("purchase removed");
              // Fetch the Purchase
              Purchase p =
                  Purchase.fromObjectAllData(change.doc.id, change.doc);
              // Find the old object position
              int index = purchasesHistoryObjects
                  .indexWhere((element) => element.purchase!.id == p.id);
              // Remove the old object
              purchasesHistoryObjects.removeAt(index);

              /// Emit New Status
              emit(loadedState = loadedState.copyWith(
                  purchasesHistoryObjects: purchasesHistoryObjects));
              // Filter New Bono Request
              filterBy(filterByPurchaseStatus, filterByActivePurchases);
            }
          }
        },
        onError: (e) {
          print("Brand Purchases Error$e");
          emit(UserPurchasesError(e.toString()));
        },
      );
    } catch (e) {
      print("Brand Purchases Error$e");
      emit(UserPurchasesError(e.toString()));
    }
  }

  ///////////////////// FILTERING/ORDERING EXISTENT DATA

  /// FILTER BY DATE RANGE
  Future<void> filterByDateRange(DateTime start, DateTime end) async {
    try {
      print("updateDateRange $startDate $endDate");
      startDate = start;
      endDate = end;
      // Remove Any Filters
      filterByPurchaseStatus = [true, true, true];
      filterByActivePurchases = [true, true];
      // Filter purchasesHistoryObjects by the new date range ...
      List<PurchaseHistoryModel> filteredDateList =
          List.from(purchasesHistoryObjects);
      filteredDateList.removeWhere((element) {
        // Remove the ones before the start date or after the end date
        return element.purchasedAt.toDate().isBefore(startDate) ||
            element.purchasedAt.toDate().isAfter(endDate);
      });
      // If the new endDate is after the date of the last fetched purchase, fetch more purchases
      if (startDate.isBefore(lastFetchedPurchaseDate) &&
          allPurchasesFetched == false) {
        print("startDate isBefore lastFetchedPurchaseDate");
        filteredDateList = await fetchMoreUserPurchases(lastFetchedPurchaseId);
        print("More Purchases Successfully Loaded");
      }
      // If the new endDate is before the date of the last fetched purchase, just emit the new state
      emit(
        loadedState = loadedState.copyWith(
          startDate: startDate,
          endDate: endDate,
          purchasesHistoryObjects: filteredDateList,
          filterByPurchaseStatus: filterByPurchaseStatus,
          filterByActivePurchases: filterByActivePurchases,
        ),
      );
      print("Date Range Successfully Updated");
    } catch (e) {
      print("Update Date Range Error$e");
      emit(UserPurchasesError(e.toString()));
    }
  }

  /// FILTER BY STATUS
  Future<void> filterBy(
      List<bool> filterStatus, List<bool> filterActive) async {
    try {
      print("filterByPurchaseStatus $filterStatus");
      print("filterByActivePurchases $filterActive");
      filterByPurchaseStatus = List.from(filterStatus);
      filterByActivePurchases = List.from(filterActive);

      /// Filter purchasesHistoryObjects by the current date range...
      List<PurchaseHistoryModel> filteredDateList =
          List.from(purchasesHistoryObjects);
      filteredDateList.removeWhere((element) {
        // Remove the ones before the start date or after the end date
        return element.purchasedAt.toDate().isBefore(startDate) ||
            element.purchasedAt.toDate().isAfter(endDate);
      });

      /// Filter By Type Of Status
      filteredDateList.removeWhere((element) {
        // Aux Function
        bool _matchesPurchaseStatusAux(
            PurchaseHistoryModel element, int index) {
          switch (index) {
            case 0:
              return element.purchaseStatus == PurchaseStatus.CONFIRMED;
            case 1:
              return element.purchaseStatus == PurchaseStatus.DIRECT;
            case 2:
              return element.purchaseStatus == PurchaseStatus.TO_CONFIRM;
            default:
              return false;
          }
        }

        // For Loop
        for (int i = 0; i < filterByPurchaseStatus.length; i++) {
          if (filterByPurchaseStatus[i] &&
              _matchesPurchaseStatusAux(element, i)) {
            return false;
          }
        }
        return true;
      });

      /// Filter By Type Of Active or InActive
      filteredDateList.removeWhere((element) {
        // Is Bono Request
        if (element.bonoReq != null) {
          if (filterByActivePurchases[0]) {
            return false;
          }
          if (filterByActivePurchases[1]) {
            return false;
          }
          return true;
        } else {
          // Is Purchase
          if (filterByActivePurchases[0] && (element.purchase!.isActive!)) {
            return false;
          }
          if (filterByActivePurchases[1] &&
              (element.purchase!.isActive == false)) {
            return false;
          }
          return true;
        }
      });
      emit(loadedState = loadedState.copyWith(
        forceRebuild: !loadedState.forceRebuild,
        orderByDescending: orderByDescending,
        filterByPurchaseStatus: filterByPurchaseStatus,
        filterByActivePurchases: filterByActivePurchases,
        purchasesHistoryObjects: filteredDateList,
      ));
    } catch (e) {
      print("Filter By Error$e");
      emit(UserPurchasesError(e.toString()));
    }
  }

  /// FILTER BY STATUS
  Future<void> filterByStatus(List<bool> filterBy) async {
    try {
      print("filterByPurchaseStatus $filterBy");
      filterByPurchaseStatus = List.from(filterBy);

      /// Filter purchasesHistoryObjects by the current date range...
      List<PurchaseHistoryModel> filteredDateList =
          List.from(purchasesHistoryObjects);
      filteredDateList.removeWhere((element) {
        // Remove the ones before the start date or after the end date
        return element.purchasedAt.toDate().isBefore(startDate) ||
            element.purchasedAt.toDate().isAfter(endDate);
      });

      /// Filter By Type Of Status
      filteredDateList.removeWhere((element) {
        // Aux Function
        bool _matchesPurchaseStatusAux(
            PurchaseHistoryModel element, int index) {
          switch (index) {
            case 0:
              return element.purchaseStatus == PurchaseStatus.CONFIRMED;
            case 1:
              return element.purchaseStatus == PurchaseStatus.DIRECT;
            case 2:
              return element.purchaseStatus == PurchaseStatus.TO_CONFIRM;
            default:
              return false;
          }
        }

        // For Loop
        for (int i = 0; i < filterByPurchaseStatus.length; i++) {
          if (filterByPurchaseStatus[i] &&
              _matchesPurchaseStatusAux(element, i)) {
            return false;
          }
        }
        return true;
      });
      emit(loadedState = loadedState.copyWith(
          orderByDescending: orderByDescending,
          filterByPurchaseStatus: filterByPurchaseStatus,
          purchasesHistoryObjects: filteredDateList,
          forceRebuild: !loadedState.forceRebuild));
    } catch (e) {
      print("Update Date Range Error$e");
      emit(UserPurchasesError(e.toString()));
    }
  }

  /// FILTER BY ACTIVE
  Future<void> filterByActive(List<bool> filterBy) async {
    try {
      print("filterByActivePurchases $filterBy");
      filterByActivePurchases = List.from(filterBy);

      /// Filter purchasesHistoryObjects by the current date range...
      List<PurchaseHistoryModel> filteredDateList =
          List.from(purchasesHistoryObjects);
      filteredDateList.removeWhere((element) {
        // Remove the ones before the start date or after the end date
        return element.purchasedAt.toDate().isBefore(startDate) ||
            element.purchasedAt.toDate().isAfter(endDate);
      });
      emit(loadedState = loadedState.copyWith(
          orderByDescending: orderByDescending,
          filterByActivePurchases: filterByActivePurchases,
          purchasesHistoryObjects: filteredDateList,
          forceRebuild: !loadedState.forceRebuild));
    } catch (e) {
      print("Update Date Range Error$e");
      emit(UserPurchasesError(e.toString()));
    }
  }

  /// ORDERING BY DATE
  Future<void> orderByDate(bool orderByDescending) async {
    try {
      print("orderByDate orderByDescending is $orderByDescending");
      this.orderByDescending = orderByDescending;
      purchasesHistoryObjects = List.from(purchasesHistoryObjects);
      // Change the order of the List
      if (this.orderByDescending) {
        purchasesHistoryObjects.sort((a, b) {
          var aDate = a.purchasedAt.toDate();
          var bDate = b.purchasedAt.toDate();
          return bDate.compareTo(aDate);
        });
      } else {
        purchasesHistoryObjects.sort((a, b) {
          var aDate = a.purchasedAt.toDate();
          var bDate = b.purchasedAt.toDate();
          return aDate.compareTo(bDate);
        });
      }
      filterBy(filterByPurchaseStatus, filterByActivePurchases);
      print("orderByDate Successfully Applied");
    } catch (e) {
      print("Order By Error$e");
      emit(UserPurchasesError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscriptionPurchases.cancel();
    _subscriptionBonoRequests.cancel();
    print("closing streams");
    return super.close();
  }
}
