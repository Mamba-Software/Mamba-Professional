import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart' as googlePlace;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/Location.dart';

import '../../GlobalVars.dart';
import 'AddressSearch.dart';
import 'LocationPlacesSearch.dart';

class MyLocations extends StatefulWidget {
  String brandId;
  MyLocations({Key? key, required this.brandId}) : super(key: key);

  @override
  _MyLocationsState createState() => _MyLocationsState();
}

class _MyLocationsState extends State<MyLocations> {

  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
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
      locations.add(Location.fromObject(documents[i], documents[i].id));
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
          title: Text(AppLocalizations.of(context)!.myLocations, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22), textAlign: TextAlign.center,),
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Styles.accent, //change your color here
          ),
        ),
        body: LoadingViewPurple(),
      )
          :
      Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.myLocations, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22), textAlign: TextAlign.center,),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.02, horizontal: MediaQuery.of(context).size.width*0.02),
                child: TextField(
                  onTap: () async {
                    // Generate a new token here
                    // TODO: Have a look at generating session token for Google Places API
                    final Suggestion? result = await showSearch(
                      context: context,
                      delegate: AddressSearch(),
                    );
                    // We have a result for our locations search
                    if (result != null) {
                      Location location = Location();
                      location.placeId = result.placeId;
                      final placeDetails = await LocationPlacesSearch().getPlaceDetailFromId(location.placeId!);
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
                      bool isOkay = await _accessDatabase.addLocation(widget.brandId, location.placeId!, location.description!, location.street!, location.streetNumber!, location.city!, location.zipCode!, location.latitude!, location.longitude!);
                      print(isOkay);
                    }
                  },
                  readOnly: true,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.addLocation,
                    hintStyle: Styles.purpleTextStyle.copyWith(fontSize: 16),
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.add_location,
                      color: Theme.of(context).primaryColor,
                    ),
                    contentPadding: EdgeInsets.only(top: 15),
                  ),
                )
            ),
            Container(
              height: 1,
              color: Theme.of(context).primaryColor,
            ),
            StreamBuilder<QuerySnapshot>(
                stream: _accessDatabase.getAllLocationsBrand(currentBrand.id!),
                builder: (context, snapshot) {
                  if (snapshot == null || snapshot.data == null || snapshot.data!.docs == null ) {
                    return Container(
                        height: MediaQuery.of(context).size.height*0.8,
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
                            leading: Icon(Icons.location_on_outlined, color: Theme.of(context).primaryColor, size: 25,),
                            title: Text(
                              location.description!,
                              style: Styles.purpleTextStyle.copyWith(fontSize: 16)
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                _accessDatabase.deleteLocation(location.id!);
                              },
                              icon: Icon(Icons.delete_outline, color: Colors.red, size: 25,),
                            ),
                            onTap: () {

                            },
                          );
                        }
                    );
                  }
                }
            ),
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