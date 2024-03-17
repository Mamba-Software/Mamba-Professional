import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/commons/constants/GlobalVars.dart';
import 'package:mamba_castelldefels/l10n/Idiomas.dart';
import 'package:mamba_castelldefels/l10n/LanguageProvider.dart';
import 'package:provider/provider.dart';

class SettingsLanguage extends StatefulWidget {
  const SettingsLanguage({super.key});

  @override
  _SettingsPrivacyState createState() => _SettingsPrivacyState();
}

class _SettingsPrivacyState extends State<SettingsLanguage> {

  // Acceso a Base de Datos
  final _userDataService = UserDataService();
  // Type of Users
  var allLocales;
  String _value = "";


  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Theme.of(context).colorScheme.secondary;
  }

  @override
  void initState() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    _value = languageProvider.idioma!.languageCode;
    allLocales = Idiomas.all;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.language, style: Theme.of(context).appBarTheme.titleTextStyle,),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.02),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.02),
                ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.only(left: 0.0, right: 16.0),
                  title: Text(
                    "Español",
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  leading: Radio(
                    value: "es",
                    groupValue: _value,
                    activeColor: Theme.of(context).colorScheme.secondary,
                    fillColor: MaterialStateProperty.resolveWith((states) => getColor(states)),
                    onChanged: (value) {
                      setState(() {
                        _value = value.toString();
                        mixpanel!.track('user_profile_settings_language', properties: {
                          'value' : _value
                        });
                        Provider.of<LanguageProvider>(context, listen: false).setLocale(allLocales[0]);
                        currentUser.idioma = Provider.of<LanguageProvider>(context, listen: false).idioma!.languageCode;
                        _userDataService.updateCurrentUserSettingsPerifl(currentUser.isPrivate!, currentUser.idioma!);
                      });
                    },
                  ),
                  trailing:Text(
                    "ES",
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold, color: _value == "es" ? Theme.of(context).colorScheme.secondary : Theme.of(context).primaryColor),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.04),
                ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.only(left: 0.0, right: 16.0),
                  title: Text(
                    "Català",
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: null,
                  leading: Radio(
                    value: "ca",
                    groupValue: _value,
                    activeColor: Theme.of(context).colorScheme.secondary,
                    fillColor: MaterialStateProperty.resolveWith((states) => getColor(states)),
                    onChanged: (value) {
                      setState(() {
                        _value = value.toString();
                        mixpanel!.track('user_profile_settings_language', properties: {
                          'value' : _value
                        });
                        Provider.of<LanguageProvider>(context, listen: false).setLocale(allLocales[1]);
                        currentUser.idioma = Provider.of<LanguageProvider>(context, listen: false).idioma!.languageCode;
                        _userDataService.updateCurrentUserSettingsPerifl(currentUser.isPrivate!, currentUser.idioma!);
                      });
                    },
                  ),
                  trailing:Text(
                    "CA",
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold, color: _value == "ca" ? Theme.of(context).colorScheme.secondary : Theme.of(context).primaryColor),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.04),
                /*
                ListTile(
                  dense: false,
                  contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                  title: Text(
                    "English",
                    style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: null,
                  leading: Radio(
                    value: "en",
                    groupValue: _value,
                    activeColor: Theme.of(context).colorScheme.secondary,
                    fillColor: MaterialStateProperty.resolveWith((states) => getColor(states)),
                    onChanged: (value) {
                      setState(() {
                        _value = value.toString();
                        mixpanel!.track('user_profile_settings_language', properties: {
                          'value' : _value
                        });
                        Provider.of<LanguageProvider>(context, listen: false).setLocale(allLocales[2]);
                        currentUser.idioma = Provider.of<LanguageProvider>(context, listen: false).idioma!.languageCode;
                        _userDataService.updateCurrentUserSettingsPerifl(currentUser.isPrivate!, currentUser.idioma!);
                      });
                    },
                  ),
                  trailing:Text(
                    "EN",
                    style: Theme.of(context).textTheme.headline1?.copyWith(fontWeight: FontWeight.bold, color: _value == "ca" ? Theme.of(context).colorScheme.secondary : Theme.of(context).primaryColor),
                  ),
                ),
                 */
                SizedBox(height: MediaQuery.of(context).size.height*0.04),
              ],
            ),
          )
      ),
    );
  }
}
