import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';

// Tus Datos Widget.
class TusDatos extends StatefulWidget {
  const TusDatos({Key? key}) : super(key: key);

  @override
  _TusDatosState createState() => _TusDatosState();
}

class _TusDatosState extends State<TusDatos> {

  // Acceso a Base de Datos
  var _userDataService = new UserDataService();
  // Boolean Loading
  bool isLoading = false;
  bool firstBuild = true;
  // Form Values
  final _formKey = GlobalKey<FormState>();
  var firstNameController;
  var lastNameController;
  String firstNameControllerTemp = "";
  String lastNameControllerTemp = "";
  // Gender Widget value
  int? genderTemp;
  final _genderKey = GlobalKey<_GenderWidgetState>();
  // Date of Birth
  TextEditingController startDateController = TextEditingController();
  // Boolean isUpdated
  bool isUpdated = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> selectSlot(ctx, type) {
    // Initial Vars
    var maxDate = DateTime.now();
    var startDate = DateTime.now();
    var title;
    var widgetPicker;
    if (type == 0) {
      startDate = DateFormat('dd-MM-yyyy', Localizations.localeOf(context).languageCode).parse(startDateController.text);
    }
    // Different types of pickers
    Widget dateTimePicker = CupertinoDatePicker(
        mode: CupertinoDatePickerMode.date,
        initialDateTime: DateTime(startDate.year, startDate.month, startDate.day, 0, 0),
        minimumDate: startDate.subtract(Duration(days: 365*80)),
        maximumDate: DateTime(maxDate.year, maxDate.month, 31, 0, 0),
        minimumYear: 1941,
        maximumYear: 2021,
        use24hFormat: true,
        onDateTimeChanged: (val) {
          setState(() {
            startDateController.text = DateFormat('dd-MM-yyyy', Localizations.localeOf(context).languageCode).format(val);
          });
        }
    );

    if (type == 0) {
      title = AppLocalizations.of(context)!.selectDateOfBirth;
      widgetPicker = dateTimePicker;
    }
    showCupertinoModalPopup(
        context: ctx,
        builder: (_) => Material(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height*0.40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        child: Text(title, style:  Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.center,)
                    ),
                  ],
                ),
                Expanded(
                    child: widgetPicker
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: TextButton(
                          child: Text(AppLocalizations.of(context)!.entendido, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          }
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.02),
              ],
            ),
          ),
        )
    );
    return Future.value("");
  }

  @override
  Widget build(BuildContext context) {
    // Initialises some data the first time that the Widget is build and data is Loaded.
    if (firstBuild) {
      firstNameController = TextEditingController(text: currentUser.firstName);
      lastNameController = TextEditingController(text: currentUser.lastName);
      startDateController = TextEditingController(text: currentUser.dateOfBirth);
      firstBuild = false;
    }
    // Checking if there has been a change that has not been saved.
    if (!isLoading) {
      if (firstNameController.text.trim() != currentUser.lastName! && firstNameControllerTemp != "") {
        isUpdated = true;
      } else if (lastNameController.text.trim() != currentUser.firstName! && lastNameControllerTemp != "") {
        isUpdated = true;
      } else if (genderTemp != currentUser.gender! && genderTemp != null) {
        isUpdated = true;
      } else if (startDateController.text != currentUser.dateOfBirth) {
        isUpdated = true;
      } else {
        isUpdated = false;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.yourInfo, style: Theme.of(context).appBarTheme.titleTextStyle,),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 25,),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: isLoading ?
        LoadingViewPurple()
          :
        SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.width*0.07),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context)!.firstName,
                            style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Flexible(
                            child: new TextFormField(
                              controller: firstNameController,
                              textCapitalization: TextCapitalization.words,
                              onChanged: (value) {
                                setState(() {
                                  firstNameControllerTemp = value;
                                });
                              },
                              validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.nameCompletoError : null,
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!.nameCompletoError,
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.04),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context)!.lastName,
                            style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Flexible(
                            child: new TextFormField(
                              controller: lastNameController,
                              textCapitalization: TextCapitalization.words,
                              onChanged: (value) {
                                setState(() {
                                  lastNameControllerTemp = value;
                                });
                              },
                              validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.lastNameError : null,
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!.lastNameError,
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey)
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.04),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.nickname,
                                style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(width: MediaQuery.of(context).size.height*0.01),
                              Padding(
                                padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.005),
                                child: Icon(Icons.lock_outline, color: Theme.of(context).primaryColor, size: 20,),
                              )
                            ],
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Flexible(
                            child: new TextFormField(
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!.nickname,
                              ),
                              initialValue: "@${currentUser.nick!}",
                              enabled: false,
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.04),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.email,
                                style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: MediaQuery.of(context).size.height*0.01),
                              Padding(
                                padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.005),
                                child: Icon(Icons.lock_outline, color: Theme.of(context).primaryColor, size: 20,),
                              )
                            ],
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Flexible(
                            child: new TextFormField(
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!.email,
                              ),
                              initialValue: currentUser.email!,
                              enabled: false,
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.04),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context)!.gender,
                            style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          GenderWidget(
                            key: _genderKey,
                            user: currentUser,
                            selectedGenderChanged: (gender) {
                              setState(() {
                                genderTemp = gender;
                              });
                            },
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.04),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context)!.dateOfBirth,
                            style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          GestureDetector(
                              onTap: () {
                                selectSlot(context, 0);
                                FocusScopeNode currentFocus = FocusScope.of(context);
                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Flexible(
                                    child: TextFormField(
                                      controller: startDateController,
                                      readOnly: true,
                                      enabled: false,
                                      //style: startDateController.text == nullDate ? Theme.of(context).textTheme.headline1!.copyWith(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w300) : Theme.of(context).textTheme.headline1!.copyWith(fontSize: 18, fontWeight: FontWeight.w300),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              )
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.04),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      floatingActionButton: isUpdated ? Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
        child: FloatingActionButton.extended(
          heroTag: "82",
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              if (isUpdated) {
                if (firstNameController.text.isNotEmpty) {
                  currentUser.firstName = firstNameController.text;
                };
                if (lastNameController.text.isNotEmpty) {
                  currentUser.lastName = lastNameController.text;
                };
                if (!(genderTemp == null)) {
                  currentUser.gender = genderTemp;
                };
                if (startDateController.text != currentUser.dateOfBirth) {
                  currentUser.dateOfBirth = startDateController.text;
                };
                setState(() {
                  isLoading = true;
                });
                currentUser.name = currentUser.firstName!+" "+currentUser.lastName!;
                await _userDataService.updateCurrentUserDatosPerifl(currentUser.name!, currentUser.firstName!, currentUser.lastName!, currentUser.gender!, currentUser.dateOfBirth!);
              }
              await Future.delayed(const Duration(seconds: 1));
              Navigator.pop(context);
            }
          },
          backgroundColor: Colors.green,
          icon: Icon(Icons.save_rounded, color: Colors.white,),
          label: Text(AppLocalizations.of(context)!.save,
            style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),),
        ),
      ) : Container(),
    );
  }
}

class GenderWidget extends StatefulWidget {
  final ValueChanged<int> selectedGenderChanged;
  final Usuario? user;
  GenderWidget({required Key key, required this.selectedGenderChanged, required this.user}) : super(key: key);

  @override
  _GenderWidgetState createState() => _GenderWidgetState();
}

class _GenderWidgetState extends State<GenderWidget> {
  bool firstBuild = true;
  var gender;

  @override
  resetGender() => gender = widget.user!.gender!;
  Widget build(BuildContext context) {
    if (firstBuild) {
      gender = widget.user!.gender!;
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
    return SizedBox.fromSize(
        size: Size(90, 90), // button width and height
        child: ClipOval(
          child: Material(
            color: gender == index ? Theme.of(context).accentColor : Theme.of(context).scaffoldBackgroundColor,
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
                    gender = index;
                    widget.selectedGenderChanged(gender);
                  }),
                },
            ),
          ),
        ),
      );
  }

}


