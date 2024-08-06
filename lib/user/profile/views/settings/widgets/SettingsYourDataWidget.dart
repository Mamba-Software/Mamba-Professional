import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/utils/Date/DateTimeUtils.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/data/Models/Usuario.dart';
import 'package:mamba/commons/widgets/loading/LoadingView.dart';
import 'package:mamba/user/bloc/user_bloc.dart';
import 'package:mamba/user/mixin/user.dart';
import 'package:mamba/user/profile/views/Settings/SettingsEditPhotoPage.dart';
import 'package:mamba/user/profile/views/settings/widgets/birthDayWidget.dart';
import 'package:mamba/user/profile/views/settings/widgets/genderWidget.dart';

// Tus Datos Widget.
class SettingsYourDataWidget extends StatefulWidget {
  final Usuario user;
  const SettingsYourDataWidget({super.key, required this.user});

  @override
  _SettingsYourDataWidgetState createState() => _SettingsYourDataWidgetState();
}

class _SettingsYourDataWidgetState extends State<SettingsYourDataWidget>
    with UserBlocMixin {
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
  //final _genderKey = GlobalKey<_GenderWidgetState>();
  // Date of Birth
  DateTime startDateLocal = DateTime.now();
  TextEditingController startDateController = TextEditingController();
  // Boolean isUpdated
  bool isUpdated = false;
  // Provider
  bool isGoogle = false;
  bool isApple = false;

  Usuario user = Usuario();

  @override
  void initState() {
    user = widget.user;
    mixpanel!.track('user_profile_settings_edit_info');
    initGoogleLogIn();
    super.initState();
  }

  // Navigate to EditPhotoPage Screen
  Future<void> navigateToEditPhotoPageScreen() async {
    await Navigator.push(
        context,
        CupertinoPageRoute<String>(
          builder: (context) => const SettingsEditPhotoPage(),
        )).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> initGoogleLogIn() async {
    User? firebaseUser = await _userDataService.getCurrentUser();
    try {
      if (firebaseUser!.providerData[0].providerId == "google.com") {
        isGoogle = true;
      } else if (firebaseUser.providerData[0].providerId == "apple.com") {
        isApple = true;
      }
    } catch (e) {
      isGoogle = false;
      isApple = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Initialises some data the first time that the Widget is build and data is Loaded.
    if (firstBuild) {
      firstNameController = TextEditingController(text: user.firstName);
      lastNameController = TextEditingController(text: user.lastName);
      startDateController = TextEditingController(text: user.dateOfBirth);
      firstBuild = false;
    }
    // Checking if there has been a change that has not been saved.
    if (!isLoading) {
      if (firstNameController.text.trim() != user.lastName! &&
          firstNameControllerTemp != "") {
        isUpdated = true;
        mixpanel!.track('user_profile_settings_edit_info_name_change');
      } else if (lastNameController.text.trim() != user.firstName! &&
          lastNameControllerTemp != "") {
        isUpdated = true;
        mixpanel!.track('user_profile_settings_edit_info_surname_change');
      } else if (genderTemp != user.gender! && genderTemp != null) {
        isUpdated = true;
        mixpanel!.track('user_profile_settings_edit_info_gender_change');
      } else if (startDateController.text != user.dateOfBirth) {
        mixpanel!.track('user_profile_settings_edit_info_birthdate_change');
        isUpdated = true;
      } else {
        isUpdated = false;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.myData,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: MediaQuery.of(context).size.width * 0.06,
          ),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: isLoading
          ? LoadingView()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                    vertical: MediaQuery.of(context).size.width * 0.07),
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
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                context.l10n.firstName,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                textAlign: TextAlign.left,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.01),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Material(
                                                    elevation: 4,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                    child: TextFormField(
                                                      controller:
                                                          firstNameController,
                                                      keyboardType:
                                                          TextInputType.name,
                                                      validator: (val) => val!
                                                              .isEmpty
                                                          ? context.l10n
                                                              .nameCompletoError
                                                          : null,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          firstNameControllerTemp =
                                                              value;
                                                        });
                                                      },
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .words,
                                                      decoration:
                                                          InputDecoration(
                                                              hintText: context
                                                                  .l10n
                                                                  .nameCompletoError,
                                                              hintStyle: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodySmall,
                                                              errorStyle: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.copyWith(
                                                                      color: AppColors
                                                                          .red),
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderSide: const BorderSide(
                                                                    color: Colors
                                                                        .transparent,
                                                                    width: 1.5),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15.0),
                                                              ),
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: const BorderSide(
                                                                    color: Colors
                                                                        .transparent,
                                                                    width: 1.5),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15.0),
                                                              ),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: const BorderSide(
                                                                    color: Colors
                                                                        .transparent,
                                                                    width: 1.5),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15.0),
                                                              ),
                                                              errorBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: const BorderSide(
                                                                    color: Colors
                                                                        .transparent,
                                                                    width: 1.5),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15.0),
                                                              ),
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .fromLTRB(
                                                                      12,
                                                                      8,
                                                                      12,
                                                                      8)),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.04),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                context.l10n.lastName,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                textAlign: TextAlign.left,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.01),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.85,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Material(
                                                    elevation: 4,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                    child: TextFormField(
                                                      controller:
                                                          lastNameController,
                                                      keyboardType:
                                                          TextInputType.name,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          lastNameControllerTemp =
                                                              value;
                                                        });
                                                      },
                                                      validator: (val) =>
                                                          val!.isEmpty
                                                              ? context.l10n
                                                                  .lastNameError
                                                              : null,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium,
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .words,
                                                      decoration:
                                                          InputDecoration(
                                                              hintText: context
                                                                  .l10n
                                                                  .lastNameError,
                                                              hintStyle: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodySmall,
                                                              errorStyle: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.copyWith(
                                                                      color: AppColors
                                                                          .red),
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderSide: const BorderSide(
                                                                    color: Colors
                                                                        .transparent,
                                                                    width: 1.5),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15.0),
                                                              ),
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: const BorderSide(
                                                                    color: Colors
                                                                        .transparent,
                                                                    width: 1.5),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15.0),
                                                              ),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: const BorderSide(
                                                                    color: Colors
                                                                        .transparent,
                                                                    width: 1.5),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15.0),
                                                              ),
                                                              errorBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: const BorderSide(
                                                                    color: Colors
                                                                        .transparent,
                                                                    width: 1.5),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15.0),
                                                              ),
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .fromLTRB(
                                                                      12,
                                                                      8,
                                                                      12,
                                                                      8)),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.04),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Material(
                                        elevation: 4,
                                        shape: const CircleBorder(),
                                        child: CircularImage(
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          image: user.imageUrl,
                                          borderWidth: 1,
                                          color: AppColors.grey,
                                        ),
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.02),
                                      FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              context.l10n.editYourPhoto,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.005),
                                            Icon(
                                              Icons.edit,
                                              size: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                context.l10n.email,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.01),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Flexible(
                                    child: Material(
                                      elevation: 4,
                                      borderRadius: BorderRadius.circular(15.0),
                                      child: TextFormField(
                                        initialValue: user.email,
                                        readOnly: true,
                                        enabled: false,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        textAlign: TextAlign.start,
                                        decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            hintText:
                                                context.l10n.lastNameError,
                                            hintStyle: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                            errorStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                    color: AppColors.red),
                                            suffixIcon: FittedBox(
                                              fit: BoxFit.contain,
                                              child: SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05,
                                                width: isGoogle || isApple
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.07
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.05,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Icon(
                                                      Icons.lock_outlined,
                                                      color: AppColors.grey,
                                                      size:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.025,
                                                    ),
                                                    isGoogle || isApple
                                                        ? SizedBox(
                                                            width: isGoogle
                                                                ? MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.023
                                                                : MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.018,
                                                            child: Image(
                                                                image: isGoogle
                                                                    ? AssetImage(
                                                                        Assets
                                                                            .google)
                                                                    : AssetImage(
                                                                        Assets
                                                                            .apple)),
                                                          )
                                                        : Container(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            border: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.transparent,
                                                  width: 1.5),
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.transparent,
                                                  width: 1.5),
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            disabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.transparent,
                                                  width: 1.5),
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.transparent,
                                                  width: 1.5),
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.transparent,
                                                  width: 1.5),
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.fromLTRB(
                                                    12, 8, 12, 8)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.04),
                            ],
                          ),
                          BirthDayWidget(
                            user: user,
                            selectStartDateChanged: (parStartDateLocale) {
                              setState(() {
                                startDateLocal = parStartDateLocale;
                                startDateController.text = DateTimeUtils()
                                    .formatDateTimeToStringDDMMMMYYYY(
                                        startDateLocal,
                                        Localizations.localeOf(context)
                                            .languageCode);
                              });
                            },
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                context.l10n.gender,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.01),
                              GenderWidget(
                                //key: _genderKey,
                                user: user,
                                selectedGenderChanged: (gender) {
                                  setState(() {
                                    genderTemp = gender;
                                  });
                                },
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.04),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: isUpdated
          ? Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
              child: FloatingActionButton.extended(
                shape: const StadiumBorder(),
                heroTag: "61",
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (isUpdated) {
                      if (firstNameController.text.isNotEmpty) {
                        user.firstName = firstNameController.text;
                      }
                      if (lastNameController.text.isNotEmpty) {
                        user.lastName = lastNameController.text;
                      }
                      if (!(genderTemp == null)) {
                        user.gender = genderTemp;
                      }
                      if (startDateController.text != user.dateOfBirth) {
                        startDateController.text = DateTimeUtils()
                            .formatDateTimeToStringDDMMYYYY(startDateLocal,
                                Localizations.localeOf(context).languageCode);
                        user.dateOfBirth = startDateController.text;
                      }
                      user.name = "${user.firstName!} ${user.lastName!}";
                      await _userDataService.updateCurrentUserDatosPerifl(
                          user.name!,
                          user.firstName!,
                          user.lastName!,
                          user.gender!,
                          user.dateOfBirth!);
                      mixpanel!
                          .track('user_profile_settings_edit_info_completed');
                    }
                    Navigator.pop(context);
                  }
                },
                backgroundColor: Colors.green,
                icon: Icon(
                  Icons.save_rounded,
                  color: Colors.white,
                  size: MediaQuery.of(context).size.width * 0.05,
                ),
                label: Text(
                  context.l10n.save,
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
