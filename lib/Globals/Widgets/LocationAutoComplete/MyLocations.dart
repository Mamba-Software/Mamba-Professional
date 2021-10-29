import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart' as googlePlace;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/Location.dart';

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

  Future<void> getAllLocations() async {
    setState(() {
      isLoading = false;
    });
  }

  @override
  initState() {
    isLoading = true;
    getAllLocations();
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
          iconTheme: IconThemeData(
            color: Styles.accent, //change your color here
          ),
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
                      if(placeDetails.fullAddress!=null) location.description = placeDetails.fullAddress!;
                      // Get Latitude/Longitude
                      var temp = await gPlace!.details.get(location.placeId!);
                      if (temp != null && temp.result != null && mounted) {
                        detailsResult = temp.result;
                        location.latitude = detailsResult!.geometry!.location!.lat!;
                        location.latitude = detailsResult!.geometry!.location!.lng!;
                      }
                      // Save location to DataBase
                      bool isOkay = await _accessDatabase.addLocation(widget.brandId, location.placeId!, location.description!, location.street!, location.streetNumber!, location.city!, location.zipCode!, location.latitude!, location.longitude!);
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
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 0),
                child: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*
   ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: filteredClients.length,
                    itemBuilder: (context, index) {
                      Usuario user = filteredClients[index];
                      return Container(
                        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.01),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context, PageTransition(type: PageTransitionType.bottomToTop, child: ProfileViewUser(userID: user.id!)));
                          },
                          child: Container(
                              height: MediaQuery.of(context).size.height*0.10,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.04, right:  MediaQuery.of(context).size.width*0.04),
                                    child: CircularImage(
                                      size: MediaQuery.of(context).size.width*0.2,
                                      image: user.imageUrl,
                                      color: Theme.of(context).primaryColor,
                                      borderWidth: 1.5,
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width*0.40,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                user.name!,
                                                style: Styles.purpleTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.20),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 30,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              )
                          ),
                        ),
                      );
                    }
                ),
   */

  @override
  void dispose() {
    super.dispose();
  }

}