// Flutter Libs
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// Internal App Resources
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Globals/Loading.dart';
// Authentication Service
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Screens/Authentication/Register.dart';
import 'package:provider/provider.dart';

// Login Widget
class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Loading Screen Boolean
  bool loading = false;
  // Password Visible
  bool _passwordVisible = false;
  // FormVariables
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  // Error Control
  String? errorText;

  Future<bool> _onBackPressed() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: Center(child: Text(AppLocalizations.of(context)!.logOut, style: Styles.redTextStyle)),
        content: Row (
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                child: Text(AppLocalizations.of(context)!.no, style: Styles.purpleTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ), // button 1
              TextButton(
                child: Text(AppLocalizations.of(context)!.yes, style: Styles.purpleTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),),
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
    errorText = AppLocalizations.of(context)!.loginError;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
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
                      padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 13.0, bottom: 0.0),
                      child: TextFormField(
                        validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.emailError : null,
                        onChanged: (val) {
                          setState(() => email = val);
                        },
                        decoration: Styles.textFromInputDecoration.copyWith(
                          labelText: AppLocalizations.of(context)!.email,
                          prefixIcon:  Padding(
                            padding: EdgeInsets.all(0.0),
                            child: Icon(
                              Icons.email_outlined,
                              color: Styles.accent,
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
                        obscureText: !_passwordVisible,
                          decoration: Styles.textFromInputDecoration.copyWith(labelText: AppLocalizations.of(context)!.password,
                              suffixIcon: Padding(
                                  padding: EdgeInsets.all(0.0),
                                  child: IconButton(
                                    icon: Icon(
                                    // Based on passwordVisible state choose the icon
                                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Styles.accent
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _passwordVisible = !_passwordVisible;
                                      });
                                    }
                                  )
                              ),
                              prefixIcon:  Padding(
                                padding: EdgeInsets.all(0.0),
                                child: Icon(
                                  Icons.vpn_key_outlined,
                                  color: Styles.accent,
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
                      style: Styles.whiteTextStyle,
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 250,
                    decoration: BoxDecoration(
                        color: Styles.accent, borderRadius: BorderRadius.circular(20)
                    ),
                    child: TextButton(
                      onPressed: () async {
                        if(_formKey.currentState!.validate()){
                          setState(() {
                            loading = true;
                          });
                          //await user.signIn(email,password);
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.login,
                        style: Styles.whiteTextStyle.copyWith(fontSize: 28),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 16.0),
                    child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute<Null>(
                                builder: (context) => Register(),
                                settings: RouteSettings(name: 'Register'),
                              )
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!.newUser,
                          style: Styles.whiteTextStyle,
                        )
                    ),
                  ),
                  Globals.errorAuthLogin ? Center(
                    child: Text(
                      errorText!,
                      style: Styles.redTextStyle.copyWith(fontWeight: FontWeight.bold),
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