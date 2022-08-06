import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/Models/ImageObject.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Images/ImageUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/DeleteConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/FullScreenImageCarousel.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingViewPurple.dart';

class Content extends StatefulWidget {
  String brandId;

  Content({Key? key, required this.brandId}) : super(key: key);

  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {

  // Acceso a Base de Datos
  var _brandDataService = new BrandDataService();
  // Boolean Loading
  bool isLoading = false;
  // Bool Max Images Added
  bool maxImagesAdded = false;
  // Max Number of Images
  int _maxImages = 10;
  // Image To Upload
  List<File>? _imagesToUpload = [];
  // Images uploaded
  List<ImageObject> _imagesUploaded = [];
  List<Widget> imageSliders = [];

  @override
  void initState() {
    isLoading = true;
    getBrandContentImages();
    super.initState();
  }

  // Selects image from Gallery and updates in firebase.
  Future getImage() async {
    List<File>? temp = await ImageUtils().pickMultipleImage();
    if ((_imagesToUpload!.length + temp!.length) > (_maxImages-_imagesUploaded.length)) {
      setState(() {
        maxImagesAdded = true;
      });
    } else {
      if (_imagesToUpload!.isNotEmpty) {
        setState(() {
          _imagesToUpload!.addAll(temp);
          maxImagesAdded = false;
        });
      } else {
        setState(() {
          _imagesToUpload = temp;
          maxImagesAdded = false;
        });
      }

    }
  }

  // Upload Image
  Future<void> uploadPhotos() async {
    setState(() {
      isLoading = true;
    });
    await _brandDataService.addBrandContentPictures(widget.brandId, _imagesToUpload!);
    _imagesToUpload = [];
    getBrandContentImages();
  }

  // Gets the user info from firebase.
  Future<void> getBrandContentImages() async {
    _imagesUploaded = await _brandDataService.getBrandContentPictures(widget.brandId);
    imageSliders = _imagesUploaded
        .map((item) => Container(
          child: Container(
            margin: EdgeInsets.all(5.0),
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                child: Stack(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute<Null>(
                            builder: (context) => FullscreenSliderDemo(
                              initialImage: _imagesUploaded.indexOf(item),
                              images: _imagesUploaded,
                            ),
                          )
                        );
                      },
                      child: Image.network(item.url!, fit: BoxFit.cover, width: MediaQuery.of(context).size.width,)
                    ),
                    Positioned(
                      bottom: -15,
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('No. ${_imagesUploaded.indexOf(item) + 1} de ${_imagesUploaded.length.toString()}',
                              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white),
                            ),
                            TextButton(
                              onPressed: () async {
                                var result = await showDialog(
                                    context: context,
                                    builder: (_) {
                                      return DeleteConfirmationDialog(text: AppLocalizations.of(context)!.myImagesDeleteDescription);
                                    }
                                );
                                if (result) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await Future.delayed(const Duration(milliseconds: 1000), () async {
                                    await _brandDataService.deleteBrandContentPictures(widget.brandId, item.id!);
                                  });
                                  getBrandContentImages();
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.delete_outline, color: AppColors.red, size: MediaQuery.of(context).size.width*0.05),
                                  SizedBox(width: 10),
                                  Text(
                                    AppLocalizations.of(context)!.delete,
                                    style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ))
        .toList();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ?
        Center(
            child: LoadingViewPurple()
        )
          ://
        SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.03),
              imageSliders.isNotEmpty ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: false,
                        aspectRatio: 2.0,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: false
                      ),
                      items: imageSliders,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.03),
                ],
              ) : Container(),
              _imagesUploaded.length != _maxImages ? Container(
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(width: 1.0, color: Theme.of(context).backgroundColor),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
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
                            AppLocalizations.of(context)!.addBrandPhotosLeft((_maxImages-_imagesUploaded.length).toString(), _maxImages.toString()),
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
              ) : Container(
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(width: 1.0, color: Theme.of(context).backgroundColor),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    title: Text(
                      AppLocalizations.of(context)!.addBrandPhotosMax,
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    leading: Icon(
                      Icons.collections_outlined,
                      size: MediaQuery.of(context).size.width*0.08,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.03),
              _imagesToUpload!.isNotEmpty ? Container(
                height: MediaQuery.of(context).size.height * 0.25,
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: _imagesToUpload!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: !(index == 0 || index == _imagesToUpload!.length-1) ? EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03) : (index == 0) ? EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.02) : EdgeInsets.only(right: _imagesToUpload!.length != 1 ? MediaQuery.of(context).size.width*0.05 : MediaQuery.of(context).size.width*0.02, left: MediaQuery.of(context).size.width*0.02),
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
                                    height: MediaQuery.of(context).size.width * 0.35,
                                    width: MediaQuery.of(context).size.width * 0.35,
                                    decoration: new BoxDecoration(
                                      //color: Theme.of(context).accentColor,
                                      borderRadius: new BorderRadius.all(
                                        const Radius.circular(10.0),
                                      ),
                                      image: new DecorationImage(
                                        fit: BoxFit.cover,
                                        image: FileImage(_imagesToUpload![index]),
                                      ),
                                    ),
                                    child: Center(),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                var temp = _imagesToUpload;
                                temp!.remove(_imagesToUpload![index]);
                                setState(() {
                                  _imagesToUpload = temp;
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
                    }
                ),
              ) : Container(),
              maxImagesAdded ? Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01, left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.05),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.addBrandPhotosMaxLeft((_maxImages-_imagesUploaded.length).toString()),
                    style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ) : Container(),
            ],
          ),
        ),
      floatingActionButton: _imagesToUpload!.isNotEmpty && !isLoading ? FloatingActionButton.extended(
        heroTag: "32",
        label: Text(AppLocalizations.of(context)!.uploadPhotos, style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),),
        icon: Icon(Icons.file_upload_outlined, size: MediaQuery.of(context).size.width*0.06,),
        backgroundColor: Theme.of(context).accentColor,
        foregroundColor: AppColors.white,
        onPressed: uploadPhotos,
      ) : Container(),
    );
  }
}

