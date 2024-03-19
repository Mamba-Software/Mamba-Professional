import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_place/google_place.dart' as googlePlace;
import 'package:mamba_castelldefels/data/DataService/Location/LocationDataService.dart';
import 'package:mamba_castelldefels/data/Models/Location.dart';
import 'package:mamba_castelldefels/commons/constants/GlobalVars.dart';
import 'package:mamba_castelldefels/app/style/AppColors.dart';
import 'package:mamba_castelldefels/commons/widgets/GroupOfComponents/Dialogs/ActionDialogs/DeleteConfirmationDialog.dart';
import 'package:mamba_castelldefels/commons/widgets/GroupOfComponents/LocationAutoComplete/AddressSearch.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';

import '../LocationAutoComplete/LocationPlacesSearch.dart';

class LocationImageTile extends StatefulWidget {
  String locationId;
  String brandId;
  ValueChanged<bool?> locationChanged;
  bool canEdit;
  var height;
  var width;

  LocationImageTile(
      {super.key,
      required this.brandId,
      required this.locationId,
      required this.locationChanged,
      required this.height,
      required this.width,
      required this.canEdit});

  @override
  _LocationImageTileState createState() => _LocationImageTileState();
}

class _LocationImageTileState extends State<LocationImageTile> {
  // Boolean Loading
  bool isLoading = true;
  // Acceso a Base de Datos
  final _locationDataService = LocationDataService();
  // Google APIS
  googlePlace.GooglePlace? gPlace;
  googlePlace.DetailsResult? detailsResult;
  // Location
  Location location = Location();
  double locationPercentatgeEvents = 0;
  Map<String, double> dataMap = {
    "1": 1,
  };

  @override
  void initState() {
    isLoading = true;
    gPlace = googlePlace.GooglePlace(Platform.isAndroid
        ? dotenv.env['PLACES_API_ANDROID']!
        : dotenv.env['PLACES_API_IOS']!);
    initLocationTile();
    super.initState();
  }

