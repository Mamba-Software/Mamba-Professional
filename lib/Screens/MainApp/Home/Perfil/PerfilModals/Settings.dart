import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:mamba_castelldefels/Providers/LanguageProvider.dart';
import 'package:mamba_castelldefels/Screens/Authentication/Login.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Idiomas/Idiomas.dart';

class Settings extends StatefulWidget {
  final ValueChanged<bool?> isSaved;
  final ValueChanged<bool?> isUpdated;
  const Settings({Key? key, required this.isSaved, required this.isUpdated}) : super(key: key);
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
  // Gets user info.
  void getUser() async {
    currentUser = await _accessDatabase.getCurrentUserDetails();
    setState(() {
      isLoading = false;
    });
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
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height*0.86,
      ),
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Styles.accent),
                    onPressed: () => {
                      isSaved = false,
                      widget.isSaved(isSaved),
                      Navigator.pop(context)
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: Text(AppLocalizations.of(context)!.settings, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
                  ),
                  MaterialButton(
                    onPressed: isUpdated ? () async => {
                      setState(() {
                        isSaved = true;
                        widget.isSaved(isSaved);
                        widget.isUpdated(isUpdated);
                        if (!(_isPrivate == null)) {
                          currentUser.isPrivate = _isPrivate;
                        };
                        if (idiomaChanged) {
                          currentUser.idioma = Provider.of<LanguageProvider>(context, listen: false).idioma!.languageCode;
                          currentUser.previousIdioma = "";
                        };
                        isLoading = true;
                        _idiomaChanged.currentState!.resetIdiomaChanged();
                        idiomaChanged = false;
                      }),
                      await _accessDatabase.updateCurrentUserSettingsPerifl(currentUser.isPrivate!, currentUser.idioma!,currentUser.previousIdioma!),

                      Navigator.pop(context),
                    } : null,
                    color: isUpdated ? Colors.green : Colors.transparent,
                    child: Icon(Icons.save, color: isUpdated ? Colors.white : Styles.accentLight),
                    padding: EdgeInsets.all(15),
                    shape: CircleBorder(),
                  ),
                ],
              ),
              isLoading ?
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: LoadingView()
                )
                  :
                new Container(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 25.0),
                    child : new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          !(currentUser.isTrainer!) ? Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 25.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      new Text(
                                        AppLocalizations.of(context)!.typeProfile,
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              )) : Container(),
                          !(currentUser.isTrainer!) ? Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 12.0),
                              child: ProfileTypeWidget(
                                key: _typeProfileKey,
                                user: currentUser,
                                selectedProfileTypeChanged: (isPrivate) {
                                  setState(() {
                                    _isPrivate = isPrivate;
                                  });
                                },
                              )
                          ) : Container(),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 12.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      new Text(
                                        AppLocalizations.of(context)!.language,
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 12.0, bottom: 12.0),
                              child: LanguagePickerWidget(
                                  key: _idiomaChanged,
                                  idiomaChanged: (bool) {
                                    idiomaChanged = bool!;
                                  },
                              )
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 12.0, bottom: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 50,
                                  width: 250,
                                  decoration: BoxDecoration(
                                      color: Styles.accent, borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: TextButton(
                                    onPressed: () async {
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
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.logout_outlined, color: Styles.white),
                                        SizedBox(width: 10),
                                        Text(
                                          AppLocalizations.of(context)!.closeSession,
                                          style: Styles.whiteTextStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 12.0, bottom: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 50,
                                  width: 250,
                                  decoration: BoxDecoration(
                                      color: Colors.red, borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: TextButton(
                                    onPressed: () async {
                                      showDialog(
                                        context: context,
                                        builder: (_) {
                                          return DeleteDialog();
                                        }
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.delete_outline, color: Styles.white),
                                        SizedBox(width: 10),
                                        Text(
                                          AppLocalizations.of(context)!.deleteAccount,
                                          style: Styles.whiteTextStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ),
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
                  padding: const EdgeInsets.only(top: 25, bottom: 10.0),
                  child: Text(AppLocalizations.of(context)!.wantDeleteUser, style: Styles.redTextStyle.copyWith(color: Colors.red, fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                ),
                Flexible(
                  child: Text("${AppLocalizations.of(context)!.writeDeleteUser} ", style: Styles.purpleTextStyle.copyWith(fontSize: 16), textAlign: TextAlign.center,),
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
                        label: Text(AppLocalizations.of(context)!.delete),
                        icon: Icon(Icons.delete_outline),
                        backgroundColor: canDelete ? Colors.red : Colors.red[100],
                        foregroundColor: Styles.white,
                        onPressed: () async {
                          // Delete Function
                          var result = await _accessDatabase.deleteUser(deleteTemp);
                          if (!result) {
                            setState(() {
                              wrongPassword = true;
                            });
                          } else {
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
                        icon: Icon(Icons.cancel_outlined, size: 30,),
                        label: Text(AppLocalizations.of(context)!.cancel),
                        backgroundColor: Styles.accent,
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
                top: -90,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox.fromSize(
                      size: Size(100, 100), // button width and height
                      child: ClipOval(
                        child: Material(
                          color: Colors.red, // button color
                          child: InkWell(
                            onTap: () async {
                              setState(() {});
                            },
                            child: Icon(Icons.warning, color: Colors.white, size: 60,), // icon
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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _icon(true, text: AppLocalizations.of(context)!.typeProfilePrivate, icon: Icons.visibility_off_outlined),
        _icon(false, text: AppLocalizations.of(context)!.typeProfilePublic, icon: Icons.visibility_outlined),
      ],
    );
  }
  Widget _icon(bool index, {required String text, required IconData icon}) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox.fromSize(
          size: Size(85, 85), // button width and height
          child: ClipOval(
            child: Material(
              color: isPrivate == index ? Styles.accentLight : null, // button color
              child: InkWell(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 38,
                      color: Styles.accent,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Styles.accent)),
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
        )
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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
          height: 80,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection:  Axis.horizontal,
            itemCount: allLocales.length,
            itemBuilder: (context, index) {
              return _iconLocale(allLocales[index], context);
            },
          ),
        ),
      ],
    );
  }
  Widget _iconLocale(Locale locale, BuildContext context ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: SizedBox.fromSize(
          size: Size(85, 85), // button width and height
          child: ClipOval(
            child: Material(
              color: _locale == locale ? Styles.accentLight : null, // button color
              child: InkWell(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(locale.languageCode.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Styles.accent)),
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
      ),
    );
  }
}
