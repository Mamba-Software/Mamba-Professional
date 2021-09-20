import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/AddressSearch.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/LocationPlacesSearch.dart';

class RegistrarMarca extends StatefulWidget {
  const RegistrarMarca({Key? key}) : super(key: key);

  @override
  _RegistrarMarcaState createState() => _RegistrarMarcaState();
}

class _RegistrarMarcaState extends State<RegistrarMarca> {
  //DataBase Access
  var _accessDatabase = new DatabaseAccess();
  // Booleans
  bool basicInfo = false;

  // Form Values
  final _formBasicInfoKey = GlobalKey<FormState>();
  String nameBrand = "";
  String ubicacionTemp = "";
  var nameBrandController = TextEditingController();
  var ubicacionController =  TextEditingController();
  // Image Picker
  var _image;
  // Multi Select Especialidades
  List<String> selected = [];
  List<String> options = ['a' , 'b' , 'c' , 'd'];
  // Ubicación
  String _streetNumber = '';
  String _street = '';
  String _city = '';
  String _zipCode = '';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crea tu Marca", style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22),),
        centerTitle: true,
        elevation: 10,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
      ),
      backgroundColor: Styles.white,
      body: SingleChildScrollView(
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
                                  "Información Básica",
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
                                  RawMaterialButton(
                                    onPressed: getImage,
                                    child: Column(
                                      children: [
                                        new Icon(
                                          Icons.camera_alt_outlined,
                                          color: Styles.accent,
                                          size: 35.0,
                                        ),
                                      ],
                                    ),
                                    shape: CircleBorder(),
                                    elevation: 10.0,
                                    fillColor: Colors.white,
                                    padding: EdgeInsets.only(left: 50, right: 50, top: 63),
                                  ):
                                  GestureDetector(
                                    onTap: getImage,
                                    child: Stack(
                                      children: <Widget>[
                                        Center(
                                            child: Container(
                                                width: MediaQuery.of(context).size.width*0.35,
                                                decoration: new BoxDecoration(
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
                                                    "Nombre",
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
                                                    hintText: AppLocalizations.of(context)!.nameCompleto,
                                                    hintStyle: TextStyle(fontSize: 12),
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
                                                    new Text(
                                                      "Ubicación",
                                                      style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                        ),
                                        Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 20,),
                                            child: new Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: <Widget>[
                                              Expanded(
                                                child: TextField(
                                                  controller: ubicacionController,
                                                  readOnly: true,
                                                  onTap: () async {
                                                    // generate a new token here
                                                    final Suggestion? result = await showSearch(
                                                      context: context,
                                                      delegate: AddressSearch(),
                                                    );
                                                    // This will change the text displayed in the TextField
                                                    if (result != null) {
                                                      final placeDetails = await LocationPlacesSearch()
                                                          .getPlaceDetailFromId(result.placeId);
                                                      setState(() {
                                                        ubicacionController.text = result.description;
                                                        _streetNumber = placeDetails.streetNumber!;
                                                        _street = placeDetails.street!;
                                                        _city = placeDetails.city!;
                                                        _zipCode = placeDetails.zipCode!;
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
                                                    hintText: "Enter your shipping address",
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
                          SizedBox(height: 10.0),
                          Text('Street Number: $_streetNumber'),
                          Text('Street: $_street'),
                          Text('City: $_city'),
                          Text('ZIP Code: $_zipCode'),
                          SizedBox(height: 20.0),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Container(
                              height: 50,
                              width: 250,
                              decoration: BoxDecoration(
                                  color: Styles.accent, borderRadius: BorderRadius.circular(20)
                              ),
                              child: TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Disponibilidad",
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
            ),
    );
  }

}
