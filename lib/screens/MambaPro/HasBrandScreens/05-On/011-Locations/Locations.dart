import 'dart:async';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart' as googlePlace;
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/mixins/platform.dart';
import 'package:mamba/data/DataService/Location/LocationDataService.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/utils/Images/ImageUtils.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/commons/widgets/loading/LoadingView.dart';
import 'package:mamba/data/Models/Location.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Location/LocationImageTile.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/LocationAutoComplete/AddressSearch.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/LocationAutoComplete/LocationPlacesSearch.dart';
import 'package:mamba/home/cubit/home_navigation_manager.dart';
import 'package:mamba/home/widgets/appbar/ResponsiveSliverAppBar.dart';
import 'package:mamba/notifications/Unread/widgets/askSupport.dart';
import 'package:mamba/notifications/Unread/widgets/profileImage.dart';
import 'package:mamba/notifications/Unread/widgets/unreadChats.dart';
import 'package:mamba/notifications/Unread/widgets/unreadNotifications.dart';
import 'package:uuid/uuid.dart';

class Locations extends StatefulWidget {
  String brandId;

  Locations({
    super.key,
    required this.brandId,
  });

  @override
  _LocationsState createState() => _LocationsState();
}

class _LocationsState extends State<Locations> with PlatformMixin {
  // App Bar and Scroll View
  ScrollController? _scrollController;
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    return _scrollController!.hasClients &&
        _scrollController!.offset >
            (MediaQuery.of(context).size.height * 0.15 - kToolbarHeight);
  }

  // Acceso a Base de Datos
  final _locationDataService = LocationDataService();
  // Google APIS
  googlePlace.GooglePlace? gPlace;
  googlePlace.DetailsResult? detailsResult;
  // Boolean Loading
  bool isLoading = false;
  bool canEdit = false;
  String loadingText = "";
  // Search Controller
  var searchClientsController = TextEditingController();
  var searchTrainersController = TextEditingController();
  // Locations From Brand
  List<Location> locationList = [];
  Location baseLocation = Location();
  // Location Containers
  final CarouselController carouselController = CarouselController();
  List<Widget> locationContainers = [];
  int selectedLocation = 0;

  // Map Variables
  Set<Marker> markers = <Marker>{};
  CameraPosition _initialPosition =
      const CameraPosition(target: LatLng(26.8206, 30.8025));
  GoogleMapController? mapController;

  void initCameraPosition() {
    setState(() {
      _initialPosition = CameraPosition(
          target: LatLng(baseLocation.latitude!, baseLocation.longitude!),
          zoom: 15);
    });
  }

  void createMarkers() async {
    setState(() {
      markers.clear();
    });
    // Set all Markers
    //print("Current Markers "+markers.length.toString());
    final Uint8List markerIcon = await ImageUtils()
        .getBytesFromAsset('assets/images/fitnessMapIcon.png', 150);
    //print("Creating "+locationList.length.toString()+" markers...");
    for (int i = 0; i < locationList.length; i++) {
      Location location = locationList[i];
      Marker marker = Marker(
        markerId: MarkerId(i.toString()),
        position: LatLng(location.latitude!, location.longitude!),
        anchor: const Offset(0.5, 0.5),
        icon: BitmapDescriptor.fromBytes(markerIcon),
        onTap: () {
          setState(() {
            selectedLocation = i;
            carouselController.animateToPage(selectedLocation);
          });
        },
      );
      // Add to Containers List
      setState(() {
        markers.add(marker);
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> getAllLocations() async {
    locationList =
        await _locationDataService.getAllBrandLocations(widget.brandId);
    //print("Location length "+locationList.length.toString());
    // Put Base Location First.
    int index =
        locationList.indexWhere((element) => element.isBaseLocation! == true);
    locationList.insert(0, locationList[index]);
    locationList.removeAt(index + 1);
    baseLocation = locationList[0];
    selectedLocation = 0;
    // Create List of Containers
    setState(() {
      locationContainers.clear();
    });
    var tempList = locationList
        .map((i) => Column(
              children: [
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(15.0),
                  child: LocationImageTile(
                    height: MediaQuery.of(context).size.height * 0.16,
                    width: MediaQuery.of(context).size.width,
                    locationId: i.id!,
                    brandId: currentBrand.id!,
                    canEdit: canEdit,
                    locationChanged: (boolean) async {
                      if (boolean == true) {
                        setState(() {
                          isLoading = true;
                          loadingText =
                              "${context.l10n.updating} ${context.l10n.locations.toLowerCase()}...";
                        });
                        await Future.delayed(const Duration(seconds: 4));
                        getAllLocations();
                      }
                    },
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01)
              ],
            ))
        .toList();
    setState(() {
      locationContainers = tempList;
    });
    initCameraPosition();
    createMarkers();
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> addNewLocation() async {
    if (!brandIsActive) {
      await navigateToPayWall(context);
    } else {
      mixpanel!.timeEvent('brand_locations_added');
      // Generate a new token here
      final sessionToken = const Uuid().v4();
      final language = currentUser.idioma;
      final Suggestion? result = await showSearch(
        context: context,
        delegate: AddressSearch(sessionToken, language!),
      );
      // We have a result for our locations search
      if (result!.placeId != "") {
        // Reload the Map
        setState(() {
          isLoading = true;
          loadingText =
              "${context.l10n.updating} ${context.l10n.locations.toLowerCase()}...";
        });
        Location location = Location();
        location.placeId = result.placeId;
        final placeDetails = await LocationPlacesSearch(sessionToken, language)
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
        // Build Correct Description
        location.description =
            "${location.street} ${location.streetNumber}, ${location.city}, ${location.zipCode}";
        // Get Latitude/Longitude
        var temp = await gPlace!.details.get(location.placeId!);
        if (temp != null && temp.result != null && mounted) {
          detailsResult = temp.result;
          location.latitude = detailsResult!.geometry!.location!.lat!;
          location.longitude = detailsResult!.geometry!.location!.lng!;
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
        await Future.delayed(const Duration(seconds: 4));
        getAllLocations();
        mixpanel!.track('brand_locations_added');
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(
        () => _isAppBarExpanded
            ? setState(() {
                appBarExpanded = true;
              })
            : setState(() {
                appBarExpanded = false;
              }),
      );
    canEdit = currentUser.brandRole < 2 ? true : false;
    isLoading = true;
    gPlace = googlePlace.GooglePlace(isAndroid
        ? dotenv.env['PLACES_API_ANDROID']!
        : dotenv.env['PLACES_API_IOS']!);
    if (isAndroid) {
      AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
    }
    getAllLocations();
  }

  FlexibleSpaceBar returnFlexibleSpaceBar(double height) {
    return FlexibleSpaceBar(
      background: Container(
        color: AppColors.darkGrey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.locations,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.white,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              color: AppColors.grey,
              height: 1.0,
            ),
          ],
        ),
      ),
      titlePadding: EdgeInsets.zero,
      //centerTitle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _scrollController,
        slivers: [
          ResponsiveSliverAppBar(
            height: context.height * 0.15,
            title: context.l10n.locations,
            appBarExpanded: appBarExpanded,
            flexibleSpace: returnFlexibleSpaceBar(
              context.height * 0.15,
            ),
          ),
          isLoading
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      Expanded(
                        child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.65,
                            child: Center(
                                child: LoadingView(
                              text: loadingText,
                            ))),
                      ),
                    ],
                  ),
                )
              : SliverFillRemaining(
                  hasScrollBody: false,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: _initialPosition,
                        scrollGesturesEnabled: true,
                        zoomGesturesEnabled: true,
                        rotateGesturesEnabled: true,
                        mapToolbarEnabled: false,
                        zoomControlsEnabled: false,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        minMaxZoomPreference: const MinMaxZoomPreference(5, 20),
                        buildingsEnabled: false,
                        markers: markers,
                        mapType: MapType.normal,
                        onTap: null,
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.width * 0.05),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.18,
                            width: MediaQuery.of(context).size.width,
                            child: GestureDetector(
                              child: CarouselSlider(
                                items: locationContainers,
                                carouselController: carouselController,
                                options: CarouselOptions(
                                    autoPlay: false,
                                    enlargeCenterPage: true,
                                    enableInfiniteScroll: false,
                                    initialPage: selectedLocation,
                                    viewportFraction: 0.82,
                                    onPageChanged: (index, reason) {
                                      setState(() {
                                        selectedLocation = index;
                                        mapController = mapController;
                                      });
                                      Location location =
                                          locationList[selectedLocation];
                                      mapController!.animateCamera(
                                          CameraUpdate.newCameraPosition(
                                              CameraPosition(
                                        target: LatLng(location.latitude!,
                                            location.longitude!),
                                        zoom: 15,
                                      )));
                                    }),
                              ),
                            ),
                          )),
                    ],
                  ),
                )
        ],
      ),
      floatingActionButton: canEdit
          ? Padding(
              padding: isAndroid
                  ? const EdgeInsets.symmetric(vertical: 20, horizontal: 10)
                  : const EdgeInsets.all(10),
              child: SizedBox(
                height: MediaQuery.of(context).size.width * 0.15,
                width: MediaQuery.of(context).size.width * 0.15,
                child: FloatingActionButton(
                  onPressed: addNewLocation,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: const Icon(
                    Icons.add,
                    color: AppColors.white,
                  ),
                ),
              ))
          : Container(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
