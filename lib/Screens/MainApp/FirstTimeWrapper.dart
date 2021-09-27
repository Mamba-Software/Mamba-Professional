import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'Home/HomePage.dart';

// Page only shown the First time the User is logging in.
// They are asked if they have an invite code to directly access his/her training brand. Two scenarios here:
// - HAVE Invitation Code: They are added to that brand and directed to the brand´s page.
// - DON'T HAVE Invitation Code: They are directed to the Search for Trainer page.
class FirstTimeWrapper extends StatefulWidget {
  const FirstTimeWrapper({Key? key}) : super(key: key);

  @override
  _FirstTimeWrapperState createState() => _FirstTimeWrapperState();
}

class _FirstTimeWrapperState extends State<FirstTimeWrapper> {

  //DataBase Access
  var _accessDatabase = new DatabaseAccess();
  // Booleans
  bool isLoading = true;
  bool codigoError1 = false;
  bool codigoError2 = false;
  bool codigoClicked = false;
  bool isLoadingCodigo = false;
  // FormVariables
  final _formKey = GlobalKey<FormState>();
  var _codigoController = TextEditingController();
  var _codigo;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    getCurrentUserDetails();
  }

  void getCurrentUserDetails() async {
    currentUser = await _accessDatabase.getCurrentUserDetails();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Styles.mainColor,
        body: Stack(
          children: <Widget>[
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.14,
                height: MediaQuery.of(context).size.height * 0.07,
                child: CircularProgressIndicator(
                  color: Styles.white,
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.07,
                height: MediaQuery.of(context).size.height * 0.07,
                child: Image(
                    image: AssetImage(Constants.logoSimple)
                ),
              ),
            ),
          ],
        )
      );
    } else {
      return Scaffold(
        backgroundColor: Styles.mainColor,
        body: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(top: 16.0),
                      width: 200,
                      height: 100,
                      child: Image.asset(Constants.logoExtended)),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(AppLocalizations.of(context)!.wellcome(currentUser.name!),
                      style: Styles.purpleTextStyle.copyWith(fontSize: 23, fontWeight:FontWeight.bold),
                      textAlign: TextAlign.center,),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0, bottom: 4.0),
                    child: Text(
                      AppLocalizations.of(context)!.alreadyCreatedFirm,
                      style: Styles.purpleTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      !codigoClicked ? Padding(
                        padding: EdgeInsets.only(
                            left: 25.0, right: 25.0, top: 12.0),
                        child: FloatingActionButton.extended(
                          onPressed: () {
                            setState(() {
                              codigoClicked = !codigoClicked;
                            });
                          },
                          backgroundColor: Colors.green,
                          icon: Icon(Icons.qr_code_outlined, size: 40,),
                          label: Text(AppLocalizations.of(context)!.addCode,
                            style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ) : Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 12.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Flexible(
                                child: Material(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(13)
                                  ),
                                  elevation: 5,
                                  child: new TextFormField(
                                    controller: _codigoController,
                                    onChanged: (val) {
                                      setState(() {
                                        codigoError1 = false;
                                        codigoError2 = false;
                                        _codigo = val;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.green,
                                      hintText: AppLocalizations.of(context)!.codigo,
                                      hintStyle: Styles.whiteTextStyle.copyWith(fontSize: 14, color: Colors.white),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white, width: 1.0),
                                        borderRadius: BorderRadius.circular(13.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white, width: 1.0),
                                        borderRadius: BorderRadius.circular(13.0),
                                      ),
                                    ),
                                    style: Styles.whiteTextStyle.copyWith(fontSize: 14, color: Colors.white),
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
                                      child: Icon(Icons.login),
                                      backgroundColor: Colors.green,
                                      foregroundColor: Styles.white,
                                      onPressed: () async {
                                        if(_codigo == "" || _codigo == null) {
                                          print("código is empty");
                                          setState(() {
                                            codigoError1 = true;
                                            codigoError2 = false;
                                          });
                                        } else {
                                          print("código not empty");
                                          print(_codigo);
                                          setState(() {
                                            isLoadingCodigo = true;
                                          });
                                          var result = await _accessDatabase.checkIfBrandExists(_codigo);
                                          if (!result) {
                                            setState(() {
                                              isLoadingCodigo = false;
                                              codigoError1 = false;
                                              codigoError2 = true;
                                            });
                                          } else {
                                            _accessDatabase.updateCurrentUserFirstTime();
                                            await _accessDatabase
                                                .updateCurrentUserBrand(
                                                _codigo);
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
                                      heroTag: null,
                                      child: Icon(Icons.close),
                                      backgroundColor: Colors.red,
                                      foregroundColor: Styles.white,
                                      onPressed: () {
                                        setState(() {
                                          codigoClicked = !codigoClicked;
                                          codigoError1 = false;
                                          codigoError2 = false;
                                          _codigo = null;
                                          _codigoController.clear();
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
                                        heroTag: null,
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
                      codigoError1 ? Padding(
                        padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0, bottom: 4.0),
                        child: Text(AppLocalizations.of(context)!.codigo, style: Styles.redTextStyle.copyWith(fontSize: 14), textAlign: TextAlign.center,)
                      ) : Container(),
                      codigoError2 ? Padding(
                        padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0, bottom: 4.0),
                        child: Text(AppLocalizations.of(context)!.brandNotFound, style: Styles.redTextStyle.copyWith(fontSize: 14),textAlign: TextAlign.center),
                      ) : Container(),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0, bottom: 4.0),
                        child: FloatingActionButton.extended(
                          label: Row(
                            children: <Widget>[
                              Text(AppLocalizations.of(context)!.noCodigo, style: Styles.whiteTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),),
                              SizedBox(width: 10,),
                              Icon(Icons.highlight_off, size: 30,)
                            ],
                          ),
                          icon: Container(),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            _accessDatabase.updateCurrentUserFirstTime();
                            Navigator.pushReplacement(
                                context,
                                CupertinoPageRoute<Null>(
                                  builder: (context) => HomePage(),
                                  settings: RouteSettings(name: 'HomePage'),
                                )
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
