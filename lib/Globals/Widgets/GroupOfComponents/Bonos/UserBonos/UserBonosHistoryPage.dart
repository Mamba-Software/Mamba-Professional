// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/DataService/Payments/Purchase/PurchaseDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/UserBonos/PurchaseListTile.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserBonosHistoryPage extends StatefulWidget {
  String userId;

  UserBonosHistoryPage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserBonosHistoryPageState createState() => _UserBonosHistoryPageState();
}

class _UserBonosHistoryPageState extends State<UserBonosHistoryPage> {

  // Screen Dimensions
  double safeAreaHeight = 0;
  double safeAreaWidth = 0;
  // Boolean Loading
  bool isLoading = true;
  bool isFirstBuild = true;
  // Acceso a Base de Datos
  final _purchaseDataService = PurchaseDataService();
  // User
  Usuario user = Usuario();
  // AlL Events From User
  List<Purchase> listPurchases = [];

  @override
  void initState() {
    initEventHistory();
    super.initState();
  }

  Future<void> initEventHistory() async {
    await getUserPurchases();
    setState(() {
      isLoading = false;
    });
  }
  
  // Init Device Sizes
  initDeviceSizes() {
    safeAreaHeight = MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    print("Device H and W: "+MediaQuery.of(context).size.height.toString()+" "+MediaQuery.of(context).size.width.toString());
    print("SafeArea H and W: "+safeAreaHeight.toString()+" "+safeAreaWidth.toString());
  }

  // Gets the Events Done by the User
  Future<void> getUserPurchases() async {
    listPurchases = await _purchaseDataService.getAllUserPurchases(widget.userId);
    listPurchases.sort((a,b) {
      var aDate =  a.purchasedAt!.toDate();
      var bDate =  b.purchasedAt!.toDate();
      return aDate.compareTo(bDate);
    });
    listPurchases = List.from(listPurchases.reversed);
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstBuild) {
      initDeviceSizes();
      isFirstBuild = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.purchaseHistory,
          style: Theme.of(context).appBarTheme.titleTextStyle,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading ?
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        itemBuilder: (context,int index) {
          return Column(
            children: [
              index == 0 ? SizedBox(height: safeAreaWidth*0.08) : Container(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
                child: Shimmer.fromColors(
                  baseColor: AppColors.grey,
                  highlightColor: AppColors.grey.withOpacity(0.5),
                  child: SizedBox(
                    height: safeAreaHeight*0.18,
                    width: safeAreaWidth*0.9,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: (safeAreaWidth*0.9)*0.20,
                          width: (safeAreaWidth*0.9)*0.20,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: (safeAreaWidth*0.9)*0.20,
                                width: (safeAreaWidth*0.9)*0.20,
                                decoration: BoxDecoration(
                                  color: AppColors.grey,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              height: safeAreaHeight*18,
                              width: safeAreaWidth*0.9*0.56,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: safeAreaHeight*0.03,
                                    width: (safeAreaWidth*0.9)*0.20,
                                    decoration: BoxDecoration(
                                      color: AppColors.grey,
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  SizedBox(height: safeAreaHeight*0.02,),
                                  Container(
                                    height: safeAreaHeight*0.02,
                                    width: (safeAreaWidth*0.9)*0.35,
                                    decoration: BoxDecoration(
                                      color: AppColors.grey,
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  SizedBox(height: safeAreaHeight*0.015,),
                                  Container(
                                    height: safeAreaHeight*0.02,
                                    width: (safeAreaWidth*0.9)*0.5,
                                    decoration: BoxDecoration(
                                      color: AppColors.grey,
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  SizedBox(height: safeAreaHeight*0.015,),
                                  Container(
                                    height: safeAreaHeight*0.02,
                                    width: (safeAreaWidth*0.9)*0.5,
                                    decoration: BoxDecoration(
                                      color: AppColors.grey,
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  SizedBox(height: safeAreaHeight*0.015,),
                                  Container(
                                    height: safeAreaHeight*0.02,
                                    width: (safeAreaWidth*0.9)*0.5,
                                    decoration: BoxDecoration(
                                      color: AppColors.grey,
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                            SizedBox(
                              height: safeAreaHeight*15,
                              width: (safeAreaWidth*0.84)*0.12,
                              child: Center(
                                child: Container(
                                  height: safeAreaHeight*0.05,
                                  width: safeAreaHeight*0.05,
                                  decoration: BoxDecoration(
                                    color: AppColors.grey,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: safeAreaHeight*0.04, horizontal: safeAreaWidth*0.08),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 1,
                      width: safeAreaWidth*0.61,
                      color: AppColors.grey,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      )
          :
      listPurchases.isNotEmpty ? ListView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: listPurchases.length,
        itemBuilder: (context,int index) {
          Purchase purchase = listPurchases[index];
          return Column(
            children: [
              index == 0 ? SizedBox(height: safeAreaWidth*0.08) : Container(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: safeAreaWidth*0.08),
                child: PurchaseListTile(
                  purchase: purchase,
                  height: safeAreaHeight,
                  width: safeAreaWidth*0.9,
                )
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: safeAreaHeight*0.04, horizontal: safeAreaWidth*0.08),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 1,
                      width: safeAreaWidth*0.61,
                      color: AppColors.grey,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ) :
      SizedBox(
        height: safeAreaHeight,
        width: safeAreaWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width*0.25,
                child: Image.asset(Constants.emptyCalendar)
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.005),
            Text(AppLocalizations.of(context)!.noEvents, style: Theme.of(context).textTheme.caption, textAlign: TextAlign.center,),
            SizedBox(height: MediaQuery.of(context).size.height*0.12),
          ],
        ),
      ),
    );
  }
}
