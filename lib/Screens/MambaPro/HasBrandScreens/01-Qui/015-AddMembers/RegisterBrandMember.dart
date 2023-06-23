import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Date/DateTimeUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:percent_indicator/percent_indicator.dart';


class RegisterBrandMember extends StatefulWidget {
  final bool isTrainer;
  const RegisterBrandMember({Key? key, required this.isTrainer}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RegisterBrandMemberState();
}

class _RegisterBrandMemberState extends State<RegisterBrandMember> with SingleTickerProviderStateMixin{

  // Booleans
  bool isLoading = false;
  String? isRecurrentLoadingText;
  // Tab Controller
  double addEventTabValue = 0.2499;
  TabController? _tabController;
  int _selectedIndex = 0;
  // Name Controller
  final formKeyInfo = GlobalKey<FormState>();
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  FocusNode focusNodeName = FocusNode();
  // Date Of Birth
  DateTime startDate = DateTime.now();
  var dayController = TextEditingController();
  var monthController = TextEditingController();
  var yearController = TextEditingController();
  FocusNode focusNodeMonth = FocusNode();
  FocusNode focusNodeYear = FocusNode();
  bool canGoNextDate = false;
  bool confirmAge = false;
  bool loadingAge = false;
  bool errorAge = false;
  // Gender Widget value
  int? gender;
  // Email
  var emailController = TextEditingController();
  bool invalidEmail = false;
  bool loadingEmail = false;
  FocusNode focusNodeFirstName = FocusNode();
  FocusNode focusNodeEmail = FocusNode();
  bool canGoNextEmail = false;

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  DateTime? convertToDate(String input, String format, BuildContext context) {
    try {
      final DateTime d = DateFormat(format, Localizations.localeOf(context).languageCode).parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  // Validate email and pwd format
  bool emailValidator(String value) {
    Pattern pattern = r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern.toString());
    if (!regex.hasMatch(value)) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height*0.08,
        title: Text(
          AppLocalizations.of(context)!.addClientsManually.split(" ")[0]+" "+(!widget.isTrainer ? AppLocalizations.of(context)!.client : AppLocalizations.of(context)!.staff),
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: IgnorePointer(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.width*0.03),
                LinearProgressIndicator(
                  value: addEventTabValue,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ),
        ),
      ),
      body: LoadingView(
          text: isRecurrentLoadingText
      ),
    ) : Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height*0.08,
        title: Text(
          AppLocalizations.of(context)!.addClientsManually.split(" ")[0]+" "+(!widget.isTrainer ? AppLocalizations.of(context)!.client : AppLocalizations.of(context)!.staff).toLowerCase(),
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: IgnorePointer(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.width*0.03),
                LinearProgressIndicator(
                  value: addEventTabValue,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*0.04),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Form(
                    key: formKeyInfo,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.06),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.firstName,
                            style: Theme.of(context).textTheme.headline1,
                            textAlign: TextAlign.left,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  autofocus: true,
                                  controller: firstNameController,
                                  keyboardType: TextInputType.name,
                                  validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.nameCompletoError : null,
                                  onFieldSubmitted: (val) {
                                    if (lastNameController.text.isEmpty) {
                                      focusNodeName.requestFocus();
                                    } else {
                                      focusNodeName.unfocus();
                                    }
                                  },
                                  style: Theme.of(context).textTheme.bodyText2,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: InputDecoration(
                                    hintStyle: Theme.of(context).textTheme.caption,
                                    errorStyle: Theme.of(context).textTheme.caption?.copyWith(color: AppColors.red),
                                    hintText: AppLocalizations.of(context)!.nameCompletoError,
                                    errorBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                    disabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.05),
                          Text(
                            AppLocalizations.of(context)!.lastName,
                            style: Theme.of(context).textTheme.headline1,
                            textAlign: TextAlign.left,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  focusNode: focusNodeName,
                                  controller: lastNameController,
                                  validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.lastNameError : null,
                                  keyboardType: TextInputType.name,
                                  style: Theme.of(context).textTheme.bodyText2,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: InputDecoration(
                                    hintStyle: Theme.of(context).textTheme.caption,
                                    errorStyle: Theme.of(context).textTheme.caption?.copyWith(color: AppColors.red),
                                    hintText: AppLocalizations.of(context)!.lastNameError,
                                    errorBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                    disabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.06),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.dateOfBirth,
                          style: Theme.of(context).textTheme.headline1,
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.02),
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width*0.15,
                              child: Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(15.0),
                                child: TextFormField(
                                  autofocus: true,
                                  controller: dayController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    if (value.length == 2) {
                                      focusNodeMonth.requestFocus();
                                    }
                                    if (errorAge) {
                                      setState(() {
                                        errorAge = false;
                                      });
                                    }
                                    if (confirmAge) {
                                      setState(() {
                                        confirmAge = false;
                                      });
                                    }
                                    if (dayController.text.length == 2 && monthController.text.length == 2 && yearController.text.length == 4) {
                                      setState(() {
                                        canGoNextDate = true;
                                      });
                                    } else {
                                      setState(() {
                                        canGoNextDate = false;
                                      });
                                    }
                                  },
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(2),// for mobile
                                  ],
                                  style: Theme.of(context).textTheme.bodyText2,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Theme.of(context).backgroundColor,
                                      hintText: "DD",
                                      hintStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.grey, fontWeight: FontWeight.normal),
                                      errorStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                      border: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8)
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width*0.02),
                            SizedBox(
                              width: MediaQuery.of(context).size.width*0.15,
                              child: Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(15.0),
                                child: TextFormField(
                                  focusNode: focusNodeMonth,
                                  controller: monthController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    if (value.length == 2) {
                                      focusNodeYear.requestFocus();
                                    }
                                    if (errorAge) {
                                      setState(() {
                                        errorAge = false;
                                      });
                                    }
                                    if (confirmAge) {
                                      setState(() {
                                        confirmAge = false;
                                      });
                                    }
                                    if (dayController.text.length == 2 && monthController.text.length == 2 && yearController.text.length == 4) {
                                      setState(() {
                                        canGoNextDate = true;
                                      });
                                    } else {
                                      setState(() {
                                        canGoNextDate = false;
                                      });
                                    }
                                  },
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(2),// for mobile
                                  ],
                                  style: Theme.of(context).textTheme.bodyText2,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Theme.of(context).backgroundColor,
                                      hintText: "MM",
                                      hintStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.grey, fontWeight: FontWeight.normal),
                                      errorStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                      border: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8)
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width*0.02),
                            SizedBox(
                              width: MediaQuery.of(context).size.width*0.18,
                              child: Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(15.0),
                                child: TextFormField(
                                  focusNode: focusNodeYear,
                                  controller: yearController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    if (errorAge) {
                                      setState(() {
                                        errorAge = false;
                                      });
                                    }
                                    if (confirmAge) {
                                      setState(() {
                                        confirmAge = false;
                                      });
                                    }
                                    if (dayController.text.length == 2 && monthController.text.length == 2 && yearController.text.length == 4) {
                                      setState(() {
                                        canGoNextDate = true;
                                      });
                                    } else {
                                      setState(() {
                                        canGoNextDate = false;
                                      });
                                    }
                                  },
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(4),// for mobile
                                  ],
                                  style: Theme.of(context).textTheme.bodyText2,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Theme.of(context).backgroundColor,
                                      hintText: "YYYY",
                                      hintStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.grey, fontWeight: FontWeight.normal),
                                      errorStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                      border: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8)
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                        errorAge ? Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          decoration: const BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  AppLocalizations.of(context)!.errorDate,
                                  style: Theme.of(context).textTheme.bodyText2,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ) : Container(),
                        AnimatedOpacity(
                          opacity: confirmAge ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.fastOutSlowIn,
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.03),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.dateOfBirth+": ",
                                      style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.left,
                                    ),
                                    Text(
                                      DateTimeUtils().formatDateTimeToStringDDMMYYYY(startDate, Localizations.localeOf(context).languageCode),
                                      style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.normal),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                Row(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.age+": ",
                                      style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.left,
                                    ),
                                    Text(
                                      (DateTime.now().difference(startDate).inDays/365).toStringAsFixed(0),
                                      style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.normal),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.06),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.gender,
                          style: Theme.of(context).textTheme.headline1,
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.02),
                        Material(
                          elevation: 8,
                          borderRadius: BorderRadius.circular(15.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height*0.06,
                            padding: const EdgeInsets.fromLTRB(18, 8, 6, 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Theme.of(context).backgroundColor,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!.female,
                                    style: Theme.of(context).textTheme.bodyText2,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Transform.scale(
                                  scale: 1.3,
                                  child: Checkbox(
                                    value: gender == 1,
                                    onChanged: (boolean) {
                                      setState(() {
                                        gender = 1;
                                      });
                                    },
                                    checkColor: Theme.of(context).primaryColorDark,
                                    activeColor: Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    side: const BorderSide(color: Colors.grey),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.02),
                        Material(
                          elevation: 8,
                          borderRadius: BorderRadius.circular(15.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height*0.06,
                            padding: const EdgeInsets.fromLTRB(18, 8, 6, 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Theme.of(context).backgroundColor,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!.male,
                                    style: Theme.of(context).textTheme.bodyText2,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Transform.scale(
                                  scale: 1.3,
                                  child: Checkbox(
                                    value: gender == 0,
                                    onChanged: (boolean) {
                                      setState(() {
                                        gender = 0;
                                      });
                                    },
                                    checkColor: Theme.of(context).primaryColorDark,
                                    activeColor: Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    side: const BorderSide(color: Colors.grey),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.02),
                        Material(
                          elevation: 8,
                          borderRadius: BorderRadius.circular(15.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height*0.06,
                            padding: const EdgeInsets.fromLTRB(18, 8, 6, 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Theme.of(context).backgroundColor,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!.transgender,
                                    style: Theme.of(context).textTheme.bodyText2,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Transform.scale(
                                  scale: 1.3,
                                  child: Checkbox(
                                    value: gender == 2,
                                    onChanged: (boolean) {
                                      setState(() {
                                        gender = 2;
                                      });
                                    },
                                    checkColor: Theme.of(context).primaryColorDark,
                                    activeColor: Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    side: const BorderSide(color: Colors.grey),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.06),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.email,
                          style: Theme.of(context).textTheme.headline1,
                          textAlign: TextAlign.left,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                autofocus: true,
                                focusNode: focusNodeEmail,
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.emailError : null,
                                onChanged: (val) {
                                  if (emailController.text.isNotEmpty) {
                                    if(emailValidator(emailController.text)){
                                      setState(() {
                                        invalidEmail = false;
                                      });
                                    } else {
                                      setState(() {
                                        invalidEmail = true;
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      invalidEmail = true;
                                    });
                                  }
                                },
                                style: Theme.of(context).textTheme.bodyText2,
                                textCapitalization: TextCapitalization.none,
                                decoration: InputDecoration(
                                  hintStyle: Theme.of(context).textTheme.caption,
                                  errorStyle: Theme.of(context).textTheme.caption?.copyWith(color: AppColors.red),
                                  hintText: AppLocalizations.of(context)!.emailError,
                                  errorBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                  disabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        invalidEmail ? Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(top: 12),
                          decoration: const BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  AppLocalizations.of(context)!.validateEmail,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      ?.copyWith(
                                      color: AppColors.white),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ) : emailController.text.isNotEmpty ? Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(top: 12),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  "Email válido",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      ?.copyWith(
                                      color: AppColors.white),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ) :  Container(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _selectedIndex != 0 ? Padding(
            padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.01, left: MediaQuery.of(context).size.width*0.09),
            child: SizedBox(
              height: 50,
              child: FloatingActionButton.extended(
                heroTag: "97",
                onPressed: () {
                  _tabController!.animateTo(_selectedIndex -= 1);
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus &&
                      currentFocus.focusedChild != null) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                  setState(() {
                    addEventTabValue -= 0.25;
                  });
                },
                backgroundColor: Theme.of(context).primaryColor,
                icon: Container(),
                label: Text(AppLocalizations.of(context)!.back, style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).primaryColorDark),),
              ),
            ),
          ) :  Padding(
            padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.01, left: MediaQuery.of(context).size.width*0.09),
            child: Container(
              height: 50,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.01),
            child: SizedBox(
              height: 50,
              child: FloatingActionButton.extended(
                heroTag: "98",
                onPressed: () async {
                  if (_selectedIndex == 0) {
                    if (formKeyInfo.currentState!.validate()) {
                      _tabController!.animateTo(_selectedIndex += 1);
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus &&
                          currentFocus.focusedChild != null) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      }
                      setState(() {
                        addEventTabValue += 0.25;
                      });
                    }
                  } else if (_selectedIndex == 1) {
                    if (invalidEmail == false) {
                      _tabController!.animateTo(_selectedIndex += 1);
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      }
                      setState(() {
                        addEventTabValue += 0.25;
                      });
                    }
                  } else if (_selectedIndex == 2) {
                    if (dayController.text.length == 2 && monthController.text.length == 2 && yearController.text.length == 4) {
                      if (confirmAge == false) {
                        // Check if Date is Valid
                        String dateString = yearController.text+"-"+monthController.text+"-"+dayController.text;
                        DateTime? date = convertToDate(dateString, "yyyy-MM-dd", context);
                        if (date == null || date.isAfter(DateTime.now())) {
                          setState(() {
                            errorAge = true;
                          });
                        } else {
                          setState(() {
                            startDate = date;
                            confirmAge = true;
                            canGoNextDate = false;
                          });
                          await Future.delayed(const Duration(seconds: 1));
                          setState(() {
                            canGoNextDate = true;
                          });
                        }
                      } else {
                        _tabController!.animateTo(_selectedIndex += 1);
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        }
                        setState(() {
                          addEventTabValue += 0.25;
                        });
                      }
                    }
                  } else if (_selectedIndex == 3) {
                    if (gender != null) {
                      _tabController!.animateTo(_selectedIndex += 1);
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      }
                      setState(() {
                        addEventTabValue += 0.25;
                      });
                    }
                  }
                },
                backgroundColor: _selectedIndex == 3 ? Colors.green : Theme.of(context).colorScheme.secondary,
                icon: Container(),
                label: Text(
                  _selectedIndex == 3 ? AppLocalizations.of(context)!.addClientsManually.split(" ")[0]+" "+(!widget.isTrainer ? AppLocalizations.of(context)!.client : AppLocalizations.of(context)!.staff).toLowerCase() : AppLocalizations.of(context)!.next,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(color: AppColors.white),)
              ),
            ),
          ),
        ],
      ),
    );


  }


  @override
  void dispose() {
    super.dispose();
  }
}