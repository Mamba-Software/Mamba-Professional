import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/Purchase/PurchaseDataService.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/data/Models/Bono.dart';
import 'package:mamba/data/Models/Condition.dart';
import 'package:mamba/data/Models/Purchase.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/managers/language_manager.dart';
import 'package:mamba/commons/utils/Bonos/BonosUtils.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Bonos/ClientBonoCard.dart';
import 'package:mamba/commons/widgets/loading/LoadingView.dart';

import 'UserPurchaseHistory/views/UserPurchaseHistory.dart';

class UserBonosWidget extends StatefulWidget {
  String userId;
  String brandId;
  double height = 0;
  double width = 0;

  UserBonosWidget(
      {super.key,
      required this.userId,
      required this.brandId,
      required this.height,
      required this.width});

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
          builder: (context) => UserPurchaseHistory(
            userId: widget.userId,
            brandId: widget.brandId,
            purchaseGroupId: '',
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height * 0.05,
          width: widget.width * 0.9,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.l10n.activeRates,
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center),
              TextButton(
                  onPressed: navigateToBonoHistoryScreen,
                  child: Text(context.l10n.purchaseHistory,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(decoration: TextDecoration.underline))),
            ],
          ),
        ),
        StreamBuilder<QuerySnapshot>(
            stream: _userDataService.getUserActivePurchasesFromBrandStream(
                widget.userId, currentBrand.id!),
            builder: (context, snapshot) {
              if (snapshot.hasData == false) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                    height: widget.height * 0.22,
                    width: widget.width * 0.9,
                    child: LoadingView(
                      hasLogo: false,
                      isSmall: true,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                );
              } else {
                userBonosPurchases =
                    _bonosUtils.documentsToPurchasesUser(snapshot.data!.docs);
                if (userBonosPurchases.isNotEmpty) {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: widget.width * 0.05),
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
                                stream: _brandDataService.getBonoInfoStream(
                                    bono.brandId!, bono.id!),
                                builder: (context,
                                    AsyncSnapshot<DocumentSnapshot> snapshot2) {
                                  if (!snapshot2.hasData) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: SizedBox(
                                        height: widget.height * 0.22,
                                        width: widget.width * 0.9,
                                        child: LoadingView(
                                          hasLogo: false,
                                          isSmall: true,
                                        ),
                                      ),
                                    );
                                  } else {
                                    bono = Bono.fromObjectAllData(
                                        snapshot2.data!.id, snapshot2.data!);
                                    // Setting Personalized Information From Above
                                    bono.setBonoSessions = sessions;
                                    bono.setConditionsData = bonoUserConditions;
                                    bono.setBonoPrice = price;
                                    return StreamBuilder<QuerySnapshot>(
                                        stream: _purchaseDataService
                                            .getPurchaseEventsStream(
                                                bonoPurchase.id!),
                                        builder: (context, snapshot) {
                                          if (snapshot.data == null) {
                                            return SizedBox(
                                              height: widget.height * 0.22,
                                              width: widget.width * 0.9,
                                              child: LoadingView(
                                                hasLogo: false,
                                                isSmall: true,
                                              ),
                                            );
                                          } else {
                                            bonoPurchase.numberOfEvents =
                                                snapshot.data!.docs.length;
                                            bonoPurchase.events =
                                                _bonosUtils.documentsToEvents(
                                                    snapshot.data!.docs);
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: ClientBonoCard(
                                                height: widget.height * 0.22,
                                                width: widget.width * 0.9,
                                                bono: bono,
                                                brand: currentBrand,
                                                purchase: bonoPurchase,
                                                canExpand: true,
                                                onlyView: false,
                                              ),
                                            );
                                          }
                                        });
                                  }
                                });
                          },
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.04),
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: widget.width * 0.05),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "${context.l10n.noData.split(" ")[0]} ${context.l10n.activeRates.toLowerCase()}",
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05),
                      ],
                    ),
                  );
                }
              }
            }),
        SizedBox(
          height: widget.height * 0.0,
        ),
      ],
    );
  }
}
