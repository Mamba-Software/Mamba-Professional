import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Utils/Images/ImageUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';

class Logo extends StatefulWidget {
  String brandId;

  Logo({Key? key, required this.brandId}) : super(key: key);
  @override
  _LogoState createState() => _LogoState();
}

class _LogoState extends State<Logo> {

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
    File? temp = await ImageUtils().pickImage();
    setState(() {
      _image = temp;
    });
  }

  // Upload Image
  Future<void> uploadPhoto() async {
    setState(() {
      isLoading = true;
    });
    String temp = await _brandDataService.updateBrandPhoto(widget.brandId, _image!);
    setState(() {
      _imageUrl = temp;
      isLoading = false;
      _image = null;
    });
  }

  // Gets the user info from firebase.
  Future<void> getBrand() async {
    currentBrand.setBasicData = await _brandDataService.getBrandDetails(widget.brandId);
    currentBrand.setUserList = await _brandDataService.getBrandUsers(widget.brandId);
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
            child: LoadingView()
        )
          ://
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
                  OutlinedButton(
                    onPressed: getImage,
                    child: Column(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        new Icon(
                          Icons.photo_library_outlined,
                          color: Theme.of(context).primaryColor,
                          size: MediaQuery.of(context).size.width * 0.1,
                        ),
                      ],
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 1.5
                      ),
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      elevation: 10,
                      shape: CircleBorder(),
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.height * 0.13, right: MediaQuery.of(context).size.height * 0.13, top: MediaQuery.of(context).size.height * 0.14),
                    ),
                  )
                      :
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
      floatingActionButton: _image != null ? FloatingActionButton(
        heroTag: "31",
        onPressed: uploadPhoto,
        tooltip: AppLocalizations.of(context)!.save,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
      ) : Container(),
    );
  }
}