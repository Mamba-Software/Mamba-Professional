import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Calendars/CalendarWidgetTrainer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CircularImage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Calendars/BrandEventsToday.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Marca/Trainer/TieneMarca/TieneMarcaModals/TodosMiembrosTrainer.dart';
import 'package:page_transition/page_transition.dart';

import 'TieneMarcaModals/SettingsBrand.dart';

class TieneMarcaTrainer extends StatefulWidget {
  const TieneMarcaTrainer({Key? key}) : super(key: key);

  @override
  _TieneMarcaTrainerState createState() => _TieneMarcaTrainerState();
}

class _TieneMarcaTrainerState extends State<TieneMarcaTrainer> {
  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  // Boolean isLoading
  bool isLoading = false;
  // Brand Events Today
  List<Event> todayEvents = [];

  @override
  void initState() {
    isLoading = true;
    initBrandHome();
    super.initState();
  }
  // Init for Brand Home
  initBrandHome() {
    getBrand();
    getAllEventsTodayBrand();
  }

  // Gets the user info from firebase.
  void getBrand() async {
    currentBrand = await _accessDatabase.getBrandDetails(currentBrand.id!);
  }

  // Gets the events passed by the trainer.
  void getAllEventsTodayBrand() async {
    todayEvents = await _accessDatabase.getAllEventsTodayBrand(currentBrand.id!);
    setState(() {
      isLoading = false;
    });
  }

  String toCapitalized(String s) => s.length > 0 ?'${s[0].toUpperCase()}${s.substring(1)}':'';

