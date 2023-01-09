import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Screens/Authentication/ForgotPassword.dart';
import 'package:mamba_castelldefels/Screens/Authentication/Register.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

// Login Page. This allow the User to get Logged In or to Register a new account.
class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {

  // Access to DatabaseService
  final _userDataService = UserDataService();
  // Loading Screen Boolean
  bool isLoading = false;
  bool isEmailSignIn = false;
  // Password Visible
  bool _passwordVisible = false;
  // Scaffold Messenger Key
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  // FormVariables
  final _formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  FocusNode focusNodePassword = FocusNode();
  String email = '';
  String password = '';
  String emailTemp = '';
  // Google Sign In
  final googleSignIn = GoogleSignIn();
  bool isLoadingGoogle = false;

  @override
  initState() {
    mixpanel!.track('mamba_login_view');
    super.initState();
  }

  Widget _renderWidget() {
    return isEmailSignIn == false ? initialLogIn() :  logInWithEmail();
  }

  Widget initialLogIn() {
    return Container(
        key: const ValueKey<int>(0),
        height: MediaQuery.of(context).size.height*0.4,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: AppColors.black,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isLoadingGoogle = true;
                });
                signInWithGoogle();
              },
              child: Material(
                elevation: 4,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30.0),
                  ),
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height*0.07,
                  width: MediaQuery.of(context).size.width*0.9,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: const Color(0xFF4285F4),
                      borderRadius: BorderRadius.circular(30)
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height*0.07,
                        width: MediaQuery.of(context).size.height*0.07,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: AppColors.white, borderRadius: BorderRadius.circular(30)
                        ),
                        child: Image(
                            image: AssetImage(Constants.google)
                        ),
                      ),
                      Expanded(
                        child: !isLoadingGoogle ? Text(
                            AppLocalizations.of(context)!.continueWithGoogle,
                            style: Theme.of(context).textTheme.headline3?.copyWith(color: AppColors.white),
                            textAlign: TextAlign.center
                        ) : Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.06,
                            height: MediaQuery.of(context).size.width * 0.06,
                            child: const CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.02),
            GestureDetector(
              onTap: () {
                setState(() {
                  isEmailSignIn = true;
                });
              },
              child: Material(
                elevation: 4,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30.0),
                  ),
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height*0.07,
                  width: MediaQuery.of(context).size.width*0.9,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(30)
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height*0.07,
                        width: MediaQuery.of(context).size.height*0.07,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: AppColors.black, borderRadius: BorderRadius.circular(30)
                        ),
                        child: Icon(
                          Icons.email_outlined,
                          size: MediaQuery.of(context).size.height*0.04,
                          color: AppColors.white,
                        ),
                      ),
                      Expanded(
                          child: Text(
                              AppLocalizations.of(context)!.loginWithEmail,
                              style: Theme.of(context).textTheme.headline3?.copyWith(color: AppColors.black),
                              textAlign: TextAlign.center
                          )
                      ),
                    ],
                  ),
                ),
              ),
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
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context)!.noAccount+" ",
                    ),
                    TextSpan(
                        text: AppLocalizations.of(context)!.register,
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(decoration: TextDecoration.underline)
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.01),
            TextButton(
              onPressed: () async {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                if (Localizations.localeOf(context).languageCode == 'es') {
                  if (!await launchUrl(Uri.parse(termsAndConditionsES))) throw 'Could not launch $termsAndConditionsES';
                } else if (Localizations.localeOf(context).languageCode == 'ca') {
                  if (!await launchUrl(Uri.parse(termsAndConditionsCA))) throw 'Could not launch $termsAndConditionsCA';
                } else {
                  if (!await launchUrl(Uri.parse(termsAndConditionsES))) throw 'Could not launch $termsAndConditionsES';
                }
              },
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context)!.useMambaTermsAndConditions,
                    ),
                    TextSpan(
                        text: AppLocalizations.of(context)!.termsAndConditions.toLowerCase(),
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(decoration: TextDecoration.underline)
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.005),
          ],
        )
    );
  }

  Widget logInWithEmail() {
    return Container(
      key: const ValueKey<int>(1),
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.height*0.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: AppColors.black,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height*0.02),
          TextFormField(
            autofocus: false,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.emailError : null,
            onChanged: (val) {
              setState(() {
                email = val;
              });
            },
            onFieldSubmitted: (val) {
              focusNodePassword.requestFocus();
            },
            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
            decoration: Styles.textFromInputDecoration.copyWith(
                labelText: AppLocalizations.of(context)!.email,
                labelStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                errorStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                prefixIcon:  Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Icon(
                    Icons.email_outlined,
                    color: AppColors.white,
                    size: MediaQuery.of(context).size.width*0.06,
                  ), // icon is 48px widget.
                )
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.01),
          TextFormField(
              focusNode: focusNodePassword,
              validator: (val) => val!.length < 6 ? AppLocalizations.of(context)!.passwordError : null,
              onChanged: (val) {
                setState(() {
                  password = val;
                });
              },
              keyboardType: TextInputType.visiblePassword,
              style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
              obscureText: !_passwordVisible,
              decoration: Styles.textFromInputDecoration.copyWith(
                  labelText: AppLocalizations.of(context)!.password,
                  labelStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                  errorStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                  suffixIcon: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            _passwordVisible ? Icons.visibility : Icons.visibility_off,
                            color: AppColors.white,
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
                      color: AppColors.white,
                      size: MediaQuery.of(context).size.width*0.06,
                    ), // icon is 48px widget.
                  )
              )
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.08),
            child: TextButton(
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
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.center
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                  children: [
                    /*
                                      TextSpan(
                                          text: AppLocalizations.of(context)!.forgotPassword+" "
                                      ),
                                      */
                    TextSpan(
                        text: AppLocalizations.of(context)!.forgotPassword,
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white, fontWeight: FontWeight.normal)
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.01),
          GestureDetector(
            onTap: () async {
              if(_formKey.currentState!.validate()){
                emailTemp = email;
                onSignInButtonPressed();
              }
            },
            child: Material(
              elevation: 4,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(30.0),
                ),
              ),
              child: Container(
                height: MediaQuery.of(context).size.height*0.07,
                width: MediaQuery.of(context).size.width*0.9,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: AppColors.white, borderRadius: BorderRadius.circular(30)
                ),
                child: !isLoading ? Center(
                  child: Text(
                      AppLocalizations.of(context)!.continueWithGoogle.split(" ")[0],
                      style: Theme.of(context).textTheme.headline3?.copyWith(color: AppColors.black)
                  ),
                ) : Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.06,
                    height: MediaQuery.of(context).size.width * 0.06,
                    child: const CircularProgressIndicator(
                      color: AppColors.black,
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              ),
            ),
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
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                children: [
                  TextSpan(
                    text: AppLocalizations.of(context)!.noAccount+" ",
                  ),
                  TextSpan(
                      text: AppLocalizations.of(context)!.register,
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(decoration: TextDecoration.underline)
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.01),
          TextButton(
            onPressed: () async {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              if (Localizations.localeOf(context).languageCode == 'es') {
                if (!await launchUrl(Uri.parse(termsAndConditionsES))) throw 'Could not launch $termsAndConditionsES';
              } else if (Localizations.localeOf(context).languageCode == 'ca') {
                if (!await launchUrl(Uri.parse(termsAndConditionsCA))) throw 'Could not launch $termsAndConditionsCA';
              } else {
                if (!await launchUrl(Uri.parse(termsAndConditionsES))) throw 'Could not launch $termsAndConditionsES';
              }
            },
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                children: [
                  TextSpan(
                    text: AppLocalizations.of(context)!.useMambaTermsAndConditions,
                  ),
                  TextSpan(
                      text: AppLocalizations.of(context)!.termsAndConditions.toLowerCase(),
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(decoration: TextDecoration.underline)
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.005),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.black,
        appBar: isEmailSignIn ? AppBar(
          toolbarHeight: MediaQuery.of(context).size.height*0.08,
          backgroundColor: AppColors.black,
          elevation: 0,
          centerTitle: false,
          title: FocusScope.of(context).hasPrimaryFocus == false ? SizedBox(
              height: MediaQuery.of(context).size.height*0.2,
              width: MediaQuery.of(context).size.width*0.3,
              child: Image.asset(Constants.logoExtended)
          ) : Container(),
          leadingWidth: MediaQuery.of(context).size.width*0.12,
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.02),
            child: IconButton(
              icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.08, color: AppColors.white),
              alignment: Alignment.center,
              onPressed: () {
                setState(() {
                  isEmailSignIn = false;
                });
              },
            ),
          ),
        ) : AppBar(
          toolbarHeight: MediaQuery.of(context).size.height*0.08,
          backgroundColor: AppColors.black,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.02, vertical: MediaQuery.of(context).size.height*0.02),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.linear,
                  child: FocusScope.of(context).hasPrimaryFocus || isEmailSignIn == false ? Container(
                      key: const ValueKey<int>(0),
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                      height: MediaQuery.of(context).size.height*0.3,
                      width: MediaQuery.of(context).size.width*0.6,
                      child: Image.asset(Constants.logoExtended)
                  ) : Container(
                    key: const ValueKey<int>(1),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.1), end: const Offset(0, 0)).animate(animation),
                      child: child,
                    );
                  },
                  child: _renderWidget(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  void signIn() async {
    int result = await _userDataService.signIn(email.trim(), password);
    if (result == 0) {
      User? user = await _userDataService.getCurrentUser();
      bool? isTrainer;
      try {
        isTrainer = await _userDataService.checkIfUserIsTrainer(user!.uid);
        if (isTrainer != null && isTrainer == false) {
          await _userDataService.signOut();
          setState(() {
            isLoading = false;
          });
          mixpanel!.track('mamba_login_wrong_app_error');
          showInSnackBar(AppLocalizations.of(context)!.wrongAppUser, AppLocalizations.of(context)!.wrongAppUserBody, true);
        } else {
          mixpanel!.track('mamba_login_completed');
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute<void>(
                builder: (context) => const SplashScreen(),
                settings: const RouteSettings(name: 'SplashScreen'),
              )
          );
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        showInSnackBar(AppLocalizations.of(context)!.loginError);
      }
    } else if (result == -1) {
      setState(() {
        isLoading = false;
        email = emailTemp;
      });
      mixpanel!.track('mamba_login_notfound_error');
      showInSnackBar(AppLocalizations.of(context)!.loginError);
    } else if (result == -2) {
      setState(() {
        isLoading = false;
      });
      mixpanel!.track('mamba_login_validate_email_error');
      showInSnackBar(AppLocalizations.of(context)!.validateError, AppLocalizations.of(context)!.resend+" "+AppLocalizations.of(context)!.email, true, true);
    }
  }

  void signInWithGoogle() async {
    final user = await googleSignIn.signIn();
    if (user == null) {
      setState(() {
        isLoadingGoogle = false;
      });
      showInSnackBar(AppLocalizations.of(context)!.loginError);
    } else {
      final googleAuth = await user.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);
      bool userExists = await _userDataService.checkIfUserExists(authResult.user!.uid);
      if (userExists) {
        // Check it is no Trainer
        bool? isTrainer;
        try {
          isTrainer = await _userDataService.checkIfUserIsTrainer(authResult.user!.uid);
          if (isTrainer != null && isTrainer == false) {
            await _userDataService.signOut();
            await googleSignIn.signOut();
            setState(() {
              isLoadingGoogle = false;
            });
            showInSnackBar(AppLocalizations.of(context)!.wrongAppUser, AppLocalizations.of(context)!.wrongAppUserBody, true);
          } else {
            mixpanel!.track('mamba_google_login_completed');
            Navigator.pushReplacement(
                context,
                CupertinoPageRoute<void>(
                  builder: (context) => const SplashScreen(),
                  settings: const RouteSettings(name: 'SplashScreen'),
                )
            );
          }
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          showInSnackBar(AppLocalizations.of(context)!.loginError);
        }
      } else {
        // Create an account and a user for this new person from google
        bool result = await _userDataService.addUserGoogle(authResult, Localizations.localeOf(context).languageCode);
        if (result) {
          mixpanel!.track('mamba_google_register_completed');
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute<void>(
                builder: (context) => const SplashScreen(),
                settings: const RouteSettings(name: 'SplashScreen'),
              )
          );
        } else {
          setState(() {
            isLoadingGoogle = false;
          });
          showInSnackBar(AppLocalizations.of(context)!.loginError);
        }
      }
    }
  }

  void showInSnackBar(String value, [String valueBody = "", bool isClickable = false, bool resendEmail = false]) {
    Widget snackbar;
    if (isClickable ) {
      snackbar = SnackBar(
        content: GestureDetector(
          onTap: () async {
            if (resendEmail == false) {
              await LaunchApp.openApp(
                  androidPackageName: 'com.mamba.mambaprofessionalapp',
                  iosUrlScheme: "mamba-professional",
                  appStoreLink: "https://apps.apple.com/us/app/mamba-professional/id1642701679",
                  openStore: true
              );
            } else {
              await _userDataService.resendEmail(email.trim());
              scaffoldMessengerKey.currentState!.hideCurrentSnackBar();
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: Text(
                    value,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.black)
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
        duration: const Duration(seconds: 6),
      );
    } else {
      snackbar = SnackBar(
        content: Text(
            value,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.black)
        ),
        backgroundColor: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
    scaffoldMessengerKey.currentState!.showSnackBar(snackbar as SnackBar);
  }

}