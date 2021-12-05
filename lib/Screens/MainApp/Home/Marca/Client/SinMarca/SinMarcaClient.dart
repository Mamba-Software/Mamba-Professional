import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Calendars/CalendarWidgetClient.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Dialogs/CancelRequestConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Dialogs/SendRequestConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Globals/Widgets/RectangularImage.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Marca/Client/TieneMarca/TodosMiembrosClient.dart';
import 'package:page_transition/page_transition.dart';

class SinMarcaClient extends StatefulWidget {
  const SinMarcaClient({Key? key}) : super(key: key);

  @override
  _SinMarcaClientState createState() => _SinMarcaClientState();
}

class _SinMarcaClientState extends State<SinMarcaClient> {
// Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  // Boolean isLoading
  bool isLoading = false;
  // Brand List
  List<Brand> brandList = [];
  // Codigo
  var _codigo;
  bool codigoError = false;
  bool codigoClicked = false;
  bool isLoadingCodigo = false;
  var _codigoController = TextEditingController();
  // Request To Brand
  String brandIdRequest = "";
  RequestToBrand? request;

  // init Widget state. Loading user info.
  @override
  void initState() {
    isLoading = true;
    getUserPendingRequests();
    getAllBrands();
    super.initState();
  }

  Future<void> getUserPendingRequests() async {
    RequestToBrand? req = await _accessDatabase.hasPendingRequest(currentUser.id!);
    if (req != null) {
      setState(() {
        request = req;
        brandIdRequest = request!.brandId!;
      });
    } else {
      setState(() {
        request = null;
        brandIdRequest = "";
      });
    }
  }

