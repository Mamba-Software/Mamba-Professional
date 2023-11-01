// ignore_for_file: public_member_api_docs, sort_constructors_first
// This class represents the Object <Event> that will be showed in the Sesions Widget.
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';

import '../../../Data/Models/Usuario.dart';

class Event {
  String? id;
  String? eventGroupId;
  String? creatorID;
  String? brandID;
  bool? isPrivate;
  String? title;
  String? imageUrl;
  String? description;
  Timestamp? doneAt;
  Timestamp? createdAt;
  String? year;
  String? month;
  String? day;
  String? hour;
  String? minute;
  double? duration;
  String? locationId;
  int? numClients;
  int? numTrainers;
  int? maxMembers;
  int? placesLeft;
  double? intensityScore;
  double? averageIntensityScore;
  int? feedbackEntries;
  var joinedMembers;
  var selectedTrainers;
  var bonos;
  String? brandName;
  String? brandLogo;
  Map<Bono, bool>? eventBonos;
  List<Bono>? allBonos;
  DateTime? startDate;
  List<Usuario> usersList = [];
  List<Brand>? brandsList = [];
  Location? location;
  List<Usuario>? joinedMembersList;
  List<Usuario>? selectedTrainersList;

  Event({
    this.id,
    this.eventGroupId,
    this.creatorID,
    this.brandID,
    this.isPrivate,
    this.title,
    this.imageUrl,
    this.description,
    this.doneAt,
    this.createdAt,
    this.year,
    this.month,
    this.day,
    this.hour,
    this.minute,
    this.duration,
    this.locationId,
    this.numClients,
    this.numTrainers,
    this.maxMembers,
    this.placesLeft,
    this.intensityScore,
    this.averageIntensityScore,
    this.feedbackEntries,
    this.joinedMembers,
    this.selectedTrainers,
    this.bonos,
    this.allBonos,
    this.location,
    this.startDate,
    this.brandName,
    this.brandLogo,
    this.eventBonos,
    this.joinedMembersList,
    this.selectedTrainersList,
  });

  //////////////////// CONSTRUCTORS ///////////////////////////////////////////////////////////////////////////////////////////

