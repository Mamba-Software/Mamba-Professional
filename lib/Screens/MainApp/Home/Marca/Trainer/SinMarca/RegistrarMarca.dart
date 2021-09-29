import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart' as googlePlace;
import 'package:image_picker/image_picker.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/AddressSearch.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/LocationPlacesSearch.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';

class RegistrarMarca extends StatefulWidget {
  const RegistrarMarca({Key? key}) : super(key: key);

  @override
  _RegistrarMarcaState createState() => _RegistrarMarcaState();
}

class _RegistrarMarcaState extends State<RegistrarMarca> {
  // DataBase Access
  var _accessDatabase = new DatabaseAccess();
  // Google APIS
  googlePlace.GooglePlace? gPlace;
  googlePlace.DetailsResult? detailsResult;
  // Boolean Basic Info
  bool basicInfo = true;
  bool isLoading = false;
  // Form Values
  final _formBasicInfoKey = GlobalKey<FormState>();
  String nameBrand = "";
  String description = "";
  var nameBrandController = TextEditingController();
  var ubicacionController =  TextEditingController();
  var descriptionController =  TextEditingController();
  // Image Picker
  bool errorImage = false;
  var _image;
  // Ubicación
  String _streetNumber = '';
  String _street = '';
  String _city = '';
  String _zipCode = '';
  double latitude = 0;
  double longitude = 0;


