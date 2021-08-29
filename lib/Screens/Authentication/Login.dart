// Flutter Libs
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// Internal App Resources
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Globals/Loading.dart';
// Authentication Service
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Providers/AuthenticationProvider.dart';
import 'package:provider/provider.dart';

// Login Widget
class Login extends StatefulWidget {

  final Function toggleView;
  Login({ required this.toggleView });

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Loading Screen Boolean
  bool loading = false;
  // FormVariables
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  // Error Control
  String errorText = '';
  bool error = false;

  Future<bool> _onBackPressed() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: Center(child: Text('¿Quieres salir de Mamba?', style: redTextStyle)),
        content: Row (
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                child: Text('No', style: purpleTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ), // button 1
              TextButton(
                child: Text('Sí', style: purpleTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ), // button 2
            ]
        )
      ),
    )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthenticationProvider>(context);
    return WillPopScope(
        onWillPop: _onBackPressed,
      child: loading ? Loading() :Scaffold(
        backgroundColor: yellowColor,
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
                      child: Image.asset(logoExtended)),
                  Padding(
                      padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 13.0, bottom: 0.0),
                      child: TextFormField(
                        validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.emailError : null,
                        onChanged: (val) {
                          setState(() => email = val);
                        },
                        decoration: textFromInputDecoration.copyWith(
                          labelText: AppLocalizations.of(context)!.email,
                          prefixIcon:  Padding(
                            padding: EdgeInsets.all(0.0),
                            child: Icon(
                              Icons.email_outlined,
                              color: purpleColor,
                            ), // icon is 48px widget.
                          )
                        )
                      )
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 16.0, bottom: 0),
                      child: TextFormField(
                        validator: (val) => val!.length < 6 ? AppLocalizations.of(context)!.passwordError : null,
                        onChanged: (val) {
                          setState(() => password = val);
                        },
                        obscureText: true,
                          decoration: textFromInputDecoration.copyWith(labelText: AppLocalizations.of(context)!.password,
                              prefixIcon:  Padding(
                                padding: EdgeInsets.all(0.0),
                                child: Icon(
                                  Icons.vpn_key_outlined,
                                  color: purpleColor,
                                ), // icon is 48px widget.
                              )
                          )
                      )
                  ),
                  TextButton(
                    onPressed: (){
                      //TODO: FORGOT PASSWORD SCREEN GOES HERE
                    },
                    child: Text(
                      AppLocalizations.of(context)!.forgotPassword,
                      style: whiteTextStyle,
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 250,
                    decoration: BoxDecoration(
                        color: purpleColor, borderRadius: BorderRadius.circular(20)
                    ),
                    child: TextButton(
                      onPressed: () async {
                        if(_formKey.currentState!.validate()){
                          setState(() {
                            loading = true;
                            error = false;
                          });
                          bool result = await user.signIn(email,password);
                          if (!result) {
                            // Aqui arriba pero el set state no es fa pq el widget ja ha cambiat a Loading() i despres ha tornat a Authenticate()
                            // Solucio, es podria possar un count al constructor per saber si s'ha intentat autenticar o no.
                            setState(() {
                              error = true;
                              errorText = AppLocalizations.of(context)!.loginError;
                              loading = false;
                            });
                          }
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.login,
                        style: whiteTextStyle.copyWith(fontSize: 28),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 16.0),
                    child: TextButton(
                        onPressed: () {
                          widget.toggleView();
                        },
                        child: Text(
                          AppLocalizations.of(context)!.newUser,
                          style: whiteTextStyle,
                        )
                    ),
                  ),
                  error ? Center(
                    child: Text(
                      errorText,
                      style: redTextStyle.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ) : new Container()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}