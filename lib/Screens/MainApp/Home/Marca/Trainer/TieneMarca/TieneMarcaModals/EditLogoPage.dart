import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';

class EditLogoPage extends StatefulWidget {
  @override
  _EditLogoPageState createState() => _EditLogoPageState();
}

class _EditLogoPageState extends State<EditLogoPage> {

  // Acceso a Base de Datos
  var _brandDataService = new BrandDataService();
  // Boolean Loading
  bool isLoading = false;
  // _Image File
  String? _imageUrl;
  // _Image File
  File? _image;

  // Selects image from Gallery and updates in firebase.
  Future getImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(image!.path);
    });
    retrieveLostData();
  }
  // Retrieve lost data of Gallery if it crashes because of Android.
  Future<void> retrieveLostData() async {
    final LostDataResponse response =
    await ImagePicker().retrieveLostData();
    if (response == null) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image = response.file as File?;
      });
    }
  }
  // Upload Image
  Future<void> uploadPhoto() async {
    setState(() {
      isLoading = true;
    });
    String temp = await _brandDataService.updateCurrentBrandPhoto(currentBrand.id!, _image!);
    setState(() {
      _imageUrl = temp;
      isLoading = false;
      _image = null;
    });
  }

  // Gets the user info from firebase.
  Future<void> getBrand() async {
    currentBrand.setBasicData = await _brandDataService.getBrandDetails(currentBrand.id!);
    currentBrand.setUserList = await _brandDataService.getBrandUsers(currentBrand.id!);
    _imageUrl = currentBrand.logoUrl;
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    isLoading = true;
    getBrand();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.uploadPhoto, style: Theme.of(context).appBarTheme.titleTextStyle,),
        centerTitle: true,
      ),
      body: isLoading ?
        Center(
            child: LoadingViewPurple()
        )
          :
        Center(
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Center(
                  child: CircularImage(size: MediaQuery.of(context).size.height * 0.35, image: _imageUrl,),
                ),
              ),
              Container(
                child: Icon(Icons.arrow_upward,size: 40,),
              ),
              Container(
                padding: EdgeInsets.all(30.0),
                height: MediaQuery.of(context).size.height * 0.4,
                child: Center(
                  child: _image == null ?
                  RawMaterialButton(
                    onPressed: getImage,
                    child: new Icon(
                      Icons.photo_library,
                      color: Theme.of(context).accentColor,
                      size: 35.0,
                    ),
                    shape: new CircleBorder(),
                    elevation: 4.0,
                    fillColor: Colors.white,
                    padding: const EdgeInsets.all(100.0),
                  ):
                  GestureDetector(
                    onTap: getImage,
                    child: Stack(
                      children: <Widget>[
                        Center(child: CircularProgressIndicator()),
                        Center(child: CircularImage(size: MediaQuery.of(context).size.height * 0.35, file: _image,)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "31",
        onPressed: uploadPhoto,
        tooltip: AppLocalizations.of(context)!.save,
        backgroundColor: Theme.of(context).accentColor,
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
      ),
    );
  }
}