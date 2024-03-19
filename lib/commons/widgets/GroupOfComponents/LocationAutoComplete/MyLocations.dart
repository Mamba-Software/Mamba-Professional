import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_place/google_place.dart' as googlePlace;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/data/DataService/Location/LocationDataService.dart';
import 'package:mamba_castelldefels/commons/constants/GlobalVars.dart';
import 'package:mamba_castelldefels/commons/widgets/GroupOfComponents/Dialogs/ActionDialogs/DeleteConfirmationDialog.dart';
import 'package:mamba_castelldefels/commons/widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/data/Models/Location.dart';
import 'package:uuid/uuid.dart';
import 'AddressSearch.dart';
import 'LocationPlacesSearch.dart';

class MyLocations extends StatefulWidget {
  String brandId;
  MyLocations({super.key, required this.brandId});

  @override
  _MyLocationsState createState() => _MyLocationsState();
}

class _MyLocationsState extends State<MyLocations> {
  // Acceso a Base de Datos
  final _locationDataService = LocationDataService();
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
    isLoading = true;
    gPlace = googlePlace.GooglePlace(Platform.isAndroid
        ? dotenv.env['PLACES_API_ANDROID']!
        : dotenv.env['PLACES_API_IOS']!);
    getAllLocations();
  }

  List<Location> documentsToLocations(List<DocumentSnapshot> documents) {
    List<Location> locations = [];
    for (int i = 0; i < documents.length; i++) {
      Location location =
          Location.fromObjectAllData(documents[i].id, documents[i]);
      if (location.isBaseLocation!) {
        locations.add(location);
        baseLocationId = location.id!;
        break;
      }
    }
    for (int i = 0; i < documents.length; i++) {
      Location location =
          Location.fromObjectAllData(documents[i].id, documents[i]);
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
      body: isLoading
          ? Scaffold(
              appBar: AppBar(
                title: Text(
                  AppLocalizations.of(context)!.locations,
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    size: MediaQuery.of(context).size.width * 0.06,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              body: LoadingView(),
            )
          : Scaffold(
              appBar: AppBar(
                title: Text(
                  AppLocalizations.of(context)!.locations,
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    size: MediaQuery.of(context).size.width * 0.06,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              body: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.width * 0.02),
                    child: ListTile(
                      onTap: () async {
                        // Generate a new token here
                        final sessionToken = const Uuid().v4();
                        final language = currentUser.idioma;
                        final Suggestion? result = await showSearch(
                          context: context,
                          delegate: AddressSearch(sessionToken, language!),
                        );
                        // We have a result for our locations search
                        if (result != null) {
                          Location location = Location();
                          location.placeId = result.placeId;
                          final placeDetails =
                              await LocationPlacesSearch(sessionToken, language)
                                  .getPlaceDetailFromId(location.placeId!);
                          // Get the information on Strings
                          if (placeDetails.street != null) {
                            location.street = placeDetails.street!;
                          } else {
                            location.street = "N/A";
                          }
                          if (placeDetails.streetNumber != null) {
                            location.streetNumber = placeDetails.streetNumber!;
                          } else {
                            location.streetNumber = "N/A";
                          }
                          if (placeDetails.city != null) {
                            location.city = placeDetails.city!;
                          } else {
                            location.city = "N/A";
                          }
                          if (placeDetails.zipCode != null) {
                            location.zipCode = placeDetails.zipCode!;
                          } else {
                            location.zipCode = "N/A";
                          }
                          //if(placeDetails.fullAddress!=null) location.description = placeDetails.fullAddress!;
                          // Build Correct Description
                          location.description =
                              "${location.street} ${location.streetNumber}, ${location.city}, ${location.zipCode}";
                          // Get Latitude/Longitude
                          var temp =
                              await gPlace!.details.get(location.placeId!);
                          if (temp != null && temp.result != null && mounted) {
                            detailsResult = temp.result;
                            location.latitude =
                                detailsResult!.geometry!.location!.lat!;
                            location.longitude =
                                detailsResult!.geometry!.location!.lng!;
                          }
                          // Save location to DataBase
                          await _locationDataService.addLocation(
                              widget.brandId,
                              false,
                              location.placeId!,
                              location.description!,
                              location.street!,
                              location.streetNumber!,
                              location.city!,
                              location.zipCode!,
                              location.latitude!,
                              location.longitude!);
                        }
                      },
                      leading: Icon(
                        Icons.add_location,
                        color: Theme.of(context).primaryColor,
                        size: MediaQuery.of(context).size.width * 0.06,
                      ),
                      title: Text(
                        AppLocalizations.of(context)!.addLocation,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  Container(
                    height: 1,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                        stream: _locationDataService
                            .getAllLocationsBrand(widget.brandId),
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {
                            return SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.65,
                                child: Center(child: LoadingView()));
                          } else {
                            locationList =
                                documentsToLocations(snapshot.data!.docs);
                            return ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: locationList.length,
                                itemBuilder: (context, index) {
                                  Location location = locationList[index];
                                  if (location.isBaseLocation!) {
                                    return Column(
                                      children: [
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.01),
                                        ListTile(
                                          leading: Icon(
                                            Icons.home_filled,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.06,
                                          ),
                                          title: Text(location.description!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary)),
                                          trailing: IconButton(
                                            onPressed: () async {
                                              // Generate a new token here
                                              final sessionToken =
                                                  const Uuid().v4();
                                              final language =
                                                  currentUser.idioma;
                                              final Suggestion? result =
                                                  await showSearch(
                                                context: context,
                                                delegate: AddressSearch(
                                                    sessionToken, language!),
                                              );
                                              // We have a result for our locations search
                                              if (result != null) {
                                                Location loc = Location();
                                                loc.placeId = result.placeId;
                                                final placeDetails =
                                                    await LocationPlacesSearch(
                                                            sessionToken,
                                                            language)
                                                        .getPlaceDetailFromId(
                                                            loc.placeId!);
                                                // Get the information on Strings
                                                if (placeDetails.street !=
                                                    null) {
                                                  loc.street =
                                                      placeDetails.street!;
                                                } else {
                                                  loc.street = "N/A";
                                                }
                                                if (placeDetails.streetNumber !=
                                                    null) {
                                                  loc.streetNumber =
                                                      placeDetails
                                                          .streetNumber!;
                                                } else {
                                                  loc.streetNumber = "N/A";
                                                }
                                                if (placeDetails.city != null) {
                                                  loc.city = placeDetails.city!;
                                                } else {
                                                  loc.city = "N/A";
                                                }
                                                if (placeDetails.zipCode !=
                                                    null) {
                                                  loc.zipCode =
                                                      placeDetails.zipCode!;
                                                } else {
                                                  loc.zipCode = "N/A";
                                                }
                                                //if(placeDetails.fullAddress!=null) location.description = placeDetails.fullAddress!;
                                                // Build Correct Description
                                                loc.description =
                                                    "${loc.street} ${loc.streetNumber}, ${loc.city}, ${loc.zipCode}";
                                                // Get Latitude/Longitude
                                                var temp = await gPlace!.details
                                                    .get(loc.placeId!);
                                                if (temp != null &&
                                                    temp.result != null &&
                                                    mounted) {
                                                  detailsResult = temp.result;
                                                  loc.latitude = detailsResult!
                                                      .geometry!.location!.lat!;
                                                  loc.longitude = detailsResult!
                                                      .geometry!.location!.lng!;
                                                }
                                                // Save location to DataBase
                                                await _locationDataService
                                                    .updateLocation(
                                                        location.id!,
                                                        widget.brandId,
                                                        true,
                                                        loc.placeId!,
                                                        loc.description!,
                                                        loc.street!,
                                                        loc.streetNumber!,
                                                        loc.city!,
                                                        loc.zipCode!,
                                                        loc.latitude!,
                                                        loc.longitude!);
                                              }
                                            },
                                            icon: Icon(
                                              Icons.edit,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              size: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.06,
                                            ),
                                          ),
                                          onTap: () {},
                                        ),
                                        Column(
                                          children: [
                                            SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.02),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.04),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .myLocationsBaseLocationDesc,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall,
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.02),
                                          ],
                                        ),
                                      ],
                                    );
                                  } else {
                                    return ListTile(
                                      leading: Icon(
                                        Icons.location_on_outlined,
                                        color: Theme.of(context).primaryColor,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.06,
                                      ),
                                      title: Text(
                                        location.description!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      trailing: IconButton(
                                        onPressed: () async {
                                          var result = await showDialog(
                                              context: context,
                                              builder: (_) {
                                                return DeleteConfirmationDialog(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .myLocationsDeleteDescription);
                                              });
                                          if (result) {
                                            _locationDataService.deleteLocation(
                                                location.id!, baseLocationId);
                                          }
                                        },
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.06,
                                        ),
                                      ),
                                      onTap: () {},
                                    );
                                  }
                                });
                          }
                        }),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
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
