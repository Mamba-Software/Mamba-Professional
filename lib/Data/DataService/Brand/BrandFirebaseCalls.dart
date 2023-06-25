import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/LibraryModels/lImage.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Condition.dart';
import 'package:mamba_castelldefels/Data/Models/ImageObject.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'package:mamba_castelldefels/Data/Models/Subscription.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Data/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/Utils/GeoFlutterFire/GeoFlutterUtils.dart';
import 'package:uuid/uuid.dart';

// Brand Firebase Service Class. All calls to Firebase are in this class.
class BrandFirebaseCalls {
  // Firebase Instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final batch = FirebaseFirestore.instance.batch();

  // Firebase collections
  String library = isProduction ? 'Library' : 'Library';
  String brands = isProduction ? 'Brands' : '7777 Brands';
  String users = isProduction ? 'Users' : '7777 Users';
  String events = isProduction ? 'Events' : '7777 Events';
  String locations = isProduction ? 'Locations' : '7777 Locations';
  String purchases = isProduction ? 'Purchases' : '7777 Purchases';
  String subscriptions = isProduction ? 'Subscriptions' : '7777 Subscriptions';

  //Utils

  Future<Usuario> getUserDetails(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore
        .collection(users).doc(uid).get();
    return Usuario.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
  }

  Future<User?> getCurrentUser() async {
    User? currentUser;
    currentUser = _auth.currentUser;
    return currentUser;
  }

  Future<void> deleteBrandContentPicture(String brandID) async {
    await _firebaseStorage.ref().child("brands/"+ brandID +"/images/" + brandID + ".jpeg").delete();

  }

  Future<void> deleteBrandPhoto(String brandID) async {
    await _firebaseStorage.ref().child("brands/"+ brandID +"/images/" + brandID + ".jpeg").delete();
  }

