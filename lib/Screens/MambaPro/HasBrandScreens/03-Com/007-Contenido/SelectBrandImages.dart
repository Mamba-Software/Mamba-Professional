import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/Models/ImageObject.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Images/ImageUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/RectangularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/DeleteConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/FullScreenImageCarousel.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';

class SelectBrandImages extends StatefulWidget {
  String brandId;

  SelectBrandImages({Key? key, required this.brandId}) : super(key: key);

  @override
  _SelectBrandImagesState createState() => _SelectBrandImagesState();
}

class _SelectBrandImagesState extends State<SelectBrandImages> {

  // App Bar and Scroll View
  ScrollController? _scrollController;

  // Acceso a Base de Datos
  final _brandDataService = BrandDataService();
  // Boolean Loading
  bool isLoading = false;
  // Bool Max Images Added
  bool maxImagesAdded = false;
  // Max Number of Images
  final int _maxImages = 10;
  // Images uploaded
  List<ImageObject> _imagesUploaded = [];
  List<Widget> imageSliders = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    isLoading = true;
    getBrandContentImages();
  }

  // Selects image from Gallery and updates in firebase.
  Future getImage() async {
    List<File>? temp = await ImageUtils().pickMultipleImage();
    if ((temp!.length) > (_maxImages-_imagesUploaded.length)) {
      setState(() {
        maxImagesAdded = true;
      });
    } else {
      setState(() {
        isLoading = true;
        maxImagesAdded = false;
      });
      await _brandDataService.addBrandContentPictures(widget.brandId, temp);
      getBrandContentImages();
    }
  }

  // Gets the user info from firebase.
  Future<void> getBrandContentImages() async {
    _imagesUploaded = await _brandDataService.getBrandContentPictures(widget.brandId);
    _imagesUploaded.sort((a,b) {
      var aDate = a.timestamp!.toDate();
      var bDate = b.timestamp!.toDate();
      return aDate.compareTo(bDate);
    });
    _imagesUploaded = List.from(_imagesUploaded.reversed);
    /*
    imageSliders = _imagesUploaded
        .map((item) => Container(
          margin: const EdgeInsets.all(5.0),
          child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              child: Stack(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute<void>(
                          builder: (context) => FullscreenSliderDemo(
                            initialImage: _imagesUploaded.indexOf(item),
                            images: _imagesUploaded,
                          ),
                        )
                      );
                    },
                    child: Image.network(item.url!, fit: BoxFit.fill, width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height*0.4,)
                  ),
                  Positioned(
                    bottom: -15,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(200, 0, 0, 0),
                            Color.fromARGB(0, 0, 0, 0)
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('No. ${_imagesUploaded.indexOf(item) + 1} de ${_imagesUploaded.length.toString()}',
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white),
                          ),
                          IconButton(
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
                            icon: Icon(
                              Icons.delete_outline,
                              color: AppColors.red,
                              size: MediaQuery.of(context).size.width*0.05
                            ),
                            alignment: Alignment.centerRight,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ))
        .toList();
     */
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          isLoading ? SliverFillRemaining(
            child: Center(
                  child: LoadingView()
              )
          ) : SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height*0.03),
                    /*
                        Text(
                          AppLocalizations.of(context)!.yourImages,
                          style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.02),
                         */
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context)!.yourImagesDescription,
                            style: Theme.of(context).textTheme.caption,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.03),
                    maxImagesAdded ? Padding(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.03,left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.05),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.addBrandPhotosMaxLeft((_maxImages-_imagesUploaded.length).toString()),
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ) : Container(),
                    _imagesUploaded.length < _maxImages ? Column(
                      children: [
                        GestureDetector(
                          onTap: getImage,
                          child: DottedBorder(
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(10),
                              dashPattern: [10, 10],
                              color: Colors.grey,
                              strokeWidth: 2,
                              child: Container(
                                height: MediaQuery.of(context).size.height*0.15,
                                width: MediaQuery.of(context).size.height*0.9,
                                color: Colors.transparent,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                            Icons.add,
                                            color: Colors.grey,
                                            size: MediaQuery.of(context).size.width*0.15
                                        ),
                                        //SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                        Text(
                                          AppLocalizations.of(context)!.add+" "+AppLocalizations.of(context)!.photos.toLowerCase(),
                                          style: Theme.of(context).textTheme.headline3?.copyWith(color: AppColors.grey),
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "("+_imagesUploaded.length.toString()+"/"+_maxImages.toString()+")",
                                      style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.grey),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                )
                              )
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.03),
                      ],
                    ) : Container(),

                  ],
                ),
              )
          ),
          isLoading ? SliverToBoxAdapter(child: Container()) : SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 2.5,
              mainAxisSpacing: MediaQuery.of(context).size.width*0.02,
              crossAxisSpacing: 10,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              ImageObject image = _imagesUploaded[index];
              return Container(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Stack(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute<void>(
                              builder: (context) => FullscreenSliderDemo(
                                initialImage: _imagesUploaded.indexOf(image),
                                images: _imagesUploaded,
                              ),
                            )
                        );
                      },
                      child: RectangularImage(
                        height: MediaQuery.of(context).size.height*0.18,
                        width: MediaQuery.of(context).size.height*0.9,
                        borderRadius: 10,
                        color: AppColors.grey,
                        borderWidth: 1,
                        image: image.url,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width*0.07,
                          decoration: const BoxDecoration(
                              color: AppColors.red,
                              shape: BoxShape.circle
                          ),
                          child: Center(
                            child: IconButton(
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
                                    await _brandDataService.deleteBrandContentPictures(widget.brandId, image.id!);
                                  });
                                  getBrandContentImages();
                                }
                              },
                              icon: Icon(
                                  Icons.remove,
                                  color: AppColors.white,
                                  size: MediaQuery.of(context).size.width*0.03
                              ),
                              alignment: Alignment.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
              },
              childCount: _imagesUploaded.length,
            ),
          ),
          isLoading ? SliverToBoxAdapter(child: Container()) : SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height*0.03),
                  ],
                ),
              )
          ),
        ],
      ),
    );
  }
}