  Future<void> getAllBrands() async {
    brandList = await _accessDatabase.getAllBrands();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?
    Center(
        child: LoadingViewPurple()
    )
        :
    Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: MediaQuery.of(context).size.width*0.01,),
            Container(
                width: MediaQuery.of(context).size.width*0.30,
                child: Image.asset(Constants.logoExtendedYellow)
            ),
          ],
        ),
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          request != null ?
          Row(
            children: [
              IconButton(
                  icon: Icon(Icons.schedule_send, size: 35, color: Theme.of(context).accentColor),
                  onPressed: () async {
                    Brand brand = brandList.singleWhere((element) => element.id == request!.brandId!);
                    var result = await showDialog(
                        context: context,
                        builder: (_) {
                          return CancelRequestConfirmationDialog(
                            text: AppLocalizations.of(context)!.cancelRequestConfirmation,
                            brand: brand,
                          );
                        }
                    );
                    if (result) {
                      setState(() {
                        brandIdRequest = "";
                      });
                      _accessDatabase.deleteRequest(request!.id!);
                      getUserPendingRequests();
                    }
                  }
              ),
              SizedBox(width: MediaQuery.of(context).size.width*0.03,),
            ],
          ) :
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.qr_code_outlined, size: 35, color: !codigoClicked ? Theme.of(context).primaryColor : Colors.white,),
                onPressed: !codigoClicked ? () {
                  setState(() {
                    codigoClicked = true;
                  });
                } : null,
              ),
              SizedBox(width: MediaQuery.of(context).size.width*0.03,),
            ],
          ),
        ],
        bottom: codigoClicked ? PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.10,),
          child: Container(
            height: MediaQuery.of(context).size.height*0.10,
            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.01),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Flexible(
                          child: Material(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13)
                            ),
                            elevation: 5,
                            child: new TextFormField(
                              controller: _codigoController,
                              onChanged: (val) {
                                setState(() {
                                  codigoError = false;
                                  _codigo = val;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!.codigo,
                                hintStyle: Styles.whiteTextStyle.copyWith(fontSize: 14, color: codigoError ? Colors.red: Colors.green),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: codigoError ? Colors.red: Colors.green, width: 1.0),
                                  borderRadius: BorderRadius.circular(13.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: codigoError ? Colors.red: Colors.green, width: 1.0),
                                  borderRadius: BorderRadius.circular(13.0),
                                ),
                              ),
                              style: Styles.whiteTextStyle.copyWith(fontSize: 14, color: codigoError ? Colors.red: Colors.green),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        !isLoadingCodigo ?
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: FloatingActionButton(
                                heroTag: "23",
                                child: Icon(Icons.login),
                                backgroundColor: Colors.green,
                                foregroundColor: Styles.white,
                                onPressed: () async {
                                  if(_codigo == null || _codigo=="") {
                                    setState(() {
                                      codigoError = true;
                                    });
                                  } else {
                                    setState(() {
                                      isLoadingCodigo = true;
                                    });
                                    var result = await _accessDatabase.checkIfBrandExists(_codigo);
                                    if (!result) {
                                      Future.delayed(const Duration(milliseconds: 500), () {
                                        setState(() {
                                          isLoadingCodigo = false;
                                          codigoError = true;
                                        });
                                      });
                                    } else {
                                      await _accessDatabase.updateCurrentUserBrand(_codigo);
                                      NotificationService().userJoinsBrand(currentUser.id!, _codigo);
                                      Navigator.pushReplacement(
                                          context,
                                          CupertinoPageRoute<Null>(
                                            builder: (context) =>
                                                SplashScreen(),
                                            settings: RouteSettings(
                                                name: 'SplashScreen'),
                                          )
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: FloatingActionButton(
                                heroTag: "24",
                                child: Icon(Icons.close),
                                backgroundColor: Colors.red,
                                foregroundColor: Styles.white,
                                onPressed: () async {
                                  setState(() {
                                    codigoClicked = !codigoClicked;
                                    codigoError = false;
                                    _codigoController.text = "";
                                  });
                                },
                              ),
                            ),
                          ],
                        ) :
                        SizedBox(
                          width: 130,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FloatingActionButton(
                                  heroTag: "25",
                                  child: SizedBox(
                                    width: 100,
                                    child: Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  backgroundColor: Colors.orangeAccent,
                                  foregroundColor: Styles.white,
                                  onPressed: false ? () {} : null
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                ),
              ],
            ),
          ),
        ) :  PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Container(),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: brandList.length,
                itemBuilder: (context, int index) {
                  Brand brand = brandList[index];
                  return Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height*0.02),
                      Container(
                        height: MediaQuery.of(context).size.height*0.05,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircularImage(
                                size: MediaQuery.of(context).size.width*0.10,
                                image: brand.logoUrl,
                                color: Theme.of(context).accentColor,
                                borderWidth: 1,
                              ),
                              SizedBox(width: MediaQuery.of(context).size.width*0.03),
                              Expanded(
                                child: Text(
                                  brand.name!,
                                  style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.35,
                        child: RectangularImage(
                          image: brand.logoUrl!,
                          size: MediaQuery.of(context).size.width,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height*0.08,
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.calendar_today_outlined, size: 30, color: Theme.of(context).primaryColor),
                                        padding: EdgeInsets.all(0),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                  type: PageTransitionType.rightToLeftWithFade,
                                                  child: CalendarWidgetClient(
                                                    brandID: brand.id!,
                                                    onlyView: true,
                                                  )
                                              )
                                          );
                                        },
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!.calendar,
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 14),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.groups_outlined, size: 35, color: Theme.of(context).primaryColor),
                                        padding: EdgeInsets.all(0),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                  type: PageTransitionType.rightToLeftWithFade,
                                                  child: TodosMiembrosClient(
                                                    brandID: brand.id!,
                                                    viewOnly: true,
                                                  )
                                              )
                                          );
                                        },
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!.members,
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 14),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(brandIdRequest == brand.id! ? Icons.schedule_send : Icons.send_outlined, size: 35, color: brandIdRequest == brand.id! ? Theme.of(context).accentColor : request == null ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.3)),
                                        padding: EdgeInsets.all(0),
                                        onPressed: request == null || brandIdRequest == brand.id! ? () async {
                                          if (brandIdRequest == brand.id!) {
                                            var result = await showDialog(
                                                context: context,
                                                builder: (_) {
                                                  return CancelRequestConfirmationDialog(
                                                    text: AppLocalizations.of(context)!.cancelRequestConfirmation,
                                                    brand: brand,
                                                  );
                                                }
                                            );
                                            if (result) {
                                              setState(() {
                                                brandIdRequest = "";
                                              });
                                              _accessDatabase.deleteRequest(request!.id!);
                                              getUserPendingRequests();
                                            }
                                          } else {
                                            var result = await showDialog(
                                                context: context,
                                                builder: (_) {
                                                  return SendRequestConfirmationDialog(
                                                    text: AppLocalizations.of(context)!.sendRequestConfirmation,
                                                    brand: brand,
                                                  );
                                                }
                                            );
                                            if (result) {
                                              setState(() {
                                                brandIdRequest = brand.id!;
                                              });
                                              await _accessDatabase.sendRequest(brand.id!, currentUser.name! ,currentUser.isTrainer!);
                                              NotificationService().userSendRequestToBrand(currentUser.id!, brand.id!);
                                              getUserPendingRequests();
                                            }
                                          }
                                        } : null,
                                      ),
                                      Text(
                                        brandIdRequest == brand.id! ? AppLocalizations.of(context)!.sent : AppLocalizations.of(context)!.join,
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 14, color: brandIdRequest == brand.id! ? Theme.of(context).accentColor : request == null ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.3)),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.question_answer_outlined, size: 35, color: Theme.of(context).primaryColor),
                                        padding: EdgeInsets.all(0),
                                        onPressed: () {

                                        },
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!.contact,
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 14),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.02),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                        child: RichText(
                          text: TextSpan(
                            style: Styles.purpleTextStyle.copyWith(fontSize: 16),
                            children: [
                              TextSpan(text: '${brand.name!} ', style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),),
                              TextSpan(text: brand.description!),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.memberSince(brand.dateJoined!),
                                style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Colors.grey),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.02),
                    ],
                  );
                }
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.01),
          ],
        ),
      ),
    );
  }
}
