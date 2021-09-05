import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:mamba_castelldefels/Providers/LanguageProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Idiomas/Idiomas.dart';

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
  bool _editStatus = false;
  bool firstBuild = true;
  // Model Usuario
  Usuario? user;

  // Type of Profile Widget value
  bool? _isPrivate = null;
  final _typeProfileKey = GlobalKey<_ProfileTypeWidgetState>();
  // Idioma Original
  bool idiomaChanged = false;
  final _idiomaChanged = GlobalKey<_LanguagePickerWidgetState>();

  @override
  void initState() {
    super.initState();
    isLoading = true;
    getUser();
  }

  void getUser() async {
    user = await _accessDatabase.getCurrentUserDetails();
    setState(() {
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MediaQuery.of(context).viewInsets,
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
                  onPressed: () => {Navigator.of(context).pop()},
                ),
                Text(AppLocalizations.of(context)!.settings, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
                !_editStatus ? IconButton(
                    icon: Icon(Icons.edit, color: Styles.accent),
                    onPressed: () => {
                      setState(() => _editStatus = !_editStatus)
                    }
                ) :
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.save, color: Colors.green),
                      onPressed: !isLoading ? () => {
                        setState(() {
                            if (!(_isPrivate == null)) user!.isPrivate = _isPrivate;
                            if (idiomaChanged) {
                              user!.previousIdioma = user!.idioma;
                              user!.idioma = Provider.of<LanguageProvider>(context, listen: false).idioma!.languageCode;
                            }
                            _accessDatabase.updateCurrentUserSettingsPerifl(user!.isPrivate!, user!.idioma!, user!.previousIdioma!);
                            _idiomaChanged.currentState!.resetIdiomaChanged();
                            _editStatus = !_editStatus;
                            idiomaChanged = false;
                        })
                      } : null,
                    ),
                    SizedBox.fromSize(
                      size: Size(10, 0),
                    ),
                    IconButton(
                      icon: Icon(Icons.highlight_off, color: Colors.red),
                      onPressed: !isLoading ? () => {
                        setState(() {
                          //nombreCompletoController.text = currentUser.name;
                          //emailController.text = currentUser.email;
                          if (idiomaChanged) {
                            var locale = Idiomas.getLocaleFromString(user!.idioma!);
                            Provider.of<LanguageProvider>(context, listen: false).setLocale(locale);
                          }
                          _idiomaChanged.currentState!.resetIdiomaChanged();
                          _typeProfileKey.currentState!.resetProfileType();
                          _editStatus = !_editStatus;
                          idiomaChanged = false;
                        })
                      } : null,
                    )
                  ],
                ),
              ],
            ),
            isLoading ?
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
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
                      Padding(
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
                                    AppLocalizations.of(context)!.changePassword,
                                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 12.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Flexible(
                                child: new TextFormField(
                                  initialValue: "abcdefghijklmn",
                                  decoration: InputDecoration(),
                                  obscureText: true,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 25.0),
                                child: Container(
                                  height: 50,
                                  width: 80,
                                  decoration: BoxDecoration(
                                      color: !_editStatus ? Styles.accentLight : Styles.accent, borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: TextButton(
                                    onPressed: _editStatus ? () async {
                                      //await user.resetPassword(currentUser.email);
                                      Navigator.pop(context);
                                    } : null,
                                    child: Text(
                                      AppLocalizations.of(context)!.change,
                                      style: Styles.whiteTextStyle.copyWith(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                      Padding(
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
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 12.0),
                          child: ProfileTypeWidget(
                            key: _typeProfileKey,
                            user: user,
                            editStatus: (_editStatus),
                            selectedProfileTypeChanged: (isPrivate) {
                              _isPrivate = isPrivate;
                            },
                          )
                      ),
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
                              editStatus: (_editStatus),
                              idiomaChanged: (bool) {
                                idiomaChanged = bool!;
                              },
                          )
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ProfileTypeWidget extends StatefulWidget {
  final ValueChanged<bool> selectedProfileTypeChanged;
  final bool editStatus;
  final Usuario? user;
  ProfileTypeWidget({required Key key, required this.selectedProfileTypeChanged, required this.editStatus, required this.user}) : super(key: key);

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
                onTap: widget.editStatus ? () => {
                  setState(() {
                    isPrivate = index;
                    widget.selectedProfileTypeChanged(isPrivate);
                  }),
                } : null,
              ),
            ),
          ),
        )
    );
  }
}

class LanguagePickerWidget extends StatefulWidget {
  bool editStatus;
  ValueChanged<bool?> idiomaChanged;
  LanguagePickerWidget({Key? key, required this.editStatus, required this.idiomaChanged}) : super(key: key);

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
                onTap: widget.editStatus ? () => {
                  setState(() {
                    _locale = locale;
                    idiomaChanged = true;
                    Provider.of<LanguageProvider>(context, listen: false).setLocale(_locale!);
                    widget.idiomaChanged(idiomaChanged);
                  }),
                } : null,
              ),
            ),
          ),
      ),
    );
  }
}


