import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/data/Models/Bono.dart';
import 'package:mamba_castelldefels/data/Models/Brand.dart';
import 'package:mamba_castelldefels/data/Models/Condition.dart';
import 'package:mamba_castelldefels/data/Models/Purchase.dart';
import 'package:mamba_castelldefels/notifications/NotificationService/LocalNotificationService.dart';
import 'package:mamba_castelldefels/app/style/AppColors.dart';
import 'package:mamba_castelldefels/commons/utils/Bonos/BonosUtils.dart';
import 'package:mamba_castelldefels/commons/widgets/GroupOfComponents/Bonos/ClientBonoCard.dart';
import 'package:mamba_castelldefels/commons/widgets/GroupOfComponents/LoadingViews/LoadingView.dart';

class JoinConfirmationDialogBonos extends StatefulWidget {
  final String text;
  final Brand brand;
  final List<Bono> bonos;
  final String userId;
  const JoinConfirmationDialogBonos(
      {super.key,
      required this.text,
      required this.bonos,
      required this.brand,
      required this.userId});

  @override
  _JoinConfirmationDialogBonosState createState() =>
      _JoinConfirmationDialogBonosState();
}

class _JoinConfirmationDialogBonosState
    extends State<JoinConfirmationDialogBonos> {
  // Boolean IsLoading
  bool isLoading = false;
  bool errorWindow = false;
  bool errorWorkShift = false;
  // Acceso a Base de true
  final UserDataService _userDataService = UserDataService();
  final _brandDataService = BrandDataService();
  final _eventDataService = EventDataService();
  LocalNotificationService localNotificationService =
      LocalNotificationService();
  // Bonos
  final _bonosUtils = BonosUtils();
  //List<Bono> userBonos = [];
  List<Purchase> userBonosPurchases = [];
  Bono bonoSelected = Bono();
  Purchase purchaseSelected = Purchase();
  // Page View Controller
  int _numPages = 1;
  int _currentPage = 0;
  String purchaseId = "";
  PageController? _pageController;
  // Work Shift
  DateTime now = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0);
  DateTime doneAt = DateTime.now();
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  String workShift = "";

  @override
  void initState() {
    super.initState();
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: isActive ? 6.0 : 4.0,
      width: isActive ? 6.0 : 4.0,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).primaryColor
            : Theme.of(context).primaryColor.withOpacity(0.5),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  Widget joinEventBodyConditions() {
    return widget.bonos.isNotEmpty
        ? Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                  stream:
                      _userDataService.getUserActivePurchasesFromBrandStream(
                          widget.userId, widget.brand.id!),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return LoadingView(
                        hasLogo: false,
                        isSmall: true,
                      );
                    } else {
                      userBonosPurchases = _bonosUtils
                          .documentsToPurchasesUser(snapshot.data!.docs);
                      userBonosPurchases.removeWhere((userPurchase) {
                        int index = widget.bonos.indexWhere((eventBono) =>
                            eventBono.id! == userPurchase.bonoId!);
                        if (index == -1) {
                          return true;
                        } else {
                          return false;
                        }
                      });
                      _numPages = userBonosPurchases.length;

                      return Column(
                        children: [
                          userBonosPurchases.length > 1
                              ? Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .whichBono,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                    height: 1.5,
                                                    fontWeight:
                                                        FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.02),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: _buildPageIndicator(),
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.02),
                                  ],
                                )
                              : Container(),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.22,
                            width: MediaQuery.of(context).size.width,
                            child: PageView.builder(
                              physics: const BouncingScrollPhysics(),
                              controller: _pageController,
                              onPageChanged: (int page) {
                                setState(() {
                                  _currentPage = page;
                                });
                              },
                              itemCount: userBonosPurchases.length,
                              itemBuilder: (context, int index) {
                                Purchase bonoPurchase =
                                    userBonosPurchases[index];
                                Bono bono = userBonosPurchases[index].bono!;
                                int sessions = bono.sessions!;
                                double price = bono.price!;
                                Condition bonoUserConditions = bono.condition!;
                                return StreamBuilder<DocumentSnapshot>(
                                    stream: _brandDataService.getBonoInfoStream(
                                        bono.brandId!, bono.id!),
                                    builder: (context,
                                        AsyncSnapshot<DocumentSnapshot>
                                            snapshot) {
                                      if (!snapshot.hasData) {
                                        return Container();
                                      } else {
                                        bono = Bono.fromObjectAllData(
                                            snapshot.data!.id, snapshot.data!);
                                        bono.setBonoSessions = sessions;
                                        bono.setConditionsData =
                                            bonoUserConditions;
                                        bono.setBonoPrice = price;
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04),
                                          child: Column(
                                            children: [
                                              ClientBonoCard(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.2,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.8,
                                                bono: bono,
                                                brand: widget.brand,
                                                purchase: bonoPurchase,
                                                canExpand: false,
                                                onlyView: true,
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    });
                              },
                            ),
                          ),
                          userBonosPurchases[_currentPage]
                                      .bono!
                                      .condition!
                                      .cancelTime !=
                                  0
                              ? Column(
                                  children: [
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.02),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: AppColors.ligthRed
                                                .withOpacity(0.8),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10))),
                                        child: ListTile(
                                            contentPadding: EdgeInsets.all(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.02),
                                            minLeadingWidth:
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.07,
                                            leading: Icon(
                                                Icons.free_cancellation,
                                                size: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.07,
                                                color: Colors.white),
                                            title: Text(
                                              "${AppLocalizations.of(context)!.cancelTimeAt} ${userBonosPurchases[_currentPage].bono!.condition!.cancelTime} ${AppLocalizations.of(context)!.hours.toLowerCase()}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                      color: Colors.white),
                                            )),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
                        ],
                      );
                    }
                  }),
            ],
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding:
            const EdgeInsets.only(top: 40, bottom: 10, left: 10, right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, bottom: 24.0, right: 10, left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          widget.text,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                joinEventBodyConditions(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          elevation: 4.0,
                          backgroundColor: Colors.green,
                          fixedSize: Size(
                              MediaQuery.of(context).size.width * 0.35,
                              MediaQuery.of(context).size.height * 0.06),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                        ),
                        label: Text(
                          AppLocalizations.of(context)!.book,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white),
                        ),
                        icon: Icon(Icons.event_available_outlined,
                            size: MediaQuery.of(context).size.width * 0.06,
                            color: Colors.white),
                        onPressed: () async {
                          if (widget.bonos.isEmpty) {
                            setState(() {
                              isLoading = true;
                            });
                            Navigator.pop(context, [true, purchaseId]);
                          } else {
                            if (userBonosPurchases.isNotEmpty) {
                              setState(() {
                                isLoading = true;
                              });
                              bonoSelected =
                                  userBonosPurchases[_currentPage].bono!;
                              purchaseId = bonoSelected.purchaseId!;
                              Navigator.pop(context, [true, purchaseId]);
                            }
                          }
                        },
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          elevation: 4.0,
                          backgroundColor: Theme.of(context).primaryColor,
                          fixedSize: Size(
                              MediaQuery.of(context).size.width * 0.35,
                              MediaQuery.of(context).size.height * 0.06),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                        ),
                        label: Text(
                          AppLocalizations.of(context)!.cancel,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                        ),
                        icon: Icon(
                          Icons.cancel_outlined,
                          size: MediaQuery.of(context).size.width * 0.06,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
                top: -83,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox.fromSize(
                      size: const Size(70, 70), // button width and height
                      child: ClipOval(
                        child: Material(
                          color: Colors.green, // button color
                          child: InkWell(
                            onTap: () async {},
                            child: const Icon(
                              Icons.event_available_outlined,
                              color: Colors.white,
                              size: 40,
                            ), // icon
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
