import 'dart:async';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart' as googlePlace;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/Location/LocationDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Location/LocationImageTile.dart';
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
  Location baseLocation = Location();
  // Location Containers
  final CarouselController carouselController = CarouselController();
  var locationContainers;
  int selectedLocation = 0;

  // Map Variables
  Set<Marker> markers = <Marker>{};
  BitmapDescriptor? customIcon;
  CameraPosition _initialPosition = const CameraPosition(target: LatLng(26.8206, 30.8025));
  GoogleMapController? mapController;
  final Completer<GoogleMapController> _controller = Completer();

  void initCameraPosition() {
    setState(() {
      _initialPosition = CameraPosition(target: LatLng(baseLocation.latitude!,baseLocation.longitude!), zoom: 15);
    });
  }

  void setCustomMarker() async {
    // Marker Icon
    customIcon = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(), 'assets/images/fitnessMapIcon.png');
  }

  void createMarkers() async {
    // Set all Markers
    markers = <Marker>{};
    for(int i = 0; i < locationList.length; i++) {
      Location location = locationList[i];
      Marker marker = Marker(
        markerId: MarkerId(i.toString()),
        position: LatLng (location.latitude!,location.longitude!),
        icon: customIcon!,
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
    if (!_controller.isCompleted) {
      _controller.complete(controller);
      setState(() {
        mapController = controller;
      });
    }
  }

  Future<void> getAllLocations() async {
    locationList = await _locationDataService.getAllBrandLocations(widget.brandId);
    for(int i = 0; i < locationList.length; i++) {
      Location location = locationList[i];
      if (location.isBaseLocation!) {
        baseLocation = location;
        selectedLocation = i;
        break;
      }
    }
    // Create List of Containers
    locationContainers = [];
    locationContainers = locationList.map((i)
      => LocationImageTile(
        height: MediaQuery.of(context).size.height*0.2,
        width: MediaQuery.of(context).size.width*0.9,
        locationId: i.id!,
        brandId: currentBrand.id!,
        locationChanged: (boolean) {
          if (boolean!) {
            setState(() {
              isLoading = true;
            });
            getAllLocations();
          }
        },
      )).toList();
    initCameraPosition();
    createMarkers();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        isLoading = false;
      });
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
    if (Platform.isAndroid) {
      AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
    }
    setCustomMarker();
    getAllLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.025),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.locations,
                            style: Theme.of(context).textTheme.headline1,
                          ),
                          FittedBox(
                            fit: BoxFit.fitHeight,
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height*0.08,
                              child: TextButton(
                                onPressed: () async {
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
                                    final placeDetails = await LocationPlacesSearch(sessionToken, language).getPlaceDetailFromId(location.placeId!);
                                    // Get the information on Strings
                                    if (placeDetails.street!=null) {
                                      location.street = placeDetails.street!;
                                    } else {
                                      location.street="N/A";
                                    }
                                    if(placeDetails.streetNumber!=null) {
                                      location.streetNumber = placeDetails.streetNumber!;
                                    } else {
                                      location.streetNumber="N/A";
                                    }
                                    if(placeDetails.city!=null) {
                                      location.city = placeDetails.city!;
                                    } else {
                                      location.city="N/A";
                                    }
                                    if(placeDetails.zipCode!=null) {
                                      location.zipCode = placeDetails.zipCode!;
                                    } else {
                                      location.zipCode="N/A";
                                    }
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
                                    // Reload the Map
                                    setState(() {
                                      isLoading = true;
                                    });
                                    getAllLocations();
                                  }
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline,
                                      color: Theme.of(context).primaryColor,
                                      size: MediaQuery.of(context).size.width*0.07,
                                    ),
                                    FittedBox(
                                      fit: BoxFit.contain,
                                      child: Text(
                                        AppLocalizations.of(context)!.add,
                                        style: Theme.of(context).textTheme.bodyText2,
                                        textAlign: TextAlign.center
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.01,),
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
          isLoading ? SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                Expanded(
                  child: SizedBox(
                      height: MediaQuery.of(context).size.height*0.65,
                      child: Center(
                          child: LoadingView()
                      )
                  ),
                ),
              ],
            ),
          ) : SliverFillRemaining(
            hasScrollBody: false,
            child: Stack(
              alignment: Alignment.bottomCenter,
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
                  myLocationButtonEnabled: true,
                  minMaxZoomPreference: const MinMaxZoomPreference(5,20),
                  buildingsEnabled: false,
                  markers: markers,
                  mapType: MapType.normal,
                  onTap: null,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.05),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height*0.2,
                    width: MediaQuery.of(context).size.width*0.9,
                    child: GestureDetector(
                      child: CarouselSlider(
                        items: locationContainers,
                        carouselController: carouselController,
                        options: CarouselOptions(
                            autoPlay: false,
                            enableInfiniteScroll: false,
                            initialPage: selectedLocation,
                            viewportFraction: 1,
                            onPageChanged: (index, reason) {
                              setState(() {
                                selectedLocation = index;
                              });
                              Location location = locationList[selectedLocation];
                              mapController!.animateCamera(CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                    target:  LatLng(location.latitude!,location.longitude!),
                                    zoom: 15,
                                  )
                              ));
                            }
                        ),
                      ),
                    ),
                  )
                    /*
                  Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height*0.2,
                        width: MediaQuery.of(context).size.width*0.9,
                        child: CarouselSlider(
                          items: locationContainers,
                          carouselController: carouselController,
                          options: CarouselOptions(
                              autoPlay: false,
                              enableInfiniteScroll: false,
                              initialPage: selectedLocation,
                              viewportFraction: 1,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  selectedLocation = index;
                                });
                              }
                          ),
                        ),
                      ),
                      /*
                      SizedBox(
                        height: MediaQuery.of(context).size.height*0.05,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: locationContainers.asMap().entries.map((entry) {
                            return GestureDetector(
                              onTap: () {
                                //mapController.
                                carouselController.animateToPage(entry.key);
                              },
                              child: Container(
                                width: 8.0,
                                height: 8.0,
                                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(selectedLocation == entry.key ? 0.9 : 0.4)
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                       */
                    ],
                  ),
                     */
                ),
                /*
                Padding(
                  padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.05),
                  child: locationContainers[selectedLocation],
                ),
                 */
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

}