import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart' as googlePlace;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DatabaseAccess.dart';
import 'package:mamba_castelldefels/Data/LocationDataService.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/Location.dart';
import 'package:uuid/uuid.dart';

import '../../GlobalVars.dart';
import 'AddressSearch.dart';
import 'LocationPlacesSearch.dart';

class MyLocationsSelect extends StatefulWidget {
  String brandId;
  MyLocationsSelect({Key? key, required this.brandId}) : super(key: key);

  @override
  _MyLocationsSelectState createState() => _MyLocationsSelectState();
}

class _MyLocationsSelectState extends State<MyLocationsSelect> {

  // Acceso a Base de Datos
  var _locationDataService = new LocationDataService();
  // Google APIS
  googlePlace.GooglePlace? gPlace;
  googlePlace.DetailsResult? detailsResult;
  // Boolean Loading
  bool isLoading = false;
  // Search Controller
  var searchClientsController = TextEditingController();
  var searchTrainersController = TextEditingController();
  // Locations From Brand
  List<Location> locationList = [];

  Future<void> getAllLocations() async {
    setState(() {
      isLoading = false;
    });
  }

  @override
  initState() {
    isLoading = true;
    gPlace = googlePlace.GooglePlace(Platform.isAndroid ? placesAPIAndroid : placesAPIIOS);
    getAllLocations();
  }

  List<Location> documentsToLocations(List<DocumentSnapshot> documents) {
    List<Location> locations = [];
    for(int i = 0; i < documents.length; i++) {
      Location location = Location.fromObject(documents[i], documents[i].id);
      if (location.isBaseLocation!) {
        locations.add(location);
        break;
      }
    }
    for(int i = 0; i < documents.length; i++) {
      Location location = Location.fromObject(documents[i], documents[i].id);
      if (!location.isBaseLocation!) {
        locations.add(location);
      }
    }
    return locations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body:  isLoading ?
      Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.locations, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22), textAlign: TextAlign.center,),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 25,),
            onPressed: () async {
              Navigator.of(context).pop(null);
            },
          ),
        ),
        body: LoadingViewPurple(),
      )
          :
      Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.locations, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22), textAlign: TextAlign.center,),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 25,),
            onPressed: () async {
              Navigator.of(context).pop(null);
            },
          ),
        ),
        body: Column(
          children: [
            Padding(
                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.02),
                child: ListTile(
                  onTap: () async {
                    // Generate a new token here
                    final sessionToken = Uuid().v4();
                    final language = currentUser.idioma;
                    final Suggestion? result = await showSearch(
                      context: context,
                      delegate: AddressSearch(sessionToken, language!),
                    );
                    // We have a result for our locations search
                    if (result != null) {
                      Location location = Location();
                      location.placeId = result.placeId;
                      final placeDetails = await LocationPlacesSearch(sessionToken, language).getPlaceDetailFromId(location.placeId!);
                      // Get the information on Strings
                      if(placeDetails.street!=null) location.street = placeDetails.street!;
                      if(placeDetails.streetNumber!=null) location.streetNumber = placeDetails.streetNumber!; else location.streetNumber="N/A";
                      if(placeDetails.city!=null) location.city = placeDetails.city!;
                      if(placeDetails.zipCode!=null) location.zipCode = placeDetails.zipCode!; else location.zipCode="N/A";
                      //if(placeDetails.fullAddress!=null) location.description = placeDetails.fullAddress!;
                      // Build Correct Description
                      location.description = "${location.street} ${location.streetNumber}, ${location.city}, ${location.zipCode}";
                      // Get Latitude/Longitude
                      var temp = await gPlace!.details.get(location.placeId!);
                      if (temp != null && temp.result != null && mounted) {
                        detailsResult = temp.result;
                        location.latitude = detailsResult!.geometry!.location!.lat!;
                        location.longitude = detailsResult!.geometry!.location!.lng!;
                      }
                      // Save location to DataBase
                      await _locationDataService.addLocation(widget.brandId, false, location.placeId!, location.description!, location.street!, location.streetNumber!, location.city!, location.zipCode!, location.latitude!, location.longitude!);
                    }
                  },
                  leading: Icon(
                    Icons.add_location,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.addLocation,
                    style: Styles.purpleTextStyle.copyWith(fontSize: 16),
                  ),
                ),
            ),
            Container(
              height: 1,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.01),
            StreamBuilder<QuerySnapshot>(
                stream: _locationDataService.getAllLocationsBrand(currentBrand.id!),
                builder: (context, snapshot) {
                  if (snapshot == null || snapshot.data == null || snapshot.data!.docs == null ) {
                    return Container(
                        height: MediaQuery.of(context).size.height*0.65,
                        child: Center(
                            child: LoadingViewPurple()
                        )
                    );
                  } else {
                    locationList = documentsToLocations(snapshot.data!.docs);
                    return ListView.builder(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: locationList.length,
                        itemBuilder: (context, index) {
                          Location location = locationList[index];
                          return ListTile(
                              leading: Icon(location.isBaseLocation! ? Icons.home_filled : Icons.location_on_outlined, color: location.isBaseLocation! ?  Theme.of(context).accentColor : Theme.of(context).primaryColor, size: 25,),
                              title: Text(
                                  location.description!,
                                  style: Styles.purpleTextStyle.copyWith(fontSize: 16, color: location.isBaseLocation! ?  Theme.of(context).accentColor : Theme.of(context).primaryColor,)
                              ),
                              onTap: () {
                                Navigator.of(context).pop(location.id);
                              },
                            );
                        }
                    );
                  }
                }
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.01),
          ],
        ),
      ),
    );
  }

  /*

   */

  @override
  void dispose() {
    super.dispose();
  }

}