import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/EventDataService.dart';

import 'package:mamba_castelldefels/Data/DataService/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Providers/ThemeProvider.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Dialogs/ConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViews/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Conversation.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/Providers/LanguageProvider.dart';
import 'package:mamba_castelldefels/Screens/Authentication/Login.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Perfil/PerfilModals/EditPhotoPage.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Perfil/PerfilModals/TusDatos.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Idiomas/Idiomas.dart';
import 'package:url_launcher/url_launcher.dart';

import 'SettingsPrivacy.dart';
import 'SettingsTheme.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  // Acceso a Base de Datos
  var _userDataService = new UserDataService();
  var _brandDataService = new BrandDataService();
  // Boolean Loading
  bool isLoading = false;
  bool firstBuild = true;
  // Type of Profile Widget value
  bool? _isPrivate = null;
  final _typeProfileKey = GlobalKey<_ProfileTypeWidgetState>();
  // Idioma Original
  bool idiomaChanged = false;
  final _idiomaChanged = GlobalKey<_LanguagePickerWidgetState>();
  // Boolean isUpdated
  bool isUpdated = false;
  // Boolean isSaved
  bool isSaved = false;
  // Theme Provider
  var themeProvider;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Checking if there has been a change that has not been saved.
    if (!isLoading) {
      themeProvider = Provider.of<ThemeProvider>(context);
      if (_isPrivate != currentUser.isPrivate! && _isPrivate != null) {
        isUpdated = true;
      } else if (idiomaChanged) {
        isUpdated = true;
      } else {
        isUpdated = false;
      }
    }
    return isLoading ?
      Scaffold(
        body: LoadingViewPurple(),
      )
        :
      Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.settings, style: Theme.of(context).appBarTheme.titleTextStyle,),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
            onPressed: () async {
              if (isUpdated) {
                setState(() {
                  isSaved = true;
                  if (!(_isPrivate == null)) {
                    currentUser.isPrivate = _isPrivate;
                  };
                  if (idiomaChanged) {
                    currentUser.idioma = Provider.of<LanguageProvider>(context, listen: false).idioma!.languageCode;
                  };
                  _idiomaChanged.currentState!.resetIdiomaChanged();
                  idiomaChanged = false;
                });
                await _userDataService.updateCurrentUserSettingsPerifl(currentUser.isPrivate!, currentUser.idioma!);
              }
              Navigator.pop(context);
              },
          ),
        ),
        body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.width*0.07),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context)!.yourInfo,
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute<String>(
                                builder: (context) => TusDatos(),
                              )
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.edit_outlined, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.05,),
                            SizedBox(width: 10),
                            Text(
                              AppLocalizations.of(context)!.editYourInfo,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute<String>(
                                builder: (context) => EditPhotoPage(),
                              )
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.face_retouching_natural, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.05,),
                            SizedBox(width: 10),
                            Text(
                              AppLocalizations.of(context)!.editYourPhoto,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ],
                        ),
                      ),
                      !(currentUser.isTrainer!) ? TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute<String>(
                                builder: (context) => SettingsPrivacy(),
                              )
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.visibility_outlined, color: Theme.of(context).primaryColor),
                            SizedBox(width: 10),
                            Text(
                              AppLocalizations.of(context)!.editYourPrivacy,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ],
                        ),
                      ) : Container(),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.typeTheme,
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute<String>(
                                builder: (context) => SettingsTheme(),
                              )
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.dark_mode_outlined, color: Theme.of(context).primaryColor),
                            SizedBox(width: 10),
                            Text(
                              AppLocalizations.of(context)!.editYourTheme,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context)!.language,
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      LanguagePickerWidget(
                        key: _idiomaChanged,
                        idiomaChanged: (bool) {
                          idiomaChanged = bool!;
                        },
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.02),
                    ],
                  ),
                  TextButton(
                    onPressed: () async {
                      if (Localizations.localeOf(context).languageCode == 'es') {
                        if (!await launch(termsAndConditionsES)) throw 'Could not launch $termsAndConditionsES';
                      } else if (Localizations.localeOf(context).languageCode == 'ca') {
                        if (!await launch(termsAndConditionsCA)) throw 'Could not launch $termsAndConditionsCA';
                      } else {
                        if (!await launch(termsAndConditionsES)) throw 'Could not launch $termsAndConditionsES';
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.policy_outlined, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.05,),
                        SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)!.termsAndConditions,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      var result = await showDialog(
                          context: context,
                          builder: (_) {
                            return ConfirmationDialog(text: AppLocalizations.of(context)!.closeSessionConfirmation);
                          }
                      );
                      if (result) {
                        setState(() {
                          isLoading = true;
                        });
                        Future.delayed(Duration(seconds: 1), () async {
                          _userDataService.signOut().then((value) =>
                              Navigator.pushAndRemoveUntil(
                                context,
                                CupertinoPageRoute<Null>(
                                  builder: (context) => Login(),
                                  settings: RouteSettings(name: 'Login'),
                                ),
                                    (_) => false,
                              )
                          );
                        });
                      }

                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.logout_outlined, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.05,),
                        SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)!.closeSession,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      showDialog(
                          context: context,
                          builder: (_) {
                            return DeleteDialog();
                          }
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red, size: MediaQuery.of(context).size.width*0.05,),
                        SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)!.deleteAccount,
                          style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        version,
                        style: Theme.of(context).textTheme.caption,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      );
  }
}