  // Selects image from Gallery and updates in firebase.
  Future getImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(image!.path);
    });
    retrieveLostData();
  }
  // Retrieve lost data of Gallery if it crashes becasue of Android.
  Future<void> retrieveLostData() async {
    final LostDataResponse response =
    await ImagePicker().retrieveLostData();
    if (response == null) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image = response.file;
      });
    }
  }

  @override
  void initState() {
    gPlace = googlePlace.GooglePlace(placesAPI);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?
      Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Styles.mainColor,
          body: Stack(
            children: <Widget>[
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.14,
                  height: MediaQuery.of(context).size.height * 0.07,
                  child: CircularProgressIndicator(
                    color: Styles.white,
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.07,
                  height: MediaQuery.of(context).size.height * 0.07,
                  child: Image(
                    image: AssetImage(Constants.logoSimple)
                  ),
                ),
              ),
            ],
          )
      )
        :
      Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.createBrand, style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22),),
          centerTitle: true,
          elevation: 10,
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 25,),
            onPressed: () {
              if (basicInfo) {
                Navigator.pop(context);
              } else {
                setState(() {
                  basicInfo = !basicInfo;
                });
              }
            },
            tooltip: 'Back',
          ),
        ),
        backgroundColor: Styles.white,
        body: basicInfo ?
        SingleChildScrollView(
          child: Form(
            key: _formBasicInfoKey,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                            child: new Text(
                              AppLocalizations.of(context)!.basicInfo,
                              style: Styles.purpleTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            height: MediaQuery.of(context).size.height * 0.20,
                            child: Center(
                              child: _image == null ?
                              OutlinedButton(
                                onPressed: getImage,
                                child: Column(
                                  children: [
                                    new Icon(
                                      Icons.image,
                                      color: Styles.accent,
                                      size: 35.0,
                                    ),
                                  ],
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: errorImage ? Colors.red : Styles.accent,
                                    width: 1.5
                                  ),
                                  backgroundColor: Colors.white,
                                  elevation: 10,
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.only(left: 50, right: 50, top: 63),
                                ),
                              ) :
                              GestureDetector(
                                onTap: getImage,
                                child: Stack(
                                  children: <Widget>[
                                    Center(
                                        child: Container(
                                            width: MediaQuery.of(context).size.width*0.35,
                                            decoration: new BoxDecoration(
                                              border: Border.all(
                                                width: 1.5,
                                                color: Styles.accent,
                                                style: BorderStyle.solid,
                                              ),
                                              shape: BoxShape.circle,
                                              image: new DecorationImage(
                                                image: FileImage(_image),
                                                fit: BoxFit.fitWidth,
                                              ),
                                            )
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: new Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          new Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              new Text(
                                                AppLocalizations.of(context)!.name,
                                                style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(left: 10, right: 20),
                                      child: new Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          new Flexible(
                                            child: new TextFormField(
                                              controller: nameBrandController,
                                              validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.nameCompletoError : null,
                                              onChanged: (val) {
                                                setState(() => {
                                                  nameBrand = val
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText: AppLocalizations.of(context)!.nameCompletoError,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                                        child: new Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            new Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text(
                                                  AppLocalizations.of(context)!.baseLocation,
                                                  style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 0),
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                icon: Icon(Icons.info_outline, color: Styles.accent, size: 20),
                                                onPressed: () {  },
                                              )
                                            ),
                                          ],
                                        )
                                    ),
                                    Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 20,),
                                        child: new Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                          Expanded(
                                            child: TextFormField(
                                              controller: ubicacionController,
                                              validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.enterAddressError : null,
                                              readOnly: true,
                                              onTap: () async {
                                                // generate a new token here
                                                final Suggestion? result = await showSearch(
                                                  context: context,
                                                  delegate: AddressSearch(),
                                                );
                                                // This will change the text displayed in the TextFormField
                                                if (result != null) {
                                                  final placeDetails = await LocationPlacesSearch()
                                                      .getPlaceDetailFromId(result.placeId);
                                                  getDetails(result.placeId);
                                                  setState(() {
                                                    ubicacionController.text = result.description;
                                                    if(placeDetails.street!=null) _street = placeDetails.street!; else _street="N/A";
                                                    if(placeDetails.streetNumber!=null) _streetNumber = placeDetails.streetNumber!; else _streetNumber="N/A";
                                                    if(placeDetails.city!=null) _city = placeDetails.city!; else _city="N/A";
                                                    if(placeDetails.zipCode!=null) _zipCode = placeDetails.zipCode!; else _zipCode="N/A";
                                                  });
                                                }
                                              },
                                              decoration: InputDecoration(
                                                icon: Container(
                                                  width: 10,
                                                  height: 10,
                                                  child: Icon(
                                                    Icons.location_on_outlined,
                                                    color: Styles.accent,
                                                    size: 35,
                                                  ),
                                                ),
                                                hintText: AppLocalizations.of(context)!.enterAddress,
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.only(left: 18.0, top: 16.0),
                                              ),
                                        ),
                                          )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _street != "" ?
                      Padding(
                          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
                          child: new Column(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(AppLocalizations.of(context)!.streetName, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold),),
                                  Text(_street, style: Styles.purpleTextStyle,),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(AppLocalizations.of(context)!.streetNumber, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold),),
                                  Text(_streetNumber, style: Styles.purpleTextStyle,),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(AppLocalizations.of(context)!.city, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold),),
                                  Text(_city, style: Styles.purpleTextStyle,),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(AppLocalizations.of(context)!.zipCode, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold),),
                                  Text(_zipCode, style: Styles.purpleTextStyle,),
                                ],
                              ),
                            ],
                          )
                      ) : Container(),
                      Padding(
                          padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    AppLocalizations.of(context)!.description,
                                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(left: 0),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(Icons.info_outline, color: Styles.accent, size: 20),
                                    onPressed: () {  },
                                  )
                              ),
                            ],
                          )
                      ),
                      Padding(
                          padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Flexible(
                                child: new TextFormField(
                                    controller: descriptionController,
                                    validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.descriptionError : null,
                                    onChanged: (val) {
                                      setState(() => description = val);
                                    },
                                    maxLines: 6,
                                    decoration: Styles.textFromInputDecoration.copyWith(hintText:AppLocalizations.of(context)!.descriptionError)
                                ),
                              ),
                            ],
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Container(
                          height: 50,
                          width: 250,
                          decoration: BoxDecoration(
                              color: Styles.accent, borderRadius: BorderRadius.circular(20)
                          ),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                if (_image==null) {
                                  setState(() {
                                    errorImage = true;
                                  });
                                } else {
                                  setState(() {
                                    errorImage = false;
                                  });
                                }
                                if(_formBasicInfoKey.currentState!.validate()){
                                  basicInfo = false;
                                }
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.disponibilidad,
                                  style: Styles.whiteTextStyle,
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.calendar_today_outlined, color: Styles.white),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ) :
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    child: Text("AQUÍ VINDRA EL CALENDAR WIDGET", style: Styles.purpleTextStyle.copyWith(fontSize: 25), textAlign: TextAlign.center,)
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Container(
                    height: 50,
                    width: 250,
                    decoration: BoxDecoration(
                        color: Styles.accent, borderRadius: BorderRadius.circular(20)
                    ),
                    child: TextButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        var result = await _accessDatabase.addBrand(nameBrand, _image, description, detailsResult!.placeId!, latitude, longitude);
                        await _accessDatabase.updateCurrentUserBrand(result);
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute<Null>(
                              builder: (context) => SplashScreen(),
                              settings: RouteSettings(name: 'SplashScreen'),
                            )
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Crear Marca",
                            style: Styles.whiteTextStyle,
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.calendar_today_outlined, color: Styles.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

  void getDetails(String placeId) async {
    var result = await gPlace!.details.get(placeId);
    if (result != null && result.result != null && mounted) {
      detailsResult = result.result;
      latitude = detailsResult!.geometry!.location!.lat!;
      longitude = detailsResult!.geometry!.location!.lng!;
    }
  }

}
