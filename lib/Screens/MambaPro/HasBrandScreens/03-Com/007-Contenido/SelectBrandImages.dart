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
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*0.01),
            Container(
              height: MediaQuery.of(context).size.height*0.007,
              width: MediaQuery.of(context).size.width*0.15,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                      AppLocalizations.of(context)!.select+" "+AppLocalizations.of(context)!.photo.toLowerCase(),
                      style: Theme.of(context).textTheme.headline1!.copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.03),
          ],
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        toolbarHeight: MediaQuery.of(context).size.height*0.1,
        elevation: 0,
      ),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _imagesUploaded.isEmpty ? Column(
                      children: [
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
                      ],
                    ) : Container(),
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
                              dashPattern: const [10, 10],
                              color: AppColors.grey.withOpacity(0.5),
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
                                              color: AppColors.grey.withOpacity(0.5),
                                              size: MediaQuery.of(context).size.width*0.1
                                          ),
                                          //SizedBox(width: MediaQuery.of(context).size.width*0.02),
                                          Text(
                                            AppLocalizations.of(context)!.add+" "+AppLocalizations.of(context)!.photos.toLowerCase(),
                                            style: Theme.of(context).textTheme.caption,
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
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context, image.url);
                  },
                  child: RectangularImage(
                    height: MediaQuery.of(context).size.height*0.18,
                    width: MediaQuery.of(context).size.height*0.9,
                    borderRadius: 10,
                    color: AppColors.grey,
                    borderWidth: 1,
                    image: image.url,
                  ),
                )
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

