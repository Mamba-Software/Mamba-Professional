import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Models/Location.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FirstTime extends StatefulWidget {

  FirstTime({Key? key}) : super(key: key);

  @override
  _FirstTimeState createState() => _FirstTimeState();
}

class _FirstTimeState extends State<FirstTime> with SingleTickerProviderStateMixin{
  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  // Boolean Loading
  bool isLoading = false;
  // Boolean isUpdated
  bool isUpdated = false;
  // Tab Controller
  double addEventTabValue = 0.20;
  TabController? _tabController;
  int _selectedIndex = 0;
  List<bool> tabs = [true, false, false, false, false];
  // Title Controller
  var titleController = TextEditingController();
  String? titleString;
  // Description Controller
  var descriptionController = TextEditingController();
  String? descriptionString;
  // Location
  Location location = Location();
  // Starting Date and Time
  TextEditingController startDateController = TextEditingController();
  bool errorDate = false;
  // Duration
  TextEditingController durationController = TextEditingController();
  String duration = "1.00";
  List<String> durations = ["0.30","1.00","1.30","2.00","2.30","3.00","3.30","4.00"];
  // Ubicació
  var ubicacionController =  TextEditingController();
  // Participants
  TextEditingController membersController = TextEditingController();
  // Evento Recurrente
  bool isRecurrent = false;
  var oneWeek;
  var twoWeek;
  var oneMonth;
  final values = <bool?>[false, false, false, false, false, false, false];
  int _value = 1;
  // Members Page
  List<Usuario> brandTrainers = [];
  List<bool> brandTrainersSelected = [];
  bool errorNoTrainerSelected = false;
  // Form To Validate User
  final formKeyInfo = GlobalKey<FormState>();
  final formKeyTime = GlobalKey<FormState>();
  final formKeyMembers = GlobalKey<FormState>();
  // Event Retrieved From BD
  var event;
  var placeDetails;

  String toCapitalized(String s) => s.length > 0 ?'${s[0].toUpperCase()}${s.substring(1)}':'';
  String undoCapitalized(String s) => s.length > 0 ?'${s[0].toLowerCase()}${s.substring(1)}':'';