class DeleteDialog extends StatefulWidget {
  const DeleteDialog({Key? key}) : super(key: key);

  @override
  _DeleteDialogState createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {

  // Acceso a Base de Datos
  var _userDataService = new UserDataService();
  var _brandDataService = new BrandDataService();
  var _eventDataService = new EventDataService();
  // Delete Alert
  bool isLoading = false;
  bool firstBuild = true;
  bool canDelete = false;
  bool wrongPassword = false;
  String deleteTemp = "";
  var deleteController;
  // Password Visible
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    if(firstBuild) {
      deleteTemp = "";
      firstBuild = false;
    }
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 10.0),
                  child: Text(AppLocalizations.of(context)!.wantDeleteUser, style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                ),
                Flexible(
                  child: Text("${AppLocalizations.of(context)!.writeDeleteUser} ", style: Theme.of(context).textTheme.bodyText2?.copyWith(height: 1.5), textAlign: TextAlign.center,),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 15, right: 15),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new Flexible(
                        child: new TextFormField(
                          obscureText: !_passwordVisible,
                          controller: deleteController,
                          onChanged: (val) {
                            setState(() => {
                              deleteTemp = val
                            });
                            if (val.length < 6) {
                              setState(() => {
                                canDelete = false
                              });
                            } else {
                              setState(() => {
                                canDelete = true
                              });
                            }
                          },
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.red),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.passworRepeat,
                            hintStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.red),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red, width: 1),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red, width: 1),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            suffixIcon: Padding(
                                padding: EdgeInsets.all(0.0),
                                child: IconButton(
                                    icon: Icon(
                                      // Based on passwordVisible state choose the icon
                                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                        color: AppColors.red
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _passwordVisible = !_passwordVisible;
                                      });
                                    }
                                )
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                wrongPassword ? Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0, left: 10, right: 10),
                    child: Text("${AppLocalizations.of(context)!.passwordNotSameError} ", style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.red), textAlign: TextAlign.center,),
                  ),
                ) : Container(),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton.extended(
                        heroTag: "39",
                        label: !isLoading ? Text(AppLocalizations.of(context)!.delete, style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),) : Container(
                          width: MediaQuery.of(context).size.width*0.20,
                          child: Center(
                            child: SizedBox(
                              width: 25,
                              height: 25,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                        ),
                        icon: !isLoading ? Icon(Icons.delete_outline, size: MediaQuery.of(context).size.width*0.06) : Container(),
                        backgroundColor: canDelete ? Colors.red : Colors.red[200],
                        foregroundColor: AppColors.white,
                        onPressed: canDelete ? () async {
                          setState(() {
                            isLoading = true;
                          });
                          // Delete Function
                          var result = await _userDataService.deleteUser(deleteTemp);
                          await _userDataService.deleteUserNickname(currentUser.nick!);
                          if (!result) {
                            setState(() {
                              isLoading = false;
                              wrongPassword = true;
                            });
                          } else {
                            if (hasBrand) {
                              if (currentUser.isTrainer!) {
                                Brand? result = await _brandDataService.checkUserIsBrandCreator(currentUser.id!);
                                if (result != null) {
                                  await _brandDataService.deleteBrand(result.id!);
                                } else {
                                  NotificationService().userLeavesBrand(currentUser.id!, currentBrand.id!);
                                  await _eventDataService.deleteUserFromUpcomingEvents(currentUser.id!, currentUser.isTrainer!);
                                  await _brandDataService.deleteUserFromBrand(currentUser.id!, currentBrand.id!);
                                }
                              } else {
                                NotificationService().userLeavesBrand(currentUser.id!, currentBrand.id!);
                                await _eventDataService.deleteUserFromUpcomingEvents(currentUser.id!, currentUser.isTrainer!);
                                await _brandDataService.deleteUserFromBrand(currentUser.id!, currentBrand.id!);
                              }
                            }
                            currentUser.setBrandList = [];
                            Navigator.pushAndRemoveUntil(
                              context,
                              CupertinoPageRoute<Null>(
                                builder: (context) => Login(),
                                settings: RouteSettings(name: 'Login'),
                              ),
                                  (_) => false,
                            );
                          }
                        } : null,
                      ),
                      FloatingActionButton.extended(
                        heroTag: "40",
                        icon: Icon(Icons.cancel_outlined, size: MediaQuery.of(context).size.width*0.06,),
                        label: Text(AppLocalizations.of(context)!.cancel, style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColorDark),),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Theme.of(context).primaryColorDark,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
                top: -83,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox.fromSize(
                      size: Size(80, 80), // button width and height
                      child: ClipOval(
                        child: Material(
                          color: Colors.red, // button color
                          child: InkWell(
                            onTap: () async {
                              setState(() {});
                            },
                            child: Icon(Icons.delete_outline, color: Colors.white, size: 45,), // icon
                          ),
                        ),
                      ),
                    ),
                  ],
                )
            )
          ],
        ),
      ),
    );
  }

  String splitCommonName(String name) {
    List<String> aux = name.split(" ");
    return aux[0];
  }

  Map<String, dynamic> toMap(String? id) {
    return {
      'uid': id,
    };
  }
}

