import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingViewPurple.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../../Data/Models/Bono.dart';

class AddBono extends StatefulWidget {
  String brandId;
  AddBono({Key? key, required this.brandId}) : super(key: key);

  @override
  _AddBonoState createState() => _AddBonoState();
}

class _AddBonoState extends State<AddBono> with SingleTickerProviderStateMixin{
  // Acceso a Base de Datos
  var _brandDataService = new BrandDataService();
  // Boolean Loading
  bool isLoading = false;
  // Boolean isUpdated
  bool isUpdated = false;
  // Tab Controller
  double addEventTabValue = 0.33;
  double updateEventTabValue = 0.50;
  TabController? _tabController;
  int _selectedIndex = 0;
  List<bool> tabs = [true, false, false];
  // Title Controller
  var titleController = TextEditingController();
  String? titleString;
  // Description Controller
  String? descriptionString;
  final formKeyInfo = GlobalKey<FormState>();

  // Duration
  TextEditingController durationController = TextEditingController();

  final values = <bool?>[false, false, false, false, false, false, false];
  int _value = 1;

  Bono bono = new Bono(
    expiration: DateTime.now().add(const Duration(days: 3)),
    activation: DateTime.now(),
  );

  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';


  @override
  initState() {
    isLoading = false;
    _tabController = TabController(length: 3, vsync: this);
  }