  Future<void> selectSlot(ctx, type) {
    // Initial Vars
    var startDate = DateTime.now();
    var title;
    var initialDuration = 1;
    var initialMembers = 1;
    var widgetPicker;
    // Init for differnt types
    if (type == 0) {
      //startDate = DateFormat('EEEE d/M/y - HH:mm', widget.locale.languageCode).parse(undoCapitalized(startDateController.text));
    } else if (type == 1) {
        initialDuration = durations.indexWhere((element) => element == duration);
    } else if (type == 2) {
      //initialMembers = members-1;
    }
    // Different types of pickers
    Widget dateTimePicker = CupertinoDatePicker(
      mode: CupertinoDatePickerMode.dateAndTime,
      initialDateTime: DateTime(startDate.year, startDate.month, startDate.day, startDate.hour,0),
      minimumDate: DateTime(startDate.year, startDate.month, startDate.day, startDate.hour,0),
      maximumDate: startDate.add(Duration(days: 365)),
      use24hFormat: true,
      minuteInterval: 30,
      onDateTimeChanged: (val) {
        setState(() {
          startDateController.text = DateFormat('EEEE d/M/y - HH:mm').format(val);
          startDateController.text = toCapitalized(startDateController.text);
          oneWeek = val.add(Duration(days: 7));
          twoWeek = val.add(Duration(days: 14));
          oneMonth= val.add(Duration(days: 30));
        });
      }
    );

    if (type == 0) {
      title = AppLocalizations.of(context)!.selectDayTime;
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
            ],
          ),
        ),
      )
    );
    return Future.value("");
  }

  @override
  initState() {
    //isLoading = true;
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? Scaffold(
      appBar: null,
      body: LoadingViewPurple(),
    ) :
    Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height*0.14,
        title: getTitle(),
        centerTitle: true,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: IgnorePointer(
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  indicatorColor: Theme.of(context).scaffoldBackgroundColor,
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
                            Icon(Icons.login_outlined, color: tabs[0] ? Theme.of(context).accentColor : Colors.white)
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
                            Icon(Icons.info_outlined, color: tabs[1] ? Theme.of(context).accentColor : Colors.white)
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
                            Icon(Icons.image_outlined, color: tabs[2] ? Theme.of(context).accentColor : Colors.white)
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
                            Icon(Icons.fitness_center_rounded, color: tabs[3] ? Theme.of(context).accentColor : Colors.white)
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
                            Icon(Icons.qr_code_outlined, color: tabs[4] ? Theme.of(context).accentColor : Colors.white)
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
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                Scaffold(
                  body: SingleChildScrollView(
                      child: Column(
                        children: [
                          Form(
                              key: formKeyInfo,
                              child: Icon(Icons.info_outlined, color: tabs[0] ? Theme.of(context).accentColor : Colors.grey)
                            ),
                        ],
                      )
                  ),
                  resizeToAvoidBottomInset: false,
                ),
                Scaffold(
                  body: SingleChildScrollView(
                      child: Column(
                        children: [
                          Icon(Icons.info_outlined, color: tabs[0] ? Theme.of(context).accentColor : Colors.grey)
                        ],
                      )
                  ),
                  resizeToAvoidBottomInset: false,
                ),
                Scaffold(
                  body: SingleChildScrollView(
                      child: Column(
                        children: [
                          Icon(Icons.info_outlined, color: tabs[0] ? Theme.of(context).accentColor : Colors.grey)
                        ],
                      )
                  ),
                  resizeToAvoidBottomInset: false,
                ),
                Scaffold(
                  body: SingleChildScrollView(
                      child: Column(
                        children: [
                          Icon(Icons.info_outlined, color: tabs[3] ? Theme.of(context).accentColor : Colors.grey)
                        ],
                      )
                  ),
                  resizeToAvoidBottomInset: false,
                ),
                Scaffold(
                  body: SingleChildScrollView(
                      child: Column(
                        children: [
                          Icon(Icons.info_outlined, color: tabs[4] ? Theme.of(context).accentColor : Colors.grey)
                        ],
                      )
                  ),
                  resizeToAvoidBottomInset: false,
                ),
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
                    heroTag: null,
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
                        addEventTabValue -= 0.20;
                      });

                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    icon: Container(),
                    label: Text(AppLocalizations.of(context)!.back, style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),),
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
                    heroTag: null,
                    onPressed: () {
                      if (_selectedIndex == 0) {
                        if (formKeyInfo.currentState!.validate()){
                          _tabController!.animateTo(_selectedIndex += 1);
                          setState(() {
                            addEventTabValue += 0.20;
                            tabs[1] = true;
                          });
                        }
                      } else if (_selectedIndex == 1) {
                        _tabController!.animateTo(_selectedIndex += 1);
                        setState(() {
                          addEventTabValue += 0.20;
                          tabs[2] = true;
                        });
                      } else if (_selectedIndex == 2) {
                        _tabController!.animateTo(_selectedIndex += 1);
                        setState(() {
                          addEventTabValue += 0.20;
                          tabs[3] = true;
                        });
                      } else if (_selectedIndex == 3) {
                        _tabController!.animateTo(_selectedIndex += 1);
                        setState(() {
                          addEventTabValue += 0.20;
                          tabs[4] = true;
                        });
                      }
                    },
                    backgroundColor: _selectedIndex == 2 ? Colors.green : Theme.of(context).accentColor,
                    icon: Container(),
                    label: Text(
                      _selectedIndex == 2 ? AppLocalizations.of(context)!.createEvent : AppLocalizations.of(context)!.next,
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),),
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }

  String splitCommonName(String name) {
    List<String> aux = name.split(" ");
    return aux[0];
  }

  Widget getTitle() {
    return Text(AppLocalizations.of(context)!.addEvent, style: Theme.of(context).appBarTheme.titleTextStyle,);
  }

}
