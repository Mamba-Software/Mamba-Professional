import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:mamba_castelldefels/data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/commons/constants/constants.dart';
import 'package:mamba_castelldefels/commons/constants/GlobalVars.dart';
import 'package:mamba_castelldefels/app/theme/ThemeProvider.dart';
import 'package:mamba_castelldefels/commons/widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:provider/provider.dart';

class SettingsTheme extends StatefulWidget {
  const SettingsTheme({super.key});

  @override
  _SettingsPrivacyState createState() => _SettingsPrivacyState();
}

class _SettingsPrivacyState extends State<SettingsTheme> {
  // Acceso a Base de Datos
  final _userDataService = UserDataService();
  // Boolean Loading
  bool isLoading = false;
  // Boolean isUpdated
  bool isUpdated = false;
  // Type of Users
  int _startValue = 0;
  int _value = 0;
  // Theme Provider
  var themeProvider;

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
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    if (currentUser.isDark != null) {
      if (currentUser.isDark!) {
        _startValue = 2;
        _value = 2;
      } else {
        _startValue = 1;
        _value = 1;
      }
    } else {
      _startValue = 3;
      _value = 3;
    }
    super.initState();
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
        title: Text(
          AppLocalizations.of(context)!.typeTheme,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: MediaQuery.of(context).size.width * 0.06,
          ),
          onPressed: () {
            if (isUpdated) {
              setState(() {
                isLoading = true;
              });
              if (_startValue == 1) {
                themeProvider.toggleTheme(false);
              } else if (_startValue == 2) {
                themeProvider.toggleTheme(true);
              } else if (_startValue == 3) {
                final brightness =
                    SchedulerBinding.instance.window.platformBrightness;
                if (brightness == Brightness.dark) {
                  themeProvider.toggleTheme(true);
                } else {
                  themeProvider.toggleTheme(false);
                }
              }
              Future.delayed(const Duration(milliseconds: 500), () {
                Navigator.pop(context);
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: !isLoading
          ? SingleChildScrollView(
              child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.only(left: 0.0, right: 0.0),
                    title: Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.01),
                      child: Text(
                        AppLocalizations.of(context)!.typeThemeLight,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!
                                .typeThemeLightDescription,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    leading: Radio(
                      value: 1,
                      groupValue: _value,
                      activeColor: Theme.of(context).colorScheme.secondary,
                      fillColor: MaterialStateProperty.resolveWith(
                          (states) => getColor(states)),
                      onChanged: (value) {
                        setState(() {
                          _value = int.parse(value.toString());
                        });
                        themeProvider.toggleTheme(false);
                      },
                    ),
                    trailing: Icon(
                      Icons.light_mode_outlined,
                      size: 30,
                      color: _value == 1
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.13,
                          child: Image.asset(Constants.themeLightImage)),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.only(left: 0.0, right: 0.0),
                    title: Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.01),
                      child: Text(
                        AppLocalizations.of(context)!.typeThemeDark,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!
                                .typeThemeDarkDescription,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    leading: Radio(
                      value: 2,
                      groupValue: _value,
                      activeColor: Theme.of(context).colorScheme.secondary,
                      fillColor: MaterialStateProperty.resolveWith(
                          (states) => getColor(states)),
                      onChanged: (value) {
                        setState(() {
                          _value = int.parse(value.toString());
                        });
                        themeProvider.toggleTheme(true);
                      },
                    ),
                    trailing: Icon(
                      Icons.dark_mode_outlined,
                      size: 30,
                      color: _value == 2
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.13,
                          child: Image.asset(Constants.themeDarkImage)),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.only(left: 0.0, right: 0.0),
                    title: Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.01),
                      child: Text(
                        AppLocalizations.of(context)!.typeThemeSystem,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!
                                .typeThemeSystemDescription,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    leading: Radio(
                      value: 3,
                      groupValue: _value,
                      activeColor: Theme.of(context).colorScheme.secondary,
                      fillColor: MaterialStateProperty.resolveWith(
                          (states) => getColor(states)),
                      onChanged: (value) {
                        setState(() {
                          _value = int.parse(value.toString());
                        });
                        final brightness =
                            SchedulerBinding.instance.window.platformBrightness;
                        if (brightness == Brightness.dark) {
                          themeProvider.toggleTheme(true);
                        } else {
                          themeProvider.toggleTheme(false);
                        }
                      },
                    ),
                    trailing: Icon(
                      Icons.app_settings_alt_outlined,
                      size: 30,
                      color: _value == 3
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.13,
                          child: Image.asset(Constants.themeSystemImage)),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  )
                ],
              ),
            ))
          : LoadingView(),
      floatingActionButton: isUpdated
          ? Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
              child: FloatingActionButton.extended(
                shape: const StadiumBorder(),
                heroTag: "62",
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  bool? isDark;
                  String value = "";
                  if (_value == 1) {
                    isDark = false;
                    value = "Light";
                  } else if (_value == 2) {
                    isDark = true;
                    value = "Dark";
                  } else if (_value == 3) {
                    isDark = null;
                    value = "System";
                  }
                  currentUser.isDark = isDark;
                  await _userDataService.updateUserThemePreferences(
                      currentUser.id!, currentUser.isDark);
                  mixpanel!.track('user_profile_settings_theme_updated',
                      properties: {'value': value});
                  Future.delayed(const Duration(milliseconds: 500), () {
                    Navigator.pop(context);
                  });
                },
                backgroundColor: Colors.green,
                icon: Icon(
                  Icons.save_rounded,
                  color: Colors.white,
                  size: MediaQuery.of(context).size.width * 0.05,
                ),
                label: Text(
                  AppLocalizations.of(context)!.save,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Colors.white),
                ),
              ),
            )
          : Container(),
    );
  }
}
