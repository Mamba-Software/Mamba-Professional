import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mamba/app/theme/theme_manager.dart';
import 'package:mamba/l10n/language_manager.dart';
import 'package:intl/intl.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/home/views/brand_screen.dart';
import 'package:mamba/data/AdminService/SettingsDataService.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/Promotions/PromotionsDataService.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/data/Models/Subscription.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/commons/widgets/Components/Text/TitleHeadline1.dart';
import 'package:mamba/commons/widgets/Components/TopSnackBar/TopSnackBarDef.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba/data/Models/RequestToBrand.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PayWall extends StatefulWidget {
  String brandId;
  bool? comesFromInitPage;
  PayWall({super.key, required this.brandId, this.comesFromInitPage});

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
  bool isDark = true;
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
    isDark = context.read<ThemeManager>().isDarkMode;    
  }

  Future<void> getSubscriptions() async {
    List<Subscription> subscriptionListAux = [];
    subscriptionList.clear();
    if (currentBrand.subscription == null) {
      if (subscritionPromo.id == null) {
        subscriptionListAux =
            await _promotionDataService.getSubscriptions("", currentBrand.id!);
      } else {
        subscriptionListAux = await _promotionDataService.getSubscriptions(
            subscritionPromo.id, currentBrand.id!);
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
        if (offerings.current?.monthly?.storeProduct != null) {
          Subscription subMonth = Subscription.fromOfferingAllData(
              offerings.current?.monthly!.storeProduct,
              context.l10n.perMonth,
              offerings.current!.monthly!);
          DateFormat format = DateFormat('dd-MM-yyyy');
          if (brand.subscription == null &&
              (brand.dateJoined != null &&
                  format
                      .parse(brand.dateJoined!)
                      .isAfter(format.parse(monthFree)))) {
            subMonth.priceString = "";
            subMonth.descriptionAdapted = 'Primer mes gratis';
          }

          subscriptionList.add(subMonth);
        }
      }
      if (offerings.current != null && offerings.current?.annual != null) {
        print(offerings.current?.annual!.storeProduct);
        //print(offerings.current?.annual!.storeProduct);
        if (offerings.current?.annual?.storeProduct != null) {
          subscriptionList.add(Subscription.fromOfferingAllData(
              offerings.current?.annual!.storeProduct,
              context.l10n.perYear,
              offerings.current!.annual!));
        }
        // Get the price and introductory period from the Product
      }
    } catch (e) {
      // optional error handling
    }
    finalSizeBox = subscriptionList.length * 0.07;
    setState(() {
      loadingPromotions = false;
      seePromotions = false;
    });
  }

  Future<void> getPromotion([bool fromSeeSubsc = false]) async {
    subscritionPromo = await _promotionDataService.getValidSubscription(
        promotionController.text, widget.brandId);
    if (fromSeeSubsc) {
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
    for (int i = 0; i < documents.length; i++) {
      RequestToBrand request =
          RequestToBrand.fromObjectAllData(documents[i].id, documents[i]);
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
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.05,
                  right: MediaQuery.of(context).size.width * 0.05,
                  top: MediaQuery.of(context).size.width * 0.15,
                  bottom: MediaQuery.of(context).size.width * 0.00),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  animationMobile(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Text(
                    context.l10n.tanksforUsing,
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(fontSize: 30),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  containerJoin(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  getAll(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  /*
                  promotionGet(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Divider(
                      color: Theme.of(context).dividerColor, thickness: 1.5),
                      */
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildContactUsContainer(),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Platform.isAndroid ? cancelSubscriptionText() : Container(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                ],
              ),
            ),
          ),
          backgroundColor: isDark
              ? Theme.of(context).scaffoldBackgroundColor
              : Theme.of(context).colorScheme.background,
          persistentFooterButtons: <Widget>[
            Container(
              child: seePromotions
                  ? Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.width * 0.04,
                        horizontal: MediaQuery.of(context).size.width * 0.01,
                      ),
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.90,
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  child: Center(
                                    child: loadingPromotions
                                        ? LoadingView(
                                            isSmall: true,
                                            color: AppColors.white,
                                            hasLogo: false,
                                          )
                                        : Text(
                                            context.l10n.seeSubscriptionPayWall,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge
                                                ?.copyWith(
                                                  color: AppColors.white,
                                                ),
                                          ),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.width * 0.04,
                        horizontal: MediaQuery.of(context).size.width * 0.01,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (int i = 0; i < subscriptionList.length; ++i)
                            generateOneSubscription(i),
                        ],
                      ),
                    ),
            ),
          ]),
    );
  }

  Widget animationMobile() {
    return FittedBox(
      fit: BoxFit.fitHeight,
      child: Container(
        child: Stack(
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.1),
                height: MediaQuery.of(context).size.height * 0.6,
                child: AnimatedAlign(
                    alignment: Alignment.center,
                    duration: const Duration(seconds: 10),
                    child: context.read<ThemeManager>().isDarkMode
                        ? Image.asset(
                            Assets.mobileProDark,
                            fit: BoxFit.contain,
                          )
                        : Image.asset(
                            Assets.mobileProLight,
                            fit: BoxFit.contain,
                          )),
              ),
            ),
            IconButton(
              onPressed: () {
                mixpanel!.track('brand_leaves_paywallscreen');
                if (widget.comesFromInitPage != null &&
                    widget.comesFromInitPage == true) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    CupertinoPageRoute<void>(
                      builder: (context) => const BrandScreen(),
                      settings: const RouteSettings(name: 'BrandScreen'),
                    ),
                    (_) => false,
                  );
                } else {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(
                Icons.close,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget containerJoin() {
    return Material(
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
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.width * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                    child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    Assets.subscriptionImage,
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.width * 0.3,
                    fit: BoxFit.fill,
                  ),
                )),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Text(
                  context.l10n.updateToday,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).primaryColor,
                      fontSize: 30),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.l10n.joinToBrands,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).primaryColor),
                    ),
                    Text(
                      'fitness',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.normal,
                            color: AppColors.mainColor,
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

  Widget getAll() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.height * 0.005),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.getAll,
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontSize: 30, fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
            Text(
              context.l10n.getAllDesc,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            listTileGetAll(
                Icons.feed_outlined,
                context.l10n.personalizeBrandPayWallHeader,
                context.l10n.personalizeBrandPayWallText),
            listTileGetAll(Icons.search, context.l10n.searcherPayWallHeader,
                context.l10n.searcherPayWallText),
            listTileGetAll(
                Icons.calendar_month_outlined,
                context.l10n.sessionControlPayWallHeader,
                context.l10n.sessionControlPayWallText),
            listTileGetAll(
                Icons.confirmation_number_outlined,
                context.l10n.pricePolicyPayWallHeader,
                context.l10n.pricePolicyPayWallText),
            listTileGetAll(Icons.leaderboard_outlined,
                context.l10n.statsPayWallHeader, context.l10n.statsPayWallText),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            TextButton(
              onPressed: () async {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                if (!await launchUrl(Uri.parse(functionalities))) {
                  throw 'Could not launch $functionalities';
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                width: MediaQuery.of(context).size.width * 0.90,
                height: MediaQuery.of(context).size.height * 0.075,
                child: Center(
                    child: Text(
                  context.l10n.moreInfoInWeb,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).primaryColor),
                )),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Divider(color: Theme.of(context).dividerColor, thickness: 1.5),
          ],
        ),
      ),
    );
  }

  Widget cancelSubscriptionText() {
    return Text(
      context.l10n.cancelSubscriptionPayWall,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }

  Widget generateOneSubscription(int index) {
    return Column(
      children: [
        GestureDetector(
            onTap: () async {
              setState(() {
                activeSubscription = index;
              });
              mixpanel!.track('brand_clicked_subscription');
              FocusManager.instance.primaryFocus?.unfocus();
              if (subscriptionList[index].package != null) {
                try {
                  var purchaserInfo = await Purchases.purchasePackage(
                      subscriptionList[index].package!);
                  if (purchaserInfo.entitlements.active.isNotEmpty &&
                      purchaserInfo
                          .entitlements
                          .all[dotenv.env['REVCAT_ENTITLEMENT_ID']!]!
                          .isActive) {
                    mixpanel!.track('brand_subscribed');
                    _brandDataService.updateBrandSubscriptionRevenueCat(
                        currentBrand.id!,
                        purchaserInfo
                            .entitlements
                            .all[dotenv.env['REVCAT_ENTITLEMENT_ID']!]!
                            .expirationDate,
                        purchaserInfo
                            .entitlements
                            .all[dotenv.env['REVCAT_ENTITLEMENT_ID']!]!
                            .originalPurchaseDate,
                        purchaserInfo
                            .entitlements
                            .all[dotenv.env['REVCAT_ENTITLEMENT_ID']!]!
                            .productIdentifier,
                        purchaserInfo
                            .entitlements
                            .all[dotenv.env['REVCAT_ENTITLEMENT_ID']!]!
                            .unsubscribeDetectedAt);
                    Navigator.pop(context);
                  }
                } on PlatformException catch (e) {
                  var errorCode = PurchasesErrorHelper.getErrorCode(e);
                  if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
                    ('ERROR ON PURCHASING');
                  }
                }
              } else {
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
                    final PageController pageController =
                        PageController(initialPage: 0);
                    int currentPage = 0;
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
                  color: index == subscriptionList.length - 1
                      ? AppColors.mainColor
                      : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                width: MediaQuery.of(context).size.width * 0.90,
                height: MediaQuery.of(context).size.height * 0.07,
                child: Center(
                  child: (activeSubscription == index)
                      ? LoadingView(
                          isSmall: true,
                          color: index == subscriptionList.length - 1
                              ? AppColors.white
                              : AppColors.mainColor,
                          hasLogo: false,
                        )
                      : index == subscriptionList.length - 1
                          ? Text(
                              subscriptionList[index].package == null
                                  ? subscriptionList[index].descriptionAdapted!
                                  : '${subscriptionList[index].priceString!} ${subscriptionList[index].descriptionAdapted!}',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                    color: AppColors.white,
                                  ),
                            )
                          : Text(
                              subscriptionList[index].package == null
                                  ? subscriptionList[index].descriptionAdapted!
                                  : '${subscriptionList[index].priceString!} ${subscriptionList[index].descriptionAdapted!}',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                    color: AppColors.white,
                                  ),
                            ),
                ),
              ),
            )),
        index == subscriptionList.length - 1
            ? Container()
            : SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      ],
    );
  }

  Widget ModalBuy(Subscription sub) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setStateBottom) {
        return FractionallySizedBox(
          heightFactor: 0.40,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text('Mamba Pro',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.left),
                    trailing: Text(context.l10n.subscriptionsAppBar,
                        style: Theme.of(context).textTheme.bodySmall),
                    dense: true,
                  ),
                  Divider(
                      color: Theme.of(context).dividerColor,
                      thickness: 1.5,
                      indent: MediaQuery.of(context).size.width * 0.05,
                      endIndent: MediaQuery.of(context).size.width * 0.05),
                  ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        Assets.subscriptionImage,
                      ),
                    ),
                    title: Text(sub.title!,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.left),
                    subtitle: Text('Fitness is Business',
                        style: Theme.of(context).textTheme.bodySmall),
                    dense: true,
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Text(context.l10n.uniquePromotion),
                        const Icon(
                          Icons.done,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text(context.l10n.startToday,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.left),
                    trailing: Text(sub.descriptionAdapted!,
                        style: Theme.of(context).textTheme.bodyLarge),
                    dense: true,
                  ),
                  ListTile(
                      title: Center(
                    child: GestureDetector(
                      onTap: () async {
                        mixpanel!.track('brand_subscribed');
                        await _brandDataService.updateBrandPay(
                            widget.brandId,
                            sub.duration!,
                            sub.id!,
                            sub.title!,
                            DateTime.now(),
                            false);
                        // currentBrand.setBasicData = await _brandDataService.getBrandDetails(widget.brandId);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.mainColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: MediaQuery.of(context).size.width * 0.90,
                          height: MediaQuery.of(context).size.height * 0.05,
                          child: Center(
                              child: Text(
                            context.l10n.subscribeNow,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black),
                          )),
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget listTileGetAll(var icon, String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.01,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: 50,
        ),
        title: Text(title,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.left),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        dense: true,
      ),
    );
  }

  Widget promotionGet() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.height * 0.005),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.promotionUse,
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontSize: 30, fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
            promotionController.text.isNotEmpty &&
                    promotionController.text.length == 17
                ? loadingPromotions
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.02,
                            vertical: MediaQuery.of(context).size.width * 0.03),
                        child: LoadingView(
                          color: Theme.of(context).primaryColor,
                          hasLogo: false,
                          isSmall: true,
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.02,
                            vertical: MediaQuery.of(context).size.width * 0.03),
                        child: subscritionPromo.id == null
                            ? Row(
                                children: [
                                  Text(context.l10n.noPromotions),
                                  const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(context.l10n.promotionDetected),
                                      const Icon(
                                        Icons.done,
                                        color: Colors.green,
                                      ),
                                    ],
                                  ),
                                ],
                              ))
                : Container(),
            promotionController.text.isNotEmpty &&
                    promotionController.text.length == 17
                ? Container()
                : SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Material(
              elevation: 4,
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
                        if (promotionController.text.isNotEmpty &&
                            promotionController.text.length == 17) {
                          setState(() {
                            loadingPromotions = true;
                          });
                          await getPromotion(true);
                        } else {
                          subscritionPromo = Subscription();
                          finalSizeBox = 0.05;
                          setState(() {
                            seePromotions = true;
                          });
                        }
                      },
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.normal,
                          color: AppColors.black),
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.white,
                          hintText: context.l10n.insertCode,
                          hintStyle: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                  color: AppColors.grey,
                                  fontWeight: FontWeight.normal),
                          errorStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.red),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.transparent, width: 1.5),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.transparent, width: 1.5),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.transparent, width: 1.5),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.transparent, width: 1.5),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          contentPadding:
                              const EdgeInsets.fromLTRB(12, 8, 12, 8)),
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
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.height * 0.005,
          vertical: MediaQuery.of(context).size.height * 0.02),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TitleHeadline1(
            text: context.l10n.anyDoubt,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.015),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.0),
            child: Text(context.l10n.getInTouchTextDesc,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Theme.of(context).primaryColor),
                textAlign: TextAlign.center),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.015),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: ElevatedButton(
              onPressed: () => launchEmail(),
              style: ElevatedButton.styleFrom(
                elevation: 4,
                backgroundColor: Theme.of(context).colorScheme.background,
                surfaceTintColor: Theme.of(context).colorScheme.background,
                fixedSize: Size(MediaQuery.of(context).size.width * 0.35,
                    MediaQuery.of(context).size.height * 0.06),
                side: BorderSide(
                    width: 1.0,
                    color: Theme.of(context)
                        .colorScheme
                        .background), // This might need adjustment
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
              ),
              child: Text(
                context.l10n.getInTouch,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> launchEmail() async {
    mixpanel!.track('user_profile_email_mamba');
    String url = 'mailto:$contactEmail';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
