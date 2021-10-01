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
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/CalendarWidget.dart';
import 'package:mamba_castelldefels/Globals/Widgets/InformationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/AddressSearch.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/LocationPlacesSearch.dart';

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
  bool editInfo = true;
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
  String address = '';
  double latitude = 0;
  double longitude = 0;
  // Time Picker Horari de Trabajo
  bool errorTime = false;
  TimeOfDay _startTime = TimeOfDay(hour: 0, minute: 00);
  TimeOfDay _endTime = TimeOfDay(hour: 23, minute: 00);
  // Descansos
  TimeOfDay _breakStartTime = TimeOfDay(hour: 13, minute: 00);
  TimeOfDay _breakEndTime = TimeOfDay(hour: 14, minute: 00);
  List<TimeOfDay> _breakList = [];
  List<int> removedIndex = [];
  int breakLimit = 6;

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
          elevation: 8,
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
          actions: [
            IconButton(
              icon: Icon(basicInfo ? Icons.arrow_forward : Icons.add_circle_outline, size: 30,),
              onPressed: () {
                if (basicInfo) {
                  setState(() {
                    basicInfo = !basicInfo;
                  });
                } else {
                  print("Ara creamos la Marca");
                }
              },
              tooltip: 'Back',
            ),
          ],
        ),
        backgroundColor: Styles.white,
        body: basicInfo ?
        SingleChildScrollView(
          child: Form(
            key: _formBasicInfoKey,
            child: Column(
              children: [
                editInfo ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                      color: Styles.accent
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Icon(Icons.edit, color: Colors.white, size: 30,),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                AppLocalizations.of(context)!.canEdit,
                                style: Styles.whiteTextStyle.copyWith(fontSize: 16,),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0, right: 8.0),
                            child: TextButton(
                                child: Text(AppLocalizations.of(context)!.entendido, style: Styles.whiteTextStyle.copyWith(fontSize: 16, decoration: TextDecoration.underline)),
                                onPressed: () {
                                  setState(() {
                                    editInfo = false;
                                  });
                                }
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ) : Container(),
                Container(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
                            child: new Text(
                              AppLocalizations.of(context)!.basicInfo,
                              style: Styles.purpleTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
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
                                                enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: Styles.accent),
                                                ),
                                                focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: Styles.accent),
                                                ),

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
                                        padding: EdgeInsets.only(left: 10, right: 10, top: 10),
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
                                                onPressed: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (_) {
                                                        return InformationDialog(text: AppLocalizations.of(context)!.baseLocationDescription);
                                                      }
                                                  );
                                                },
                                              )
                                            ),
                                          ],
                                        )
                                    ),
                                    Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10,),
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
                                                  address =_street+" "+_streetNumber+", "+_city;
                                                  if(placeDetails.city!=null) address +=", "+_zipCode;
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
                                                contentPadding: EdgeInsets.only(left: 18.0, top: 25.0),
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
                          padding: EdgeInsets.only(left: 15, right: 10, top: 10, bottom: 10),
                          child: new Column(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context)!.streetName, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold),),
                                  Text(_street, style: Styles.purpleTextStyle,),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context)!.streetNumber, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold),),
                                  Text(_streetNumber, style: Styles.purpleTextStyle,),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context)!.city, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold),),
                                  Text(_city, style: Styles.purpleTextStyle,),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context)!.zipCode, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold),),
                                  Text(_zipCode, style: Styles.purpleTextStyle,),
                                ],
                              ),
                            ],
                          )
                      ) : Container(),
                      Padding(
                          padding: EdgeInsets.only(left: 10, right: 10, top: 10),
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
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (_) {
                                            return InformationDialog(text: AppLocalizations.of(context)!.brandDescription);
                                          }
                                      );
                                    },
                                  )
                              ),
                            ],
                          )
                      ),
                      Padding(
                          padding: EdgeInsets.only(left: 10, right: 10, top: 10),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 30),
                            child: new Text(
                              AppLocalizations.of(context)!.disponibilidad,
                              style: Styles.purpleTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                                      child: new Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          new Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                AppLocalizations.of(context)!.workingHours,
                                                style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                              padding: const EdgeInsets.only(left: 0),
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                icon: Icon(Icons.info_outline, color: Styles.accent, size: 20),
                                                onPressed: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (_) {
                                                        return InformationDialog(text: AppLocalizations.of(context)!.workingHoursDescription);
                                                      }
                                                  );
                                                },
                                              )
                                          ),
                                        ],
                                      )
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 5,),
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        TextButton(
                                          onPressed: () async {
                                            TimeOfDay temp = await _selectTime(_startTime);
                                            setState(() {
                                              _startTime = temp;
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(5)),
                                              border: Border.all(color: Styles.accent, width: 1.0),
                                              color: Colors.transparent,
                                            ),
                                            child: Text(
                                              '${_startTime.format(context)}',
                                              style: Styles.purpleTextStyle.copyWith(fontSize: 25),
                                            ),
                                          ),
                                        ),
                                        Text("-", style: Styles.purpleTextStyle.copyWith(fontSize: 30),),
                                        TextButton(
                                          onPressed: () async {
                                            TimeOfDay temp = await _selectTime(_endTime);
                                            setState(() {
                                              _endTime = temp;
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(5)),
                                              border: Border.all(color: Styles.accent, width: 1.0),
                                              color: Colors.transparent,
                                            ),
                                            child: Text(
                                              '${_endTime.format(context)}',
                                              style: Styles.purpleTextStyle.copyWith(fontSize: 25),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  errorTime ? Padding(
                                    padding: EdgeInsets.only(left: 10, right: 10, top: 5.0, bottom: 0),
                                    child: Text(
                                        AppLocalizations.of(context)!.workingHoursError,
                                        style: Styles.redTextStyle.copyWith(fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                  ) : new Container(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                                      child: new Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          new Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                AppLocalizations.of(context)!.lunchBreak,
                                                style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                              padding: const EdgeInsets.only(left: 0),
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                icon: Icon(Icons.info_outline, color: Styles.accent, size: 20),
                                                onPressed: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (_) {
                                                        return InformationDialog(text: AppLocalizations.of(context)!.lunchBreakDescription);
                                                      }
                                                  );
                                                },
                                              )
                                          ),
                                        ],
                                      )
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 5,),
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.52,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              TextButton(
                                                onPressed: () async {
                                                  TimeOfDay temp = await _selectTime(_breakStartTime);
                                                  setState(() {
                                                    _breakStartTime = temp;
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                                    border: Border.all(color: Styles.accent, width: 1.0),
                                                    color: Colors.transparent,
                                                  ),
                                                  child: Text(
                                                    '${_breakStartTime.format(context)}',
                                                    style: Styles.purpleTextStyle.copyWith(fontSize: 25),
                                                  ),
                                                ),
                                              ),
                                              Text("-", style: Styles.purpleTextStyle.copyWith(fontSize: 30),),
                                              TextButton(
                                                onPressed: () async {
                                                  TimeOfDay temp = await _selectTime(_breakEndTime);
                                                  setState(() {
                                                    _breakEndTime = temp;
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                                    border: Border.all(color: Styles.accent, width: 1.0),
                                                    color: Colors.transparent,
                                                  ),
                                                  child: Text(
                                                    '${_breakEndTime.format(context)}',
                                                    style: Styles.purpleTextStyle.copyWith(fontSize: 25),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        _breakList.length < breakLimit ? Padding(
                                          padding: const EdgeInsets.only(left: 0.0),
                                          child: OutlinedButton(
                                            onPressed: () {
                                              setState(() {
                                                _breakList.add(_breakStartTime);
                                                _breakList.add(_breakEndTime);
                                              });
                                            },
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon( Icons.add, color: Colors.white, size: 30,),
                                              ],
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              backgroundColor: Styles.accent,
                                              elevation: 3,
                                              shape: CircleBorder(),
                                              padding: EdgeInsets.all(5),
                                            ),
                                          ),
                                        ) : Container(),
                                      ],
                                    ),
                                  ),
                                  ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: _breakList.length,
                                    itemBuilder: (context, int index) {
                                      if(index.isEven && !removedIndex.contains(index)) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 5,),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              Container(
                                                width: MediaQuery.of(context).size.width * 0.52,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () async {
                                                        TimeOfDay temp = await _selectTime(_breakList[index]);
                                                        setState(() {
                                                          _breakList[index] = temp;
                                                        });
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                                          border: Border.all(color: Colors.green, width: 1.0),
                                                          color: Colors.transparent,
                                                        ),
                                                        child: Text(
                                                          '${_breakList[index].format(context)}',
                                                          style: Styles.purpleTextStyle.copyWith(fontSize: 25, color: Colors.green),
                                                        ),
                                                      ),
                                                    ),
                                                    Text("-", style: Styles.purpleTextStyle.copyWith(fontSize: 30, color: Colors.green),),
                                                    TextButton(
                                                      onPressed: () async {
                                                        TimeOfDay temp = await _selectTime(_breakList[index+1]);
                                                        setState(() {
                                                          _breakList[index+1] = temp;
                                                        });
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                                          border: Border.all(color: Colors.green, width: 1.0),
                                                          color: Colors.transparent,
                                                        ),
                                                        child: Text(
                                                          '${_breakList[index+1].format(context)}',
                                                          style: Styles.purpleTextStyle.copyWith(fontSize: 25, color: Colors.green),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 0.0),
                                                child: OutlinedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      removedIndex.add(index);
                                                      removedIndex.add(index+1);
                                                      breakLimit += 2;
                                                    });
                                                  },
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon( Icons.remove, color: Colors.white, size: 30,),
                                                    ],
                                                  ),
                                                  style: OutlinedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    elevation: 3,
                                                    shape: CircleBorder(),
                                                    padding: EdgeInsets.all(5),
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child: Text(AppLocalizations.of(context)!.lunchBreakAdded, style: Styles.purpleTextStyle.copyWith(fontSize: 13,fontStyle: FontStyle.italic, color: Colors.green), textAlign: TextAlign.center,),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    },
                                    shrinkWrap: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
                                if (_startTime == TimeOfDay(hour: 0, minute: 00) && _endTime == TimeOfDay(hour: 23, minute: 00)) {
                                  setState(() {
                                    errorTime = true;
                                  });
                                } else {
                                  setState(() {
                                    errorTime = false;
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
                                  AppLocalizations.of(context)!.next,
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
        CalendarWidget(),
    );
  }

  Future<TimeOfDay> _selectTime(TimeOfDay time) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: time,
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.light().copyWith(
              primary: Colors.amber,
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              // Using 12-Hour format
                alwaysUse24HourFormat: true),
            // If you want 24-Hour format, just change alwaysUse24HourFormat to true
            child: child!)
        );
      }
    );
    if (newTime != null) {
      return newTime;
    } else {
      return time;
    }
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
