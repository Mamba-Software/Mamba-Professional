import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart' as googlePlace;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/Location/LocationDataService.dart';
import 'package:mamba_castelldefels/commons/constants/GlobalVars.dart';
import 'package:mamba_castelldefels/app/style/AppColors.dart';
import 'package:mamba_castelldefels/commons/widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:uuid/uuid.dart';
import 'AddressSearch.dart';
import 'LocationPlacesSearch.dart';

class MyLocationsSelect extends StatefulWidget {
  String brandId;
  MyLocationsSelect({super.key, required this.brandId});

  @override
  _MyLocationsSelectState createState() => _MyLocationsSelectState();
}

class _MyLocationsSelectState extends State<MyLocationsSelect> {
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
  // Google Maps
  GoogleMapController? mapController;
  final Completer<GoogleMapController> _controller = Completer();

  Future<void> getAllLocations() async {
    setState(() {
      isLoading = false;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!_controller.isCompleted) {
      _controller.complete(controller);
      setState(() {
        mapController = controller;
      });
    }
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
                  AppLocalizations.of(context)!.myLocations,
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    size: MediaQuery.of(context).size.width * 0.06,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                ),
              ),
              body: LoadingView(),
            )
          : Scaffold(
              appBar: AppBar(
                title: Text(
                  AppLocalizations.of(context)!.myLocations,
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    size: MediaQuery.of(context).size.width * 0.06,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(null);
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
                        print('Error on locations');
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
                    color: AppColors.grey,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  StreamBuilder<QuerySnapshot>(
                      stream: _locationDataService
                          .getAllLocationsBrand(currentBrand.id!),
                      builder: (context, snapshot) {
                        if (snapshot.data == null) {
                          return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.65,
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
                                return ListTile(
                                  leading: Icon(
                                    location.isBaseLocation!
                                        ? Icons.home_filled
                                        : Icons.location_on_outlined,
                                    color: location.isBaseLocation!
                                        ? Theme.of(context)
                                            .colorScheme
                                            .secondary
                                        : Theme.of(context).primaryColor,
                                    size: MediaQuery.of(context).size.width *
                                        0.06,
                                  ),
                                  title: Text(location.description!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: location.isBaseLocation!
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                : Theme.of(context)
                                                    .primaryColor,
                                          )),
                                  onTap: () {
                                    Navigator.of(context).pop(location.id);
                                  },
                                );
                              });
                        }
                      }),
                  /*
            StreamBuilder<QuerySnapshot>(
                stream: _locationDataService.getAllLocationsBrand(currentBrand.id!),
                builder: (context, snapshot) {
                  if (snapshot == null || snapshot.data == null || snapshot.data!.docs == null ) {
                    return Container(
                        height: MediaQuery.of(context).size.height*0.65,
                        child: Center(
                            child: LoadingView()
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
                          CameraPosition _initialPosition = CameraPosition(target: LatLng(location.latitude!,location.longitude!));
                          Marker marker = Marker(
                            markerId: const MarkerId('1'),
                            position: LatLng(location.latitude!,location.longitude!),
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                            onTap: () {},
                          );
                          Set<Marker> markers = <Marker>{};
                          markers.add(marker);
                          return GestureDetector(
                            onTap: () async {
                              Navigator.of(context).pop(location.id);
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03, vertical: MediaQuery.of(context).size.width*0.02,),
                              child: Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                                      borderRadius: const BorderRadius.all(Radius.circular(15.0))
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: MediaQuery.of(context).size.height*0.1,
                                        width: MediaQuery.of(context).size.height*0.1,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            bottomLeft: Radius.circular(15),
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            bottomLeft: Radius.circular(15),
                                          ),
                                          child: GoogleMap(
                                            onMapCreated: _onMapCreated,
                                            initialCameraPosition: _initialPosition,
                                            scrollGesturesEnabled: false,
                                            zoomGesturesEnabled: false,
                                            rotateGesturesEnabled: false,
                                            mapToolbarEnabled: false,
                                            zoomControlsEnabled: false,
                                            minMaxZoomPreference: const MinMaxZoomPreference(16,16),
                                            myLocationButtonEnabled: false,
                                            mapType: MapType.satellite,
                                            markers: markers,
                                            trafficEnabled: false,
                                            indoorViewEnabled: false,
                                            buildingsEnabled: false,
                                            onTap: null,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              location.description!,
                                              style: Theme.of(context).textTheme.bodyText2,
                                            ),
                                            location.isBaseLocation! ? Text(
                                              AppLocalizations.of(context)!.baseLocation,
                                              style: Theme.of(context).textTheme.caption?.copyWith(height: 1.5),
                                            ) : Container(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                    );
                  }
                }
            ),

             */
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