  Event.fromObjectAllData(
      String documentId, DocumentSnapshot documentSnapshot) {
    id = documentId;
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('eventGroupId')) {
      eventGroupId = documentSnapshot.get("eventGroupId");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('creatorID')) {
      creatorID = documentSnapshot.get("creatorID").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('brandID')) {
      brandID = documentSnapshot.get("brandID").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('isPrivate')) {
      isPrivate = documentSnapshot.get("isPrivate");
    } else {
      isPrivate = false;
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('title')) {
      title = documentSnapshot.get("title").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('imageUrl')) {
      imageUrl = documentSnapshot.get("imageUrl").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('description')) {
      description = documentSnapshot.get("description").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('doneAt')) {
      doneAt = documentSnapshot.get("doneAt");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('createdAt')) {
      createdAt = documentSnapshot.get("createdAt");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>).containsKey('year')) {
      year = documentSnapshot.get("year").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('month')) {
      month = documentSnapshot.get("month").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>).containsKey('day')) {
      day = documentSnapshot.get("day").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>).containsKey('hour')) {
      hour = documentSnapshot.get("hour").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('minute')) {
      minute = documentSnapshot.get("minute").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('duration')) {
      duration = double.parse(documentSnapshot.get("duration").toString());
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('locationId')) {
      locationId = documentSnapshot.get("locationId").toString();
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
        .containsKey('maxMembers')) {
      maxMembers = documentSnapshot.get("maxMembers");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('intensityScore')) {
      intensityScore =
          double.parse(documentSnapshot.get("intensityScore").toString());
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('averageIntensityScore')) {
      averageIntensityScore = double.parse(
          documentSnapshot.get("averageIntensityScore").toString());
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('feedbackEntries')) {
      feedbackEntries = documentSnapshot.get("feedbackEntries");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('joinedMembers')) {
      joinedMembers = documentSnapshot.get("joinedMembers");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('selectedTrainers')) {
      selectedTrainers = documentSnapshot.get("selectedTrainers");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('bonos')) {
      bonos = documentSnapshot.get("bonos");
    }
  }

  Event.fromObjectOnlyCoverData(
      String documentId, DocumentSnapshot documentSnapshot) {
    id = documentId;
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('isPrivate')) {
      isPrivate = documentSnapshot.get("isPrivate");
    } else {
      isPrivate = false;
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('title')) {
      title = documentSnapshot.get("title").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('imageUrl')) {
      imageUrl = documentSnapshot.get("imageUrl").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('doneAt')) {
      doneAt = documentSnapshot.get("doneAt");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('createdAt')) {
      createdAt = documentSnapshot.get("createdAt");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>).containsKey('year')) {
      year = documentSnapshot.get("year").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('month')) {
      month = documentSnapshot.get("month").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>).containsKey('day')) {
      day = documentSnapshot.get("day").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>).containsKey('hour')) {
      hour = documentSnapshot.get("hour").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('minute')) {
      minute = documentSnapshot.get("minute").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('duration')) {
      duration = double.parse(documentSnapshot.get("duration").toString());
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
        .containsKey('maxMembers')) {
      maxMembers = documentSnapshot.get("maxMembers");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('intensityScore')) {
      intensityScore =
          double.parse(documentSnapshot.get("intensityScore").toString());
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('averageIntensityScore')) {
      averageIntensityScore = double.parse(
          documentSnapshot.get("averageIntensityScore").toString());
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('feedbackEntries')) {
      feedbackEntries = documentSnapshot.get("feedbackEntries");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('brandID')) {
      brandID = documentSnapshot.get("brandID").toString();
    }
  }

  //////////////////// SETTERS ///////////////////////////////////////////////////////////////////////////////////////////

  // Set Basic Data
  set setBasicData(Event event) {
    creatorID = event.creatorID;
    brandID = event.brandID;
    title = event.title;
    imageUrl = event.imageUrl;
    description = event.description;
    year = event.year;
    month = event.month;
    day = event.day;
    hour = event.hour;
    minute = event.minute;
    duration = event.duration;
    locationId = event.locationId;
    numClients = event.numClients;
    numTrainers = event.numTrainers;
    maxMembers = event.maxMembers;
    intensityScore = event.intensityScore;
    averageIntensityScore = event.averageIntensityScore;
    feedbackEntries = event.feedbackEntries;
    joinedMembers = event.joinedMembers;
    selectedTrainers = event.selectedTrainers;
    bonos = event.bonos;
  }

  // Users
  set setUserList(List<Usuario> userList) {
    usersList = userList;
  }

  // Brands
  set setBrandList(List<Brand> brandList) {
    brandsList = brandList;
  }

  // Locations
  set setLocation(Location location) {
    this.location = location;
  }

  // Locations
  set setBrandId(String brandID) {
    this.brandID = brandID;
  }

  Event copyWith({
    String? id,
    String? eventGroupId,
    String? creatorID,
    String? brandID,
    bool? isPrivate,
    String? title,
    String? imageUrl,
    String? description,
    Timestamp? doneAt,
    Timestamp? createdAt,
    String? year,
    String? month,
    String? day,
    String? hour,
    String? minute,
    double? duration,
    String? locationId,
    int? numClients,
    int? numTrainers,
    int? maxMembers,
    int? placesLeft,
    double? intensityScore,
    double? averageIntensityScore,
    int? feedbackEntries,
    var joinedMembers,
    var selectedTrainers,
    var bonos,
    String? brandName,
    String? brandLogo,
    Map<Bono, bool>? eventBonos,
    List<Bono>? allBonos,
    DateTime? startDate,
    Location? location,
    List<Usuario>? joinedMembersList,
    List<Usuario>? selectedTrainersList,
  }) {
    return Event(
      id: id ?? this.id,
      eventGroupId: eventGroupId ?? this.eventGroupId,
      creatorID: creatorID ?? this.creatorID,
      brandID: brandID ?? this.brandID,
      isPrivate: isPrivate ?? this.isPrivate,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      doneAt: doneAt ?? this.doneAt,
      createdAt: createdAt ?? this.createdAt,
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      duration: duration ?? this.duration,
      locationId: locationId ?? this.locationId,
      numClients: numClients ?? this.numClients,
      numTrainers: numTrainers ?? this.numTrainers,
      maxMembers: maxMembers ?? this.maxMembers,
      placesLeft: placesLeft ?? this.placesLeft,
      intensityScore: intensityScore ?? this.intensityScore,
      averageIntensityScore:
          averageIntensityScore ?? this.averageIntensityScore,
      feedbackEntries: feedbackEntries ?? this.feedbackEntries,
      joinedMembers: joinedMembers ?? this.joinedMembers,
      selectedTrainers: selectedTrainers ?? this.selectedTrainers,
      bonos: bonos ?? this.bonos,
      brandName: brandName ?? this.brandName,
      brandLogo: brandLogo ?? this.brandLogo,
      eventBonos: eventBonos ?? this.eventBonos,
      allBonos: allBonos ?? this.allBonos,
      startDate: startDate ?? this.startDate,
      location: location ?? this.location,
      joinedMembersList: joinedMembersList ?? this.joinedMembersList,
      selectedTrainersList: selectedTrainersList ?? this.selectedTrainersList,
    );
  }
}
