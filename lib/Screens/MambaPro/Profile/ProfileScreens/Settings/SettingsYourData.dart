import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/Profile/ProfileScreens/Settings/SettingsEditPhotoPage.dart';

// Tus Datos Widget.
class SettingsYourData extends StatefulWidget {
  const SettingsYourData({Key? key}) : super(key: key);

  @override
  _SettingsYourDataState createState() => _SettingsYourDataState();
}

class _SettingsYourDataState extends State<SettingsYourData> {

  // Acceso a Base de Datos
  final _userDataService = UserDataService();
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
    mixpanel!.track('user_profile_settings_edit_info');
    super.initState();
  }

  // Navigate to EditPhotoPage Screen
  Future<void> navigateToEditPhotoPageScreen() async {
    await Navigator.push(
        context,
        CupertinoPageRoute<String>(
          builder: (context) => SettingsEditPhotoPage(),
        )
    ).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> selectSlot(ctx, type) {
    // Initial Vars
    var startDate = DateTime.now();
    var title;
    var widgetPicker;
    // Different types of pickers
    Widget dateTimePicker = CupertinoTheme(
      data: CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
            dateTimePickerTextStyle: Theme.of(context).textTheme.bodyText1,
          )
      ),
      child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: DateTime(startDate.year, startDate.month, startDate.day, 0, 0),
          minimumDate: startDate.subtract(const Duration(days: 365*80)),
          maximumDate: DateTime(startDate.year, startDate.month, 31, 0, 0),
          minimumYear: 1941,
          maximumYear: startDate.year,
          use24hFormat: true,
          onDateTimeChanged: (val) {
            setState(() {
              startDateController.text = DateFormat('dd-MM-yyyy', Localizations.localeOf(context).languageCode).format(val);
            });
          }
      ),
    );
    if (type == 0) {
      title = AppLocalizations.of(context)!.selectDateOfBirth;
      widgetPicker = dateTimePicker;
    }
    showCupertinoModalPopup(
        context: ctx,
        builder: (_) => Material(
          shape: const RoundedRectangleBorder(
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
                        child: Text(title,
                          style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,)
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.01),
                    child: widgetPicker,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: TextButton(
                          child: Text(AppLocalizations.of(context)!.entendido,
                              style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
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
        mixpanel!.track('user_profile_settings_edit_info_name_change');
      } else if (lastNameController.text.trim() != currentUser.firstName! && lastNameControllerTemp != "") {
        isUpdated = true;
        mixpanel!.track('user_profile_settings_edit_info_surname_change');
      } else if (genderTemp != currentUser.gender! && genderTemp != null) {
        isUpdated = true;
        mixpanel!.track('user_profile_settings_edit_info_gender_change');
      } else if (startDateController.text != currentUser.dateOfBirth) {
        mixpanel!.track('user_profile_settings_edit_info_birthdate_change');
        isUpdated = true;
      } else {
        isUpdated = false;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myData, style: Theme.of(context).appBarTheme.titleTextStyle,),
        centerTitle: true,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: isLoading ?
        LoadingView()
          :
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: Column(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.45,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!.firstName,
                                            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.45,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller: firstNameController,
                                                keyboardType: TextInputType.name,
                                                validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.nameCompletoError : null,
                                                style: Theme.of(context).textTheme.bodyText2,
                                                onChanged: (value) {
                                                  setState(() {
                                                    firstNameControllerTemp = value;
                                                  });
                                                },
                                                textCapitalization: TextCapitalization.words,
                                                decoration: InputDecoration(
                                                  hintText: AppLocalizations.of(context)!.nameCompletoError,
                                                  hintStyle: Theme.of(context).textTheme.caption,
                                                  errorStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                                  border: UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Theme.of(context).primaryColor,
                                                          width: 1.0
                                                      )
                                                  ),
                                                  enabledBorder: UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Theme.of(context).primaryColor,
                                                          width: 1.0
                                                      )
                                                  ),
                                                  focusedBorder: UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Theme.of(context).primaryColor,
                                                          width: 1.0
                                                      )
                                                  ),
                                                  errorBorder: const UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.red,
                                                          width: 1.0
                                                      )
                                                  ),
                                                  disabledBorder: InputBorder.none,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: MediaQuery.of(context).size.height*0.04),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.6,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!.lastName,
                                            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.85,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller: lastNameController,
                                                keyboardType: TextInputType.name,
                                                onChanged: (value) {
                                                  setState(() {
                                                    lastNameControllerTemp = value;
                                                  });
                                                },
                                                validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.lastNameError : null,
                                                style: Theme.of(context).textTheme.bodyText2,
                                                textCapitalization: TextCapitalization.words,
                                                decoration: InputDecoration(
                                                  hintStyle: Theme.of(context).textTheme.caption,
                                                  hintText: AppLocalizations.of(context)!.lastNameError,
                                                  errorStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                                  border: UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Theme.of(context).primaryColor,
                                                          width: 1.0
                                                      )
                                                  ),
                                                  enabledBorder: UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Theme.of(context).primaryColor,
                                                          width: 1.0
                                                      )
                                                  ),
                                                  focusedBorder: UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Theme.of(context).primaryColor,
                                                          width: 1.0
                                                      )
                                                  ),
                                                  errorBorder: const UnderlineInputBorder(
                                                      borderSide: const BorderSide(
                                                          color: Colors.red,
                                                          width: 1.0
                                                      )
                                                  ),
                                                  disabledBorder: InputBorder.none,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: MediaQuery.of(context).size.height*0.04),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Center(
                                child: GestureDetector(
                                  onTap: navigateToEditPhotoPageScreen,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      CircularImage(
                                        size: MediaQuery.of(context).size.width * 0.3,
                                        image: currentUser.imageUrl,
                                        borderWidth: 1,
                                        color: AppColors.grey,
                                      ),
                                      SizedBox(height: MediaQuery.of(context).size.width*0.02),
                                      FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!.editYourPhoto,
                                              style: Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).primaryColor),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(width: MediaQuery.of(context).size.width*0.005),
                                            Icon(Icons.edit, size: MediaQuery.of(context).size.width*0.04, color: Theme.of(context).primaryColor,),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                            ),
                          ),
                        ],
                      ),
                      /*
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.18,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: GestureDetector(
                            onTap: navigateToEditPhotoPageScreen,
                            child: CircularImage(
                              size: MediaQuery.of(context).size.height * 0.18,
                              image: currentUser.imageUrl!,
                              borderWidth: 1,
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context)!.firstName,
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Flexible(
                            child: TextFormField(
                              controller: firstNameController,
                              textCapitalization: TextCapitalization.words,
                              onChanged: (value) {
                                setState(() {
                                  firstNameControllerTemp = value;
                                });
                              },
                              style: Theme.of(context).textTheme.bodyText2,
                              validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.nameCompletoError : null,
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!.nameCompletoError,
                                hintStyle: Theme.of(context).textTheme.caption,
                                enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey)
                                ),
                                focusedBorder: const UnderlineInputBorder(
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
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Flexible(
                            child: TextFormField(
                              controller: lastNameController,
                              textCapitalization: TextCapitalization.words,
                              onChanged: (value) {
                                setState(() {
                                  lastNameControllerTemp = value;
                                });
                              },
                              style: Theme.of(context).textTheme.bodyText2,
                              validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.lastNameError : null,
                              decoration: InputDecoration(
                                hintStyle: Theme.of(context).textTheme.caption,
                                hintText: AppLocalizations.of(context)!.lastNameError,
                                enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey)
                                ),
                                focusedBorder: const UnderlineInputBorder(
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
                                style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(width: MediaQuery.of(context).size.height*0.01),
                              Padding(
                                padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.005),
                                child: Icon(Icons.lock_outline, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.05,),
                              )
                            ],
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Flexible(
                            child: TextFormField(
                              style: Theme.of(context).textTheme.bodyText2,
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
                                style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: MediaQuery.of(context).size.height*0.01),
                              Padding(
                                padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.005),
                                child: Icon(Icons.lock_outline, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.05,),
                              )
                            ],
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Flexible(
                            child: TextFormField(
                              style: Theme.of(context).textTheme.bodyText2,
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!.email,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              initialValue: currentUser.email!,
                              enabled: false,
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.04),
                        ],
                      ),
                       */
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context)!.dateOfBirth,
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
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
                                  Flexible(
                                    child: TextFormField(
                                      controller: startDateController,
                                      readOnly: true,
                                      enabled: false,
                                      decoration: InputDecoration(
                                        border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).primaryColor,
                                                width: 1.0
                                            )
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).primaryColor,
                                                width: 1.0
                                            )
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).primaryColor,
                                                width: 1.0
                                            )
                                        ),
                                        errorBorder: const UnderlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.red,
                                                width: 1.0
                                            )
                                        ),
                                        disabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context).primaryColor,
                                                width: 1.0
                                            )
                                        ),
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context)!.gender,
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
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
          heroTag: "61",
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              if (isUpdated) {
                if (firstNameController.text.isNotEmpty) {
                  currentUser.firstName = firstNameController.text;
                }
                if (lastNameController.text.isNotEmpty) {
                  currentUser.lastName = lastNameController.text;
                }
                if (!(genderTemp == null)) {
                  currentUser.gender = genderTemp;
                }
                if (startDateController.text != currentUser.dateOfBirth) {
                  currentUser.dateOfBirth = startDateController.text;
                }
                currentUser.name = currentUser.firstName!+" "+currentUser.lastName!;
                _userDataService.updateCurrentUserDatosPerifl(currentUser.name!, currentUser.firstName!, currentUser.lastName!, currentUser.gender!, currentUser.dateOfBirth!);
                mixpanel!.track('user_profile_settings_edit_info_completed');
              }
              Navigator.pop(context);
            }
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

  resetGender() => gender = widget.user!.gender!;

  @override
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
        size: Size(MediaQuery.of(context).size.width*0.25, MediaQuery.of(context).size.width*0.25), // button width and height
        child: ClipOval(
          child: Material(
            color: gender == index ? Theme.of(context).colorScheme.secondary : Theme.of(context).scaffoldBackgroundColor,
            child: InkWell(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 30,
                      color: gender == index ? AppColors.white : Theme.of(context).primaryColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                          text,
                          style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold, color: gender == index ? AppColors.white : Theme.of(context).primaryColor)
                      ),
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


