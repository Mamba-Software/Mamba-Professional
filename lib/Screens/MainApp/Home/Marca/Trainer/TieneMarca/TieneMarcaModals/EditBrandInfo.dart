import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/Location.dart';
import 'package:google_place/google_place.dart' as googlePlace;

// Tus Datos Widget.
class EditBrandInfo extends StatefulWidget {
  Locale? locale;
  EditBrandInfo({Key? key, this.locale}) : super(key: key);

  @override
  _EditBrandInfoState createState() => _EditBrandInfoState();
}

class _EditBrandInfoState extends State<EditBrandInfo> with SingleTickerProviderStateMixin {

  // DataBase Access
  var _brandDataService = new BrandDataService();
  // Boolean isLoading
  bool isLoading = false;
  bool isUpdated = false;
  // Form To Validate
  final formKeyInfo = GlobalKey<FormState>();
  // Name Brand Controller
  var nameBrandController = TextEditingController();
  String nameBrandControllerTemp = "";
  // Description Controller
  var descriptionController = TextEditingController();
  String descriptionControllerTemp = "";
  // Max Members Brand
  TextEditingController membersController = TextEditingController();
  int members = 1;
  int membersMax = 30;
  bool errorMembers = false;
  // Time Picker Horari de Trabajo
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  List<double> _workShift = [];
  int? errorTime;
  // Descansos
  TextEditingController breakStartTimeController = TextEditingController();
  TextEditingController breakEndTimeController = TextEditingController();
  TimeOfDay _breakStartTime = TimeOfDay(hour: 13, minute: 00);
  TimeOfDay _breakEndTime = TimeOfDay(hour: 14, minute: 00);
  List<TimeOfDay> _breakList = [];
  List<int> removedIndex = [];
  int breakLimit = 2;
  bool errorBreakTime = false;
  List<int> startBreaks = [];

