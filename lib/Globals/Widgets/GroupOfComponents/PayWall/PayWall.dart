import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/AdminService/SettingsDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Promotions/PromotionsDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Subscription.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Text/TitleHeadline1.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/TopSnackBar/TopSnackBarDef.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Data/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/BrandScreen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../Providers/ThemeProvider.dart';

class PayWall extends StatefulWidget {
  String brandId;
  bool? comesFromInitPage;
  PayWall({Key? key, required this.brandId, this.comesFromInitPage}) : super(key: key);

  @override
  _PayWallState createState() => _PayWallState();
}

class _PayWallState extends State<PayWall> {

  // App Bar and Scroll View
  ScrollController _scrollController = ScrollController();
  bool appBarExpanded = false;

  // Acceso a Base de Datos
  final _brandDataService = BrandDataService();
  final _userDataService = UserDataService();
  final _promotionDataService = PromotionsDataService();
  final _settingsDataService = SettingsDataService();
  String? brandId = '';

  //PayWall
  bool seePromotions = true;
  bool loadingPromotions = false;
  int activeSubscription = -1;
  var promotionController = TextEditingController();
  Subscription subscritionPromo = Subscription();
  List<Subscription> subscriptionList = [];
  double finalSizeBox = 0.01;
  final _topSnackBar = TopSnackBarDef();


  // Boolean Loading
  bool isLoading = false;
  // Request List
  List<RequestToBrand> requestList = [];

