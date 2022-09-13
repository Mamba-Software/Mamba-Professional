import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
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
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/03-Com/007-Contenido/SelectBrandImages.dart';

class BrandImages extends StatefulWidget {
  String brandId;
  bool pinned;
  ValueChanged<bool?> pinnedChanged;

  BrandImages({Key? key, required this.brandId, required this.pinned, required this.pinnedChanged}) : super(key: key);

  @override
  _BrandImagesState createState() => _BrandImagesState();
}

class _BrandImagesState extends State<BrandImages> {

  // App Bar and Scroll View
  ScrollController? _scrollController;
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    return _scrollController!.hasClients && _scrollController!.offset > (MediaQuery.of(context).size.height*0.15 - kToolbarHeight);
  }
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
    _scrollController = ScrollController()
      ..addListener(() => _isAppBarExpanded ?
      setState(() {
        appBarExpanded = true;
      }) :
      setState(() {
        appBarExpanded = false;
      }),
      );
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
          SliverAppBar(
            backgroundColor: AppColors.darkGrey,
            expandedHeight: MediaQuery.of(context).size.height*0.15,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            elevation: 4,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.darkGrey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.025),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.photos,
                            style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white,),
                          ),
                          FittedBox(
                            fit: BoxFit.fitHeight,
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height*0.08,
                              width: MediaQuery.of(context).size.width*0.11,
                              child: TextButton(
                                onPressed: null,
                                child: Icon(
                                  Icons.filter_list,
                                  color: AppColors.darkGrey,
                                  size: MediaQuery.of(context).size.width*0.07,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                    Container(
                      color: AppColors.grey,
                      height: 1.0,
                    ),
                  ],
                ),
              ),
              titlePadding: EdgeInsets.zero,
              //centerTitle: true,
            ),
            title: appBarExpanded ? Text(AppLocalizations.of(context)!.photos, style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(color: AppColors.white,),) : Container(),
            centerTitle: true,
            leading: Builder(
              builder: (BuildContext innerContext) => Padding(
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.02),
                child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: AppColors.white,
                      size: MediaQuery.of(context).size.height*0.04,
                    ),
                    onPressed: () => mambaProScaffoldKey.currentState?.openDrawer()
                ),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.01),
                child: IconButton(
                  icon: Icon(
                    widget.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: widget.pinned ? AppColors.red :  AppColors.white.withOpacity(0.5),
                    size: MediaQuery.of(context).size.width*0.06,
                  ),
                  onPressed: () {
                    setState(() {
                      widget.pinned = !widget.pinned;
                    });
                    widget.pinnedChanged(widget.pinned);
                  },
                ),
              ),
            ],
          ),
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
                              dashPattern: const [10, 10],
                              color: AppColors.grey.withOpacity(0.5),
                              strokeWidth: 2,
                              child: Container(
                                  height: MediaQuery.of(context).size.height*0.15,
                                  width: MediaQuery.of(context).size.height*0.9,
                                  color: Colors.transparent,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
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
                                            AppLocalizations.of(context)!.photosDimensions,
                                            style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10),
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
                                  await _brandDataService.deleteBrandContentPictures(widget.brandId, image.id!, image.url!);

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