  Future<void> initLocationTile() async {
    await getLocationDetails();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onLaunchCoordinates() {
    mixpanel!.track('brand_locations_tap');
    MapsLauncher.launchCoordinates(
        location.latitude!, location.longitude!, location.description!);
  }

  Future<void> getLocationDetails() async {
    location = await _locationDataService.getSingleLocation(widget.locationId);
    locationPercentatgeEvents = await _locationDataService
        .getLocationPercentatgeEvents(widget.brandId, widget.locationId);
    dataMap = {
      "1": locationPercentatgeEvents,
    };
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.background,
            highlightColor: AppColors.grey.withOpacity(0.3),
            child: Container(
              height: widget.height,
              width: widget.width,
              decoration: const BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
            ),
          )
        : Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: const BorderRadius.all(Radius.circular(15.0))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: widget.height,
                  width: widget.width * 0.55,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Container(
                      width: widget.width * 0.6,
                      constraints:
                          BoxConstraints(minHeight: widget.height * 0.15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(location.description!,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                          location.isBaseLocation!
                              ? Column(
                                  children: [
                                    SizedBox(
                                      height: widget.height * 0.07,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.home_filled,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.035,
                                        ),
                                        SizedBox(
                                          width: widget.width * 0.02,
                                        ),
                                        Text(
                                            AppLocalizations.of(context)!
                                                .baseLocation,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                    fontWeight:
                                                        FontWeight.w700),
                                            textAlign: TextAlign.center),
                                      ],
                                    ),
                                  ],
                                )
                              : Container(),
                          SizedBox(
                            height: widget.height * 0.05,
                          ),
                          locationPercentatgeEvents.isNaN == false
                              ? SizedBox(
                                  height: widget.height * 0.35,
                                  width: widget.width * 0.7,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      locationPercentatgeEvents > 0
                                          ? SizedBox(
                                              height: widget.height * 0.4,
                                              child: PieChart(
                                                legendOptions:
                                                    const LegendOptions(
                                                        showLegends: false),
                                                dataMap: dataMap,
                                                chartType: ChartType.disc,
                                                //baseChartColor: AppColors.darkerGrey,
                                                animationDuration:
                                                    const Duration(seconds: 0),
                                                colorList: const <Color>[
                                                  AppColors.grey
                                                ],
                                                emptyColor: AppColors.darkGrey,
                                                chartValuesOptions:
                                                    const ChartValuesOptions(
                                                        showChartValues: false,
                                                        showChartValuesInPercentage:
                                                            true,
                                                        decimalPlaces: 0),
                                                totalValue: 100,
                                              ),
                                            )
                                          : Container(),
                                      SizedBox(
                                        width: widget.width * 0.3,
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .percentageEvents(
                                                    locationPercentatgeEvents
                                                        .toStringAsFixed(0)),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                            textAlign: TextAlign.center),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: widget.height,
                  width: widget.width * 0.2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: widget.height * 0.7,
                        width: widget.width * 0.2,
                        child: IconButton(
                          onPressed: _onLaunchCoordinates,
                          icon: Icon(
                            Icons.directions,
                            size: widget.width * 0.15,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      widget.canEdit
                          ? SizedBox(
                              height: widget.height * 0.25,
                              width: widget.width * 0.2,
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: TextButton(
                                  onPressed: () async {
                                    if (!brandIsActive) {
                                      await navigateToPayWall(context);
                                    } else {
                                      if (location.isBaseLocation!) {
                                        // Generate a new token here
                                        final sessionToken = const Uuid().v4();
                                        final language = currentUser.idioma;
                                        final Suggestion? result =
                                            await showSearch(
                                          context: context,
                                          delegate: AddressSearch(
                                              sessionToken, language!),
                                        );
                                        // We have a result for our locations search
                                        if (result!.placeId != "") {
                                          Location loc = Location();
                                          loc.placeId = result.placeId;
                                          final placeDetails =
                                              await LocationPlacesSearch(
                                                      sessionToken, language)
                                                  .getPlaceDetailFromId(
                                                      loc.placeId!);
                                          // Get the information on Strings
                                          if (placeDetails.street != null) {
                                            loc.street = placeDetails.street!;
                                          } else {
                                            loc.street = "N/A";
                                          }
                                          if (placeDetails.streetNumber !=
                                              null) {
                                            loc.streetNumber =
                                                placeDetails.streetNumber!;
                                          } else {
                                            loc.streetNumber = "N/A";
                                          }
                                          if (placeDetails.city != null) {
                                            loc.city = placeDetails.city!;
                                          } else {
                                            loc.city = "N/A";
                                          }
                                          if (placeDetails.zipCode != null) {
                                            loc.zipCode = placeDetails.zipCode!;
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
                                          // Notifying update
                                          widget.locationChanged(true);
                                          mixpanel!
                                              .track('brand_locations_edited');
                                        }
                                      } else {
                                        var result = await showDialog(
                                            context: context,
                                            builder: (_) {
                                              return DeleteConfirmationDialog(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .myLocationsDeleteDescription);
                                            });
                                        if (result) {
                                          //print("Deleting Location "+location.description!);
                                          await _locationDataService
                                              .deleteLocation(location.id!,
                                                  currentBrand.baseLocation!);
                                          //print("Deleted");
                                          widget.locationChanged(true);
                                          mixpanel!
                                              .track('brand_locations_deleted');
                                        }
                                      }
                                    }
                                  },
                                  child: location.isBaseLocation!
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.edit,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              size: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.05,
                                            ),
                                            SizedBox(
                                                width: widget.width * 0.01),
                                            FittedBox(
                                              fit: BoxFit.contain,
                                              child: Text(
                                                  AppLocalizations.of(context)!
                                                      .edit,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
                                                  textAlign: TextAlign.center),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.delete_outline,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              size: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.05,
                                            ),
                                            SizedBox(
                                                width: widget.width * 0.01),
                                            FittedBox(
                                              fit: BoxFit.contain,
                                              child: Text(
                                                  AppLocalizations.of(context)!
                                                      .delete,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
                                                  textAlign: TextAlign.center),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