  @override
  initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  Future<void> getSubscriptions()
  async {
    List<Subscription> subscriptionListAux = [];
    subscriptionList.clear();
    if(currentBrand.subscription == null) {
      if (subscritionPromo.id == null) {
        subscriptionListAux = await _promotionDataService.getSubscriptions("", currentBrand.id!);
      }
      else {
        subscriptionListAux =
        await _promotionDataService.getSubscriptions(subscritionPromo.id, currentBrand.id!);
      }
      for (int j = 0; j < subscriptionListAux.length; ++j) {
        if (currentUser.idioma == "ca") {
          subscriptionListAux[j].descriptionAdapted =
              subscriptionListAux[j].description;
        }
        subscriptionList.add(subscriptionListAux[j]);
      }
    }
    try {
      Purchases.getCustomerInfo();
      String monthFree = await _settingsDataService.checkMonthOffer();
      Brand brand = await _brandDataService.getBrandDetails(currentBrand.id!);
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current?.monthly != null) {
        if(offerings.current?.monthly?.storeProduct != null)
        {
          Subscription subMonth = Subscription.fromOfferingAllData(offerings.current?.monthly!.storeProduct, AppLocalizations.of(context)!.perMonth, offerings.current!.monthly!);
          DateFormat format = DateFormat('dd-MM-yyyy');
          if(brand.subscription == null && (brand.dateJoined != null && format.parse(brand.dateJoined!).isAfter(format.parse(monthFree))))
          {
            subMonth.priceString = "";
            subMonth.descriptionAdapted = 'Primer mes gratis';
          }

          subscriptionList.add(subMonth);
        }
      }
      if (offerings.current != null && offerings.current?.annual != null) {
        print(offerings.current?.annual!.storeProduct);
        //print(offerings.current?.annual!.storeProduct);
        if(offerings.current?.annual?.storeProduct != null)
        {
          subscriptionList.add(Subscription.fromOfferingAllData(offerings.current?.annual!.storeProduct, AppLocalizations.of(context)!.perYear, offerings.current!.annual!));
        }
        // Get the price and introductory period from the Product
      }
    }  catch (e) {
      // optional error handling
    }
    finalSizeBox = subscriptionList.length * 0.07;
    setState(() {
      loadingPromotions = false;
      seePromotions = false;
    });

  }

  Future<void> getPromotion([bool fromSeeSubsc = false]) async
  {
    subscritionPromo =
    await _promotionDataService
        .getValidSubscription(
        promotionController.text, widget.brandId);
    if(fromSeeSubsc)
    {
      setState(() {
        loadingPromotions = false;
        seePromotions = true;
      });
    }
    /*
    if(fromSeeSubsc)
    {
      setState(() {
        loadingPromotions = false;
        seePromotions = false;
      });
    }
    else {
      setState(() {
        loadingPromotions = false;
      });
      }
     */

  }

  List<RequestToBrand> documentsToRequests(List<DocumentSnapshot> documents) {
    List<RequestToBrand> requests = [];
    for(int i = 0; i < documents.length; i++) {
      RequestToBrand request = RequestToBrand.fromObjectAllData(documents[i].id, documents[i]);
      requests.add(request);
    }
    /*
    for (var i=0; i< 10; i++) {
      RequestToBrand request = RequestToBrand.fromObjectAllData(documents[0].id, documents[0]);
      requests.add(request);
    }
     */

    return requests;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05, right: MediaQuery.of(context).size.width * 0.05, top: MediaQuery.of(context).size.width * 0.15, bottom: MediaQuery.of(context).size.width * 0.00),
            child:  Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                animationMobile(),
                SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.02),
                Text(
                  AppLocalizations.of(context)!.tanksforUsing,
                  style: Theme.of(context)
                      .textTheme
                      .headline1
                      ?.copyWith(fontSize: 30),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.04),
                containerJoin(),
                SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.04),
                getAll(),
                SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.02),
                promotionGet(),
                SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.02),
                Divider(color: Theme.of(context).dividerColor, thickness: 1.5),
                buildContactUsContainer(),

              ],
            ),
          ),
        ),
        persistentFooterButtons:   <Widget>[Container(
          child:
          seePromotions
              ? Padding(
            padding: EdgeInsets.symmetric(
              vertical:
              MediaQuery.of(context).size.width *
                  0.04,
              horizontal:
              MediaQuery.of(context).size.width *
                  0.01,),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                    onTap: () async {
                      mixpanel!.track('brand_see_subscription');
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        loadingPromotions = true;
                      });
                      await getSubscriptions();
                    },
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.mainColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: MediaQuery.of(context).size.height * 0.07,
                        child:  Center(
                          child: loadingPromotions? LoadingView(isSmall: true, color: AppColors.white, hasLogo: false,) : Text(
                            AppLocalizations.of(context)!.seeSubscriptionPayWall,
                            style: Theme.of(context)
                                .textTheme
                                .headline1
                                ?.copyWith(
                              color: AppColors.white,
                            ),
                          ),

                        ),
                      ),
                    )
                ),
              ],
            ),
          ) : Padding(
                padding: EdgeInsets.symmetric(
                  vertical:
                  MediaQuery.of(context).size.width *
                      0.04,
                  horizontal:
                  MediaQuery.of(context).size.width *
                      0.01,),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                for (int i = 0; i < subscriptionList.length; ++i)
                    generateOneSubscription(i),
            ],
          ),
              ),
        ),
        ]
      ),
    );
  }

  Widget animationMobile()
  {
    return FittedBox(
      fit: BoxFit.fitHeight,
      child:
      Container(
        child: Stack(
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width* 0.1),
                height: MediaQuery.of(context).size.height*0.6,
                child: AnimatedAlign(
                  alignment: Alignment.center,
                  duration: Duration(seconds: 10),
                  child: Provider.of<ThemeProvider>(context, listen: false).isDarkMode? Image.asset(
                    Constants.mobileProDark,
                    fit: BoxFit.contain,
                  ) : Image.asset(
                    Constants.mobileProLight,
                    fit: BoxFit.contain,
                  )
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                mixpanel!.track('brand_leaves_paywallscreen');
                if(widget.comesFromInitPage != null && widget.comesFromInitPage == true)
                {
                  Navigator.pushAndRemoveUntil(
                    context,
                    CupertinoPageRoute<void>(
                      builder: (context) => const BrandScreen(),
                      settings: const RouteSettings(name: 'BrandScreen'),
                    ),
                        (_) => false,
                  );
                }
                else {
                  Navigator.pop(context);
                }
              },
              icon: Icon(
                Icons.close,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget containerJoin()
  {
    return  Material(
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor.withOpacity(0.3),
          //color: AppColors.darkGrey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        width: MediaQuery.of(context).size.width * 0.90,
        height: MediaQuery.of(context).size.height * 0.32,
        child:  Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        Constants.subscriptionImage,
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: MediaQuery.of(context).size.width * 0.3,
                        fit: BoxFit.fill,
                      ),
                    )
                ),
                SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.02),
                Text(
                  AppLocalizations.of(context)!.updateToday,
                  style: Theme.of(context)
                      .textTheme
                      .headline1
                      ?.copyWith(
                      fontWeight: FontWeight.normal, color: Theme.of(context).primaryColor, fontSize: 30
                  ),
                ),
                SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.joinToBrands,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.copyWith(
                          fontWeight: FontWeight.normal, color: Theme.of(context).primaryColor
                      ),
                    ),
                    Text(
                      'fitness',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.copyWith(
                          fontWeight: FontWeight.normal, color: AppColors.mainColor,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),

        ),
      ),
    );
  }

  Widget getAll()
  {
    return  Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal:  MediaQuery.of(context).size.height *
            0.005),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.getAll,
              style: Theme.of(context)
                  .textTheme
                  .headline1
                  ?.copyWith(fontSize: 30, fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
            Text(
              AppLocalizations.of(context)!.getAllDesc,
              style: Theme.of(context)
                  .textTheme
                  .bodyText1,
              textAlign: TextAlign.center,
            ),
            SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.03),
            listTileGetAll(Icons.feed_outlined, AppLocalizations.of(context)!.personalizeBrandPayWallHeader, AppLocalizations.of(context)!.personalizeBrandPayWallText),
            listTileGetAll(Icons.search, AppLocalizations.of(context)!.searcherPayWallHeader, AppLocalizations.of(context)!.searcherPayWallText),
            listTileGetAll(Icons.calendar_month_outlined, AppLocalizations.of(context)!.sessionControlPayWallHeader, AppLocalizations.of(context)!.sessionControlPayWallText),
            listTileGetAll(Icons.confirmation_number_outlined, AppLocalizations.of(context)!.pricePolicyPayWallHeader, AppLocalizations.of(context)!.pricePolicyPayWallText),
            listTileGetAll(Icons.leaderboard_outlined, AppLocalizations.of(context)!.statsPayWallHeader, AppLocalizations.of(context)!.statsPayWallText),
            SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.03),
            TextButton(
              onPressed: () async {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                if (Localizations.localeOf(context).languageCode == 'es') {
                  if (!await launchUrl(Uri.parse(functionalitiesES))) throw 'Could not launch $functionalitiesES';
                } else if (Localizations.localeOf(context).languageCode == 'ca') {
                  if (!await launchUrl(Uri.parse(functionalitiesCA))) throw 'Could not launch $functionalitiesCA';
                } else {
                  if (!await launchUrl(Uri.parse(functionalitiesES))) throw 'Could not launch $functionalitiesES';
                }
              },
              child:  Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius
                      .circular(20),
                ),
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.90,
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.05,
                child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.moreInfoInWeb,
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyText1
                          ?.copyWith(
                          fontWeight: FontWeight
                              .normal,
                          color: Theme.of(context).primaryColor
                      ),
                    )

                ),
              ),
            ),
            SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.01),
            Divider(color: Theme.of(context).dividerColor, thickness: 1.5),
          ],
        ),
      ),
    );
  }

  Widget generateOneSubscription(int index)
  {
    return Column(
      children: [
        GestureDetector(
            onTap: () async {
              setState(() {
                activeSubscription = index;
              });
              mixpanel!.track('brand_clicked_subscription');
              FocusManager.instance.primaryFocus?.unfocus();
              if(subscriptionList[index].package != null) {
                try {
                  var purchaserInfo = await Purchases.purchasePackage(
                      subscriptionList[index].package!);
                  if (purchaserInfo.entitlements.active.isNotEmpty &&
                      purchaserInfo.entitlements.all[entitlementID]!.isActive) {
                    mixpanel!.track('brand_subscribed');
                    _brandDataService.updateBrandSubscriptionRevenueCat(
                        currentBrand.id!,
                        purchaserInfo.entitlements.all[entitlementID]!
                            .expirationDate,
                        purchaserInfo.entitlements.all[entitlementID]!
                            .originalPurchaseDate,
                        purchaserInfo.entitlements.all[entitlementID]!
                            .productIdentifier,
                        purchaserInfo.entitlements.all[entitlementID]!
                            .unsubscribeDetectedAt);
                    Navigator.pop(context);
                  }
                } on PlatformException catch (e) {
                  var errorCode = PurchasesErrorHelper.getErrorCode(e);
                  if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
                    ('ERROR ON PURCHASING');
                  }
                }
              }
              else {
                await showModalBottomSheet<int?>(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  builder: (BuildContext context) {
                    // Page View Controller
                    final PageController _pageController = PageController(
                        initialPage: 0);
                    int _currentPage = 0;
                    bool isRoles = true;
                    // Widget
                    return ModalBuy(subscriptionList[index]);
                  },
                );
              }
              setState(() {
                activeSubscription = -1;
              });
              //
            },
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.mainColor,
                    width: 1,
                  ),
                  color: index == subscriptionList.length - 1? AppColors.mainColor : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                width: MediaQuery.of(context).size.width * 0.90,
                height: MediaQuery.of(context).size.height * 0.07,
                child:  Center(
                  child: (activeSubscription == index)? LoadingView(isSmall: true, color: index == subscriptionList.length - 1 ? AppColors.white : AppColors.mainColor, hasLogo: false,) : index == subscriptionList.length - 1? Text(
                    subscriptionList[index].package == null? subscriptionList[index].descriptionAdapted! : subscriptionList[index].priceString! + ' ' + subscriptionList[index].descriptionAdapted!,
                    style:  Theme.of(context)
                        .textTheme
                        .headline1
                        ?.copyWith(
                      color: AppColors.white,
                    ),
                  ) : Text(
                    subscriptionList[index].package == null? subscriptionList[index].descriptionAdapted! : subscriptionList[index].priceString! + ' ' + subscriptionList[index].descriptionAdapted!,
                    style: Theme.of(context)
                        .textTheme
                        .headline1
                        ?.copyWith(
                      color: AppColors.white,
                    ),
                  ),

                ),
              ),
            )
        ),
        index == subscriptionList.length - 1? Container() : SizedBox(
            height: MediaQuery.of(context).size.height *
                0.02),
      ],
    );
  }

  Widget ModalBuy(Subscription sub)
  {
    return StatefulBuilder(
      builder: (BuildContext context,
          StateSetter setStateBottom) {
        return FractionallySizedBox(
          heightFactor: 0.40,
          child: SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.5,
            width: MediaQuery
                .of(context)
                .size
                .width,
            child: Padding(
              padding: EdgeInsets.all(MediaQuery
                  .of(context)
                  .size
                  .width * 0.02),
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                        'Mamba Pro',
                        style: Theme
                            .of(context)
                            .textTheme
                            .caption,
                        textAlign: TextAlign.left
                    ),
                    trailing: Text(
                        AppLocalizations.of(context)!.subscriptionsAppBar,
                        style: Theme
                            .of(context)
                            .textTheme
                            .caption
                    ),
                    dense: true,
                  ),
                  Divider(color: Theme
                      .of(context)
                      .dividerColor,
                      thickness: 1.5,
                      indent: MediaQuery
                          .of(context)
                          .size
                          .width * 0.05,
                      endIndent: MediaQuery
                          .of(context)
                          .size
                          .width * 0.05),
                  ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        Constants.subscriptionImage,),
                    ),
                    title: Text(
                        sub.title!,
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyText1,
                        textAlign: TextAlign.left
                    ),
                    subtitle: Text(
                        'Fitness is Business',
                        style: Theme
                            .of(context)
                            .textTheme
                            .caption
                    ),
                    dense: true,
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Text(AppLocalizations.of(context)!.uniquePromotion),
                        Icon(
                          Icons.done,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text(
                        AppLocalizations.of(context)!.startToday,
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyText1,
                        textAlign: TextAlign.left
                    ),
                    trailing: Text(
                        sub.descriptionAdapted!,
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyText1
                    ),
                    dense: true,
                  ),
                  ListTile(
                      title: Center(
                        child: GestureDetector(
                          onTap: () async {
                            mixpanel!.track('brand_subscribed');
                            await _brandDataService
                                .updateBrandPay(widget.brandId,
                                sub.duration!,
                                sub.id!,
                                sub.title!, DateTime.now(), false);
                              // currentBrand.setBasicData = await _brandDataService.getBrandDetails(widget.brandId);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.mainColor,
                                borderRadius: BorderRadius
                                    .circular(10),
                              ),
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.90,
                              height: MediaQuery
                                  .of(context)
                                  .size
                                  .height * 0.05,
                              child: Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.subscribeNow,
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .bodyText1
                                        ?.copyWith(
                                        fontWeight: FontWeight
                                            .bold,
                                        color: AppColors.black
                                    ),
                                  )

                              ),
                            ),
                          ),
                        ),
                      )
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }



  Widget listTileGetAll(var icon, String title, String subtitle)
  {
    return Padding(
      padding: EdgeInsets.only(bottom:  MediaQuery.of(context).size.height *
        0.01,),
      child: ListTile(
        leading: Icon(
          icon,
          size: 50,
        ),
        title: Text(
            title,
            style: Theme.of(context).textTheme.bodyText1,
            textAlign: TextAlign.left
        ),
        subtitle: Text(
            subtitle,
            style: Theme.of(context).textTheme.caption
        ),
        dense: true,
      ),
    );
  }

  Widget promotionGet()
  {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal:  MediaQuery.of(context).size.height *
            0.005),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.promotionUse,
              style: Theme.of(context)
                  .textTheme
                  .headline1
                  ?.copyWith(fontSize: 30, fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
            promotionController
                .text.isNotEmpty && promotionController.text.length == 17?
            loadingPromotions? Padding(
              padding: EdgeInsets.symmetric(
                  horizontal:
                  MediaQuery.of(context).size.width *
                      0.02,
                  vertical:
                  MediaQuery.of(context).size.width *
                      0.03),
              child: LoadingView(
                color: Theme.of(context).primaryColor,
                hasLogo: false,
                isSmall: true,
              ),
            ) : Padding(
                padding: EdgeInsets.symmetric(
                    horizontal:
                    MediaQuery.of(context).size.width *
                        0.02,
                    vertical:
                    MediaQuery.of(context).size.width *
                        0.03),
                child: subscritionPromo.id == null? Row(
                  children: [
                    Text(AppLocalizations.of(context)!.noPromotions),
                    Icon(
                      Icons.close,
                      color: Colors.red,
                    ),
                  ],
                ) : Column(
                  children: [
                    Row(
                      children: [
                        Text(AppLocalizations.of(context)!.promotionDetected),
                        Icon(
                          Icons.done,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ],
                )
            ) : Container(),
            promotionController
                .text.isNotEmpty && promotionController.text.length == 17?  Container() : SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.02),
            Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(15.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      maxLength: 17,
                      autofocus: false,
                      controller: promotionController,
                      keyboardType: TextInputType.name,
                      onChanged: (val) async {
                        if (promotionController
                            .text.isNotEmpty && promotionController.text.length == 17) {
                          setState(() {
                            loadingPromotions = true;
                          });
                          await getPromotion(true);
                        }
                        else {
                          subscritionPromo = Subscription();
                          finalSizeBox = 0.05;
                          setState(() {
                            seePromotions = true;
                          });
                        }
                      },
                      style: Theme.of(context)
                          .textTheme
                          .headline3
                          ?.copyWith(
                          fontWeight: FontWeight.normal,
                          color: AppColors.black),
                      textCapitalization:
                      TextCapitalization.words,
                      decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.white,
                          hintText:
                          AppLocalizations.of(context)!.insertCode,
                          hintStyle: Theme.of(context)
                              .textTheme
                              .headline3
                              ?.copyWith(
                              color: AppColors.grey,
                              fontWeight:
                              FontWeight.normal),
                          errorStyle: Theme.of(context)
                              .textTheme
                              .bodyText2
                              ?.copyWith(
                              color: AppColors.red),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 1.5),
                            borderRadius:
                            BorderRadius.circular(15.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 1.5),
                            borderRadius:
                            BorderRadius.circular(15.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 1.5),
                            borderRadius:
                            BorderRadius.circular(15.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 1.5),
                            borderRadius:
                            BorderRadius.circular(15.0),
                          ),
                          contentPadding:
                          const EdgeInsets.fromLTRB(
                              12, 8, 12, 8)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContactUsContainer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal:  MediaQuery.of(context).size.height *
          0.005, vertical: MediaQuery.of(context).size.height *
          0.02),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TitleHeadline1(
            text: AppLocalizations.of(context)!.anyDoubt,
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.015),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.0),
            child: Text(
                AppLocalizations.of(context)!.getInTouchText,
                style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).primaryColor),
                textAlign: TextAlign.center
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.015),
          SizedBox(
            width: MediaQuery.of(context).size.width*0.4,
            child: OutlinedButton(
              onPressed: () => launchEmail(),
              child: Text(
                AppLocalizations.of(context)!.getInTouch,
                style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              style: OutlinedButton.styleFrom(
                elevation: 4,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                fixedSize: Size(MediaQuery.of(context).size.width*0.35, MediaQuery.of(context).size.height*0.06),
                side: BorderSide(width: 1.0, color: Theme.of(context).scaffoldBackgroundColor),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
              ),
            ),
          ),
        ],

      ),
    );
  }

  Future<void> launchEmail() async {
    mixpanel!.track('user_profile_email_mamba');
    const url = 'mailto:mambastylecastelldefels@gmail.com';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    }
  }


  @override
  void dispose() {
    super.dispose();
  }

}