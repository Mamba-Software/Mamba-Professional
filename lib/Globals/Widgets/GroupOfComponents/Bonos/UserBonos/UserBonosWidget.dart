import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Condition.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Utils/Bonos/BonosUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/ClientBonoCard.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/UserBonos/UserBonosHistoryPage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/BrandPurchaseHistory/views/BrandPurchaseHistory.dart';

class UserBonosWidget extends StatefulWidget {
  String userId;
  String brandId;
  double height = 0;
  double width = 0;

  UserBonosWidget({Key? key, required this.userId, required this.brandId, required this.height, required this.width}) : super(key: key);

  @override
  _UserBonosWidgetState createState() => _UserBonosWidgetState();
}

class _UserBonosWidgetState extends State<UserBonosWidget> {

  // Boolean Loading
  bool isLoading = true;
  // Acceso a Base de Datos
  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();
  // AlL Events From User
  final _bonosUtils = BonosUtils();
  List<Purchase> userBonosPurchases = [];

  @override
  void initState() {
    super.initState();
  }

  // Navigate to Event History Screen
  void navigateToBonoHistoryScreen() {
    mixpanel!.track('profile_view_purchase_history');
    Navigator.push(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => BrandPurchaseHistory(
            brandId: widget.brandId,
            userId: widget.userId,
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height*0.05,
          width: widget.width*0.9,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  AppLocalizations.of(context)!.activeBono,
                  style: Theme.of(context).textTheme.headline3,
                  textAlign: TextAlign.center
              ),
              TextButton(
                  child: Text(
                      AppLocalizations.of(context)!.purchaseHistory,
                      style: Theme.of(context).textTheme.caption?.copyWith(decoration: TextDecoration.underline)
                  ),
                  onPressed: navigateToBonoHistoryScreen
              ),
            ],
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: _userDataService.getUserActivePurchasesFromBrandStream(widget.userId, currentBrand.id!),
          builder: (context, snapshot) {
            if (snapshot.hasData == false) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  height: widget.height*0.22,
                  width: widget.width*0.9,
                  child: LoadingView(
                    hasLogo: false,
                    isSmall: true,
                  ),
                ),
              );
            } else {
              userBonosPurchases = _bonosUtils.documentsToPurchasesUser(snapshot.data!.docs);
              if (userBonosPurchases.isNotEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: widget.width*0.05),
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: userBonosPurchases.length,
                        itemBuilder: (context, int index) {
                          Purchase bonoPurchase = userBonosPurchases[index];
                          Bono bono = userBonosPurchases[index].bono!;
                          int sessions = bono.sessions!;
                          double price = bono.price!;
                          Condition bonoUserConditions = bono.condition!;
                          return StreamBuilder<DocumentSnapshot>(
                              stream: _brandDataService.getBonoInfoStream(bono.brandId!, bono.id!),
                              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot2) {
                                if (!snapshot2.hasData) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: SizedBox(
                                      height: widget.height*0.22,
                                      width: widget.width*0.9,
                                      child: LoadingView(
                                        hasLogo: false,
                                        isSmall: true,
                                      ),
                                    ),
                                  );
                                } else {
                                  bono = Bono.fromObjectAllData(snapshot2.data!.id, snapshot2.data!);
                                  // Setting Personalized Information From Above
                                  bono.setBonoSessions = sessions;
                                  bono.setConditionsData = bonoUserConditions;
                                  bono.setBonoPrice = price;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: ClientBonoCard(
                                      height: widget.height*0.22,
                                      width: widget.width*0.9,
                                      bono: bono,
                                      brand: currentBrand,
                                      purchase: bonoPurchase,
                                      canExpand: true,
                                      onlyView: false,
                                    ),
                                  );
                                }
                              }
                          );
                        },
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.04),
                    ],
                  ),
                );
              } else {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: widget.width*0.05),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.noData.split(" ")[0]+" "+AppLocalizations.of(context)!.activeBono.toLowerCase(),
                            style: Theme.of(context).textTheme.caption,
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.05),
                    ],
                  ),
                );
              }
            }
          }
        ),
        SizedBox(height: widget.height*0.0,),
      ],
    );
  }
}
