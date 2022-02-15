import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_place/google_place.dart' as googlePlace;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:mamba_castelldefels/Data/LocationDataService.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/Location.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:uuid/uuid.dart';

import '../../GlobalVars.dart';
import 'AddressSearch.dart';
import 'LocationPlacesSearch.dart';

class BrandLocations extends StatefulWidget {
  String brandId;
  BrandLocations({Key? key, required this.brandId}) : super(key: key);

  @override
  _BrandLocationsState createState() => _BrandLocationsState();
}

class _BrandLocationsState extends State<BrandLocations> {

  // Acceso a Base de Datos
  var _locationDataService = new LocationDataService();
  // Boolean Loading
  bool isLoading = false;
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
    getAllLocations();
  }

  List<Location> documentsToLocations(List<DocumentSnapshot> documents) {
    List<Location> locations = [];
    for(int i = 0; i < documents.length; i++) {
      Location location = Location.fromObjectAllData(documents[i].id, documents[i]);
      if (location.isBaseLocation!) {
        locations.add(location);
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
      appBar: null,
      body:  isLoading ?
      Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.locations, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22), textAlign: TextAlign.center,),
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
          title: Text(AppLocalizations.of(context)!.locations, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22), textAlign: TextAlign.center,),
          centerTitle: true,
        ),
        body: Column(
          children: [
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
                          if (location.isBaseLocation!) {
                            return Column(
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                ListTile(
                                  leading: Icon(Icons.home_filled, color: Theme.of(context).accentColor, size: 25,),
                                  title: Text(
                                      location.description!,
                                      style: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Theme.of(context).accentColor)
                                  ),
                                  trailing: IconButton(
                                    onPressed: () async {
                                      Clipboard.setData(new ClipboardData(text: location.description!)).then((_){
                                        showTopSnackBar(
                                          context,
                                          CustomSnackBar.info(
                                            icon: Container(),
                                            iconRotationAngle: 0,
                                            backgroundColor: Theme.of(context).accentColor,
                                            message: AppLocalizations.of(context)!.copyCorrectLocation,
                                            textStyle: Styles.whiteTextStyle,
                                          ),
                                        );
                                      });
                                    },
                                    icon: Icon(Icons.copy, color: Theme.of(context).accentColor, size: 25,),
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
                                              AppLocalizations.of(context)!.myLocationsBaseLocationClientDesc,
                                              style: Styles.purpleTextStyle.copyWith(color: Colors.grey, fontSize: 16),
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
                              leading: Icon(Icons.location_on_outlined, color: Theme.of(context).primaryColor, size: 25,),
                              title: Text(
                                  location.description!,
                                  style: Styles.purpleTextStyle.copyWith(fontSize: 16)
                              ),
                              trailing: IconButton(
                                onPressed: () async {
                                  Clipboard.setData(new ClipboardData(text: location.description!)).then((_){
                                    showTopSnackBar(
                                      context,
                                      CustomSnackBar.info(
                                        icon: Container(),
                                        iconRotationAngle: 0,
                                        backgroundColor: Theme.of(context).accentColor,
                                        message: AppLocalizations.of(context)!.copyCorrectLocation,
                                        textStyle: Styles.whiteTextStyle,
                                      ),
                                    );
                                  });
                                },
                                icon: Icon(Icons.copy, color: Theme.of(context).primaryColor, size: 25,),
                              ),
                              onTap: () {

                              },
                            );
                          }
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