  // Cupertino Picker
  Future<void> selectSlot(ctx, type, bool? isStart) {
    // Initial Vars
    var startDate = DateTime.now();
    var title;
    var initialDuration = 1;
    var initialMembers = 1;
    var widgetPicker;
    // Init for differnt types
    if (type == 0) {

    } else if (type == 1) {

    } else if (type == 2) {
      initialMembers = members-1;
    } else if (type == 3) {
      // No changes needed at the moment
    }
    Widget membersPicker = CupertinoPicker(
        scrollController: new FixedExtentScrollController(
            initialItem: initialMembers
        ),
        itemExtent: 40.0,
        backgroundColor: Colors.transparent,
        onSelectedItemChanged: (int index) {
          setState(() {
            members = index+1;
            membersController.text = "${members.toString()}";
          });
        },
        children: new List<Widget>.generate(
            membersMax, (int index) {
          var member = index+1;
          return new Center(
            child: new Text(
                "${member.toString()}"
            ),
          );
        }
        )
    );
    Widget workdayTimePicker = CupertinoDatePicker(
        mode: CupertinoDatePickerMode.time,
        initialDateTime: DateTime(startDate.year, startDate.month, startDate.day, startDate.hour,0),
        minimumDate: DateTime(startDate.year, startDate.month, startDate.day, 0, 0),
        maximumDate: DateTime(startDate.year, startDate.month, startDate.day, 23, 0),
        use24hFormat: true,
        minuteInterval: 30,
        onDateTimeChanged: (val) {
          if (isStart!) {
            setState(() {
              startTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(val);
            });
          } else {
            setState(() {
              endTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(val);
            });
          }
        }
    );
    Widget breakTimePicker = CupertinoDatePicker(
        mode: CupertinoDatePickerMode.time,
        initialDateTime: DateTime(startDate.year, startDate.month, startDate.day, startDate.hour,0),
        minimumDate: DateTime(startDate.year, startDate.month, startDate.day, 0, 0),
        maximumDate: DateTime(startDate.year, startDate.month, startDate.day, 23, 0),
        use24hFormat: true,
        minuteInterval: 30,
        onDateTimeChanged: (val) {
          if (isStart!) {
            setState(() {
              breakStartTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(val);
            });
          } else {
            setState(() {
              breakEndTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(val);
            });
          }
        }
    );
    if (type == 2) {
      title = AppLocalizations.of(context)!.selectMembers;
      widgetPicker = membersPicker;
    } else if (type == 3) {
      title = AppLocalizations.of(context)!.selectTime;
      widgetPicker = workdayTimePicker;
    } else if (type == 4) {
      title = AppLocalizations.of(context)!.selectTime;
      widgetPicker = breakTimePicker;
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
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(title, style:  Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
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

  // Gets the user info from firebase.
  Future<void> getBrand() async {
    currentBrand.setBasicData = await _brandDataService.getBrandDetails(currentBrand.id!);
    currentBrand.setUserList = await _brandDataService.getBrandUsers(currentBrand.id!);
  }

  @override
  void initState() {
    nameBrandController.text = currentBrand.name!;
    descriptionController.text = currentBrand.description!;
    members = currentBrand.maxMembers!;
    membersController.text = currentBrand.maxMembers.toString();
    var startHourWS = int.parse(currentBrand.workShift[0].toStringAsFixed(2).split(".")[0]);
    var startMinWS = int.parse(currentBrand.workShift[0].toStringAsFixed(2).split(".")[1]);
    startTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, startHourWS, startMinWS,));
    var endHourWS = int.parse(currentBrand.workShift[1].toStringAsFixed(2).split(".")[0]);
    var endMinWS = int.parse(currentBrand.workShift[1].toStringAsFixed(2).split(".")[1]);
    endTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, endHourWS, endMinWS,));
    for (var i=2; i < currentBrand.workShift.length ; i+=2) {
      var start = currentBrand.workShift[i];
      int s = start.toInt();
      startBreaks.add(s);
      var startHour = int.parse(start.toStringAsFixed(2).split(".")[0]);
      var startMin = int.parse(start.toStringAsFixed(2).split(".")[1]);
      var end = currentBrand.workShift[i+1];
      int e = end.toInt();
      startBreaks.add(e);
      var endHour = int.parse(end.toStringAsFixed(2).split(".")[0]);
      var endMin = int.parse(end.toStringAsFixed(2).split(".")[1]);
      _breakStartTime = TimeOfDay(hour: startHour, minute: startMin);
      _breakEndTime = TimeOfDay(hour: endHour, minute: endMin);
      _breakList.add(_breakStartTime);
      _breakList.add(_breakEndTime);
    }
    breakStartTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 13, 0,));
    breakEndTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 14, 0,));
    super.initState();
  }

  bool checkIfBreakTimeChanged() {
    if (_breakList.length - removedIndex.length != (currentBrand.workShift.length-2)) {
      return true;
    } else {
      List<int> endBreaks = [];
      for (var j=0; j <_breakList.length; j+=1) {
        if (j.isEven && !removedIndex.contains(j)) {
          int temp = _breakList[j].hour + _breakList[j].minute;
          int temp1 = _breakList[j+1].hour + _breakList[j+1].minute;
          endBreaks.add(temp);
          endBreaks.add(temp1);
        }
      }
     if (listEquals(startBreaks, endBreaks) == false) {
       return true;
     }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      var startHourWS = int.parse(currentBrand.workShift[0].toStringAsFixed(2).split(".")[0]);
      var startMinWS = int.parse(currentBrand.workShift[0].toStringAsFixed(2).split(".")[1]);
      var endHourWS = int.parse(currentBrand.workShift[1].toStringAsFixed(2).split(".")[0]);
      var endMinWS = int.parse(currentBrand.workShift[1].toStringAsFixed(2).split(".")[1]);
      if (nameBrandControllerTemp.trim() != currentBrand.name! && nameBrandControllerTemp != "") {
        isUpdated = true;
      } else if (descriptionControllerTemp.trim() != currentBrand.description! && descriptionControllerTemp != "") {
        isUpdated = true;
      } else if (startTimeController.text != DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, startHourWS, startMinWS,)) || endTimeController.text != DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, endHourWS, endMinWS,))) {
        isUpdated = true;
      } else if (checkIfBreakTimeChanged()) {
        isUpdated = true;
      } else {
        isUpdated = false;
      }
    }

    return isLoading ?
    Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.yourBrand, style:  Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 25,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: LoadingViewPurple(),
    )
        :
    Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(AppLocalizations.of(context)!.yourBrand, style:  Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.width*0.07),
            child: Form(
              key: formKeyInfo,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.nameBrand,
                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                  Flexible(
                    child: new TextFormField(
                      keyboardType: TextInputType.text,
                      controller: nameBrandController,
                      onChanged: (value) {
                        setState(() {
                          nameBrandControllerTemp = value;
                        });
                      },
                      validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.nameBrandError : null,
                      style: Styles.purpleTextStyle.copyWith(fontSize: 16),
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintStyle: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Colors.grey),
                        hintText: AppLocalizations.of(context)!.nameBrandError,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.05),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.createBrandDescDescription,
                          style: Styles.purpleTextStyle.copyWith(color: Colors.grey, fontSize: 16),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  Text(
                    AppLocalizations.of(context)!.description,
                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                  Flexible(
                    child: new TextFormField(
                      keyboardType: TextInputType.text,
                      controller: descriptionController,
                      onChanged: (value) {
                        setState(() {
                          descriptionControllerTemp = value;
                        });
                      },
                      validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.descriptionError : null,
                      minLines: 1,
                      maxLines: 5,
                      maxLength: 250,
                      decoration: InputDecoration(
                        hintStyle: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Colors.grey),
                        hintText: AppLocalizations.of(context)!.descriptionError,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.05),
                  /*
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.maxNumberClientsError,
                          style: Styles.purpleTextStyle.copyWith(color: Colors.grey, fontSize: 16),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  Text(
                    AppLocalizations.of(context)!.maxNumberClients,
                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                  GestureDetector(
                      onTap: () {
                        selectSlot(context, 2, null);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new Flexible(
                            child: TextFormField(
                              controller: membersController,
                              minLines: 1,
                              readOnly: true,
                              enabled: false,
                              style: Styles.purpleTextStyle,
                              decoration: InputDecoration(
                                hintStyle: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Colors.grey),
                                hintText: AppLocalizations.of(context)!.maxNumberClientsError,
                                labelStyle: Styles.purpleTextStyle,
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
                  errorMembers ? Text(
                    AppLocalizations.of(context)!.maxNumberClientsError,
                    style: Styles.redTextStyle.copyWith(fontSize: 12),
                  ) : new Container(),
                  SizedBox(height: MediaQuery.of(context).size.height*0.03),
                  */
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.createBrandWorkshiftDescription,
                          style: Styles.purpleTextStyle.copyWith(color: Colors.grey, fontSize: 16),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  Text(
                    AppLocalizations.of(context)!.workingHours,
                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      TextButton(
                        onPressed: () async {
                          selectSlot(context, 3, true);
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            border: Border.all(color: Theme.of(context).primaryColor, width: 1.0),
                            color: Colors.transparent,
                          ),
                          child: Text(
                            startTimeController.text,
                            style: Styles.purpleTextStyle.copyWith(fontSize: 25),
                          ),
                        ),
                      ),
                      Text("-", style: Styles.purpleTextStyle.copyWith(fontSize: 30),),
                      TextButton(
                        onPressed: () async {
                          selectSlot(context, 3, false);
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            border: Border.all(color: Theme.of(context).primaryColor, width: 1.0),
                            color: Colors.transparent,
                          ),
                          child: Text(
                            endTimeController.text,
                            style: Styles.purpleTextStyle.copyWith(fontSize: 25),
                          ),
                        ),
                      ),
                    ],
                  ),
                  errorTime != null ? Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, top: 5.0, bottom: 0),
                    child: Text(
                      errorTime == 1 ? AppLocalizations.of(context)!.workingHoursError : AppLocalizations.of(context)!.workingHoursError1,
                      style: Styles.redTextStyle.copyWith(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ) : new Container(),
                  SizedBox(height: MediaQuery.of(context).size.height*0.05),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.createBrandBreakDescription,
                          style: Styles.purpleTextStyle.copyWith(color: Colors.grey, fontSize: 16),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  Text(
                    AppLocalizations.of(context)!.lunchBreak,
                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * 0.53,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            TextButton(
                              onPressed: _breakList.length < breakLimit ? () {
                                selectSlot(context, 4, true);
                              } : null,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  border: Border.all(color: _breakList.length < breakLimit ? Theme.of(context).primaryColor : Colors.grey, width: 1.0),
                                  color: Colors.transparent,
                                ),
                                child: Text(
                                  breakStartTimeController.text,
                                  style: Styles.purpleTextStyle.copyWith(fontSize: 25, color: _breakList.length < breakLimit ? Theme.of(context).primaryColor : Colors.grey),
                                ),
                              ),
                            ),
                            Text("-", style: Styles.purpleTextStyle.copyWith(fontSize: 30, color: _breakList.length < breakLimit ? Theme.of(context).primaryColor : Colors.grey),),
                            TextButton(
                              onPressed: _breakList.length < breakLimit ? () {
                                selectSlot(context, 4, false);
                              } : null,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  border: Border.all(color: _breakList.length < breakLimit ? Theme.of(context).primaryColor : Colors.grey, width: 1.0),
                                  color: Colors.transparent,
                                ),
                                child: Text(
                                  breakEndTimeController.text,
                                  style: Styles.purpleTextStyle.copyWith(fontSize: 25, color: _breakList.length < breakLimit ? Theme.of(context).primaryColor : Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _breakList.length < breakLimit ? Padding(
                        padding: const EdgeInsets.only(left: 0.0),
                        child: OutlinedButton(
                          onPressed: () {
                            double toDouble(DateTime myTime) => myTime.hour + myTime.minute/60.0;
                            if (toDouble(DateFormat('HH:mm', widget.locale!.languageCode).parse(breakStartTimeController.text)) > toDouble(DateFormat('HH:mm', widget.locale!.languageCode).parse(breakEndTimeController.text))){
                              setState(() {
                                errorBreakTime = true;
                              });
                            } else {
                              DateTime start = DateFormat('HH:mm', widget.locale!.languageCode).parse(breakStartTimeController.text);
                              DateTime end = DateFormat('HH:mm', widget.locale!.languageCode).parse(breakEndTimeController.text);
                              _breakStartTime = TimeOfDay(hour: start.hour, minute: start.minute);
                              _breakEndTime = TimeOfDay(hour: end.hour, minute: end.minute);
                              setState(() {
                                errorBreakTime = false ;
                                _breakList.add(_breakStartTime);
                                _breakList.add(_breakEndTime);
                              });
                            }
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon( Icons.add, color: Colors.white, size: 30,),
                            ],
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.green,
                            elevation: 3,
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(5),
                          ),
                        ),
                      ) : Container(),
                    ],
                  ),
                  errorBreakTime ? Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, top: 5.0, bottom: 0),
                    child: Text(
                      AppLocalizations.of(context)!.workingHoursError1,
                      style: Styles.redTextStyle.copyWith(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ) : new Container(),
                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _breakList.length,
                    itemBuilder: (context, int index) {
                      if(index.isEven && !removedIndex.contains(index)) {
                        return Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width * 0.53,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  TextButton(
                                    onPressed: false ? () {

                                    } : null,
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        border: Border.all(color: Colors.green, width: 1.0),
                                        color: Colors.transparent,
                                      ),
                                      child: Text(
                                        '${_breakList[index].format(context)}',
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 25, color: Colors.green),
                                      ),
                                    ),
                                  ),
                                  Text("-", style: Styles.purpleTextStyle.copyWith(fontSize: 30, color: Colors.green),),
                                  TextButton(
                                    onPressed: false ? () {

                                    } : null,
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        border: Border.all(color: Colors.green, width: 1.0),
                                        color: Colors.transparent,
                                      ),
                                      child: Text(
                                        '${_breakList[index+1].format(context)}',
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 25, color: Colors.green),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 0.0),
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    removedIndex.add(index);
                                    removedIndex.add(index+1);
                                    breakLimit += 2;
                                  });
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon( Icons.remove, color: Colors.white, size: 30,),
                                  ],
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  elevation: 3,
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(5),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(AppLocalizations.of(context)!.lunchBreakAdded, style: Styles.purpleTextStyle.copyWith(fontSize: 13,fontStyle: FontStyle.italic, color: Colors.green), textAlign: TextAlign.center,),
                            ),
                          ],
                        );
                      } else {
                        return Container();
                      }
                    },
                    shrinkWrap: true,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  _breakList.length < breakLimit ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.createBrandAddDescription,
                          style: Styles.purpleTextStyle.copyWith(color: Theme.of(context).primaryColor, fontSize: 16),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ) : Container(),
                  SizedBox(height: MediaQuery.of(context).size.height*0.10),
                ],
              ),
            )
        ),
      ),
      floatingActionButton: isUpdated ? Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
        child: FloatingActionButton.extended(
          heroTag: "81",
          onPressed: () async {
            if (validateInfo()) {
              setState(() {
                isLoading = true;
              });
              DateTime start = DateFormat('HH:mm', widget.locale!.languageCode).parse(startTimeController.text);
              DateTime end = DateFormat('HH:mm', widget.locale!.languageCode).parse(endTimeController.text);
              double toDouble(DateTime myTime) => myTime.hour + myTime.minute/60.0;
              double toDouble2(TimeOfDay myTime) => myTime.hour + myTime.minute/60.0;
              _workShift.add(toDouble(start));
              _workShift.add(toDouble(end));
              for (var i=0; i < _breakList.length; i+=2) {
                if(!removedIndex.contains(i)) {
                  _workShift.add(toDouble2(_breakList[i]));
                  _workShift.add(toDouble2(_breakList[i+1]));
                }
              }
              setState(() {
                isLoading = true;
              });
              await _brandDataService.updateBrandInfo(currentBrand.id!, nameBrandController.text, descriptionController.text, members, _workShift);
              await getBrand();
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
  bool validateInfo() {
    DateTime start = DateFormat('HH:mm', widget.locale!.languageCode).parse(startTimeController.text);
    DateTime end = DateFormat('HH:mm', widget.locale!.languageCode).parse(endTimeController.text);
    double toDouble(DateTime myTime) => myTime.hour + myTime.minute / 60.0;
    if (!formKeyInfo.currentState!.validate()) {
      return false;
    }
    if (membersController.text.isEmpty) {
      setState(() {
      errorMembers = true;
      });
      return false;
    }
    if (TimeOfDay(hour: start.hour, minute: start.minute) == TimeOfDay(hour: 0, minute: 00) && TimeOfDay(hour: end.hour, minute: end.minute) == TimeOfDay(hour: 23, minute: 00)) {
      setState(() {
        errorTime = 1;
      });
      return false;
    }
    if (toDouble(start) > toDouble(end)) {
      setState(() {
        errorTime = 2;
      });
      return false;
    }
    setState(() {
      errorTime == null;
      errorMembers = false;
    });
    return true;
  }


}

