import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ForgotPassword extends StatefulWidget {
  ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  // Access to DataBaseService
  var _userDataService = new UserDataService();
  // Password Visible
  bool isLoading = false;
  // Scaffold Messenger Key
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  // FormVariables
  final _formKey = GlobalKey<FormState>();
  // Email
  String email = '';
  String? emailTemp;
  // Password
  bool _passwordVisible = false;
  String password1 = '';
  String password2 = '';

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
          key: scaffoldMessengerKey,
          child: Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.resetPassword, style: Theme.of(context).appBarTheme.titleTextStyle!.copyWith(color: Colors.white)),
              elevation: 0,
              iconTheme: IconThemeData(
                color: Colors.white, //change your color here
              ),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width * 0.06,),
                onPressed: () {
                  if (email.isNotEmpty) {
                    Navigator.pop(context, email.trim());
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            resizeToAvoidBottomInset: true,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            body: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.height*0.03),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.emailError,
                              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.black),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.02),
                        TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) => val!.length < 1 ? AppLocalizations.of(context)!.emailError : null,
                            onChanged: (val) {
                              setState(() => email = val);
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
                                  ), // icon is 48px widget.
                                )
                            )
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.04),
                        Material(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                          ),
                          child: Container(
                            height: MediaQuery.of(context).size.height*0.07,
                            width: MediaQuery.of(context).size.width*0.50,
                            decoration: BoxDecoration(
                                color: AppColors.white, borderRadius: BorderRadius.circular(10)
                            ),
                            child: !isLoading ? TextButton(
                              onPressed: () async {
                                int result = 0;
                                if(email.isEmpty) {
                                  showInSnackBar(AppLocalizations.of(context)!.emailError);
                                } else {
                                  if(emailValidator(email)){
                                    setState(() {
                                      isLoading = true;
                                    });
                                    FocusScopeNode currentFocus = FocusScope.of(context);
                                    if (!currentFocus.hasPrimaryFocus) {
                                      currentFocus.unfocus();
                                    }
                                    result = await _userDataService.resetPassword(email);
                                    if (result == 1) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      showInSnackBar(AppLocalizations.of(context)!.validatePassword);
                                      Future.delayed(Duration(seconds: 5), () async {
                                        Navigator.pop(context, email.trim());
                                      });
                                    } else {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      showInSnackBar(AppLocalizations.of(context)!.loginError);
                                    }
                                  } else {
                                    showInSnackBar(AppLocalizations.of(context)!.validateEmail);
                                  }
                                }
                              },
                              child: Text(
                                AppLocalizations.of(context)!.recover,
                                style: Theme.of(context).textTheme.headline3?.copyWith(color: AppColors.black),
                              ),
                            ) : Center(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.06,
                                height: MediaQuery.of(context).size.height * 0.03,
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).primaryColor,
                                  strokeWidth: 2.5,
                                ),
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
        );

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


