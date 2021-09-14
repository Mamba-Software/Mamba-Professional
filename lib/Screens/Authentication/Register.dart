import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
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
  var _accessDatabase = new DatabaseAccess();
  // Password Visible
  bool isLoading = false;
  // Password Visible
  bool _passwordVisible = false;
  // isTrainer?
  bool isTrainer = false;
  bool? isTrainerTemp;
  // Scaffold Messenger Key
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  // FormVariables
  final _formKey = GlobalKey<FormState>();
  bool errorGender = false;
  String errorGenderText = '';
  String name = '';
  String nameTemp = '';
  String email = '';
  String emailTemp = '';
  String password1 = '';
  String password2 = '';
  // Gender Widget value
  int? gender;
  var genderTemp;
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
                        Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 12.0),
                            child: UserTypeWidget(
                              isTrainer: isTrainerTemp == null ? isTrainer : isTrainerTemp!,
                              selectedProfileTypeChanged: (_isTrainer) {
                                isTrainer = _isTrainer;
                              },
                            )
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 8.0, bottom: 0),
                            child: TextFormField(
                              initialValue: nameTemp,
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
                              initialValue: emailTemp,
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
                              genderTemp: genderTemp,
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
                                isTrainerTemp = isTrainer;
                                nameTemp = name;
                                emailTemp = email;
                                genderTemp = gender;
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

class UserTypeWidget extends StatefulWidget {
  final ValueChanged<bool> selectedProfileTypeChanged;
  final bool isTrainer;
  UserTypeWidget({Key? key, required this.selectedProfileTypeChanged, required this.isTrainer}) : super(key: key);

  @override
  _UserTypeWidgetState createState() => _UserTypeWidgetState();
}

class _UserTypeWidgetState extends State<UserTypeWidget> {
  bool firstBuild = true;
  var _isTrainer;

  @override
  Widget build(BuildContext context) {
    if (firstBuild) {
      _isTrainer = widget.isTrainer;
      firstBuild = false;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _icon(false, text: AppLocalizations.of(context)!.client, icon: Icons.directions_run),
        _icon(true, text: AppLocalizations.of(context)!.trainer, icon: Icons.record_voice_over),
      ],
    );
  }
  Widget _icon(bool index, {required String text, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkResponse(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 45,
                color: _isTrainer == index ? Colors.white : Styles.accent,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                    text,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: _isTrainer == index ? Colors.white : Styles.accent
                    )
                ),
              ),
            ],
          ),
          onTap: () => {
            setState(() {
              _isTrainer = index;
              widget.selectedProfileTypeChanged(_isTrainer);
            }),
          },
        ),
    );
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


