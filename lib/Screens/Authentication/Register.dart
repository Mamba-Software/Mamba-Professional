// Flutter Libs
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
// Internal App Resources
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Globals/SplashScreen.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
// Authentication Service
import 'package:mamba_castelldefels/Providers/AuthenticationProvider.dart';
import 'package:mamba_castelldefels/Providers/LanguageProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Register Widget
class Register extends StatefulWidget {
  Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // Access to DataBaseService
  var _accessDatabase = new DatabaseAccess();
  // Password Visible
  bool isLoading = false;
  // Password Visible
  bool _passwordVisible = false;
  // Switch Trainer Client
  bool isTrainer = false;
  Color textColorClient = Styles.white;
  Color textColorTrainer = Styles.accent;
  FontWeight fontWeightClient = FontWeight.bold;
  FontWeight fontWeightTrainer = FontWeight.normal;
  void toggleSwitch(bool value) {
    if(isTrainer == false) {
      setState(() {
        isTrainer = true;
        textColorTrainer = Styles.white;
        fontWeightTrainer = FontWeight.bold;
        textColorClient = Styles.accent;
        fontWeightClient = FontWeight.normal;
      });
    } else {
      setState(() {
        isTrainer = false;
        textColorClient = Styles.white;
        fontWeightClient = FontWeight.bold;
        textColorTrainer = Styles.accent;
        fontWeightTrainer = FontWeight.normal;
      });
    }
  }
  // Scaffold Messenger Key
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  // FormVariables
  final _formKey = GlobalKey<FormState>();
  bool errorGender = false;
  String errorGenderText = '';
  String name = '';
  String email = '';
  String password1 = '';
  String password2 = '';
  // Gender Widget value
  int? gender;
  void updateGender(int newGender) {
    setState(() {
      gender = newGender;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
            appBar: AppBar(
              title: Image.asset(
                      Constants.logoExtended,
                      fit: BoxFit.contain,
                      height: 32,
                    ),
              centerTitle: true,
              elevation: 10,
              iconTheme: IconThemeData(
                color: Colors.white, //change your color here
              ),
            ),
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
                        Padding(
                          padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 8.0),
                          child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                AppLocalizations.of(context)!.createAccount,
                                style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24)
                              )
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                                child: Text(
                                  AppLocalizations.of(context)!.client,
                                  style: TextStyle(color: textColorClient, fontSize: 22, fontWeight: fontWeightClient),
                                ),
                              ),
                              Container(
                                child: Transform.scale( scale: 2.0,
                                  child: new Switch(
                                    onChanged: toggleSwitch,
                                    value: isTrainer,
                                    activeColor: Styles.accent,
                                    activeTrackColor: Styles.accentLight,
                                    inactiveThumbColor: Styles.accent,
                                    inactiveTrackColor: Styles.accentLight,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                                child: Text(
                                  AppLocalizations.of(context)!.trainer,
                                  style: TextStyle(color: textColorTrainer, fontSize: 22, fontWeight: fontWeightTrainer),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 8.0, bottom: 0),
                            child: TextFormField(
                              validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.nameCompletoError  : null,
                              onChanged: (val) {
                                setState(() => name = val);
                              },
                              decoration: Styles.textFromInputDecoration.copyWith(labelText: AppLocalizations.of(context)!.nameCompleto,
                                  prefixIcon:  Padding(
                                    padding: EdgeInsets.all(0.0),
                                    child: Icon(
                                      Icons.badge_outlined,
                                      color: Styles.accent,
                                    ), // icon is 48px widget.
                                  )
                              )
                            )
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 16.0, bottom: 0),
                            child: TextFormField(
                              validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.emailError : null,
                              onChanged: (val) {
                                setState(() => email = val);
                              },
                              decoration: Styles.textFromInputDecoration.copyWith(labelText: AppLocalizations.of(context)!.email,
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
                          child: GenderWidget(
                              selectedGenderChanged: (gender) {
                                updateGender(gender);
                              }
                          ),
                        ),
                        errorGender ? Padding(
                          padding: EdgeInsets.only(left: 0, right: 0, top: 2.0),
                          child: Center(
                            child: Text(
                              errorGenderText,
                              style: Styles.redTextStyle.copyWith(fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ) : new Container(),
                        Padding(
                            padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 16.0, bottom: 0),
                            child: TextFormField(
                              validator: (val) => val!.length < 6 ? AppLocalizations.of(context)!.passwordError : null,
                              onChanged: (val) {
                                setState(() => password1 = val);
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
                        Padding(
                          padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 16.0, bottom: 16.0),
                          child: TextFormField(
                              validator: (val) => val == password1 ? null : AppLocalizations.of(context)!.passwordNotSameError,
                              onChanged: (val) {
                                setState(() => password2 = val);
                              },
                              obscureText: !_passwordVisible,
                              decoration: Styles.textFromInputDecoration.copyWith(labelText: AppLocalizations.of(context)!.passworRepeat,
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
                          ),
                        ),
                        Container(
                          height: 50,
                          width: 250,
                          decoration: BoxDecoration(
                              color: Styles.accent, borderRadius: BorderRadius.circular(20)),
                          child: TextButton(
                            onPressed: () async {
                              if (gender == null) {
                                setState(() {
                                  errorGender = true;
                                  errorGenderText = AppLocalizations.of(context)!.registerGenderError;
                                  isLoading = false;
                                });
                              } else {
                                setState(() {
                                  errorGender = false;
                                });
                              };
                              if(_formKey.currentState!.validate()){
                                onSignUpButtonPressed();
                              }
                            },
                            child: Text(
                              AppLocalizations.of(context)!.register,
                              style: Styles.whiteTextStyle.copyWith(fontSize: 28),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 8.0),
                          child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                AppLocalizations.of(context)!.alreadyUser,
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

  void onSignUpButtonPressed() {
    setState(() {
      isLoading = true;
    });
    signUp();
  }

  void signUp() async{
    try {
      var result =  await _accessDatabase.addUser(email, password1, name, isTrainer, gender!, Localizations.localeOf(context).languageCode);
      if(result == 0) {
        setState(() {
          isLoading = false;
        });
        showInSnackBar(AppLocalizations.of(context)!.validate);
        Future.delayed(Duration(seconds: 4), () async {
          Navigator.pop(context);
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
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showInSnackBar(AppLocalizations.of(context)!.sameEmail);
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

class GenderWidget extends StatefulWidget {
  final ValueChanged<int> selectedGenderChanged;
  GenderWidget({required this.selectedGenderChanged});

  @override
  _GenderWidgetState createState() => _GenderWidgetState();
}

class _GenderWidgetState extends State<GenderWidget> {
  int? gender;

  @override
  Widget build(BuildContext context) {
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


