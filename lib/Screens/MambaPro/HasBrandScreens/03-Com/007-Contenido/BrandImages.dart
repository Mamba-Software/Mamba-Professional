import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/Models/ImageObject.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Images/ImageUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Badges/CounterBadgeIcon.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/RectangularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/TopSnackBar/TopSnackBarDef.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/DeleteConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/FullScreenImageCarousel.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/FavouriteConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:permission_handler/permission_handler.dart';

class BrandImages extends StatefulWidget {
  String brandId;
  bool pinned;
  ValueChanged<bool?> pinnedChanged;

  BrandImages({Key? key, required this.brandId, required this.pinned, required this.pinnedChanged}) : super(key: key);

  @override
  _BrandImagesState createState() => _BrandImagesState();
}

class _BrandImagesState extends State<BrandImages> with WidgetsBindingObserver {

  // App Bar and Scroll View
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  ScrollController? _scrollController;
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    if (!_scrollController!.hasClients) {
      return false;
    }
    if (_scrollController!.position.userScrollDirection == ScrollDirection.forward) {
      // User is down up, so AppBar should expand.
      return false;
    }
    // Use the same condition as before to check if AppBar is expanded.
    return _scrollController!.offset > (MediaQuery.of(context).size.height * 0.13 - kToolbarHeight);
  }
  // Acceso a Base de Datos
  final _brandDataService = BrandDataService();
  // Boolean Loading
  bool isLoading = false;
  String isLoadingText = "";
  String isLoadingTextExtra = "";
  bool canEdit = false;
  // Bool Max Images Added
  bool maxImagesAdded = false;
  // Max Number of Images
  final int _maxImages = 10;
  int currentImage = 1;
  int totalCurrentImage = 1;
  // Images uploaded
  List<ImageObject> _imagesUploaded = [];
  ImageObject baseImage = ImageObject();
  int baseImageIndex = 0;
  List<Widget> imageSliders = [];

  bool canClickFav = true;

  // Settings when permission not given
  bool isSettingsOpened = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController()
      ..addListener(() => _isAppBarExpanded ?
      setState(() {
        appBarExpanded = true;
      }) :
      setState(() {
        appBarExpanded = false;
      }),
      );
    canEdit = currentUser.brandRole < 2 ? true : false;
    isLoading = true;
    Future.delayed(Duration.zero, () {
      setState(() {
        isLoadingText = AppLocalizations.of(context)!.loading.split(".")[0]+" "+AppLocalizations.of(context)!.photos.toLowerCase()+"...";
      });
    });
    getBrandContentImages();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    // If user resumed to this app, check permission
    if(state == AppLifecycleState.resumed && isSettingsOpened) {
      setState(() {
        isSettingsOpened = false;
      });
      var status = await Permission.photos.status;
      print("Status After Settings: "+status.toString());
      if (status.isLimited || status.isGranted) {
        getImage();
      }
    }
  }

  // Selects image from Gallery and updates in firebase.
  Future getImage() async {
    if (!brandIsActive) {
      await navigateToPayWall(context);
    } else {
      mixpanel!.timeEvent('brand_images_added');
      try {
        List<File>? temp = await ImageUtils().pickMultipleImage();
        if ((temp!.length) > (_maxImages-_imagesUploaded.length)) {
          mixpanel!.track('brand_images_max_images_error');
          setState(() {
            maxImagesAdded = true;
          });
        } else {
          int currentImage = 1;
          setState(() {
            isLoading = true;
            isLoadingText = AppLocalizations.of(context)!.adding+" "+AppLocalizations.of(context)!.photos.toLowerCase()+"...";
            maxImagesAdded = false;
          });
          for (File f in temp) {
            // Updating Loading Text
            setState(() {
              isLoadingTextExtra =  " (" + currentImage.toString()+"/"+temp.length.toString()+")";
            });
            currentImage += 1;
            await _brandDataService.addBrandContentPictureIndividual(widget.brandId, f);
          }
          getBrandContentImages();
          mixpanel!.track('brand_images_added');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print(e.toString());
        var status = await Permission.photos.status;
        if (Platform.isIOS && (status.isDenied || status.isPermanentlyDenied)) {
          bool temp = await openAppSettings();
          setState(() {
            isSettingsOpened = temp;
          });
        }
      }

    }
  }

  // Gets the user info from firebase.
  Future<void> getBrandContentImages() async {
    _imagesUploaded = await _brandDataService.getBrandContentPictures(widget.brandId);
    if(_imagesUploaded.isNotEmpty) {
      // Find the base image
      baseImage = _imagesUploaded.firstWhere((element) =>  element.isBaseImage != null && element.isBaseImage == true, orElse: () => ImageObject());
      // If there isn´t baseImage, set it randomly
      if (baseImage.id == null) {
        // Random
        baseImage = _imagesUploaded.first;
        baseImage.setBaseImage = baseImage;
        _imagesUploaded.remove(baseImage);
        await _brandDataService.updateBrandBaseImage(widget.brandId, baseImage, null);
      }
      _imagesUploaded.removeWhere((element) =>  element.isBaseImage != null && element.isBaseImage == true);
      _imagesUploaded.sort((a,b) {
        var aDate = a.timestamp!.toDate();
        var bDate = b.timestamp!.toDate();
        return aDate.compareTo(bDate);
      });
      _imagesUploaded = List.from(_imagesUploaded.reversed);
      _imagesUploaded.insert(0, baseImage);
    }
    setState(() {
      isLoading = false;
      isLoadingTextExtra = "";
    });
  }

  void showInSnackBar(String value, int duration) {
    final snackbar = SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.0, horizontal: MediaQuery.of(context).size.width * 0.05),
      elevation: 8,
      content: Row(
        children: [
          Icon(Icons.info_outlined, color: Theme.of(context).primaryColor, size:  MediaQuery.of(context).size.width*0.08,),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
                value,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Theme.of(context).primaryColor),
          borderRadius: const BorderRadius.all(Radius.circular(10.0))
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      duration: Duration(seconds: duration),
    );
    scaffoldMessengerKey.currentState!.showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        body: Stack(
          alignment: Alignment.bottomRight,
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  backgroundColor: AppColors.darkGrey,
                  expandedHeight: MediaQuery.of(context).size.height*0.15,
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                  elevation: 4,
                  floating: false,
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
                  title: AnimatedOpacity(
                      opacity: appBarExpanded ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                          AppLocalizations.of(context)!.photos,
                          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(color: AppColors.white,)
                      )
                  ),
                  centerTitle: false,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CounterBadgeIcon(
                          counter: unreadNotifications,
                          top: 5,
                          right: 7,
                          child: IconButton(
                            icon: Icon(Icons.notifications, color: AppColors.white, size: MediaQuery.of(context).size.width*0.06),
                            alignment: Alignment.center,
                            padding: EdgeInsets.zero,
                            onPressed: () => navigateToNotificationsScreen(context),
                          ),
                        ),
                        CounterBadgeIcon(
                          counter: unreadChats,
                          top: 5,
                          right: 7,
                          child: IconButton(
                            icon: Icon(Icons.chat, color: AppColors.white, size: MediaQuery.of(context).size.width*0.06),
                            alignment: Alignment.center,
                            padding: EdgeInsets.zero,
                            onPressed: () => navigateToChatScreen(context),
                          ),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width*0.03),
                        GestureDetector(
                          onTap: () => navigateToProfileScreen(context),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.width * 0.08,
                            child: Center(
                              child: CircularImage(
                                size: MediaQuery.of(context).size.width * 0.08,
                                image: currentUser.imageUrl,
                                color: AppColors.grey,
                                borderWidth: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width*0.03),
                  ],
                ),
                isLoading ? SliverFillRemaining(
                  child: Center(
                        child: LoadingView(
                          //text: (AppLocalizations.of(context)!.loading.split(".")[0]+" "+AppLocalizations.of(context)!.photos.toLowerCase()+"...") + isLoadingTextExtra!,
                          text: isLoadingText + isLoadingTextExtra,
                        )
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
                                    AppLocalizations.of(context)!.yourImagesDescription.split("\n")[0],
                                    style: Theme.of(context).textTheme.caption?.copyWith(height: 1.5),
                                    textAlign: TextAlign.left
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
                                style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ) : Container(),
                        ],
                      ),
                    )
                ),
                isLoading || _imagesUploaded.isEmpty ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: Image.asset(Constants.emptyCalendar)),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.2),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                AppLocalizations.of(context)!.noData.split(" ")[0]+" "+AppLocalizations.of(context)!.photos.toLowerCase()+". "+AppLocalizations.of(context)!.yourImagesDescription.split("\n")[2],
                                style: Theme.of(context).textTheme.caption,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ) : SliverGrid(
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
                            child: Material(
                              elevation: 8,
                              borderRadius: BorderRadius.circular(15.0),
                              child: RectangularImage(
                                height: MediaQuery.of(context).size.height*0.18,
                                width: MediaQuery.of(context).size.height*0.9,
                                borderRadius: 10,
                                color: AppColors.grey,
                                borderWidth: 0,
                                image: image.url,
                              ),
                            ),
                          ),
                          /// Set Favorite Image
                          canEdit && image.isBaseImage != true ? Positioned(
                            top: MediaQuery.of(context).size.width*0.03,
                            right: MediaQuery.of(context).size.width*0.14,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 7.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width*0.1,
                                decoration: BoxDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Theme.of(context).scaffoldBackgroundColor, //New
                                          blurRadius: 1.0,
                                          offset: const Offset(0, 0)
                                      )
                                    ],
                                ),
                                child: Center(
                                  child: IconButton(
                                    onPressed: () async {
                                      if(!brandIsActive) {
                                        await navigateToPayWall(context);
                                      }
                                      else {
                                        if (image.isBaseImage != null && image.isBaseImage!) {
                                          //topSnackBarComp.showSnackBarBottom(context, AppLocalizations.of(context)!.myImagesFavouriteDelete, 5, false);
                                        } else if (canClickFav) {
                                          var result = await showDialog(
                                              context: context,
                                              builder: (_) {
                                                return FavouriteConfirmationDialog(
                                                    text: AppLocalizations.of(
                                                        context)!
                                                        .myImagesFavouriteDescription);
                                              }
                                          );
                                          if (result) {
                                            setState(() {
                                              canClickFav = false;
                                              _imagesUploaded[_imagesUploaded.indexWhere((element) => element.isBaseImage != null && element.isBaseImage == true)].isBaseImage = false;
                                              image.isBaseImage = true;
                                            });
                                            await _brandDataService.updateBrandBaseImage(widget.brandId, image, baseImage.id!);
                                            await getBrandContentImages();
                                            setState(() {
                                              canClickFav = true;
                                            });
                                          }
                                        }
                                      }
                                    },
                                    icon: image.isBaseImage != null && image.isBaseImage! ? Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                        size: MediaQuery.of(context).size.width*0.06
                                    ) : Icon(
                                        Icons.favorite_outline_outlined,
                                        color: Theme.of(context).primaryColor,
                                        size: MediaQuery.of(context).size.width*0.06
                                    ),
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ),
                            ),
                          ) : Container(),
                          /// Delete Image
                          canEdit && image.isBaseImage != true ? Positioned(
                            top: MediaQuery.of(context).size.width*0.03,
                            right: MediaQuery.of(context).size.width*0.02,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 7.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width*0.1,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Theme.of(context).scaffoldBackgroundColor, //New
                                        blurRadius: 1.0,
                                        offset: const Offset(0, 0)
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: IconButton(
                                    onPressed: () async {
                                      if (!brandIsActive) {
                                        await navigateToPayWall(context);
                                      } else {
                                        if ((image.isBaseImage == null || !image.isBaseImage!) && canClickFav) {
                                          var result = await showDialog(
                                            context: context,
                                            builder: (_) {
                                              return DeleteConfirmationDialog(
                                                  text: AppLocalizations.of(context)!.myImagesDeleteDescription
                                              );
                                            }
                                          );
                                          if (result) {
                                            mixpanel!.track('brand_images_delete');
                                            setState(() {
                                              isLoading = true;
                                              isLoadingText = AppLocalizations.of(context)!.deleting+" "+AppLocalizations.of(context)!.photos.toLowerCase()+"...";
                                              isLoadingTextExtra =  " (" + 1.toString()+"/"+1.toString()+")";
                                            });
                                            await _brandDataService.deleteBrandContentPictures(widget.brandId, image.id!, image.url!);
                                            getBrandContentImages();
                                          }
                                        } else {
                                          //topSnackBarComp.showSnackBarBottom(context, AppLocalizations.of(context)!.myImagesFavouriteDelete, 5, false);
                                        }
                                      }
                                    },
                                    icon: Icon(
                                        Icons.delete_outline,
                                        color: AppColors.red,
                                        size: MediaQuery.of(context).size.width*0.06
                                    ),
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ),
                            ),
                          ) : Container(),
                          /// Delete Last Cover Image
                          canEdit && image.isBaseImage == true && _imagesUploaded.length == 1 ? Positioned(
                            top: MediaQuery.of(context).size.width*0.03,
                            right: MediaQuery.of(context).size.width*0.02,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 7.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width*0.1,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Theme.of(context).scaffoldBackgroundColor, //New
                                        blurRadius: 1.0,
                                        offset: const Offset(0, 0)
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: IconButton(
                                    onPressed: () async {
                                      if (!brandIsActive) {
                                        await navigateToPayWall(context);
                                      } else {
                                        if (canClickFav) {
                                          var result = await showDialog(
                                            context: context,
                                            builder: (_) {
                                              return DeleteConfirmationDialog(
                                                text: AppLocalizations.of(context)!.myImagesDeleteDescription+"\n\n"+AppLocalizations.of(context)!.yourImagesDescription.split("\n")[2]);
                                            }
                                          );
                                          if (result) {
                                            mixpanel!.track('brand_images_delete');
                                            setState(() {
                                              isLoading = true;
                                              isLoadingText = AppLocalizations.of(context)!.deleting+" "+AppLocalizations.of(context)!.photos.toLowerCase()+"...";
                                              isLoadingTextExtra =  " (" + 1.toString()+"/"+1.toString()+")";
                                            });
                                            await _brandDataService.deleteBrandCoverPicture(widget.brandId, image.id!, image.url!);
                                            getBrandContentImages();
                                          }
                                        }
                                      }
                                    },
                                    icon: Icon(
                                        Icons.delete_outline,
                                        color: AppColors.red,
                                        size: MediaQuery.of(context).size.width*0.06
                                    ),
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ),
                            ),
                          ) : Container(),
                          /// Cover Image
                          image.isBaseImage == true ? Positioned(
                            top: MediaQuery.of(context).size.width*0.038,
                            right: _imagesUploaded.length == 1 ? MediaQuery.of(context).size.width*0.16 : MediaQuery.of(context).size.width*0.03,
                            child: GestureDetector(
                              onTap: () {
                                showInSnackBar(AppLocalizations.of(context)!.myImagesFavouriteDelete, 5);
                              },
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Container(
                                  height: MediaQuery.of(context).size.height*0.045,
                                  width: MediaQuery.of(context).size.width*0.25,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(30.0),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Theme.of(context).scaffoldBackgroundColor, //New
                                          blurRadius: 1.0,
                                          offset: const Offset(0, 0)
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.favorite, color: AppColors.red, size:  MediaQuery.of(context).size.width*0.05,),
                                      const SizedBox(width: 4),
                                      Text(
                                        AppLocalizations.of(context)!.createBrandCover,
                                        style: Theme.of(context).textTheme.bodyText2?.copyWith(color:Theme.of(context).primaryColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ) : Container(),
                        ],
                      ),
                    );
                    },
                    childCount: _imagesUploaded.length,
                  ),
                ),
                isLoading || _imagesUploaded.isEmpty ? SliverToBoxAdapter(child: Container()) : SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height*0.05),
                        ],
                      ),
                    )
                ),
              ],
            ),
            Padding(
              padding: Platform.isAndroid ? EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.02, horizontal: MediaQuery.of(context).size.width*0.045) : EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.06, horizontal: MediaQuery.of(context).size.width*0.04),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.0115),
                  width: MediaQuery.of(context).size.width*0.2,
                  decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          AppLocalizations.of(context)!.photos,
                          style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 11),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                          " "+_imagesUploaded.length.toString()+"/"+_maxImages.toString(),
                          style: Theme.of(context).textTheme.caption?.copyWith(fontSize: 11),
                          textAlign: TextAlign.center
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        floatingActionButton: canEdit ? Padding(
            padding: Platform.isAndroid ? const EdgeInsets.symmetric(vertical: 20, horizontal: 10) : const EdgeInsets.all(10),
            child: SizedBox(
              height: MediaQuery.of(context).size.width*0.15,
              width: MediaQuery.of(context).size.width*0.15,
              child: FloatingActionButton(
                onPressed: () async {
                  if (_imagesUploaded.length < _maxImages) {
                    await getImage();
                  }
                },
                backgroundColor: _imagesUploaded.length < _maxImages ? Theme.of(context).colorScheme.secondary : Theme.of(context).disabledColor,
                child: const Icon(Icons.add, color: AppColors.white),
              ),
            )
        ) : Container(),
      ),
    );
  }
}

