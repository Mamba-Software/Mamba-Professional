// Flutter Libs
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
// Internal App Resources
import 'package:mamba_castelldefels/Globals/Constants.dart';
// Authentication Service
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:mamba_castelldefels/Screens/Authentication/Register.dart';
import 'package:mamba_castelldefels/Screens/MainApp/FirstTimeWrapper.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/HomePage.dart';

// Login Widget
class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Access to DataBaseService
  var _accessDatabase = new DatabaseAccess();
  // Loading Screen Boolean
  bool isLoading = false;
  // Password Visible
  bool _passwordVisible = false;
  // Scaffold Messenger Key
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  // FormVariables
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

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
    return WillPopScope(
      onWillPop: _onBackPressed,
        child: ScaffoldMessenger(
          key: scaffoldMessengerKey,
          child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: Styles.mainColor,
              body: isLoading ?
              Stack(
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
                  :
              Center(
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
                                onSignInButtonPressed();
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
                      ],
                    ),
                  ),
                ),
              ),
          ),
        ),
    );
  }

  void signIn() async {
    int result = await _accessDatabase.signIn(email, password);
    if (result == 0) {
      Usuario? user = await _accessDatabase.getCurrentUserDetails();
      if(!(user.isFirst!)) {
        Navigator.pushReplacement(
            context,
            CupertinoPageRoute<Null>(
              builder: (context) => HomePage(),
              settings: RouteSettings(name: 'HomePage'),
            )
        );
      } else {
        Navigator.pushReplacement(
            context,
            CupertinoPageRoute<Null>(
              builder: (context) => FirstTimeWrapper(),
              settings: RouteSettings(name: 'FirstTimeWrapper'),
            )
        );
      }
    } else if(result == -2) {
      setState(() {
        isLoading = false;
      });
      showInSnackBar(AppLocalizations.of(context)!.validateError);
    } else {
      setState(() {
        isLoading = false;
      });
      showInSnackBar(AppLocalizations.of(context)!.loginError);
    }
  }

  // Actions to do when login and register
  void onSignInButtonPressed() {
    setState(() {
      isLoading = true;
    });
    signIn();
  }

  void showInSnackBar(String value) {
    final snackbar = new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontFamily: "Raleway"),
      ),
      backgroundColor: Styles.accent,
      duration: Duration(seconds: 3),
    );
    scaffoldMessengerKey.currentState!.showSnackBar(snackbar);
  }


}