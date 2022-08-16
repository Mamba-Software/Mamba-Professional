import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Screens/Authentication/ForgotPassword.dart';
import 'package:mamba_castelldefels/Screens/Authentication/Register.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';

// Login Page. This allow the User to get Logged In or to Register a new account.
class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  // Access to DatabaseService
  final _userDataService = UserDataService();
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
            backgroundColor: Theme.of(context).colorScheme.secondary,
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
                                padding: const EdgeInsets.all(0.0),
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
                                    padding: const EdgeInsets.all(0.0),
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
                                  padding: const EdgeInsets.all(0.0),
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
                                  settings: const RouteSettings(name: 'ForgotPassword'),
                                )
                            );
                            if (email != null) {
                              setState(() {
                                emailController.text = email;
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
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
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
                                child: const CircularProgressIndicator(
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
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
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
                                      settings: const RouteSettings(name: 'Register'),
                                    )
                                );
                                if (email != null) {
                                  setState(() {
                                    emailController.text = email;
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
        User? user = await _userDataService.getCurrentUser();
        bool? isTrainer = await _userDataService.checkIfUserIsTrainer(user!.uid);
        if (isTrainer != null && isTrainer == false) {
          await _userDataService.signOut();
          setState(() {
            isLoading = false;
          });
          showInSnackBar(AppLocalizations.of(context)!.wrongAppUser, AppLocalizations.of(context)!.wrongAppUserBody, true);
        } else {
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute<void>(
                builder: (context) => const SplashScreen(),
                settings: const RouteSettings(name: 'SplashScreen'),
              )
          );
        }
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

  void showInSnackBar(String value, [String valueBody = "", bool isClickable = false]) {
    Widget snackbar;
    if (isClickable ) {
      snackbar = SnackBar(
        content: GestureDetector(
          onTap: () async {
            await LaunchApp.openApp(
                androidPackageName: 'com.mamba.mambastyleapp',
                iosUrlScheme: "mamba-style",
                appStoreLink: "https://apps.apple.com/app/mamba-style/id1601684650"
              // openStore: false
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                    value,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.black)
                ),
              ),
              Flexible(
                child: Text(
                  valueBody,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.black, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        duration: const Duration(seconds: 10),
      );
    } else {
      snackbar = SnackBar(
        content: Text(
            value,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.black)
        ),
        backgroundColor: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
    scaffoldMessengerKey.currentState!.showSnackBar(snackbar as SnackBar);
  }

}