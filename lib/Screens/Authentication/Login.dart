import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
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
  var emailController = TextEditingController();
  String email = '';
  String password = '';
  String emailTemp = '';

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
          key: scaffoldMessengerKey,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
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
                        SizedBox(height: MediaQuery.of(context).size.height*0.05),
                        Container(
                          padding: EdgeInsets.only(top: 16.0),
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
                          style: Theme.of(context).textTheme.headline1!.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                          decoration: Styles.textFromInputDecoration.copyWith(
                              labelText: AppLocalizations.of(context)!.email,
                              prefixIcon:  Padding(
                                padding: EdgeInsets.all(0.0),
                                child: Icon(
                                    Icons.email_outlined,
                                    color: Theme.of(context).primaryColor
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
                            style: Theme.of(context).textTheme.headline1!.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                            obscureText: !_passwordVisible,
                            decoration: Styles.textFromInputDecoration.copyWith(
                                labelText: AppLocalizations.of(context)!.password,
                                suffixIcon: Padding(
                                    padding: EdgeInsets.all(0.0),
                                    child: IconButton(
                                        icon: Icon(
                                          // Based on passwordVisible state choose the icon
                                            _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                            color: Theme.of(context).primaryColor
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
                                    color: Theme.of(context).primaryColor,
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
                            style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontSize: 18),
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
                                color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(10)
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
                                style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontSize: 23),
                              ),
                            ) : Center(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.06,
                                height: MediaQuery.of(context).size.height * 0.03,
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).scaffoldBackgroundColor,
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
                                style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 23),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.05),
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
      int result = await _accessDatabase.signIn(email.trim(), password);
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