  @override
  Widget build(BuildContext context) {
    return isLoading ?
      Center(
        child: LoadingViewPurple(),
      )
        :
      Scaffold(
        appBar: null,
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.height*0.32,
                child: Stack(
                  alignment: Alignment.topCenter,
                  fit: StackFit.expand,
                  children: <Widget>[
                    Positioned(
                      top: MediaQuery.of(context).size.height*0.07,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.bottomToTop,
                                    child: SettingsBrand(),
                                  )
                              ).whenComplete(() {
                                setState(() {
                                  isLoading = true;
                                  initBrandHome();
                                });
                              });
                            },
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.20,
                              child: Center(
                                child: CircularImage(size: MediaQuery.of(context).size.height * 0.19, image: currentBrand.logoUrl, color: Theme.of(context).accentColor, borderWidth: 2,),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height*0.29,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Text("${currentBrand.name!}", style: Theme.of(context).textTheme.headline1!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 26, fontFamily: "Helvetica"), textAlign: TextAlign.center),
                    ),
                  ]
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.04),
              todayEvents.length > 0 ? Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.bottomToTop,
                              child: BrandEventsToday(
                                brandId: currentBrand.id!
                              )
                          )
                      ).whenComplete(() {
                        setState(() {
                          isLoading = true;
                          initBrandHome();
                        });
                      });
                    },
                    child: Material(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: MediaQuery.of(context).size.height * 0.08,
                        decoration: new BoxDecoration(
                          color: Theme.of(context).accentColor,
                          border: Border.all(color: Theme.of(context).accentColor, width: 1),
                          borderRadius: new BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width * 0.09,
                                child: Icon(Icons.calendar_today_outlined, color: Colors.white, size: 30,)
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.69,
                              child: Center(child: Text(AppLocalizations.of(context)!.today(toCapitalized(DateFormat('EEEE d/M/yy', Localizations.localeOf(context).languageCode).format(DateTime.now()))), style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.w400)),),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.04),
                ],
              ) : Container(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.bottomToTop,
                          child: CalendarWidgetTrainer(
                            brandID: currentBrand.id!,
                            canEdit: true,
                          )
                      )
                  ).whenComplete(() {
                    setState(() {
                      isLoading = true;
                      initBrandHome();
                    });
                  });
                },
                child: Material(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.all(
                      const Radius.circular(10.0),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: MediaQuery.of(context).size.height * 0.20,
                        decoration: new BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: Theme.of(context).accentColor, width: 1),
                          borderRadius: new BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                          image: new DecorationImage(
                            fit: BoxFit.cover,
                            //colorFilter: new ColorFilter.mode(Colors.black.withOpacity(1), BlendMode.dstATop),
                            image: Image.asset(Constants.calendarImage).image,
                          ),
                        ),
                        child: Center(),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: MediaQuery.of(context).size.height * 0.20,
                        decoration: new BoxDecoration(
                          color: Colors.white,
                          gradient: LinearGradient(
                              begin: FractionalOffset.topCenter,
                              end: FractionalOffset.bottomCenter,
                              colors: [
                                Colors.grey.withOpacity(0.0),
                                Colors.black,
                              ],
                              stops: [
                                0.0,
                                0.75
                              ]
                          ),
                          border: Border.all(color: Theme.of(context).accentColor, width: 1),
                          borderRadius: new BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                        ),
                        child: Center(),
                      ),
                      Padding(
                        padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.calendar, style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23, fontFamily: "Helvetica"), textAlign: TextAlign.center),
                            SizedBox(height: MediaQuery.of(context).size.height*0.005),
                            Text(AppLocalizations.of(context)!.calendarBrandText(currentBrand.name!), style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 14, color: Colors.grey[200])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.04),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.bottomToTop,
                          child: TodosMiembrosTrainer()
                      )
                  ).whenComplete(() {
                    setState(() {
                      isLoading = true;
                      initBrandHome();
                    });
                  });
                },
                child: Material(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.all(
                      const Radius.circular(10.0),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: MediaQuery.of(context).size.height * 0.20,
                        decoration: new BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: Theme.of(context).accentColor, width: 1),
                          borderRadius: new BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                          image: new DecorationImage(
                            fit: BoxFit.cover,
                            //colorFilter: new ColorFilter.mode(Colors.black.withOpacity(1), BlendMode.dstATop),
                            image: Image.asset(Constants.teamImage).image,
                          ),
                        ),
                        child: Center(),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: MediaQuery.of(context).size.height * 0.20,
                        decoration: new BoxDecoration(
                          color: Colors.white,
                          gradient: LinearGradient(
                              begin: FractionalOffset.topCenter,
                              end: FractionalOffset.bottomCenter,
                              colors: [
                                Colors.grey.withOpacity(0.0),
                                Colors.black,
                              ],
                              stops: [
                                0.0,
                                0.75
                              ]
                          ),
                          border: Border.all(color: Theme.of(context).accentColor, width: 1),
                          borderRadius: new BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                        ),
                        child: Center(),
                      ),
                      Padding(
                        padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.members, style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23, fontFamily: "Helvetica"), textAlign: TextAlign.center),
                            SizedBox(height: MediaQuery.of(context).size.height*0.005),
                            Text(AppLocalizations.of(context)!.membersBrandText, style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 14, color: Colors.grey[200])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.04),
              GestureDetector(
                onTap: () {

                },
                child: Material(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.all(
                      const Radius.circular(10.0),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: MediaQuery.of(context).size.height * 0.20,
                        decoration: new BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: Theme.of(context).accentColor, width: 1),
                          borderRadius: new BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                          image: new DecorationImage(
                            fit: BoxFit.cover,
                            //colorFilter: new ColorFilter.mode(Colors.black.withOpacity(1), BlendMode.dstATop),
                            image: Image.asset(Constants.statisticsImage).image,
                          ),
                        ),
                        child: Center(),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: MediaQuery.of(context).size.height * 0.20,
                        decoration: new BoxDecoration(
                          color: Colors.white,
                          gradient: LinearGradient(
                              begin: FractionalOffset.topCenter,
                              end: FractionalOffset.bottomCenter,
                              colors: [
                                Colors.grey.withOpacity(0.0),
                                Colors.black,
                              ],
                              stops: [
                                0.0,
                                0.75
                              ]
                          ),
                          border: Border.all(color: Theme.of(context).accentColor, width: 1),
                          borderRadius: new BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                        ),
                        child: Center(),
                      ),
                      Padding(
                        padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.stats, style: Theme.of(context).textTheme.headline1!.copyWith(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 23, fontFamily: "Helvetica"), textAlign: TextAlign.center),
                            SizedBox(height: MediaQuery.of(context).size.height*0.005),
                            Text(AppLocalizations.of(context)!.statsBrandText, style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 14, color: Colors.white.withOpacity(0.5))),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.70, bottom: MediaQuery.of(context).size.height * 0.07),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.5), size: 50,)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.04),
            ],
          ),
    ),
      );
  }
}