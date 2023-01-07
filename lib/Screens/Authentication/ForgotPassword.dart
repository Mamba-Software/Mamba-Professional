import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
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
  void initState() {
    mixpanel!.track('mamba_forgot_password_view');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.resetPassword, style: Theme.of(context).textTheme.headline3!.copyWith(color: Colors.white)),
          elevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(
            color: Colors.white, //change your color here
          ),
          backgroundColor: AppColors.black,
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
        backgroundColor: AppColors.black,
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
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  TextFormField(
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.emailError : null,
                      onChanged: (val) {
                        setState(() => email = val);
                      },
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                      decoration: Styles.textFromInputDecoration.copyWith(
                          labelText: AppLocalizations.of(context)!.email,
                          labelStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                          errorStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                          prefixIcon:  const Padding(
                            padding: EdgeInsets.all(0.0),
                            child: Icon(
                              Icons.email_outlined,
                              color: AppColors.white,
                            ), // icon is 48px widget.
                          )
                      )
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.04),
                  GestureDetector(
                    onTap: () async {
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
                            Future.delayed(const Duration(seconds: 5), () async {
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
                              AppLocalizations.of(context)!.recover,
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
    RegExp regex = RegExp(pattern.toString());
    if (!regex.hasMatch(value)) {
      return false;
    } else {
      return true;
    }
  }

  void showInSnackBar(String value) {
    final snackbar = SnackBar(
      content: Text(
          value,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.black)
      ),
      backgroundColor: Colors.white,
      duration: const Duration(seconds: 3),
    );
    scaffoldMessengerKey.currentState!.showSnackBar(snackbar);
  }
}


