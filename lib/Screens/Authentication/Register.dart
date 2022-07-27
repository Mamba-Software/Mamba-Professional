import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamba_castelldefels/Data/DataService/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Register Page that allows the User to create his profile. This is the same for Client and Trainer.
// After registering the page pop´s after 5 seconds and the user is sent to the Login page. Before Login in
// they need to verify his email.
class Register extends StatefulWidget {
  Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
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
              title: Text(AppLocalizations.of(context)!.createAccount, style: Theme.of(context).appBarTheme.titleTextStyle!.copyWith(color: Colors.white),),
              centerTitle: false,
              elevation: 0,
              iconTheme: IconThemeData(
                color: Colors.white, //change your color here
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
                onPressed: () {
                  if (email.isNotEmpty) {
                    Navigator.pop(context, email.trim());
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              backgroundColor: Theme.of(context).accentColor,
            ),
            resizeToAvoidBottomInset: true,
            backgroundColor: Theme.of(context).accentColor,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.passwordError,
                                style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.black),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.02),
                        TextFormField(
                            validator: (val) => val!.length < 6 ? AppLocalizations.of(context)!.passwordError : null,
                            onChanged: (val) {
                              setState(() => password1 = val);
                            },
                            obscureText: !_passwordVisible,
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.black),
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
                                  ), // icon is 48px widget.
                                )
                            )
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.02),
                        TextFormField(
                            validator: (val) => val == password1 ? null : AppLocalizations.of(context)!.passwordNotSameError,
                            onChanged: (val) {
                              setState(() => password2 = val);
                            },
                            obscureText: !_passwordVisible,
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.black),
                            decoration: Styles.textFromInputDecoration.copyWith(
                                labelText: AppLocalizations.of(context)!.passworRepeat,
                                labelStyle: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.black),
                                errorStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                suffixIcon: Padding(
                                    padding: EdgeInsets.all(0.0),
                                    child: IconButton(
                                        icon: Icon(
                                          // Based on passwordVisible state choose the icon
                                            _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                          color: AppColors.black,
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
                            height: MediaQuery.of(context).size.height*0.06,
                            width: MediaQuery.of(context).size.width*0.50,
                            decoration: BoxDecoration(
                                color: AppColors.white, borderRadius: BorderRadius.circular(10)
                            ),
                            child: !isLoading ? TextButton(
                              onPressed: () async {
                                if(_formKey.currentState!.validate()){
                                  emailTemp = email;
                                  onSignUpButtonPressed();
                                }
                              },
                              child: Text(
                                AppLocalizations.of(context)!.register,
                                style: Theme.of(context).textTheme.headline3?.copyWith(color: AppColors.black),
                              ),
                            ) : Center(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.06,
                                height: MediaQuery.of(context).size.height * 0.03,
                                child: CircularProgressIndicator(
                                  color: AppColors.black,
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

  void onSignUpButtonPressed() {
    setState(() {
      isLoading = true;
    });
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    signUp();
  }

  void signUp() async{
      var result =  await _userDataService.addUser(email.trim(), password1, Localizations.localeOf(context).languageCode);
      if (result == 0) {
        setState(() {
          isLoading = false;
        });
        showInSnackBar(AppLocalizations.of(context)!.validate);
        Future.delayed(Duration(seconds: 5), () async {
          Navigator.pop(context, email.trim());
        });
      } else if (result == -1) {
        setState(() {
          isLoading = false;
        });
        showInSnackBar(AppLocalizations.of(context)!.sameEmail);
      } else {
        setState(() {
          isLoading = false;
        });
        showInSnackBar(AppLocalizations.of(context)!.registerError);
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


class GenderWidget extends StatefulWidget {
  final ValueChanged<int> selectedGenderChanged;
  final int? genderTemp;
  GenderWidget({required this.selectedGenderChanged, required this.genderTemp});

  @override
  _GenderWidgetState createState() => _GenderWidgetState();
}

class _GenderWidgetState extends State<GenderWidget> {
  bool firstBuild = true;
  int? gender;

  @override
  Widget build(BuildContext context) {
    if (firstBuild) {
      if(widget.genderTemp != null) gender = widget.genderTemp;
      firstBuild = false;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _icon(0, text: AppLocalizations.of(context)!.male, icon: Icons.male_outlined),
        _icon(1, text: AppLocalizations.of(context)!.female, icon: Icons.female_outlined),
        _icon(2, text: AppLocalizations.of(context)!.transgender, icon: Icons.transgender_outlined),
      ],
    );
  }

  Widget _icon(int index, {required String text, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkResponse(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: gender == index ? Colors.white : Styles.accent,
              size: 45,
            ),
            Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize:22, color: gender == index ? Colors.white : Styles.accent)),
          ],
        ),
        onTap: () => {
          setState(() {
            gender = index;
            widget.selectedGenderChanged(gender!);
          }),
        }
      ),
    );
  }
}


