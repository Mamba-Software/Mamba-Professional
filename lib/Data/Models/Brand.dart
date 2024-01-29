// Model for a Brand in our App
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';

import 'ImageObject.dart';
import 'RequestToBrand.dart';

class Brand {
  String? id;
  String? adminID;
  String? logoUrl;
  String? name;
  String? description;
  String? dateJoined;
  String? roomId;
  String? baseLocation;
  int? numClients;
  int? numTrainers;
  var workShift;
  int? maxMembers;
  int? bookingWindow;
  int? bookingWindowMin;
  bool? freeSession;
  double? distance;
  String? city;
  String? zipCode;
  String? baseImage;
  double? longitude;
  double? latitude;
  bool? notShow;
  bool? directPurchase;
  int? gracePeriod;
  int? maxCanWeek;
  int? paymentTerms;

  Timestamp? endDatePay;
  String? subscriptionId;
  Map<String, dynamic>? subscription;
  List<String> promotions = [];

  List<ImageObject> imagesList = [];
  List<RequestToBrand> requestsList = [];
  List<Usuario> usersList = [];
  List<Event> eventsList = [];
  List<Location> locationList = [];

  Brand({
    this.id,
    this.adminID,
    this.logoUrl,
    this.name,
    this.description,
    this.dateJoined,
    this.roomId,
    this.baseLocation,
    this.numClients,
    this.numTrainers,
    this.workShift,
    this.maxMembers,
    this.bookingWindow,
    this.bookingWindowMin,
    this.freeSession,
    this.city,
    this.zipCode,
    this.baseImage,
    this.longitude,
    this.latitude,
    this.notShow,
    this.directPurchase,
    this.endDatePay,
    this.subscriptionId,
    this.subscription,
    this.gracePeriod,
    this.maxCanWeek,
    this.paymentTerms,
  });

  //////////////////// CONSTRUCTORS ///////////////////////////////////////////////////////////////////////////////////////////

  Brand.fromObjectAllData(
      String documentId, DocumentSnapshot documentSnapshot) {
    id = documentId;
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('adminID')) {
      adminID = documentSnapshot.get("adminID").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('logoUrl')) {
      logoUrl = documentSnapshot.get("logoUrl").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>).containsKey('name')) {
      name = documentSnapshot.get("name").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('description')) {
      description = documentSnapshot.get("description").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('dateJoined')) {
      dateJoined = documentSnapshot.get("dateJoined").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('roomId')) {
      roomId = documentSnapshot.get("roomId").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('baseLocation')) {
      baseLocation = documentSnapshot.get("baseLocation").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('numClients')) {
      numClients = documentSnapshot.get("numClients");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('numTrainers')) {
      numTrainers = documentSnapshot.get("numTrainers");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('workShift')) {
      workShift = documentSnapshot.get("workShift");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('maxMembers')) {
      maxMembers = documentSnapshot.get("maxMembers");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('bookingWindow')) {
      bookingWindow = documentSnapshot.get("bookingWindow");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('bookingWindowMin')) {
      bookingWindowMin = documentSnapshot.get("bookingWindowMin");
    } else {
      bookingWindowMin = 0;
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('freeSession')) {
      freeSession = documentSnapshot.get("freeSession");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('directPurchase')) {
      directPurchase = documentSnapshot.get("directPurchase");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('baseImage')) {
      baseImage = documentSnapshot.get("baseImage").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('endDatePay')) {
      endDatePay = documentSnapshot.get("endDatePay");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('subscriptionId')) {
      subscriptionId = documentSnapshot.get("subscriptionId").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('notShow')) {
      notShow = documentSnapshot.get("notShow");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('subscription')) {
      subscription = documentSnapshot.get("subscription");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('gracePeriod')) {
      gracePeriod = documentSnapshot.get("gracePeriod");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('maxCanWeek')) {
      maxCanWeek = documentSnapshot.get("maxCanWeek");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('paymentTerms')) {
      paymentTerms = documentSnapshot.get("paymentTerms");
    }
  }

  Brand.fromObjectOnlyCoverData(
      String documentId, DocumentSnapshot documentSnapshot) {
    id = documentId;
    if ((documentSnapshot.data() as Map<String, dynamic>).containsKey('name')) {
      name = documentSnapshot.get("name").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('logoUrl')) {
      logoUrl = documentSnapshot.get("logoUrl").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('dateJoined')) {
      dateJoined = documentSnapshot.get("dateJoined").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('paymentTerms')) {
      paymentTerms = documentSnapshot.get("paymentTerms");
    }
  }

  //////////////////// SETTERS ///////////////////////////////////////////////////////////////////////////////////////////

  // Set Basic Data
  set setBasicData(Brand brand) {
    name = brand.name;
    logoUrl = brand.logoUrl;
    adminID = brand.adminID;
    description = brand.description;
    dateJoined = brand.dateJoined;
    roomId = brand.roomId;
    baseLocation = brand.baseLocation;
    numClients = brand.numClients;
    numTrainers = brand.numTrainers;
    workShift = brand.workShift;
    maxMembers = brand.maxMembers;
    bookingWindow = brand.bookingWindow;
    bookingWindowMin = brand.bookingWindowMin;
    directPurchase = brand.directPurchase;
    freeSession = brand.freeSession;
    baseImage = brand.baseImage;
    endDatePay = brand.endDatePay;
    subscriptionId = brand.subscriptionId;
    subscription = brand.subscription;
    city = brand.city;
    zipCode = brand.zipCode;
    baseImage = brand.baseImage;
    latitude = brand.latitude;
    longitude = brand.longitude;
    notShow = brand.notShow;
    gracePeriod = brand.gracePeriod;
    maxCanWeek = brand.maxCanWeek;
    paymentTerms = brand.paymentTerms;
  }

  // Requests
  set setRequestList(List<RequestToBrand> requestList) {
    requestsList = requestList;
  }

  // Users
  set setUserList(List<Usuario> userList) {
    usersList = userList;
  }

  // Events
  set setEventsList(List<Event> eventsList) {
    this.eventsList = eventsList;
  }

  // Images
  set setImageList(List<ImageObject> imagesList) {
    this.imagesList = imagesList;
  }

  // Locations
  set setLocationList(List<Location> locationList) {
    this.locationList = locationList;
  }
}
