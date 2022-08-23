import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart' as googlePlace;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/Location/LocationDataService.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/DeleteConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LocationAutoComplete/AddressSearch.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LocationAutoComplete/LocationPlacesSearch.dart';
import 'package:uuid/uuid.dart';

class Locations extends StatefulWidget {
  String brandId;
  bool pinned;
  ValueChanged<bool?> pinnedChanged;

  Locations({Key? key, required this.brandId, required this.pinned, required this.pinnedChanged}) : super(key: key);

  @override
  _LocationsState createState() => _LocationsState();
}

class _LocationsState extends State<Locations> {

  // App Bar and Scroll View
  ScrollController? _scrollController;
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    return _scrollController!.hasClients && _scrollController!.offset > (MediaQuery.of(context).size.height*0.15 - kToolbarHeight);
  }
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
  // String baseLocationId
  String baseLocationId = "";

  Future<void> getAllLocations() async {
    setState(() {
      isLoading = false;
    });
  }

  @override
  initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() => _isAppBarExpanded ?
      setState(() {
        appBarExpanded = true;
      }) :
      setState(() {
        appBarExpanded = false;
      }),
      );
    isLoading = true;
    gPlace = googlePlace.GooglePlace(Platform.isAndroid ? placesAPIAndroid : placesAPIIOS);
    getAllLocations();
  }

  List<Location> documentsToLocations(List<DocumentSnapshot> documents) {
    List<Location> locations = [];
    for(int i = 0; i < documents.length; i++) {
      Location location = Location.fromObjectAllData(documents[i].id, documents[i]);
      if (location.isBaseLocation!) {
        locations.add(location);
        baseLocationId = location.id!;
        break;
      }
    }
    for(int i = 0; i < documents.length; i++) {
      Location location = Location.fromObjectAllData(documents[i].id, documents[i]);
      if (!location.isBaseLocation!) {
        locations.add(location);
      }
    }
    return locations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            expandedHeight: MediaQuery.of(context).size.height*0.15,
            elevation: 4,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Theme.of(context).backgroundColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: kToolbarHeight + MediaQuery.of(context).size.height*0.051),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                      child: Text(
                        AppLocalizations.of(context)!.locations,
                        style: Theme.of(context).textTheme.headline1,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.035,),
                    Container(
                      color: AppColors.grey,
                      height: 1.0,
                    ),
                  ],
                ),
              ),
              titlePadding: EdgeInsets.zero,
              //centerTitle: true,
            ),
            title: appBarExpanded ? Text(AppLocalizations.of(context)!.locations, style: Theme.of(context).appBarTheme.titleTextStyle,) : Container(),
            centerTitle: true,
            leading: Builder(
              builder: (BuildContext innerContext) => Padding(
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.02),
                child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      size: MediaQuery.of(context).size.height*0.04,
                    ),
                    onPressed: () => mambaProScaffoldKey.currentState?.openDrawer()
                ),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.01),
                child: IconButton(
                  icon: Icon(
                    widget.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: widget.pinned ? AppColors.red : Theme.of(context).primaryColor.withOpacity(0.5),
                    size: MediaQuery.of(context).size.width*0.06,
                  ),
                  onPressed: () {
                    setState(() {
                      widget.pinned = !widget.pinned;
                    });
                    widget.pinnedChanged(widget.pinned);
                  },
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
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
                        if(placeDetails.street!=null) location.street = placeDetails.street!; else location.street="N/A";
                        if(placeDetails.streetNumber!=null) location.streetNumber = placeDetails.streetNumber!; else location.streetNumber="N/A";
                        if(placeDetails.city!=null) location.city = placeDetails.city!; else location.city="N/A";
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
                      size: MediaQuery.of(context).size.width*0.06,
                    ),
                    title: Text(
                      AppLocalizations.of(context)!.addLocation,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
              ],
            ),
          ),
          StreamBuilder<QuerySnapshot>(
              stream: _locationDataService.getAllLocationsBrand(widget.brandId),
              builder: (context, snapshot) {
                if (snapshot == null || snapshot.data == null || snapshot.data!.docs == null ) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Expanded(
                      child: SizedBox(
                          height: MediaQuery.of(context).size.height*0.65,
                          child: Center(
                              child: LoadingView()
                          )
                      ),
                    ),
                  );
                } else {
                  locationList = documentsToLocations(snapshot.data!.docs);
                  if (locationList.isNotEmpty) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                        Location location = locationList[index];
                        if (location.isBaseLocation!) {
                          return Column(
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height*0.01),
                              ListTile(
                                leading: Icon(Icons.home_filled, color: Theme.of(context).colorScheme.secondary, size: MediaQuery.of(context).size.width*0.06,),
                                title: Text(
                                    location.description!,
                                    style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).colorScheme.secondary)
                                ),
                                trailing: IconButton(
                                  onPressed: () async {
                                    // Generate a new token here
                                    final sessionToken = Uuid().v4();
                                    final language = currentUser.idioma;
                                    final Suggestion? result = await showSearch(
                                      context: context,
                                      delegate: AddressSearch(sessionToken, language!),
                                    );
                                    // We have a result for our locations search
                                    if (result != null) {
                                      Location loc = Location();
                                      loc.placeId = result.placeId;
                                      final placeDetails = await LocationPlacesSearch(sessionToken, language).getPlaceDetailFromId(loc.placeId!);
                                      // Get the information on Strings
                                      if(placeDetails.street!=null) loc.street = placeDetails.street!; else loc.street="N/A";
                                      if(placeDetails.streetNumber!=null) loc.streetNumber = placeDetails.streetNumber!; else loc.streetNumber="N/A";
                                      if(placeDetails.city!=null) loc.city = placeDetails.city!; else loc.city="N/A";
                                      if(placeDetails.zipCode!=null) loc.zipCode = placeDetails.zipCode!; else loc.zipCode="N/A";
                                      //if(placeDetails.fullAddress!=null) location.description = placeDetails.fullAddress!;
                                      // Build Correct Description
                                      loc.description = "${loc.street} ${loc.streetNumber}, ${loc.city}, ${loc.zipCode}";
                                      // Get Latitude/Longitude
                                      var temp = await gPlace!.details.get(loc.placeId!);
                                      if (temp != null && temp.result != null && mounted) {
                                        detailsResult = temp.result;
                                        loc.latitude = detailsResult!.geometry!.location!.lat!;
                                        loc.longitude = detailsResult!.geometry!.location!.lng!;
                                      }
                                      // Save location to DataBase
                                      await _locationDataService.updateLocation(location.id!,widget.brandId, true, loc.placeId!, loc.description!, loc.street!, loc.streetNumber!, loc.city!, loc.zipCode!, loc.latitude!, loc.longitude!);
                                    }
                                  },
                                  icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.secondary, size: MediaQuery.of(context).size.width*0.06,),
                                ),
                                onTap: () {

                                },
                              ),
                              Column(
                                children: [
                                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.04),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            AppLocalizations.of(context)!.myLocationsBaseLocationDesc,
                                            style: Theme.of(context).textTheme.caption,
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                                ],
                              ),
                            ],
                          );
                        } else {
                          return ListTile(
                            leading: Icon(Icons.location_on_outlined, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.06,),
                            title: Text(
                              location.description!,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                            trailing: IconButton(
                              onPressed: () async {
                                var result = await showDialog(
                                    context: context,
                                    builder: (_) {
                                      return DeleteConfirmationDialog(text: AppLocalizations.of(context)!.myLocationsDeleteDescription);
                                    }
                                );
                                if (result) {
                                  _locationDataService.deleteLocation(location.id!, baseLocationId);
                                }
                              },
                              icon: Icon(Icons.delete_outline, color: Colors.red, size: MediaQuery.of(context).size.width*0.06,),
                            ),
                            onTap: () {

                            },
                          );
                        }
                      },
                      childCount: locationList.length,
                      ),
                    );
                  } else {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                                width: MediaQuery.of(context).size.width*0.30,
                                child: Image.asset(Constants.emptyCalendar)
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.005),
                            Text(AppLocalizations.of(context)!.noRequestsFound, style: Theme.of(context).textTheme.caption, textAlign: TextAlign.center,),
                            SizedBox(height: MediaQuery.of(context).size.height*0.12),
                          ],
                        ),
                      ),
                    );
                  }
                }
              }
          ),
        ],
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