  Future<bool> deleteLocation(String locationId, String? baseLocation) async {
    try {
      // If Base Location == null it means brand is getting deleted.
      if (baseLocation != null) {
        DateTime now = DateTime.now();
        List<Event> futureEventsList = [];
        // Filter out only the ones that are upcoming
        QuerySnapshot querySnapshot =  await _firestore.collection(locations).doc(locationId).collection("Events").get();
        for (int i = 0; i < querySnapshot.docs.length; i++) {
          Event event = Event.fromObjectOnlyCoverData(querySnapshot.docs[i].id, querySnapshot.docs[i]);
          var startDate = DateTime(
            int.parse(event.year!),
            int.parse(event.month!),
            int.parse(event.day!),
            int.parse(event.hour!),
            int.parse(event.minute!),
          );
          if (startDate.isAfter(now)) {
            futureEventsList.add(event);
          }
        }
        // Update Event Location With Base Location
        for (int i = 0; i < futureEventsList.length; i++) {
          Event event = futureEventsList[i];
          // Update Location Field in the main Doc
          await _firestore
              .collection(events)
              .doc(event.id)
              .update({
            "locationId": baseLocation,
          });
          await updateEventLocation(event.id!, baseLocation, locationId);
        }
      }
      // Delete Location
      await _firestore.collection(locations).doc(locationId).delete();
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<void> updateEventLocation(String eventId, String locationId, String previousLocation) async {
    try {
      // Delete Previous Location
      await _firestore
          .collection(events)
          .doc(eventId)
          .collection("Locations")
          .doc(previousLocation)
          .delete();
      // Add New Location
      Location location = await getSingleLocation(locationId);
      await _firestore
          .collection(events)
          .doc(eventId)
          .collection("Locations")
          .doc(locationId)
          .set({
        "description": location.description,
        "longitude": location.longitude,
        "latitude": location.latitude,
        ...GeoFlutterUtils.getGeoPoint(location.latitude!, location.longitude!),
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<Location> getSingleLocation(String locationId) async {
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot =
    await _firestore.collection(locations).doc(locationId).get();
    return Location.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
  }

  Future<void> deleteRequestToBrand(RequestToBrand request) async {
    await _firestore
        .collection(users)
        .doc(request.userId)
        .collection("Requests")
        .doc(request.id)
        .delete();
  }

  //Checkers

  Future<bool> checkIfBrandExists(String brandID) async {
    try {
      var userDocRef = await _firestore.collection(brands).doc(brandID);
      var doc = await userDocRef.get();
      if (doc.exists) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      e.toString();
      return false;
    }
  }

  Future<Brand?> checkUserIsBrandCreator(String userId) async {
    Brand brand = Brand();
    QuerySnapshot querySnapshot = await _firestore
        .collection(brands)
        .where("adminID", isEqualTo: userId)
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      brand = Brand.fromObjectAllData(
          querySnapshot.docs[i].id, querySnapshot.docs[i]);
    }
    if (brand.id == null)
      return null;
    else
      return brand;
  }

  Future<bool> checkIfBrandBonoHasPurchases(String brandId, String bonoId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(brands)
          .doc(brandId)
          .collection("Bonos")
          .doc(bonoId)
          .collection("Purchases")
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return true;
      } else {
        // Check if there is any open Request
        QuerySnapshot querySnapshot2 = await _firestore
            .collection(brands)
            .doc(brandId)
            .collection("Bonos")
            .doc("Bonos Requests")
            .collection("Bonos Requests")
            .where("bonoId", isEqualTo: bonoId)
            .get();
        if (querySnapshot2.docs.isNotEmpty) {
          return true;
        } else {
          return false;
        }
      }
    } catch (e) {
      e.toString();
      return false;
    }
  }


  //Getters

  Future<Brand> getBrandDetails(String brandID) async {
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(brands).doc(brandID).get();
    Brand brand = Brand.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
    List<ImageObject> contentImages = [];
    QuerySnapshot querySnapshot2 = await _firestore.collection(brands).doc(brand.id!).collection("Images").get();
    for (int i = 0; i < querySnapshot2.docs.length; i++) {
      contentImages.add(ImageObject.fromObjectAllData(querySnapshot2.docs[i].id, querySnapshot2.docs[i]));
    }
    brand.setImageList = contentImages;
    return brand;
  }

  Future<Brand> getBrandCoverDetails(String brandID) async {
    try {
      DocumentSnapshot<
          Map<String, dynamic>> _documentSnapshot = await _firestore
          .collection(brands).doc(brandID).get();
      return Brand.fromObjectOnlyCoverData(
          _documentSnapshot.id, _documentSnapshot);
    } catch (e) {
      print(e.toString());
      return Brand();
    }
  }

  Future<String> getBrandLogoUrl(String brandID) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(brands).doc(brandID).get();
      return _documentSnapshot.get("logoUrl");
    } catch (e) {
      print(e.toString());
      return "";
    }
  }

  Future<int> getBrandNumberRequests(String brandID) async {
    try {
      QuerySnapshot querySnapshot =
      await _firestore
          .collection(brands)
          .doc(brandID)
          .collection("Requests")
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      print(e.toString());
      return 0;
    }
  }

  Future<List<Usuario>> getBrandUsers(String brandId) async {
    List<Usuario> users = [];
    try {
      await _firestore.collection(brands).doc(brandId)
          .collection("Users")
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          users.add(Usuario.fromObjectOnlyCoverData(doc.id, doc));
        }
      });
      return users;
    } catch (e) {
      print(e.toString());
      return users;
    }
  }

  Future<List<Usuario>> getBrandTrainers(String brandId) async {
    List<Usuario> users = [];
    try {
      await _firestore.collection(brands).doc(brandId)
          .collection("Users")
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          if (doc.get("isTrainer") == true) {
            users.add(Usuario.fromObjectOnlyCoverData(doc.id, doc));
          }
        }
      });
      return users;
    } catch (e) {
      print(e.toString());
      return users;
    }
  }

  Future<List<Usuario>> getBrandClients(String brandId) async {
    List<Usuario> users = [];
    try {
      await _firestore.collection(brands).doc(brandId)
          .collection("Users")
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          if (doc.get("isTrainer") == false) {
            users.add(Usuario.fromObjectOnlyCoverData(doc.id, doc));
          }
        }
      });
      return users;
    } catch (e) {
      print(e.toString());
      return users;
    }
  }

  Future<List<Brand>> getAllBrands() async {
    List<Brand> brandList = [];
    QuerySnapshot querySnapshot = await _firestore.collection(brands).get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      brandList.add(
          Brand.fromObjectAllData(
              querySnapshot.docs[i].id, querySnapshot.docs[i]));
    }
    return brandList;
  }

  Future<List<Brand>> getAllBrandsFromUser(String userId) async {
    List<Brand> brandList = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(users)
        .doc(userId)
        .collection("Brands")
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      brandList.add(Brand.fromObjectOnlyCoverData(
          querySnapshot.docs[i].id, querySnapshot.docs[i]));
    }
    return brandList;
  }

  Future<List<ImageObject>> getBrandContentPictures(String brandID) async {
    // Get the Image documents of the Brand
    List<ImageObject> contentImages = [];
    QuerySnapshot querySnapshot = await _firestore.collection(brands).doc(brandID).collection("Images").get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      contentImages.add(ImageObject.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]));
    }
    return contentImages;
  }


  Future<String> getRandomBrandPhoto(String brandID) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection(brands).doc(brandID).collection("Images").get();
      Random rnd = Random();
      int index = rnd.nextInt(querySnapshot.size);
      ImageObject image = ImageObject.fromObjectAllData(querySnapshot.docs[index].id, querySnapshot.docs[index]);
      return image.url!;
    } catch (e) {
      QuerySnapshot querySnapshot = await _firestore.collection(library).doc('Images').collection("Events").get();
      Random rnd = Random();
      int index = rnd.nextInt(querySnapshot.size);
      lImage image = lImage.fromObjectAllData(querySnapshot.docs[index].id, querySnapshot.docs[index]);
      return image.url!;
    }
  }

  Future<List<Bono>> getAllBonosFromBrandList(String brandId) async {
    List<Bono> bonos = [];
    try {
      await _firestore.collection(brands).doc(brandId)
          .collection("Bonos")
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          bonos.add(Bono.fromObjectAllData(doc.id, doc));
        }
      });
      return bonos;
    } catch (e) {
      print(e.toString());
      return bonos;
    }
  }

  Future<Bono> getBonoInfo(String brandId, String bonoId) async {
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(brands).doc(brandId).collection("Bonos").doc(bonoId).get();
    return Bono.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
  }

  Future<int> getUserBrandRole(String brandId, String userId) async {
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(brands).doc(brandId).collection("Users").doc(userId).get();
    try {
      return _documentSnapshot.get("role");
    } catch (e) {
      return 3;
    }

  }

  Future<List<Event>> getAllEventsFromBrandStats(String brandId) async {
    Timestamp now = Timestamp.fromDate(DateTime.now());
    List<Event> events = [];

    QuerySnapshot querySnapshot = await _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Events")
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      if(querySnapshot.docs[i].id != 'Private Events' && querySnapshot.docs[i].id != 'Recurrent Events') {
        events.add(Event.fromObjectOnlyCoverData(
            querySnapshot.docs[i].id, querySnapshot.docs[i]));
      }
    }
