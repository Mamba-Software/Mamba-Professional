import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DatabaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Calendars/CalendarWidgetTrainer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Images/CircularImage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Images/ImageFullScreen.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Calendars/BrandEventsToday.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Marca/Trainer/TieneMarca/TieneMarcaModals/TodosMiembrosTrainer.dart';
import 'package:page_transition/page_transition.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'TieneMarcaModals/SettingsBrand.dart';

class TieneMarcaTrainer extends StatefulWidget {
  const TieneMarcaTrainer({Key? key}) : super(key: key);

  @override
  _TieneMarcaTrainerState createState() => _TieneMarcaTrainerState();
}

class _TieneMarcaTrainerState extends State<TieneMarcaTrainer> {
  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  var _brandDataService = new BrandDataService();
  // Boolean isLoading
  bool isLoading = false;
  // Brand Events Today
  List<Event> todayEvents = [];
  int numberEventsFinished = 0;
  int numberEventsToDo = 0;

  @override
  void initState() {
    isLoading = true;
    initBrandHome();
    super.initState();
  }

  // Init for Brand Home
  initBrandHome() async {
    await updateMembers();
    await getBrand();
    await getNumberFinishedEvents();
    await getAllEventsTodayBrand();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Update Number of Members.
  Future<void> updateMembers() async {
    await _accessDatabase.updateNumberMembers(currentBrand.id!);
  }

  // Gets the user info from firebase.
  Future<void> getBrand() async {
    currentBrand.setBasicData = await _brandDataService.getBrandDetails(currentBrand.id!);
    currentBrand.setUserList = await _brandDataService.getBrandUsers(currentBrand.id!);
  }

  // Gets number of finished events
  Future<void> getNumberFinishedEvents() async {
    numberEventsFinished = await _accessDatabase.getNumberEventsFinishedBrand(currentBrand.id!);
    numberEventsToDo = await _accessDatabase.getNumberEventsToDoBrand(currentBrand.id!);
  }
  // Gets all events of today.
  Future<void> getAllEventsTodayBrand() async {
    todayEvents = await _accessDatabase.getAllEventsTodayBrand(currentBrand.id!);
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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      child: Text("${currentBrand.name!}",
                          style: Theme.of(context).textTheme.headline1!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 25, fontFamily: "Helvetica"), textAlign: TextAlign.left
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.qr_code_outlined, color: Colors.green, size: MediaQuery.of(context).size.height*0.03,),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.all(0),
                          onPressed: () {
                            Clipboard.setData(new ClipboardData(text: currentBrand.id)).then((_){
                              showTopSnackBar(
                                context,
                                CustomSnackBar.info(
                                  icon: Container(),
                                  iconRotationAngle: 0,
                                  backgroundColor: Theme.of(context).accentColor,
                                  message: AppLocalizations.of(context)!.copyCorrectCode,
                                  textStyle: Styles.whiteTextStyle,
                                ),
                              );
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.height*0.03,),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.all(0),
                          onPressed: () {
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
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.02),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute<Null>(
                                builder: (context) => FullScreenPage(
                                  child:  Image.network(
                                    currentBrand.logoUrl!,
                                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          color: Theme.of(context).accentColor,
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                  dark: false,
                                )
                            )
                        );
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height*0.15,
                        child: Center(
                          child: CircularImage(size: MediaQuery.of(context).size.width * 0.33, image: currentBrand.logoUrl, color: Theme.of(context).accentColor, borderWidth: 2,),
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width*0.05),
                    Container(
                      height: MediaQuery.of(context).size.height*0.15,
                      width: MediaQuery.of(context).size.width * 0.50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width*0.50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(Icons.directions_run, color: Theme.of(context).accentColor,),
                                    SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                                    Text(
                                      currentBrand.numberClients.toString(),
                                      style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).accentColor, fontSize: 16),),
                                    SizedBox(width: MediaQuery.of(context).size.width * 0.01,),
                                    Flexible(child: Text(AppLocalizations.of(context)!.clients.toLowerCase(), style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Theme.of(context).accentColor), textAlign: TextAlign.center,))
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width*0.50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(Icons.record_voice_over, color: Theme.of(context).accentColor,),
                                    SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                                    Text(
                                      currentBrand.numberTrainers.toString(),
                                      style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).accentColor, fontSize: 16),),
                                    SizedBox(width: MediaQuery.of(context).size.width * 0.01,),
                                    Flexible(child: Text(AppLocalizations.of(context)!.trainers.toLowerCase(), style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Theme.of(context).accentColor), textAlign: TextAlign.center,))
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width*0.50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(Icons.event_available_outlined, color: Theme.of(context).primaryColor,),
                                    SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                                    Text(
                                      numberEventsFinished.toString(),
                                      style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 16),),
                                    SizedBox(width: MediaQuery.of(context).size.width * 0.01,),
                                    Flexible(child: Text(AppLocalizations.of(context)!.sessionsDone.toLowerCase(), style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Theme.of(context).primaryColor), textAlign: TextAlign.center,))
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width*0.50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(Icons.event, color: Theme.of(context).primaryColor,),
                                    SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
                                    Text(
                                      numberEventsToDo.toString(),
                                      style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 16),),
                                    SizedBox(width: MediaQuery.of(context).size.width * 0.01,),
                                    Flexible(child: Text(AppLocalizations.of(context)!.sessionsToDo.toLowerCase(), style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Theme.of(context).primaryColor), textAlign: TextAlign.center,))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.04),
                todayEvents.length > 0 ? Column(
                  children: [
                    Platform.isAndroid ? SizedBox(height: MediaQuery.of(context).size.height*0.01) : Container(),
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
                              image: Image.asset(Constants.mySessionsImage).image,
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
    ),
      );
  }
}