import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Purchase/PurchaseDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Condition.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/LocalNotificationService.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/ClientBonoCard.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';

class LeaveConfirmationDialogBonos extends StatefulWidget {
  final String text;
  final Event event;
  final Brand brand;
  final List<Bono> bonos;
  final String purchaseId;
  final Usuario user;
  const LeaveConfirmationDialogBonos({Key? key, required this.text, required this.event, required this.brand, required this.bonos, required this.purchaseId, required this.user}) : super(key: key);

  @override
  _LeaveConfirmationDialogBonosState createState() => _LeaveConfirmationDialogBonosState();
}

class _LeaveConfirmationDialogBonosState extends State<LeaveConfirmationDialogBonos> {

  // Boolean
  bool isLoading = false;
  // Acceso a Base de true
  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();
  final _purchaseDataService = PurchaseDataService();
  LocalNotificationService localNotificationService = LocalNotificationService();
  // Bonos
  Bono bonoSelected = Bono();
  // Cancel Conditons
  bool freeCancel = true;

  @override
  void initState() {
    if (widget.bonos.isNotEmpty) {
      getBonoPurchaseMade();
    }
    super.initState();
  }

  void getBonoPurchaseMade() async {
    // Bonos del Usuari
    List<Bono> userBonos = await _userDataService.getUserActiveBonos(widget.user.id!, widget.purchaseId);
    // Restem amb els Bonos que no és poden usar per aquest Event
    userBonos.removeWhere((userBono) {
      int index = widget.bonos.indexWhere((eventBono) => eventBono.id! == userBono.id!);
      if (index == -1) {
        return true;
      } else {
        return false;
      }
    });
    // Busquem dins dels bonos de l'usuari quin conté l'event
    for (Bono userBono in userBonos) {
        setState(() {
          bonoSelected = userBono;
        });
      }
    /*
    for (Bono userBono in userBonos) {
      // Agafem la Purchase del Bono
      bool eventExists = await _purchaseDataService.checkIfEventInPurchase(userBono.purchaseId!, widget.event.id!);
      if (eventExists) {
        setState(() {
          bonoSelected = userBono;
        });
        break;
      }
    }*/

  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.only(top: 40, bottom: 10, left: 10, right: 10),
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
                  padding: const EdgeInsets.only(top: 8.0, bottom: 24.0, right: 10, left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(widget.text, style: Theme.of(context).textTheme.bodyText2?.copyWith(height: 1.5),textAlign: TextAlign.center,),
                      ),
                    ],
                  ),
                ),
                widget.bonos.isNotEmpty ? bonoSelected.id != null ? Column(
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                        stream: _userDataService.getBonoFromEventUser(widget.user.id!, bonoSelected.id!),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height*0.2,
                              width: MediaQuery.of(context).size.width*0.76,
                              child: LoadingView(
                                hasLogo: false,
                                isSmall: true,
                              ),
                            );
                          } else {
                            bonoSelected = Bono.fromObjectAllData(snapshot.data!.id, snapshot.data!);
                            int sessions = bonoSelected.sessions!;
                            double price = bonoSelected.price!;
                            Condition bonoUserConditions = bonoSelected.condition!;
                            String purchaseId = bonoSelected.purchaseId!;
                            return StreamBuilder<DocumentSnapshot>(
                                stream: _brandDataService.getBonoInfoStream(widget.brand.id!, bonoSelected.id!),
                                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                  if (!snapshot.hasData) {
                                    return SizedBox(
                                      height: MediaQuery.of(context).size.height*0.2,
                                      width: MediaQuery.of(context).size.width*0.76,
                                      child: LoadingView(
                                        hasLogo: false,
                                        isSmall: true,
                                      ),
                                    );
                                  } else {
                                    bonoSelected = Bono.fromObjectAllData(snapshot.data!.id, snapshot.data!);
                                    bonoSelected.setBonoSessions = sessions;
                                    bonoSelected.setConditionsData = bonoUserConditions;
                                    bonoSelected.setBonoPrice = price;
                                    bonoSelected.setPurchaseId = purchaseId;
                                    return FutureBuilder<Purchase>(
                                        future: _purchaseDataService.getPurchaseInfo(purchaseId),
                                        builder: (context, snapshot) {
                                          if (snapshot.data == null) {
                                            return SizedBox(
                                              height: MediaQuery.of(context).size.height*0.2,
                                              width: MediaQuery.of(context).size.width*0.76,
                                              child: LoadingView(
                                                hasLogo: false,
                                                isSmall: true,
                                              ),
                                            );
                                          } else {
                                            Purchase bonoPurchase = snapshot.data!;
                                            return Padding(
                                              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
                                              child: ClientBonoCard(
                                                height: MediaQuery.of(context).size.height*0.2,
                                                width: MediaQuery.of(context).size.width*0.76,
                                                bono: bonoSelected,
                                                brand: widget.brand,
                                                purchase: bonoPurchase,
                                                canExpand: false,
                                                onlyView: true,
                                              ),
                                            );
                                          }
                                        }
                                    );
                                  }
                                }
                            );
                          }
                        }
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  ],
                ) : SizedBox(
                  height: MediaQuery.of(context).size.height*0.3,
                  width: MediaQuery.of(context).size.width*0.76,
                  child: LoadingView(
                    hasLogo: false,
                    isSmall: true,
                  ),
                ) : Container(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          elevation: 4.0,
                          backgroundColor: Colors.red,
                          fixedSize: Size(MediaQuery.of(context).size.width*0.35, MediaQuery.of(context).size.height*0.06),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                        ),
                        label: Text(
                          AppLocalizations.of(context)!.delete,
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                        ),
                        icon: isLoading ? SizedBox(
                          width: MediaQuery.of(context).size.width * 0.05,
                          height: MediaQuery.of(context).size.height * 0.025,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ) : Icon(Icons.event_busy_outlined, size: MediaQuery.of(context).size.width*0.06, color: Colors.white,),
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          Navigator.pop(context, true);

                        },
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width*0.01),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          elevation: 4.0,
                          backgroundColor: Theme.of(context).primaryColor,
                          fixedSize: Size(MediaQuery.of(context).size.width*0.35, MediaQuery.of(context).size.height*0.06),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                        ),
                        label: Text(
                          AppLocalizations.of(context)!.cancel,
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColorDark,),
                        ),
                        icon: Icon(Icons.cancel_outlined, size: MediaQuery.of(context).size.width*0.06, color: Theme.of(context).primaryColorDark,),
                        onPressed: () {
                          Navigator.pop(context, false);
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
                      size: Size(70, 70), // button width and height
                      child: ClipOval(
                        child: Material(
                          color: Colors.red, // button color
                          child: InkWell(
                            onTap: () async {
                            },
                            child: Icon(Icons.event_busy_outlined, color: Colors.white, size: 40,), // icon
                          ),
                        ),
                      ),
                    ),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
}