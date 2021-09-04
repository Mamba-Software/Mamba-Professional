// Flutter Libs
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';

import 'Home/HomePage.dart';
// Internal App Tools

class FirstTimeWrapper extends StatefulWidget {
  const FirstTimeWrapper({Key? key}) : super(key: key);

  @override
  _FirstTimeWrapperState createState() => _FirstTimeWrapperState();
}

class _FirstTimeWrapperState extends State<FirstTimeWrapper> {

  //DataBase Access
  var _accessDatabase = new DatabaseAccess();
  // Models
  Usuario? user;
  // Booleans
  bool codigo = false;
  bool isLoading = true;
  // FormVariables
  final _formKey = GlobalKey<FormState>();
  String key = "";

  @override
  void initState() {
    super.initState();
    isLoading = true;
    getCurrentUserDetails();
  }

  void getCurrentUserDetails() async {
    user = await _accessDatabase.getCurrentUserDetails();
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
                width: MediaQuery.of(context).size.width * 0.3,
                height: MediaQuery.of(context).size.height * 0.15,
                child: CircularProgressIndicator(
                  color: Styles.white,
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.15,
                height: MediaQuery.of(context).size.height * 0.15,
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
                    child: Text(AppLocalizations.of(context)!.wellcome(user!.name!),
                      style: Styles.purpleTextStyle.copyWith(fontSize: 23, fontWeight:FontWeight.bold),
                      textAlign: TextAlign.center,),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0, bottom: 4.0),
                    child: Text(
                      user!.isTrainer! ? AppLocalizations.of(context)!.alreadyCreatedTrainer : AppLocalizations.of(context)!.alreadyCreatedClient,
                      style: Styles.purpleTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 24.0),
                        child: FloatingActionButton(
                          child: Text(AppLocalizations.of(context)!.yes, style: Styles.whiteTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              codigo = true;
                            });

                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 24.0),
                        child: FloatingActionButton(
                          child: Text(AppLocalizations.of(context)!.no, style: Styles.whiteTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),),
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
                  codigo ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
                        child: Text(
                          user!.isTrainer! ? AppLocalizations.of(context)!.alreadyCreatedTrainerFirm : AppLocalizations.of(context)!.perfectClient,
                          style: Styles.purpleTextStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 45.0, right: 45.0, top: 4.0, bottom: 0),
                        child: TextFormField(
                            validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.codigo : null,
                            onChanged: (val) {
                              setState(() => key = val);
                            },
                            decoration: Styles.textFromInputDecoration.copyWith(labelText: AppLocalizations.of(context)!.codigo)
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FloatingActionButton.extended(
                          icon: Icon(Icons.qr_code),
                          label: Text(AppLocalizations.of(context)!.letsGo, style: Styles.purpleTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),),
                          backgroundColor: Styles.white,
                          foregroundColor: Styles.accent,
                          onPressed: () async {
                            // TODO: validació del codi per entrar directament a formar part del grup de entrenadors.
                            //if(_formKey.currentState!.validate()){}
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
                  ) : Container(),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}

