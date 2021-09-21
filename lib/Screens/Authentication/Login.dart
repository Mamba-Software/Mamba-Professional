import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Idiomas/Idiomas.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:mamba_castelldefels/Providers/LanguageProvider.dart';
import 'package:mamba_castelldefels/Screens/Admin/Admin.dart';
import 'package:mamba_castelldefels/Screens/Authentication/Register.dart';
import 'package:mamba_castelldefels/Screens/MainApp/FirstTimeWrapper.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/HomePage.dart';
import 'package:provider/provider.dart';

// Login Page. This allow the User to get Logged In or to Register a new account.
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
  String emailTemp = '';

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
          key: scaffoldMessengerKey,
          child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: Styles.mainColor,
              body: isLoading ?
              Stack(
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
                              initialValue: emailTemp,
                              validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.emailError : null,
                              onChanged: (val) {
                                setState(() {
                                  email = val;
                                });
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
                                setState(() {
                                  password = val;
                                });
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
                            if(email.isEmpty) {
                              showInSnackBar(AppLocalizations.of(context)!.emailError);
                            } else {
                              if(emailValidator(email)){
                                _accessDatabase.resetPassword(email);
                                showInSnackBar(AppLocalizations.of(context)!.validatePassword);
                              } else {
                                showInSnackBar(AppLocalizations.of(context)!.validateEmail);
                              }
                            }
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
                                emailTemp = email;
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
        );
  }

  void signIn() async {
    try {
      int result = await _accessDatabase.signIn(email, password);
      if (result == 0) {
        currentUser = await _accessDatabase.getCurrentUserDetails();
        Provider.of<LanguageProvider>(context, listen: false).setLocale(Idiomas.getLocaleFromString(currentUser.idioma!));
        if(currentUser.isAdmin!) {
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute<Null>(
                builder: (context) => Admin(),
                settings: RouteSettings(name: 'Admin'),
              )
          );
        } else {
          if(!(currentUser.isFirst!)) {
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
        }
      } else if(result == -2) {
        setState(() {
          isLoading = false;
        });
        showInSnackBar(AppLocalizations.of(context)!.validateError);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        email = emailTemp;
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

  // Validate email and pwd format
  bool emailValidator(String value) {
    Pattern pattern = r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = new RegExp(pattern.toString());
    if (!regex.hasMatch(value)) {
      return false;
    } else {
      return true;
    }
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