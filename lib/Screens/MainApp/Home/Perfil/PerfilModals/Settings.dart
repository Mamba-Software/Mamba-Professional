import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Providers/ClientProvider.dart';
import 'package:mamba_castelldefels/Providers/LanguageProvider.dart';
import 'package:mamba_castelldefels/Providers/UserProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Idiomas/Idiomas.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _editStatus = false;
  // Form Values
  final _formKey = GlobalKey<FormState>();
  String nombreCompletoTemp = "";
  String emailTemp = "";
  final nombreCompletoController = TextEditingController(text: currentUser.name);
  final emailController = TextEditingController(text: currentUser.email);
  // Type of Profile Widget value
  bool? _isPrivate = null;
  final _typeProfileKey = GlobalKey<_ProfileTypeWidgetState>();
  // Idioma Original
  bool idiomaChanged = false;
  final _idiomaChanged = GlobalKey<_LanguagePickerWidgetState>();
  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<UserProvider>(context).usuario;
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
                  icon: Icon(Icons.arrow_back, color: purpleColor),
                  onPressed: () => {Navigator.of(context).pop()},
                ),
                Text(AppLocalizations.of(context)!.settings, style: purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
                !_editStatus ? IconButton(
                    icon: Icon(Icons.edit, color: purpleColor),
                    onPressed: () => {
                      setState(() => _editStatus = !_editStatus)
                    }
                ) :
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.save, color: Colors.green),
                      onPressed: () => {
                        setState(() {
                          if(_formKey.currentState!.validate()){
                            //if (!nombreCompletoTemp.isEmpty) currentUser.name = nombreCompletoTemp;
                            //if (!emailTemp.isEmpty) currentUser.email = emailTemp;
                            if (!(_isPrivate == null)) currentUser.isPrivate = _isPrivate;
                            Provider.of<ClientProvider>(context, listen: false).updateClientFirebase(currentUser);
                            _idiomaChanged.currentState!.resetIdiomaChanged();
                            _editStatus = !_editStatus;
                            idiomaChanged = false;
                          }
                        })
                      },
                    ),
                    SizedBox.fromSize(
                      size: Size(10, 0),
                    ),
                    IconButton(
                      icon: Icon(Icons.highlight_off, color: Colors.red),
                      onPressed: () => {
                        setState(() {
                          //nombreCompletoController.text = currentUser.name;
                          //emailController.text = currentUser.email;
                          if (idiomaChanged) {
                            var tempIdioma = usuario.idioma;
                            usuario.idioma = usuario.previousIdioma;
                            usuario.previousIdioma = tempIdioma;
                            Provider.of<UserProvider>(context, listen: false).updateUsuarioFirebase(usuario);
                          }
                          _idiomaChanged.currentState!.resetIdiomaChanged();
                          _typeProfileKey.currentState!.resetProfileType();
                          _editStatus = !_editStatus;
                          idiomaChanged = false;
                        })
                      },
                    )
                  ],
                ),
              ],
            ),
            new Container(
              child: Padding(
                padding: EdgeInsets.only(bottom: 25.0),
                child: Form(
                  key: _formKey,
                  child: new Column(
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
                                    style: purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 2.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Flexible(
                                child: new TextFormField(
                                  controller: nombreCompletoController,
                                  validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.passwordError : null,
                                  onChanged: (val) {
                                    setState(() => nombreCompletoTemp = val);
                                  },
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!.newPassword,
                                  ),
                                  obscureText: true,
                                  enabled: _editStatus,
                                ),
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 2.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Flexible(
                                child: new TextFormField(
                                  controller: nombreCompletoController,
                                  validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.passwordNotSameError : null,
                                  onChanged: (val) {
                                    setState(() => nombreCompletoTemp = val);
                                  },
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!.passworRepeat,
                                  ),
                                  obscureText: true,
                                  enabled: _editStatus,
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
                                    style: purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 10.0),
                          child: ProfileTypeWidget(
                            key: _typeProfileKey,
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
                                    style: purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
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
            )
          ],
        ),
      ),
    );
  }
}

class ProfileTypeWidget extends StatefulWidget {
  final ValueChanged<bool> selectedProfileTypeChanged;
  final bool editStatus;
  ProfileTypeWidget({required Key key, required this.selectedProfileTypeChanged, required this.editStatus}) : super(key: key);

  @override
  _ProfileTypeWidgetState createState() => _ProfileTypeWidgetState();
}

class _ProfileTypeWidgetState extends State<ProfileTypeWidget> {
  bool isPrivate = currentUser.isPrivate;

  @override
  resetProfileType() => isPrivate = currentUser.isPrivate;
  Widget build(BuildContext context) {
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
              color: isPrivate == index ? purpleColorTrans : null, // button color
              child: InkWell(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 38,
                      color: purpleColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: purpleColor)),
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
  bool idiomaChanged = false;

  @override
  resetIdiomaChanged() => {
    idiomaChanged = false
  };
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    _locale = languageProvider.idioma;
    final allLocales = Idiomas.all;
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
              color: _locale == locale ? purpleColorTrans : null, // button color
              child: InkWell(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(locale.languageCode.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: purpleColor)),
                    ),
                  ],
                ),
                onTap: widget.editStatus ? () => {
                  setState(() {
                    _locale = locale;
                    var usuario = Provider.of<UserProvider>(context, listen: false).usuario;
                    usuario.previousIdioma = usuario.idioma;
                    usuario.idioma = _locale!.languageCode;
                    idiomaChanged = true;
                    Provider.of<UserProvider>(context, listen: false).updateUsuarioFirebase(usuario);
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


