import 'package:flutter/material.dart';
import 'dart:io';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';

import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/utils/Images/ImageUtils.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/commons/widgets/loading/LoadingView.dart';

class Logo extends StatefulWidget {
  String brandId;

  Logo({super.key, required this.brandId});
  @override
  _LogoState createState() => _LogoState();
}

class _LogoState extends State<Logo> {
  // Acceso a Base de Datos
  final _brandDataService = BrandDataService();
  // Boolean Loading
  bool isLoading = false;
  // _Image File
  String? _imageUrl;
  // _Image File
  File? _image;

  // Selects image from Gallery and updates in firebase.
  Future getImage() async {
    mixpanel!.timeEvent('brand_info_logo_picture');
    File? temp = await ImageUtils().pickImage();
    setState(() {
      _image = temp;
    });
    mixpanel!.track('brand_info_logo_picture');
  }

  // Upload Image
  Future<void> uploadPhoto() async {
    setState(() {
      isLoading = true;
    });
    String temp =
        await _brandDataService.updateBrandPhoto(widget.brandId, _image!);
    setState(() {
      _imageUrl = temp;
      isLoading = false;
      _image = null;
    });
    mixpanel!.track('brand_info_logo_change_completed');
  }

  // Gets the user info from firebase.
  Future<void> getBrand() async {
    currentBrand.setBasicData =
        await _brandDataService.getBrandDetails(widget.brandId);
    currentBrand.setUserList =
        await _brandDataService.getBrandUsers(widget.brandId);
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
        title: Text(
          context.l10n.uploadPhoto,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: MediaQuery.of(context).size.width * 0.06,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? Center(child: LoadingView())
          : //
          Center(
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Center(
                      child: CircularImage(
                        size: MediaQuery.of(context).size.height * 0.35,
                        image: _imageUrl,
                      ),
                    ),
                  ),
                  Container(
                    child: const Icon(
                      Icons.arrow_upward,
                      size: 40,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(30.0),
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Center(
                      child: _image == null
                          ? OutlinedButton(
                              onPressed: getImage,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 1.5),
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                elevation: 10,
                                shape: const CircleBorder(),
                                padding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.height *
                                        0.13,
                                    right: MediaQuery.of(context).size.height *
                                        0.13,
                                    top: MediaQuery.of(context).size.height *
                                        0.14),
                              ),
                              child: Column(
                                //mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.photo_library_outlined,
                                    color: Theme.of(context).primaryColor,
                                    size:
                                        MediaQuery.of(context).size.width * 0.1,
                                  ),
                                ],
                              ),
                            )
                          : GestureDetector(
                              onTap: getImage,
                              child: Stack(
                                children: <Widget>[
                                  const Center(
                                      child: CircularProgressIndicator()),
                                  Center(
                                      child: CircularImage(
                                    size: MediaQuery.of(context).size.height *
                                        0.35,
                                    file: _image,
                                  )),
                                ],
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: _image != null
          ? FloatingActionButton(
              heroTag: "31",
              onPressed: uploadPhoto,
              tooltip: context.l10n.save,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(
                Icons.check,
                color: Colors.white,
              ),
            )
          : Container(),
    );
  }
}
