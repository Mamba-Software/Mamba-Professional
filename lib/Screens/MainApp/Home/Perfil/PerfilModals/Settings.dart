import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Dialogs/ConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/Conversation.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:mamba_castelldefels/Providers/LanguageProvider.dart';
import 'package:mamba_castelldefels/Screens/Authentication/Login.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Perfil/PerfilModals/EditPhotoPage.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Perfil/PerfilModals/TusDatos.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Idiomas/Idiomas.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
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


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Checking if there has been a change that has not been saved.
    if (!isLoading) {
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
            icon: Icon(Icons.arrow_back, size: 25,),
            onPressed: () async {
              if (isUpdated) {
                setState(() {
                  isSaved = true;
                  if (!(_isPrivate == null)) {
                    currentUser.isPrivate = _isPrivate;
                  };
                  if (idiomaChanged) {
                    currentUser.idioma = Provider.of<LanguageProvider>(context, listen: false).idioma!.languageCode;
                    currentUser.previousIdioma = "";
                  };
                  _idiomaChanged.currentState!.resetIdiomaChanged();
                  idiomaChanged = false;
                });
                await _accessDatabase.updateCurrentUserSettingsPerifl(currentUser.isPrivate!, currentUser.idioma!,currentUser.previousIdioma!);
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
                        style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
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
                            Icon(Icons.edit_outlined, color: Theme.of(context).primaryColor),
                            SizedBox(width: 10),
                            Text(
                              AppLocalizations.of(context)!.editYourInfo,
                              style: Styles.purpleTextStyle,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
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
                            Icon(Icons.face_retouching_natural, color: Theme.of(context).primaryColor),
                            SizedBox(width: 10),
                            Text(
                              AppLocalizations.of(context)!.editYourPhoto,
                              style: Styles.purpleTextStyle,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.02),
                    ],
                  ),
                  !(currentUser.isTrainer!) ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.typeProfile,
                        style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      ProfileTypeWidget(
                        key: _typeProfileKey,
                        user: currentUser,
                        selectedProfileTypeChanged: (isPrivate) {
                          setState(() {
                            _isPrivate = isPrivate;
                          });
                        },
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.02),
                    ],
                  ) : Container(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context)!.language,
                        style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
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
                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                  TextButton(
                    onPressed: () async {
                      if (!await launch(termsAndConditions)) throw 'Could not launch $termsAndConditions';
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.policy_outlined, color: Theme.of(context).primaryColor),
                        SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)!.termsAndConditions,
                          style: Styles.purpleTextStyle,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
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
                          _accessDatabase.signOut().then((value) =>
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
                        Icon(Icons.logout_outlined, color: Theme.of(context).primaryColor),
                        SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)!.closeSession,
                          style: Styles.purpleTextStyle,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
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
                        Icon(Icons.delete_outline, color: Colors.red),
                        SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)!.deleteAccount,
                          style: Styles.purpleTextStyle.copyWith(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        version,
                        style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Theme.of(context).primaryColor),
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
  var _accessDatabase = new DatabaseAccess();
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
            color: Colors.white
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
                  child: Text(AppLocalizations.of(context)!.wantDeleteUser, style: Styles.redTextStyle.copyWith(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                ),
                Flexible(
                  child: Text("${AppLocalizations.of(context)!.writeDeleteUser} ", style: Styles.purpleTextStyle.copyWith(fontSize: 16, height: 1.5), textAlign: TextAlign.center,),
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
                          style: Styles.redTextStyle.copyWith(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.passworRepeat,
                            hintStyle: Styles.redTextStyle.copyWith(fontSize: 14, color: Colors.red),
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
                                        color: Styles.red
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
                    child: Text("${AppLocalizations.of(context)!.passwordNotSameError} ", style: Styles.redTextStyle.copyWith(fontSize: 16), textAlign: TextAlign.center,),
                  ),
                ) : Container(),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton.extended(
                        heroTag: "39",
                        label: !isLoading ? Text(AppLocalizations.of(context)!.delete) : Container(
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
                        icon: !isLoading ? Icon(Icons.delete_outline) : Container(),
                        backgroundColor: canDelete ? Colors.red : Colors.red[100],
                        foregroundColor: Styles.white,
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          // Delete Function
                          String? userId = currentUser.id;
                          var result = await _accessDatabase.deleteUser(deleteTemp);
                          if (!result) {
                            setState(() {
                              wrongPassword = true;
                            });
                          } else {
                            await _accessDatabase.deleteUserMemberConversations(toMap(userId));
                            if (currentUser.brandID != "null" && currentUser.brandID != null) {
                              // 12/12/2021
                              Conversation conv = await _accessDatabase.getConversationByBrand(currentUser.brandID); //12/12/2021
                              for(int i = 0; i < conv.users.length; ++i) {
                                if(conv.users[i]['uid'] == currentUser.id) {
                                  conv.users.removeAt(i);
                                }
                              }
                              await _accessDatabase.updateConversationUsers(conv.conversationId, conv.users);
                              if (currentUser.isTrainer!) {
                                Brand? result = await _accessDatabase.checkUserIsBrandCreator(currentUser.id!);
                                if (result != null) {
                                  await _accessDatabase.deleteBrand(result.id!);
                                } else {
                                  NotificationService().userLeavesBrand(currentUser.id!, currentUser.brandID!);
                                  await _accessDatabase.deleteUserFromAllBrandEvents(currentUser.id!, currentUser.brandID!, currentUser.isTrainer!);
                                  await _accessDatabase.leaveBrand(currentUser.id!);
                                }
                              } else {
                                NotificationService().userLeavesBrand(currentUser.id!, currentUser.brandID!);
                                await _accessDatabase.deleteUserFromAllBrandEvents(currentUser.id!, currentUser.brandID!, currentUser.isTrainer!);
                                await _accessDatabase.leaveBrand(currentUser.id!);
                              }
                            }
                            Navigator.pushAndRemoveUntil(
                              context,
                              CupertinoPageRoute<Null>(
                                builder: (context) => Login(),
                                settings: RouteSettings(name: 'Login'),
                              ),
                                  (_) => false,
                            );
                          }
                        },
                      ),
                      FloatingActionButton.extended(
                        heroTag: "40",
                        icon: Icon(Icons.cancel_outlined, size: 30,),
                        label: Text(AppLocalizations.of(context)!.cancel),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Styles.white,
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
          size: Size(85, 85), // button width and height
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
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Theme.of(context).primaryColor)
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
