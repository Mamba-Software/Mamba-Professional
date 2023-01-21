import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Promotions/PromotionsDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Promotion.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/DynamicLinks/DynamicLinkUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/RequestConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Data/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/01-Qui/015-AddMembers/ShareBrandLink.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/BrandScreen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class PayWall extends StatefulWidget {
  String brandId;
  bool? comesFromInitPage;
  PayWall({Key? key, required this.brandId, this.comesFromInitPage}) : super(key: key);

  @override
  _PayWallState createState() => _PayWallState();
}

class _PayWallState extends State<PayWall> {

  // App Bar and Scroll View
  ScrollController? _scrollController;
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    return _scrollController!.hasClients && _scrollController!.offset > (MediaQuery.of(context).size.height*0.15 - kToolbarHeight);
  }

  // Acceso a Base de Datos
  final _brandDataService = BrandDataService();
  final _userDataService = UserDataService();
  final _promotionDataService = PromotionsDataService();
  String? brandId = '';

  //PayWall
  bool seePromotions = true;
  bool loadingPromotions = false;
  var promotionController = TextEditingController();
  Promotion promotion = Promotion();

  // Boolean Loading
  bool isLoading = false;
  // Request List
  List<RequestToBrand> requestList = [];

  @override
  initState() {
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
  }

  Future<void> getPromotion([bool fromSeeSubsc = false]) async
  {
    promotion =
    await _promotionDataService
        .getValidPromotion(
        promotionController.text);
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
        /*
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.roles,
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
          centerTitle: true,
          /*
          actions: [
            Padding(
              padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.02),
              child: IconButton(
                icon: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                  size: MediaQuery.of(context).size.width*0.06,
                ),
                onPressed: navigateToRolesInformationModal,
              ),
            ),
          ],
          */
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: MediaQuery.of(context).size.width * 0.06,
            ),
            onPressed: () {
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
          ),
        ),

         */
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05, vertical: MediaQuery.of(context).size.width * 0.15),
            child:  Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                animationMobile(),
                Text(
                  'Gracias por probar Mamba Professional',
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
                        0.04),
                promotionGet(),
                SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.15),


              ],
            ),
          ),
        ),
        bottomSheet:   FittedBox(
          fit: BoxFit.fitHeight,
          child:
          seePromotions
              ? Padding(
            padding: EdgeInsets.symmetric(
              vertical:
              MediaQuery.of(context).size.width *
                  0.04,
              horizontal:
              MediaQuery.of(context).size.width *
                  0.10,),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                    onTap: () async {
                      if(!loadingPromotions) {
                        if(promotion.id == null) {
                          //  _topSnackBar.topsnackbar(context,
                          //'Te regalamos la promoción 3MONTHS, disfruta de 3 meses gratuitos',
                          //  AppColors.mainColor);
                          setState(() {
                            loadingPromotions = true;
                            promotionController.text = '3MONTHS';
                          });
                          await getPromotion(true);
                        }
                        else {
                          setState(() {
                            seePromotions = false;
                          });
                        }
                      }
                    },
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.mainColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: MediaQuery.of(context).size.height * 0.07,
                        child:  Center(
                          child: Text(
                            'Ver subscripciones',
                            style: Theme.of(context)
                                .textTheme
                                .headline1
                                ?.copyWith(
                              color: Theme.of(context)
                                  .primaryColorDark,
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
                      0.10,),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                promotion.id != null? GestureDetector(
                  onTap: () async {
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
                        final PageController _pageController = PageController(initialPage: 0);
                        int _currentPage = 0;
                        bool isRoles = true;
                        // Widget
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
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        title: Text(
                                            'Mamba pro',
                                            style: Theme.of(context).textTheme.caption,
                                            textAlign: TextAlign.left
                                        ),
                                        trailing: Text(
                                            'Subscripciones',
                                            style: Theme.of(context).textTheme.caption
                                        ),
                                        dense: true,
                                      ),
                                      Divider(color: Theme.of(context).dialogBackgroundColor, thickness: 1.5, indent: MediaQuery.of(context).size.width*0.05, endIndent: MediaQuery.of(context).size.width*0.05),
                                      ListTile(
                                        leading: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image(
                                            image: NetworkImage(
                                                'https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/mambapro_logo.jpg?alt=media&token=3ba956c1-6cc7-4219-9e41-d3c1f10e0dc6'),
                                          ),
                                        ),
                                        title: Text(
                                            'Professional 3 Months Subscriptions',
                                            style: Theme.of(context).textTheme.bodyText1,
                                            textAlign: TextAlign.left
                                        ),
                                        subtitle: Text(
                                            'Fitness is Business',
                                            style: Theme.of(context).textTheme.caption
                                        ),
                                        dense: true,
                                      ),
                                      ListTile(
                                        title:  Row(
                                          children: [
                                            Text('Has aplicado una promoción unica   '),
                                            Icon(
                                              Icons.done,
                                              color: Colors.green,
                                            ),
                                          ],
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                            'Empieza: hoy',
                                            style: Theme.of(context).textTheme.bodyText1,
                                            textAlign: TextAlign.left
                                        ),
                                        trailing: Text(
                                            '3 meses gratis',
                                            style: Theme.of(context).textTheme.bodyText1
                                        ),
                                        dense: true,
                                      ),
                                      ListTile(
                                          title: Center(
                                            child: GestureDetector(
                                              onTap: () async {
                                                await _brandDataService.updateBrandPay(widget.brandId, promotion.time!, [promotion.id!]);
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
                                                  child:  Center(
                                                      child: Text(
                                                        'Suscribirme',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1
                                                            ?.copyWith(
                                                            fontWeight: FontWeight.bold, color: AppColors.black
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
                          } ,
                        );
                      },
                    );
                    //await _brandDataService.updateBrandPay(widget.brandId, promotion.time!, [promotion.id!]);
                    //Navigator.pop(context);
                  },
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.mainColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      width: MediaQuery.of(context).size.width * 0.90,
                      height: MediaQuery.of(context).size.height * 0.07,
                      child:  Center(
                        child: Text(
                          currentUser.idioma == 'ca'? promotion.descriptionCat! : promotion.descriptionEsp!,
                          style: Theme.of(context)
                              .textTheme
                              .headline1
                              ?.copyWith(
                            color: Theme.of(context)
                                .primaryColor,
                          ),
                        ),

                      ),
                    ),
                  ),
                ) : Container(),
                SizedBox(height:  MediaQuery.of(context).size.width *
                    0.04,),
                GestureDetector(
                  onTap: () async {
                    //_topSnackBar.topsnackbar(context, 'Te regalamos la promoción 3MONTHS, disfruta de 3 meses gratuitos', AppColors.mainColor);
                    setState(() {
                      promotionController.text = '3MONTHS';
                    });
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
                        final PageController _pageController = PageController(initialPage: 0);
                        int _currentPage = 0;
                        bool isRoles = true;
                        // Widget
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
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        title: Text(
                                            'Mamba pro',
                                            style: Theme.of(context).textTheme.caption,
                                            textAlign: TextAlign.left
                                        ),
                                        trailing: Text(
                                            'Subscripciones',
                                            style: Theme.of(context).textTheme.caption
                                        ),
                                        dense: true,
                                      ),
                                      Divider(color: Theme.of(context).dialogBackgroundColor, thickness: 1.5, indent: MediaQuery.of(context).size.width*0.05, endIndent: MediaQuery.of(context).size.width*0.05),
                                      ListTile(
                                        leading: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image(
                                            image: NetworkImage(
                                                'https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/mambapro_logo.jpg?alt=media&token=3ba956c1-6cc7-4219-9e41-d3c1f10e0dc6'),
                                          ),
                                        ),
                                        title: Text(
                                            'Professional 3 Months Subscriptions',
                                            style: Theme.of(context).textTheme.bodyText1,
                                            textAlign: TextAlign.left
                                        ),
                                        subtitle: Text(
                                            'Fitness is Business',
                                            style: Theme.of(context).textTheme.caption
                                        ),
                                        dense: true,
                                      ),
                                      ListTile(
                                        title:  Row(
                                          children: [
                                            Text('Te regalamos promoción unica   '),
                                            Icon(
                                              Icons.done,
                                              color: Colors.green,
                                            ),
                                          ],
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(
                                            'Empieza: hoy',
                                            style: Theme.of(context).textTheme.bodyText1,
                                            textAlign: TextAlign.left
                                        ),
                                        trailing: Text(
                                            '3 meses gratis',
                                            style: Theme.of(context).textTheme.bodyText1
                                        ),
                                        dense: true,
                                      ),
                                      ListTile(
                                          title: Center(
                                            child: GestureDetector(
                                              onTap: () async {
                                                await _brandDataService.updateBrandPay(widget.brandId, promotion.time!, [promotion.id!]);
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
                                                  child:  Center(
                                                      child: Text(
                                                        'Suscribirme',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1
                                                            ?.copyWith(
                                                            fontWeight: FontWeight.bold, color: AppColors.black
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
                          } ,
                        );
                      },
                    );
                  },
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.mainColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      width: MediaQuery.of(context).size.width * 0.90,
                      height: MediaQuery.of(context).size.height * 0.07,
                      child:  Center(
                        child: Text(
                          '29,99 € / mes',
                          style: Theme.of(context)
                              .textTheme
                              .headline1
                              ?.copyWith(
                            color: Theme.of(context)
                                .primaryColorDark,
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
                  child: Image.asset(
                    Constants.mobilePro,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
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
    return  Container(
      decoration: BoxDecoration(
        color: Theme.of(context).dialogBackgroundColor.withOpacity(0.3),
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
                    child: Image.network(
                      'https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/mambapro_logo.jpg?alt=media&token=3ba956c1-6cc7-4219-9e41-d3c1f10e0dc6',
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
                'Actualiza hoy',
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
                    'Únete a las ',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.copyWith(
                        fontWeight: FontWeight.normal, color: Theme.of(context).primaryColor
                    ),
                  ),
                  Text(
                    '500',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.copyWith(
                        fontWeight: FontWeight.bold, color: AppColors.mainColor
                    ),
                  ),
                  Text(
                    ' marcas de entrenamiento',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.copyWith(
                        fontWeight: FontWeight.normal, color: Theme.of(context).primaryColor
                    ),
                  )
                ],
              ),
            ],
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
              'Obtenlo todo',
              style: Theme.of(context)
                  .textTheme
                  .headline1
                  ?.copyWith(fontSize: 30, fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
            Text(
              'Desbloquea todo el potencial de mamba pro con una subscripción única',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1,
              textAlign: TextAlign.center,
            ),
            SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.03),
            listTileGetAll(Icons.all_inclusive, 'Todo ilimitado', 'Haz cosas muchas cosas para ser mejor en todo lo quye hagas'),
            listTileGetAll(Icons.model_training, 'Todo ilimitado', 'Haz cosas muchas cosas para ser mejor en todo lo quye hagas'),
            listTileGetAll(Icons.sports_mma, 'Todo ilimitado', 'Haz cosas muchas cosas para ser mejor en todo lo quy hagas'),
            listTileGetAll(Icons.local_fire_department, 'Todo ilimitado', 'Haz cosas muchas cosas para ser mejor en todo lo quy hagas'),
            listTileGetAll(Icons.quiz, 'Todo ilimitado', 'Haz cosas muchas cosas para ser mejor en todo lo quy hagas'),
            SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.01),
            Divider(color: Theme.of(context).dialogBackgroundColor, thickness: 1.5),
          ],
        ),
      ),
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
              'Canjea una promoción',
              style: Theme.of(context)
                  .textTheme
                  .headline1
                  ?.copyWith(fontSize: 30, fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
            SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.05),
            Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(15.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      maxLength: 7,
                      autofocus: false,
                      controller: promotionController,
                      keyboardType: TextInputType.name,
                      onChanged: (val) async {
                        if (promotionController
                            .text.isNotEmpty && promotionController.text.length == 7) {
                          setState(() {
                            loadingPromotions = true;
                          });
                          await getPromotion();
                        }
                        else {
                          promotion = Promotion();
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
                          'Introduce codigo promocional',
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
            promotionController
                .text.isNotEmpty && promotionController.text.length == 7?
            loadingPromotions? Padding(
              padding: EdgeInsets.symmetric(
                  horizontal:
                  MediaQuery.of(context).size.width *
                      0.02,
                  vertical:
                  MediaQuery.of(context).size.width *
                      0.06),
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
                        0.06),
                child: promotion.id == null? Row(
                  children: [
                    Text('No hay promociones'),
                    Icon(
                      Icons.close,
                      color: Colors.red,
                    ),
                  ],
                ) : Column(
                  children: [
                    Row(
                      children: [
                        Text('Promoción detectada'),
                        Icon(
                          Icons.done,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ],
                )
            ) : Container(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

}