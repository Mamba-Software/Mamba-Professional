import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Screens/Authentication/ForgotPassword.dart';
import 'package:mamba_castelldefels/Screens/Authentication/Register.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';

// Login Page. This allow the User to get Logged In or to Register a new account.
class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  // Access to DatabaseService
  var _userDataService = new UserDataService();
  // Loading Screen Boolean
  bool isLoading = false;
  // Password Visible
  bool _passwordVisible = false;
  // Scaffold Messenger Key
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  // FormVariables
  final _formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  String email = '';
  String password = '';
  String emailTemp = '';

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
          key: scaffoldMessengerKey,
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Theme.of(context).accentColor,
            body: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.05),
                          width: MediaQuery.of(context).size.width*0.50,
                          child: Image.asset(Constants.logoExtended)
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.03),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.emailError : null,
                          onChanged: (val) {
                            setState(() {
                              email = val;
                            });
                          },
                          style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.black),
                          decoration: Styles.textFromInputDecoration.copyWith(
                              labelText: AppLocalizations.of(context)!.email,
                              labelStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.black),
                              errorStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                              prefixIcon:  Padding(
                                padding: EdgeInsets.all(0.0),
                                child: Icon(
                                  Icons.email_outlined,
                                  color: AppColors.black,
                                  size: MediaQuery.of(context).size.width*0.06,
                                ), // icon is 48px widget.
                              )
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.02),
                        TextFormField(
                            validator: (val) => val!.length < 6 ? AppLocalizations.of(context)!.passwordError : null,
                            onChanged: (val) {
                              setState(() {
                                password = val;
                              });
                            },
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.black),
                            obscureText: !_passwordVisible,
                            decoration: Styles.textFromInputDecoration.copyWith(
                                labelText: AppLocalizations.of(context)!.password,
                                labelStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.black),
                                errorStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                suffixIcon: Padding(
                                    padding: EdgeInsets.all(0.0),
                                    child: IconButton(
                                        icon: Icon(
                                          // Based on passwordVisible state choose the icon
                                          _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                          color: AppColors.black,
                                          size: MediaQuery.of(context).size.width*0.06,
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
                                    color: AppColors.black,
                                    size: MediaQuery.of(context).size.width*0.06,
                                  ), // icon is 48px widget.
                                )
                            )
                        ),
                        TextButton(
                          onPressed: () async {
                            FocusScopeNode currentFocus = FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                            String? email = await Navigator.push(
                                context,
                                CupertinoPageRoute<String>(
                                  builder: (context) => ForgotPassword(),
                                  settings: RouteSettings(name: 'ForgotPassword'),
                                )
                            );
                            if (email != null) {
                              setState(() {
                                this.emailController.text = email;
                                this.email = email;
                              });
                            }
                          },
                          child: Text(
                            AppLocalizations.of(context)!.forgotPassword,
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.white),
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.01),
                        Material(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                          ),
                          child: Container(
                            height: MediaQuery.of(context).size.height*0.06,
                            width: MediaQuery.of(context).size.width*0.50,
                            decoration: BoxDecoration(
                                color: AppColors.black, borderRadius: BorderRadius.circular(10)
                            ),
                            child: !isLoading ? TextButton(
                              onPressed: () async {
                                if(_formKey.currentState!.validate()){
                                  emailTemp = email;
                                  onSignInButtonPressed();
                                }
                              },
                              child: Text(
                                AppLocalizations.of(context)!.login,
                                style: Theme.of(context).textTheme.headline3?.copyWith(color: AppColors.white)
                              ),
                            ) : Center(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.06,
                                height: MediaQuery.of(context).size.height * 0.03,
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.01),
                        Material(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                          ),
                          child: Container(
                            height: MediaQuery.of(context).size.height*0.06,
                            width: MediaQuery.of(context).size.width*0.50,
                            decoration: BoxDecoration(
                                color: Colors.white, borderRadius: BorderRadius.circular(10)
                            ),
                            child: TextButton(
                              onPressed: () async {
                                FocusScopeNode currentFocus = FocusScope.of(context);
                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }
                                String? email = await Navigator.push(
                                    context,
                                    CupertinoPageRoute<String>(
                                      builder: (context) => Register(),
                                      settings: RouteSettings(name: 'Register'),
                                    )
                                );
                                if (email != null) {
                                  setState(() {
                                    this.emailController.text = email;
                                    this.email = email;
                                  });
                                }
                              },
                              child: Text(
                                AppLocalizations.of(context)!.register,
                                  style: Theme.of(context).textTheme.headline3?.copyWith(color: AppColors.black)
                              ),
                            ),
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
      int result = await _userDataService.signIn(email.trim(), password);
      if (result == 0) {
        Navigator.pushReplacement(
            context,
            CupertinoPageRoute<Null>(
              builder: (context) => SplashScreen(),
              settings: RouteSettings(name: 'SplashScreen'),
            )
        );
      } else if (result == -1) {
        setState(() {
          isLoading = false;
          email = emailTemp;
        });
        showInSnackBar(AppLocalizations.of(context)!.loginError);
      } else if (result == -2) {
        setState(() {
          isLoading = false;
        });
        showInSnackBar(AppLocalizations.of(context)!.validateError);
      }
  }

  // Actions to do when login and register
  void onSignInButtonPressed() {
    setState(() {
      isLoading = true;
    });
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    signIn();
  }

  void showInSnackBar(String value) {
    final snackbar = new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: "Helvetica",
          color: Colors.black,
          fontSize: 16.0,
          //fontWeight: FontWeight.w800,
        ),
      ),
      backgroundColor: Colors.white,
      duration: Duration(seconds: 5),
    );
    scaffoldMessengerKey.currentState!.showSnackBar(snackbar);
  }

}