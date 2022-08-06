import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingViewPurple.dart';

class SettingsPrivacy extends StatefulWidget {
  const SettingsPrivacy({Key? key}) : super(key: key);

  @override
  _SettingsPrivacyState createState() => _SettingsPrivacyState();
}

class _SettingsPrivacyState extends State<SettingsPrivacy> {

  // Acceso a Base de Datos
  var _userDataService = new UserDataService();
  // Boolean Loading
  bool isLoading = false;
  // Boolean isUpdated
  bool isUpdated = false;
  // Type of Users
  int _startValue = currentUser.isPrivate! ? 2 : 1;
  int _value = currentUser.isPrivate! ? 2 : 1;

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Theme.of(context).accentColor;
  }

  @override
  Widget build(BuildContext context) {
    // Checking if there has been a change that has not been saved.
    if (!isLoading) {
      if (_startValue != _value) {
        isUpdated = true;
      } else {
        isUpdated = false;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.typeProfile, style: Theme.of(context).appBarTheme.titleTextStyle,),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: !isLoading ? SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.04),
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                  title: Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.01),
                    child: Text(
                      AppLocalizations.of(context)!.typeProfilePublic,
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.typeProfilePublicDescription,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ),
                    ],
                  ),
                  leading: Radio(
                    value: 1,
                    groupValue: _value,
                    activeColor: Theme.of(context).accentColor,
                    fillColor: MaterialStateProperty.resolveWith((states) => getColor(states)),
                    onChanged: (value) {
                      setState(() {
                        _value = int.parse(value.toString());
                      });
                    },
                  ),
                  trailing: Icon(
                    Icons.visibility_outlined,
                    size: 30,
                    color: _value == 1 ? Theme.of(context).accentColor : Theme.of(context).primaryColor,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        height: MediaQuery.of(context).size.height*0.20,
                        child: Image.asset(Constants.publicProfileImage)
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.04),
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                  title: Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.01),
                    child: Text(
                      AppLocalizations.of(context)!.typeProfilePrivate,
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.typeProfilePrivateDescription,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ),
                    ],
                  ),
                  leading: Radio(
                    value: 2,
                    groupValue: _value,
                    activeColor: Theme.of(context).accentColor,
                    fillColor: MaterialStateProperty.resolveWith((states) => getColor(states)),
                    onChanged: (value) {
                      setState(() {
                        _value = int.parse(value.toString());
                      });
                    },
                  ),
                  trailing: Icon(
                    Icons.visibility_off_outlined,
                    size: 30,
                    color: _value == 2 ? Theme.of(context).accentColor : Theme.of(context).primaryColor,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        height: MediaQuery.of(context).size.height*0.20,
                        child: Image.asset(Constants.privateProfileImage)
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.04),
              ],
            ),
          )
      ) : LoadingViewPurple(),
      floatingActionButton: isUpdated ? Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
        child: FloatingActionButton.extended(
          heroTag: "82",
          onPressed: () async {
            setState(() {
              isLoading = true;
            });
            bool isPrivate = false;
            if (_value == 1) {
              isPrivate = false;
            } else {
              isPrivate = true;
            }
            currentUser.isPrivate = isPrivate;
            await _userDataService.updateCurrentUserSettingsPerifl(currentUser.isPrivate!, currentUser.idioma!);
            Future.delayed(const Duration(milliseconds: 500), () {
              Navigator.pop(context);
            });
          },
          backgroundColor: Colors.green,
          icon: Icon(Icons.save_rounded, color: Colors.white, size: MediaQuery.of(context).size.width*0.05,),
          label: Text(AppLocalizations.of(context)!.save,
            style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.white),),
        ),
      ) : Container(),
    );
  }
}
