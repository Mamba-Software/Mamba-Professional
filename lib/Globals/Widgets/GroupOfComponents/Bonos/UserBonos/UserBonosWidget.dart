import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Payments/Purchase/PurchaseDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Condition.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Utils/Bonos/BonosUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/ClientBonoCard.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/UserBonos/UserBonosHistoryPage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';

class UserBonosWidget extends StatefulWidget {
  String userId;
  double height = 0;
  double width = 0;

  UserBonosWidget({Key? key, required this.userId, required this.height, required this.width}) : super(key: key);

  @override
  _UserBonosWidgetState createState() => _UserBonosWidgetState();
}

class _UserBonosWidgetState extends State<UserBonosWidget> {

  // Boolean Loading
  bool isLoading = true;
  // Acceso a Base de Datos
  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();
  final _purchaseDataService = PurchaseDataService();
  // AlL Events From User
  final _bonosUtils = BonosUtils();
  List<Bono> userBonos = [];
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
            builder: (context) => UserBonosHistoryPage(
              userId: widget.userId,
            )
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
          stream: _userDataService.getAllBonosFromUser(widget.userId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
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
              userBonos = _bonosUtils.documentsToBonosUser(snapshot.data!.docs, true, true);
              if (userBonos.isNotEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: widget.width*0.05),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: userBonos.length,
                    itemBuilder: (context,int index) {
                      Bono bono = userBonos[index];
                      int sessions = bono.sessions!;
                      double price = bono.price!;
                      Condition bonoUserConditions = bono.condition!;
                      String purchaseId = bono.purchaseId!;
                      return StreamBuilder<DocumentSnapshot>(
                          stream: _brandDataService.getBonoInfoStream(bono.brandId!, bono.id!),
                          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (!snapshot.hasData) {
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
                              bono = Bono.fromObjectAllData(snapshot.data!.id, snapshot.data!);
                              bono.setBonoSessions = sessions;
                              bono.setConditionsData = bonoUserConditions;
                              bono.setBonoPrice = price;
                              return FutureBuilder<Purchase>(
                                  future: _purchaseDataService.getPurchaseInfo(purchaseId),
                                  builder: (context, snapshot) {
                                    if (snapshot.data == null) {
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
                                      Purchase bonoPurchase = snapshot.data!;
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
                            }
                          }
                      );
                    },
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
