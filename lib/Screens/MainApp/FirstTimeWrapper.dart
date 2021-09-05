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
  bool isLoading = true;
  // FormVariables
  final _formKey = GlobalKey<FormState>();
  var _codigoController = TextEditingController();
  String _codigo = "";

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
                      AppLocalizations.of(context)!.alreadyCreatedFirm,
                      style: Styles.purpleTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Padding(
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
                                      validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.codigo : null,
                                      onChanged: (val) {
                                        setState(() => _codigo = val);
                                      },
                                      decoration: InputDecoration(
                                        hintText: AppLocalizations.of(context)!.codigo,
                                        hintStyle: Styles.whiteTextStyle,
                                        filled: true,
                                        fillColor: Colors.green,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.green, width: 1.0),
                                          borderRadius: BorderRadius.circular(13.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.green, width: 1.0),
                                          borderRadius: BorderRadius.circular(13.0),
                                        ),
                                      ),
                                      style: Styles.whiteTextStyle.copyWith(fontSize: 14.5),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: FloatingActionButton(
                                    child: Icon(Icons.qr_code),
                                    backgroundColor: Colors.green,
                                    foregroundColor: Styles.white,
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
                            )),
                      ),
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