/*
    querySnapshot = await _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Events").doc('Private Events').collection('Private Events')
        .get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      events.add(Event.fromObjectOnlyCoverData(
          querySnapshot.docs[i].id, querySnapshot.docs[i]));

    }*/

    return events;
  }

  Future<List<Usuario>> getBrandUsersStats(String brandId) async {
    List<Usuario> users = [];
    Usuario user;
    List<Brand> brandList = [];
    Brand brand;
    try {
      await _firestore.collection(brands).doc(brandId)
          .collection("Users")
          .get()
          .then((snapshot) async {
        for (DocumentSnapshot doc in snapshot.docs) {
          user = Usuario.fromObjectOnlyCoverData(doc.id, doc);
          if(!user.isTrainer!)
            {
              users.add(user);
            }
          //user = await getUserDetails(doc.id);
          //brandList = await getAllBrandsFromUser(doc.id);
          //brand = brandList.firstWhere((element) => element.id == brandId);
        }
      });
      return users;
    } catch (e) {
      print(e.toString());
      return users;
    }
  }

  Future<List<Purchase>> getBrandPurchases(String brandId) async {
    List<Purchase> purchasesList = [];
    Purchase purchase;
    try {
      await _firestore
          .collection(purchases)
          .where("brandId", isEqualTo: brandId)
          .get()
          .then((snapshot) async {
        for (DocumentSnapshot doc in snapshot.docs) {
          purchase = Purchase.fromObjectAllData(doc.id, doc);
          //user = await getUserDetails(doc.id);
          //brandList = await getAllBrandsFromUser(doc.id);
          //brand = brandList.firstWhere((element) => element.id == brandId);
          purchasesList.add(purchase);
        }
      });
      return purchasesList;
    } catch (e) {
      print(e.toString());
      return purchasesList;
    }
  }

  Future<List<Bono>> getAllBonosFromBrandStats(String brandId) async {
    List<Bono> bonos = [];
    try {
      await _firestore.collection(brands).doc(brandId)
          .collection("Bonos")
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          bonos.add(Bono.fromObjectAllData(doc.id, doc));
        }
      });
      return bonos;
    } catch (e) {
      print(e.toString());
      return bonos;
    }
  }


  // Get Brand Subscription
  Future<Subscription> getBrandSubscription(String brandId, String subscriptionId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> _documentSnapshot =
      await _firestore.collection(brands).doc(brandId)
          .collection('Subscriptions').doc(subscriptionId).get();
        return Subscription.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
    }
    catch (e){
      print(e);
      return Subscription();
    }
  }

  //Add

  Future<String> addBrand(String name, File image, String description, List<double> workShift, int maxMembers, int bookingWindow) async {
    QuerySnapshot querySnapshot3 = await _firestore.collection(library).doc('Images').collection("Events").get();
    Random rnd = Random();
    int index = rnd.nextInt(querySnapshot3.size);
    //int index = 0;

    bool firestoreError = false;
    var uid = const Uuid().v4();
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String formatted = formatter.format(now);
    await _firestore.collection(brands).doc(uid).set({
      "adminID": currentUser.id!,
      "logoUrl": "",
      "name": name,
      "description": description,
      "dateJoined": formatted,
      "baseLocation": null,
      "numClients": 0,
      "numTrainers": 1,
      "workShift": workShift,
      "maxMembers": maxMembers,
      "bookingWindow": bookingWindow,
      "isActive": false,
      "baseImage": ImageObject.fromObjectAllData(querySnapshot3.docs[index].id, querySnapshot3.docs[index]).url!,
      "directPurchase": false,
    }).catchError((err) {
      print(err);
      firestoreError = true;
    });

    if (!firestoreError) {
      await updateBrandPhoto(uid, image);
      return uid;
    } else {
      return "Error";
    }
  }

  Future<void> addUserToBrand(String userId, String brandId, int role) async {
    Usuario user = await getUserDetails(userId);
    await _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Users")
        .doc(userId)
        .set({
      "name": user.name,
      "firstName": user.firstName,
      "lastName": user.lastName,
      "nick": user.nick,
      "imageUrl": user.imageUrl,
      "noImageUrl": user.noImageUrl,
      "isTrainer": user.isTrainer,
      "isPrivate": user.isPrivate,
      "notificationToken": user.notificationToken,
      "role": role,
    }).catchError((err) {
      print(err);
    });
  }

  Future<void> addBrandContentPictureIndividual(String brandID, File image) async {
    // Add each brand to the .../BrandId/images directory
    final uid = const Uuid().v4();
    // Upload the image to Firebase Storage
    var storageRef = _firebaseStorage.ref().child("brands/"+ brandID +"/images/" + uid + ".jpeg");
    var uploadTask = storageRef.putFile(image);
    await uploadTask.whenComplete(() async {
      await storageRef.getDownloadURL().then((value) async {
        // Add Image to the Brand Images Subcollection
        await _firestore.collection(brands).doc(brandID)
        .collection("Images")
        .doc(uid)
        .set({
          "url": value,
          "timestamp": Timestamp.now(),
          "isBaseImage": false,
        });
      });
    });
  }

  Future<void> addBrandContentPictures(String brandID, List<File> images) async {
    // Add each brand to the .../BrandId/images directory
    for (var i=0; i<images.length; i++) {
      var image = images[i];
      final uid = const Uuid().v4();
      // Upload the image to Firebase Storage
      var storageRef = _firebaseStorage.ref().child("brands/"+ brandID +"/images/" + uid + ".jpeg");
      var uploadTask = storageRef.putFile(image);
      await uploadTask.whenComplete(() async {
        await storageRef.getDownloadURL().then((value) async {
          // Add Image to the Brand Images Subcollection
          await _firestore.collection(brands).doc(brandID)
          .collection("Images")
          .doc(uid)
          .set({
            "url": value,
            "timestamp": Timestamp.now(),
            "isBaseImage": false,
          });
        });
      });
    }
  }

  Future<void> acceptRequestFromUser(RequestToBrand request) async {
    // Accept the user to Brand
    int role = 0;
    if (request.isTrainer!) {
      role = 3;
    }
    // New Database
    addUserToBrand(request.userId!, request.brandId!, role);
    // Delete the Request
    deleteRequestToBrand(request);
  }

  Future<void> addBonoToBrand(String brandId, Bono bono, Condition condition) async {
    var uid = const Uuid().v4();
    await _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Bonos")
        .doc(uid)
        .set({
      "title": bono.title!,
      "description": bono.description,
      "price": bono.price!,
      "sessions": bono.sessions,
      "isActive": bono.isActive,
      "color": bono.color,
      "compras": 0,
      "opacity": bono.opacity,
      "imageUrl": bono.imageUrl,
      "isDegradate": bono.isDegradate,
      "expirationTime": condition.expirationTime,
      "weeklySessions": condition.weeklySessions,
      "cancelTime": condition.cancelTime,
    }).catchError((err) {
      print(err);
    });

  }

  Future<void> addBonoRequestToBrand(String brandId, String userId, String bonoId, String title, String price, String classes, Timestamp timeRequested) async {
    var uid = const Uuid().v4();
    await _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Bonos")
        .doc("Bonos Requests")
        .collection("Bonos Requests")
        .doc(uid)
        .set({
      "userId": userId,
      "title": title,
      "price": price,
      "classes": classes,
      "bonoId": bonoId,
      "timeRequested": timeRequested,
    }).catchError((err) {
      print(err);
    });
  }

  //Update

  Future<void> updateBrandInfo(String brandID, String name, String description,
      int maxMembers, List<double> workShift, int bookingWindow, bool? directPurchase) async {
    await _firestore.collection(brands).doc(brandID).update({
      "name": name,
      "description": description,
      "maxMembers": maxMembers,
      "bookingWindow": bookingWindow,
      "workShift": workShift,
      "directPurchase": directPurchase,
    });
  }

  Future<String> updateBrandPhoto(String brandID, File image) async {
    var result;
    var storageRef = _firebaseStorage.ref().child("brands/"+ brandID +"/images/" + brandID + ".jpeg");
    var uploadTask = storageRef.putFile(image);
    await uploadTask.whenComplete(() async {
      await storageRef.getDownloadURL().then((value) async {
        result = value;
        await _firestore.collection(brands).doc(brandID).update({
          "logoUrl": value,
        });
      });
    });
    return result;
  }

  Future<void> updateBrandBaseImage(String brandID, ImageObject newBaseImage, String? oldBaseImage) async {
    // Brands Cover Data
    await _firestore.collection(brands).doc(brandID).update({
      "baseImage": newBaseImage.url!,
    });
    // Brands / Image
    await _firestore.collection(brands).doc(brandID).collection("Images").doc(newBaseImage.id).update({
      "isBaseImage": true,
    });
    // Only if there is an Old Base Image
    if (oldBaseImage != null) {
      await _firestore.collection(brands).doc(brandID).collection("Images").doc(oldBaseImage).update({
        "isBaseImage": false,
      });
    }
  }

  Future<void> updateBrandBaseLocation(String brandID, String locationID) async {
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore
        .collection(locations)
        .doc(locationID).get();
    Location location = Location.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
    await _firestore
        .collection(brands)
        .doc(brandID)
        .update({
      "baseLocation": locationID,
      "zipCode": location.zipCode,
      "city": location.city,
      "latitude": location.latitude,
      "longitude": location.longitude,
      ...GeoFlutterUtils.getGeoPoint(location.latitude!, location.longitude!),
    });
  }

  Future<void> updateBrandRoom(String brandID, String roomId) async {
    await _firestore.collection(brands).doc(brandID).update({
      "roomId": roomId,
    });
  }

  Future<void> updateBono(String brandId, Bono bono, Condition condition) async {
    await _firestore
    .collection(brands)
    .doc(brandId)
    .collection("Bonos")
    .doc(bono.id)
    .update({
      "title": bono.title!,
      "description": bono.description,
      "price": bono.price!,
      "sessions": bono.sessions,
      "isActive": bono.isActive,
      "color": bono.color,
      "opacity": bono.opacity,
      "imageUrl": bono.imageUrl,
      "isDegradate": bono.isDegradate,
      "expirationTime": condition.expirationTime,
      "weeklySessions": condition.weeklySessions,
      "cancelTime": condition.cancelTime,
    }).catchError((err) {
      print(err);
    });
  }

  Future<void> updateBonoCompras(String brandID, String bonoId) async {
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(brands).doc(brandID).collection("Bonos").doc(bonoId).get();
    Bono b = Bono.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
    await _firestore.collection(brands).doc(brandID).collection("Bonos").doc(bonoId).update({
      "compras": b.compras! + 1,
    });
  }

  Future<void> updateBonoActive(String brandID, String bonoId, bool isActive) async {
    DocumentSnapshot<Map<String, dynamic>> _documentSnapshot = await _firestore.collection(brands).doc(brandID).collection("Bonos").doc(bonoId).get();
    Bono b = Bono.fromObjectAllData(_documentSnapshot.id, _documentSnapshot);
    await _firestore.collection(brands).doc(brandID).collection("Bonos").doc(bonoId).update({
      "isActive": isActive,
    });
  }

  Future<void> updateUserBrandRole(String userId, String brandId, int role) async {
    await _firestore.collection(brands).doc(brandId).collection("Users").doc(userId).update({
      "role": role,
    });
  }

  Future<void> updateBrandPay(String brandID, int time, String subscriptionId, String title, DateTime endDate, bool revenueCatSub) async {
    Timestamp initTime = Timestamp.fromDate(DateTime.now());
    Timestamp endTime = Timestamp.fromDate(DateTime.now());
    var uid = const Uuid().v4();
    if(!revenueCatSub) {
      DateTime now = DateTime.now();
      initTime = Timestamp.fromDate(DateTime.now());
      var temp = now.add(Duration(days: time));
      endTime = Timestamp.fromDate(temp);
      await _firestore
          .collection(brands)
          .doc(brandID)
          .collection("Subscriptions")
          .doc(uid)
          .set({
        "subscriptionId": subscriptionId,
        "endDate": endTime,
        "startDate": initTime,
        "isActive": true,
        "title": title,
      });
    }
    else
      {
        initTime = Timestamp.fromDate(DateTime.now());
        endTime = Timestamp.fromDate(endDate);
        await _firestore
            .collection(brands)
            .doc(brandID)
            .collection("Subscriptions")
            .doc(uid)
            .set({
          "subscriptionId": subscriptionId,
          "endDate": endTime,
          "startDate": initTime,
          "isActive": true,
          "title": title,
          "isRevenueCat": revenueCatSub,
        });
      }

    await _firestore.collection(brands).doc(brandID).update({
      "endDatePay": endTime,
      "subscriptionId": uid,
    });
    await _firestore.collection(subscriptions).doc(subscriptionId).collection('Brands').doc(brandID).set({
      "useDate": initTime,
    });
  }

  Future<void> updateBrandSubscriptionRevenueCat(String brandID,String? expires_date, String? original_purchase_date, String? product_plan_identifier, String? unsuscribedAT) async {
    Map<String, dynamic> map = {
      "expires_date": expires_date,
      "original_purchase_date": original_purchase_date,
      "product_plan_identifier": product_plan_identifier,
      "brandIsActive": true,
      "unsuscribed": (unsuscribedAT == null) ? false : true,
    };
    print(map);
    await _firestore.collection(brands).doc(brandID).update({
      "subscription": map,
    });
  }

  //Delete

  Future<void> deleteBrand(String brandId) async {
    // Delete All Events from Brand
    await deleteBrandEvents(brandId);
    // Delete All Locations from Brand
    await deleteBrandLocations(brandId);
    // Delete All Users from Brand
    await deleteBrandUsers(brandId);
    // Delete Brand Photo
    await deleteBrandPhoto(brandId);
    // Delete Brand
    await _firestore.collection(brands).doc(brandId).delete();
  }

  Future<void> deleteUserFromBrand(String userId, String brandId) async {
    // Delete From Brand/Users
    await _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Users")
        .doc(userId)
        .delete();
    // Delete From Users/Brands
    await _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Users")
        .doc(userId)
        .delete();

  }

  Future<void> deleteBrandContentPictures(String brandID, String imageId, String? imageUrl) async {
    // Delete Image From Storage
    _firebaseStorage.ref().child("brands/"+ brandID +"/images/" + imageId + ".jpeg").delete();
    // Delete Image From Firebase Firestore
    await _firestore
        .collection(brands)
        .doc(brandID)
        .collection("Images")
        .doc(imageId)
        .delete();
    // Get a new Image of the Brand
    String newImageUrl = await getRandomBrandPhoto(brandID);
    // Get all places where we can find the picture in Events
    QuerySnapshot querySnapshot = await _firestore
        .collection(brands)
        .doc(brandID)
        .collection("Events")
        .where("imageUrl", isEqualTo: imageUrl)
        .get();
    // Update all places where we can find the picture in Events
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      Event event = Event.fromObjectOnlyCoverData(querySnapshot.docs[i].id, querySnapshot.docs[i]);
      await _firestore.collection(events).doc(event.id).update({
        "imageUrl": newImageUrl,
      });
    }
    // Get all places where we can find the picture in Events
    QuerySnapshot querySnapshotBonos = await _firestore
        .collection(brands)
        .doc(brandID)
        .collection("Bonos")
        .where("imageUrl", isEqualTo: imageUrl)
        .get();
    // Update all places where we can find the picture in Events
    for (int i = 0; i < querySnapshotBonos.docs.length; i++) {
      Bono bono = Bono.fromObjectAllData(querySnapshotBonos.docs[i].id, querySnapshotBonos.docs[i]);
      await _firestore.collection(brands).doc(brandID).collection("Bonos").doc(bono.id!).update({
        "imageUrl": newImageUrl,
      });
    }
  }

  Future<void> deleteBrandUsers(String brandId) async {
    await _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Users")
        .get().then((snapshot) async {
      for (DocumentSnapshot doc in snapshot.docs) {
        NotificationService().userLeavesBrand(doc.id, brandId);
        await doc.reference.delete();
      }
    });
  }

  Future<void> deleteBrandEvents(String brandId) async {
    await _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Events")
        .get()
        .then((snapshot) async {
          for (DocumentSnapshot doc in snapshot.docs) {
            await _firestore
            .collection(events)
            .doc(doc.id)
            .delete();
          }
        });
  }

  Future<void> deleteBrandLocations(String brandId) async {
    try {
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection(brands)
            .doc(brandId)
            .collection("Locations")
            .get();
        for (int i = 0; i < querySnapshot.docs.length; i++) {
          await deleteLocation(querySnapshot.docs[i].id, null);
        }
      } catch (e) {
        print(e.toString());
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Delete Brand Bono Request
  Future<void> deleteBrandBonoRequest(String brandId, String userId, String? bonoRequestId) async {
    // Delete in Brand/Bonos/BonosRequests
    await _firestore.collection(brands)
        .doc(brandId)
        .collection("Bonos")
        .doc("Bonos Requests")
        .collection("Bonos Requests")
        .doc(bonoRequestId)
        .delete();
    // Delete in Brand/Bonos/BonosRequests
    await _firestore.collection(users)
        .doc(userId)
        .collection("Bonos")
        .doc("Bonos Requests")
        .collection("Bonos Requests")
        .doc(bonoRequestId)
        .delete();
  }

  // Delete Brand Bono Request
  Future<void> deleteBrandBono(String brandId, String bonoId) async {
    // Delete Brand Bono
    await _firestore.collection(brands)
        .doc(brandId)
        .collection("Bonos")
        .doc(bonoId)
        .delete();
  }

  // Delete Brand Bono Request
  Future<void> deleteUserBrandBonos(String brandId, String userId) async {
    /// Get Active Purhcases
    QuerySnapshot querySnapshot = await _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Users")
        .doc(userId)
        .collection("Purchases")
        .where("isActive", isEqualTo: true)
        .get();
    /// Update the IsActive Field
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      Purchase purchase = Purchase.fromObjectAllData(querySnapshot.docs[i].id, querySnapshot.docs[i]);
      /// Purchases/{purchaseId}
      await _firestore.collection(purchases).doc(purchase.id!).update({
        "isActive": false,
      });
      /// Users/{userId}/Purchases/{purchaseId}
      await _firestore.collection(users).doc(userId).collection("Purchases").doc(purchase.id!).update({
        "isActive": false,
      });
      /// Brands/{brandId}/Purchases/{purchaseId}
      await _firestore.collection(brands).doc(brandId).collection("Purchases").doc(purchase.id!).update({
        "isActive": false,
      });
      /// Brands/{brandId}/Bonos/{bonoId}/Purchases/{purchaseId}
      await _firestore.collection(brands).doc(brandId).collection("Bonos").doc(purchase.bonoId!).collection("Purchases").doc(purchase.id!).update({
        "isActive": false,
      });
      /// Brands/{brandId}/Users/{userId}/Purchases/{purchaseId}
      await _firestore.collection(brands).doc(brandId).collection("Users").doc(userId).collection("Purchases").doc(purchase.id!).update({
        "isActive": false,
      });
    }
  }

  //STREAMS

  Stream<QuerySnapshot> getBrandTrainersStream(String brandId) {
    return _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Users")
        .where("isTrainer", isEqualTo: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getBrandRequestsStream(String brandId) {
    return _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Requests")
        .snapshots();
  }

  Stream<QuerySnapshot> getAllEventsFromBrand(String brandId) {
    return _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Events")
        .snapshots();
  }

  Stream<QuerySnapshot>  getAllBonosFromBrand(String brandId) {
    return _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Bonos")
        .snapshots();
  }

  Stream<QuerySnapshot>  getBonosRequestsFromBrand(String brandId) {
    return _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Bonos")
        .doc("Bonos Requests")
        .collection("Bonos Requests")
        .snapshots();
  }


  //Get bonos from brand
  Stream<DocumentSnapshot> getBonoInfoStream(String brandId, String bonoId) {
    return _firestore
        .collection(brands)
        .doc(brandId)
        .collection("Bonos")
        .doc(bonoId)
        .snapshots();
  }

  //Get subscription from brand
  Stream<DocumentSnapshot> getBrandSubscriptionStream(String brandId) {
    return _firestore
        .collection(brands)
        .doc(brandId)
        .snapshots();
  }

}
