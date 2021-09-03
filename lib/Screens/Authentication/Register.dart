// Flutter Libs
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// Internal App Resources
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Globals/Loading.dart';
// Authentication Service
import 'package:mamba_castelldefels/Providers/AuthenticationProvider.dart';
import 'package:mamba_castelldefels/Providers/LanguageProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Register Widget
class Register extends StatefulWidget {
  final Function toggleView;
  Register({ required this.toggleView });

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // Loading Screen Boolean
  bool loading = false;
  // Password Visible
  bool _passwordVisible = false;
  // Switch Trainer Client
  bool isTrainer = false;
  Color textColorClient = whiteColor;
  Color textColorTrainer = purpleColor;
  FontWeight fontWeightClient = FontWeight.bold;
  FontWeight fontWeightTrainer = FontWeight.normal;
  void toggleSwitch(bool value) {
    if(isTrainer == false) {
      setState(() {
        isTrainer = true;
        textColorTrainer = whiteColor;
        fontWeightTrainer = FontWeight.bold;
        textColorClient = purpleColor;
        fontWeightClient = FontWeight.normal;
      });
    } else {
      setState(() {
        isTrainer = false;
        textColorClient = whiteColor;
        fontWeightClient = FontWeight.bold;
        textColorTrainer = purpleColor;
        fontWeightTrainer = FontWeight.normal;
      });
    }
  }
  // FormVariables
  final _formKey = GlobalKey<FormState>();
  String errorText = '';
  bool errorGender = false;
  String errorGenderText = '';
  String name = '';
  String email = '';
  String password1 = '';
  String password2 = '';

  // OnBackPressed
  Future<bool> _onBackPressed() async {
    return widget.toggleView() ?? false;
  }
  // Gender Widget value
  int? gender;
  void updateGender(int newGender) {
    setState(() {
      gender = newGender;
    });
  }

  @override
  Widget build(BuildContext context) {
    errorText = AppLocalizations.of(context)!.registerError;
    final user = Provider.of<AuthenticationProvider>(context);
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: loading ? Loading() :Scaffold(
          backgroundColor: yellowColor,
          body: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.only(top: 24.0),
                        width: 200,
                        height: 100,
                        child: Image.asset(logoExtended)),
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
                          style: redTextStyle.copyWith(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ) : new Container(),
                    Padding(
                        padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 8.0, bottom: 0),
                        child: TextFormField(
                          validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.nameCompletoError  : null,
                          onChanged: (val) {
                            setState(() => name = val);
                          },
                          decoration: textFromInputDecoration.copyWith(labelText: AppLocalizations.of(context)!.nameCompleto,
                              prefixIcon:  Padding(
                                padding: EdgeInsets.all(0.0),
                                child: Icon(
                                  Icons.badge_outlined,
                                  color: purpleColor,
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
                          decoration: textFromInputDecoration.copyWith(labelText: AppLocalizations.of(context)!.email,
                              prefixIcon:  Padding(
                                padding: EdgeInsets.all(0.0),
                                child: Icon(
                                  Icons.email_outlined,
                                  color: purpleColor,
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
                            setState(() => password1 = val);
                          },
                          obscureText: !_passwordVisible,
                          decoration: textFromInputDecoration.copyWith(labelText: AppLocalizations.of(context)!.password,
                              suffixIcon: Padding(
                                  padding: EdgeInsets.all(0.0),
                                  child: IconButton(
                                      icon: Icon(
                                        // Based on passwordVisible state choose the icon
                                          _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                          color: purpleColor
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
                                  color: purpleColor,
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
                          decoration: textFromInputDecoration.copyWith(labelText: AppLocalizations.of(context)!.passworRepeat,
                              suffixIcon: Padding(
                                  padding: EdgeInsets.all(0.0),
                                  child: IconButton(
                                      icon: Icon(
                                        // Based on passwordVisible state choose the icon
                                          _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                          color: purpleColor
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
                                  color: purpleColor,
                                ), // icon is 48px widget.
                              )
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
                                activeColor: purpleColor,
                                activeTrackColor: purpleLightColor,
                                inactiveThumbColor: purpleColor,
                                inactiveTrackColor: purpleLightColor,
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
                    Container(
                      height: 50,
                      width: 250,
                      decoration: BoxDecoration(
                          color: purpleColor, borderRadius: BorderRadius.circular(20)),
                      child: TextButton(
                        onPressed: () async {
                          if(gender == null) {
                            setState(() {
                              errorGender = true;
                              errorGenderText = AppLocalizations.of(context)!.registerGenderError;
                            });
                          } else {
                            setState(() {
                              errorGender = false;
                            });
                          };
                          String defIdioma = Localizations.localeOf(context).languageCode;
                          if(_formKey.currentState!.validate()){
                            setState(() {
                              loading = true;
                            });
                            await user.signUp(email,password1,name,gender!,defIdioma,isTrainer);
                          }
                        },
                        child: Text(
                          AppLocalizations.of(context)!.register,
                          style: whiteTextStyle.copyWith(fontSize: 28),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 8.0),
                      child: TextButton(
                          onPressed: () {
                            widget.toggleView();
                          },
                          child: Text(
                            AppLocalizations.of(context)!.alreadyUser,
                            style: whiteTextStyle,
                          )
                      ),
                    ),
                    errorAuthRegister ? Padding(
                      padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 8.0),
                      child: Center(
                        child: Text(
                          errorText,
                          style: redTextStyle.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ) : new Container()
                  ],
              ),
            ),

            ),
          ),
      ),
    );
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
              color: gender == index ? Colors.white : purpleColor,
            ),
            Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize:22, color: gender == index ? Colors.white : purpleColor)),
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