  @override
  Widget build(BuildContext context) {
    return isLoading ? Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height*0.14,
        title: Text(AppLocalizations.of(context)!.bonos, style: Theme.of(context).appBarTheme.titleTextStyle,),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: IgnorePointer(
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.transparent,
                    onTap: (index) {
                      _selectedIndex = index;
                    },
                    tabs: [
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info_outlined, color: tabs[0] ? Theme.of(context).accentColor : Theme.of(context).scaffoldBackgroundColor, size: MediaQuery.of(context).size.width*0.06,)
                            ],
                          ),
                        ),
                      ),
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.local_atm, color: tabs[1] ? Theme.of(context).accentColor : Theme.of(context).scaffoldBackgroundColor, size: MediaQuery.of(context).size.width*0.06,)
                            ],
                          ),
                        ),
                      ),
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.color_lens, color: tabs[2] ? Theme.of(context).accentColor : Theme.of(context).scaffoldBackgroundColor, size: MediaQuery.of(context).size.width*0.06,)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  LinearProgressIndicator(
                    value: addEventTabValue,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    color: Theme.of(context).accentColor,
                  ),
                ],
              )
          ),
        ),
      ),
      body: LoadingViewPurple(),
    ) :
    Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height*0.14,
        title: Text(AppLocalizations.of(context)!.bonos, style: Theme.of(context).appBarTheme.titleTextStyle,),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: IgnorePointer(
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.transparent,
                  onTap: (index) {
                    _selectedIndex = index;
                  },
                  tabs: [
                    Tab(
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outlined, color: tabs[0] ? Theme.of(context).accentColor : Theme.of(context).scaffoldBackgroundColor, size: MediaQuery.of(context).size.width*0.06,)
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_atm, color: tabs[1] ? Theme.of(context).accentColor : Theme.of(context).scaffoldBackgroundColor, size: MediaQuery.of(context).size.width*0.06,)
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.color_lens, color: tabs[2] ? Theme.of(context).accentColor : Theme.of(context).scaffoldBackgroundColor, size: MediaQuery.of(context).size.width*0.06,)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                LinearProgressIndicator(
                  value: addEventTabValue,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  color: Theme.of(context).accentColor,
                ),
              ],
            )
          ),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                informationPage(),
                timePage(),
                othersPage(),
              ],
            )
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.01),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _selectedIndex != 0 ? Padding(
                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.01, left: MediaQuery.of(context).size.width*0.09),
                child: Container(
                  height: 50,
                  child: FloatingActionButton.extended(
                    heroTag: "4",
                    onPressed: () {
                      if (_selectedIndex == 1) {
                        setState(() {
                          tabs[1] = false;
                        });
                      } else if (_selectedIndex == 2) {
                        setState(() {
                          tabs[2] = false;
                        });
                      }
                      _tabController!.animateTo(_selectedIndex -= 1);
                      setState(() {
                        addEventTabValue -= 0.33;
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
                child: Container(
                  height: 50,
                  child: FloatingActionButton.extended(
                    heroTag: "5",
                    onPressed: () {
                      if (_selectedIndex == 0) {
                        if (formKeyInfo.currentState!.validate()){
                          _tabController!.animateTo(_selectedIndex += 1);
                          setState(() {
                            addEventTabValue += 0.33;
                            tabs[1] = true;
                          });
                        }
                      } else if (_selectedIndex == 1) {
                          _tabController!.animateTo(_selectedIndex += 1);
                          setState(() {
                            addEventTabValue += 0.33;
                            tabs[2] = true;
                          });

                      }
                      else _addBono();
                    },
                    backgroundColor: _selectedIndex == 2 ? Colors.green : Theme.of(context).accentColor,
                    icon: Container(),
                    label: Text(
                      _selectedIndex == 2 ? AppLocalizations.of(context)!.bonos : AppLocalizations.of(context)!.next,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(color: AppColors.white),),
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }

  Widget informationPage()
  {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: formKeyInfo,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.03),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    new Text(
                                      AppLocalizations.of(context)!.title,
                                      style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            )
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Flexible(
                                  child: new TextFormField(
                                    controller: titleController,
                                    validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.titleError : null,
                                    onChanged: (val) {
                                      setState(() {
                                        bono.title = val;
                                      });
                                    },
                                    style: Theme.of(context).textTheme.bodyText2,
                                    decoration: InputDecoration(
                                      hintStyle: Theme.of(context).textTheme.caption,
                                      hintText: AppLocalizations.of(context)!.titleHint,
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                    ),
                                    enabled: true,
                                  ),
                                ),
                              ],
                            )
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    new Text(
                                      AppLocalizations.of(context)!.description,
                                      style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            )
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 0.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Flexible(
                                  child: new TextFormField(
                                    keyboardType: TextInputType.visiblePassword,
                                    minLines: 1,
                                    maxLines: 4,
                                    onChanged: (val) {
                                      setState(() {
                                        bono.description = val;
                                      });
                                    },
                                    style: Theme.of(context).textTheme.bodyText2,
                                    decoration: InputDecoration(
                                      hintStyle: Theme.of(context).textTheme.caption,
                                      hintText:AppLocalizations.of(context)!.descriptionError,
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            )
                        ),
                        Row(
                          children: [
                            Column(
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01),
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        new Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            new Text(
                                              'Fecha de activación',
                                              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                ),
                                Padding(
                                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01),
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        new Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            new Text(
                                              DateFormat('dd/MM/yyyy').format(bono.activation!),
                                              style: Theme.of(context).textTheme.bodyText2,
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                ),
                              ],
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width * 0.2),
                            Column(
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01),
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        new Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            new Text(
                                              'Fecha de expiración',
                                              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                ),
                                Padding(
                                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01),
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        new Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            new Text(
                                              DateFormat('dd/MM/yyyy').format(bono.expiration!),
                                              style: Theme.of(context).textTheme.bodyText2,
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                ),
                              ],
                            ),
                          ],
                        ),

                        Padding(
                            padding: EdgeInsets.all(10),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Flexible(
                              child: SfDateRangePicker(
                                //todayHighlightColor: Colors.red,
                                selectionColor: Styles.mainColor,
                                rangeSelectionColor: Styles.mainColorTrans,
                                endRangeSelectionColor: Styles.mainColor,
                                startRangeSelectionColor: Styles.mainColor,
                                onSelectionChanged: _onSelectionChanged,
                                selectionMode: DateRangePickerSelectionMode.range,
                                initialSelectedRange: PickerDateRange(
                                    DateTime.now(),
                                    DateTime.now().add(const Duration(days: 3))),
                              ),

                          ),
                              ],
                            )
                        ),


                      ]
                  ),
                ),
              ),
            ],
          )
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  Widget timePage()
  {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
            children: [
              Text('Seleccionador de fecha')
            ],
          )
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  Widget othersPage()
  {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
            children: [
              Text('Aqui campos others'),
            ],
          )
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  bool validateDateAndTime(DateTime startTime, double duration) {
    // Calculating the Time to check
    var hour = duration.toString().split(".")[0];
    var min = duration.toStringAsFixed(2).split(".")[1];
    var endTime =  startTime.add(Duration(hours: int.parse(hour), minutes: int.parse(min)));
    // Computing the workshift
    var workshift1 = currentBrand.workShift[0];
    var workshift2 = currentBrand.workShift[1];
    var startWorkHour = workshift1.toStringAsFixed(2).split(".")[0];
    var startWorkMin = workshift1.toStringAsFixed(2).split(".")[1];
    var endWorkHour = workshift2.toStringAsFixed(2).split(".")[0];
    var endWorkMin = workshift2.toStringAsFixed(2).split(".")[1];
    var startWorkDay =  DateTime(startTime.year, startTime.month, startTime.day, int.parse(startWorkHour),int.parse(startWorkMin));
    var endWorkDay =  DateTime(startTime.year, startTime.month, startTime.day, int.parse(endWorkHour),int.parse(endWorkMin));
    if ( // Can´t create event in the past
       startTime.isBefore(DateTime.now())|| startTime.isAtSameMomentAs(DateTime.now()) || endTime.isBefore(DateTime.now()) || endTime.isAtSameMomentAs(DateTime.now())
      // Can´t create event outside of working hours
      || startTime.isBefore(startWorkDay) || endTime.isBefore(startWorkDay)
      || startTime.isAfter(endWorkDay) || endTime.isAfter(endWorkDay)
    ) {
      return false;
    } else {
      // Can´t create event in break period of working hours
      for (var i=2; i<currentBrand.workShift.length; i+=2) {
        // Breaks
        var break1 = currentBrand.workShift[i];
        var break2 = currentBrand.workShift[i+1];
        // Take the minute and the hour
        var startBreakHour = break1.toStringAsFixed(2).split(".")[0];
        var startBreakMin = break1.toStringAsFixed(2).split(".")[1];
        var endBreakHour = break2.toStringAsFixed(2).split(".")[0];
        var endBreakMin = break2.toStringAsFixed(2).split(".")[1];
        // Date Time formatted
        var startBreak =  DateTime(startTime.year, startTime.month, startTime.day, int.parse(startBreakHour), int.parse(startBreakMin));
        var endBreak =  DateTime(startTime.year, startTime.month, startTime.day, int.parse(endBreakHour), int.parse(endBreakMin));
        // Condition check
        if ( ((startTime.isAfter(startBreak) || startTime.isAtSameMomentAs(startBreak)) && (startTime.isBefore(endBreak))) ||
            ((endTime.isAfter(startBreak)) && (endTime.isBefore(endBreak) || endTime.isAtSameMomentAs(endBreak)))) {
          return false;
        }
      }
      return true;
    }
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    /// The argument value will return the changed date as [DateTime] when the
    /// widget [SfDateRangeSelectionMode] set as single.
    ///
    /// The argument value will return the changed dates as [List<DateTime>]
    /// when the widget [SfDateRangeSelectionMode] set as multiple.
    ///
    /// The argument value will return the changed range as [PickerDateRange]
    /// when the widget [SfDateRangeSelectionMode] set as range.
    ///
    /// The argument value will return the changed ranges as
    /// [List<PickerDateRange] when the widget [SfDateRangeSelectionMode] set as
    /// multi range.
    setState(() {
      if (args.value is PickerDateRange) {
        bono.activation = args.value.startDate;
        bono.expiration = args.value.endDate ?? args.value.startDate;
       // bono.expiration = DateFormat('dd/MM/yyyy').format(args.value.startDate) as DateTime?;
        _range = '${DateFormat('dd/MM/yyyy').format(args.value.startDate)} -'
        // ignore: lines_longer_than_80_chars
            ' ${DateFormat('dd/MM/yyyy').format(args.value.endDate ?? args.value.startDate)}';
      }
    });
  }


  Future<void> _addBono() async {
    setState(() {
      isLoading = true;
    });
   _brandDataService.addBonoToBrand(widget.brandId, bono);
    Navigator.pop(context);
  }
}
