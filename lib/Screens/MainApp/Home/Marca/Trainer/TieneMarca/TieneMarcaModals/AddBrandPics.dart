import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Images/ImageUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViews/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Globals/Widgets/RectangularImage.dart';

final List<String> imgList = [
  'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
  'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
  'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
  'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
  'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
  'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
];

class AddBrandPics extends StatefulWidget {
  @override
  _AddBrandPicsState createState() => _AddBrandPicsState();
}

class _AddBrandPicsState extends State<AddBrandPics> {

  // Acceso a Base de Datos
  var _brandDataService = new BrandDataService();
  // Boolean Loading
  bool isLoading = false;
  // Bool Max Images Added
  bool maxImagesAdded = false;
  // Max Number of Images
  int _maxImages = 10;
  // _Image Files
  List<File>? _images = [];

  Image? mySessions = Image.asset(Constants.calendarImage);

  // Selects image from Gallery and updates in firebase.
  Future getImage() async {
    if (_images!.length > _maxImages) {
      setState(() {
        maxImagesAdded = true;
      });
    }
    List<File>? temp = await ImageUtils().pickMultipleImage();
    setState(() {
      _images = temp;
    });
  }

  // Upload Image
  Future<void> uploadPhotos() async {
    setState(() {
      isLoading = true;
    });
    //String temp = await _brandDataService.updateCurrentBrandPhoto(currentBrand.id!, _image!);
    setState(() {
      //_imageUrl = temp;
      isLoading = false;
      //_image = null;
    });
  }

  // Gets the user info from firebase.
  Future<void> getBrandContentImages() async {
    currentBrand.setBasicData = await _brandDataService.getBrandDetails(currentBrand.id!);
    currentBrand.setUserList = await _brandDataService.getBrandUsers(currentBrand.id!);
    //_imageUrl = currentBrand.logoUrl;
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    isLoading = true;
    getBrandContentImages();
    super.initState();
  }

  final List<Widget> imageSliders = imgList
      .map((item) => Container(
        child: Container(
          margin: EdgeInsets.all(5.0),
          child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              child: Stack(
                children: <Widget>[
                  Image.network(item, fit: BoxFit.cover, width: 1000.0),
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(200, 0, 0, 0),
                            Color.fromARGB(0, 0, 0, 0)
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      child: Text(
                        'No. ${imgList.indexOf(item)} image',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.content, style: Theme.of(context).appBarTheme.titleTextStyle,),
        centerTitle: true,
      ),
      body: isLoading ?
        Center(
            child: LoadingViewPurple()
        )
          :
        SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height*0.03),
                  Container(
                    child: CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: true,
                        aspectRatio: 2.0,
                        enlargeCenterPage: true,
                      ),
                      items: imageSliders,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.03),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                  onTap: getImage,
                  title: Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.01),
                    child: Text(
                      AppLocalizations.of(context)!.addBrandPhotos,
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.addBrandPhotosLeft(3.toString(), 10.toString()),
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ),
                    ],
                  ),
                  leading: Icon(
                    Icons.add_a_photo_outlined,
                    size: MediaQuery.of(context).size.width*0.08,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.03),
              _images != null ? Container(
                height: MediaQuery.of(context).size.height * 0.26,
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: _images!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: !(index == 0 || index == _images!.length-1) ? EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03) : (index == 0) ? EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.02) : EdgeInsets.only(right: _images!.length != 1 ? MediaQuery.of(context).size.width*0.05 : MediaQuery.of(context).size.width*0.02, left: MediaQuery.of(context).size.width*0.02),
                        child: Column(
                          children: [
                            Material(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.all(
                                  const Radius.circular(10.0),
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.bottomLeft,
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.width * 0.40,
                                    width: MediaQuery.of(context).size.width * 0.40,
                                    decoration: new BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: new BorderRadius.all(
                                        const Radius.circular(10.0),
                                      ),
                                      image: new DecorationImage(
                                        fit: BoxFit.cover,
                                        image: FileImage(_images![index]),
                                      ),
                                    ),
                                    child: Center(),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                var temp = _images;
                                temp!.remove(_images![index]);
                                setState(() {
                                  _images = temp;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.clear, color: AppColors.red, size: MediaQuery.of(context).size.width*0.05),
                                  SizedBox(width: 10),
                                  Text(
                                    AppLocalizations.of(context)!.discard,
                                    style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );

                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                        onTap: getImage,
                        title: Padding(
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.01),
                          child: Text(
                            AppLocalizations.of(context)!.addBrandPhotos,
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.addBrandPhotosLeft(3.toString(), 10.toString()),
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),
                          ],
                        ),
                        leading: Icon(
                          Icons.add_a_photo_outlined,
                          size: MediaQuery.of(context).size.width*0.08,
                          color: Theme.of(context).primaryColor,
                        ),
                      );


                    }
                ),
              ) : Container(),
              maxImagesAdded ? Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01, left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.05),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.addBrandPhotosMax,
                    style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ) : Container(),

            ],
          ),
        ),
      floatingActionButton: _images!.isNotEmpty ? FloatingActionButton.extended(
        heroTag: "32",
        label: Text(AppLocalizations.of(context)!.uploadPhotos, style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),),
        icon: Icon(Icons.file_upload_outlined, size: MediaQuery.of(context).size.width*0.06,),
        backgroundColor: Theme.of(context).accentColor,
        foregroundColor: AppColors.white,
        onPressed: () {
          Navigator.pop(context, true);
        },
      ) : Container(),
    );
  }
}