class ProfileTypeWidget extends StatefulWidget {
  final ValueChanged<bool> selectedProfileTypeChanged;
  final Usuario? user;
  ProfileTypeWidget({required Key key, required this.selectedProfileTypeChanged, required this.user}) : super(key: key);

  @override
  _ProfileTypeWidgetState createState() => _ProfileTypeWidgetState();
}

class _ProfileTypeWidgetState extends State<ProfileTypeWidget> {
  bool firstBuild = true;
  var isPrivate;
  @override
  resetProfileType() => isPrivate = widget.user!.isPrivate!;
  Widget build(BuildContext context) {
    if (firstBuild) {
      isPrivate = widget.user!.isPrivate!;
      firstBuild = false;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _icon(true, text: AppLocalizations.of(context)!.typeProfilePrivate, icon: Icons.visibility_off_outlined),
        SizedBox(width: MediaQuery.of(context).size.width*0.10),
        _icon(false, text: AppLocalizations.of(context)!.typeProfilePublic, icon: Icons.visibility_outlined),
      ],
    );
  }
  Widget _icon(bool index, {required String text, required IconData icon}) {
    return SizedBox.fromSize(
          size: Size(85, 85), // button width and height
          child: ClipOval(
            child: Material(
              color: isPrivate == index ? Theme.of(context).accentColor : Theme.of(context).scaffoldBackgroundColor,
              child: InkWell(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).primaryColor)),
                    ),
                  ],
                ),
                onTap: () => {
                  setState(() {
                    isPrivate = index;
                    widget.selectedProfileTypeChanged(isPrivate);
                  }),
                },
              ),
            ),
          ),
        );
  }
}

class LanguagePickerWidget extends StatefulWidget {
  ValueChanged<bool?> idiomaChanged;
  LanguagePickerWidget({Key? key, required this.idiomaChanged}) : super(key: key);
  @override
  _LanguagePickerWidgetState createState() => _LanguagePickerWidgetState();
}

class _LanguagePickerWidgetState extends State<LanguagePickerWidget> {
  Locale? _locale;
  var allLocales;
  bool idiomaChanged = false;
  @override
  resetIdiomaChanged() => {
    idiomaChanged = false
  };
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    _locale = languageProvider.idioma;
    allLocales = Idiomas.all;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _iconLocale(allLocales[0], context),
        SizedBox(width: MediaQuery.of(context).size.width*0.10),
        _iconLocale(allLocales[1], context),
      ],
    );
  }
  Widget _iconLocale(Locale locale, BuildContext context ) {
    return SizedBox.fromSize(
          size: Size(MediaQuery.of(context).size.width*0.17, MediaQuery.of(context).size.width*0.17), // button width and height
          child: ClipOval(
            child: Material(
              color: _locale == locale ? Theme.of(context).accentColor : Theme.of(context).scaffoldBackgroundColor, // button color
              child: InkWell(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                          locale.languageCode.toUpperCase(),
                          style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.bold)
                      ),
                    ),
                  ],
                ),
                onTap: () => {
                  setState(() {
                    _locale = locale;
                    if (_locale!.languageCode != currentUser.idioma!) {
                      idiomaChanged = true;
                    } else {
                      idiomaChanged = false;
                    }
                    Provider.of<LanguageProvider>(context, listen: false).setLocale(_locale!);
                    widget.idiomaChanged(idiomaChanged);
                  }),
                }
              ),
            ),
          ),
      );
  }
}
