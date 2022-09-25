import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Library/LibraryDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Location/LocationDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/LocalNotificationService.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectDateDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectDurationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectMembersDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectTimeDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/RectangularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/BonoCard.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/DeleteConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/DeleteRecurrentEventDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/EditRecurrentEventDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/SelectEventUsers/SelectTrainersEvent.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LocationAutoComplete/MyLocationsSelect.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/SelectEventUsers/SelectClientsEvent.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/03-Com/007-Contenido/SelectBrandImages.dart';
import 'package:uuid/uuid.dart';
import 'package:weekday_selector/weekday_selector.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../Data/Models/Bono.dart';

class AddOrEditEvent extends StatefulWidget {
  Locale locale;
  String? eventId;

  AddOrEditEvent({Key? key, required this.locale, this.eventId}) : super(key: key);

  @override
  _AddOrEditEventState createState() => _AddOrEditEventState();
}

class _AddOrEditEventState extends State<AddOrEditEvent> with SingleTickerProviderStateMixin{
  // Acceso a Base de Datos
  final _eventDataService = EventDataService();
  final _locationDataService = LocationDataService();
  final _brandDataService = BrandDataService();
  // Notification Services
  final NotificationService _notificationService = NotificationService();
  final LocalNotificationService _localNotificationService = LocalNotificationService();
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
  // Event Object -- IF Edit Event
  Event event = Event();
  // Title Controller
  var titleController = TextEditingController();
  String? titleString;
  // Description Controller
  var descriptionController = TextEditingController();
  String? descriptionString;
  // Event Image
  bool isRandomImage = true;
  bool imageError = true;
  String? eventImageUrl;
  // Location
  String? originalLocationId;
  Location location = Location();
  // Starting Date and Time
  DateTime startDate = DateTime.now();
  DateTime originalStartDate = DateTime.now();
  TextEditingController startDateController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  bool errorDate = false;
  Timestamp? doneAt;
  // Duration
  String duration = "1.00";
  TextEditingController durationController = TextEditingController();
  // Participants
  TextEditingController membersController = TextEditingController();
  int eventMaxMembers = 1;
  int membersMax = currentBrand.maxMembers!;
  // Evento Recurrente
  bool modifyAllEventGroup = false;
  bool isRecurrent = false;
  String? isRecurrentLoadingText;
  int currentEvent = 1;
  int totalEvents = 1;
  var oneWeek;
  var twoWeek;
  var oneMonth;
  List<bool?> values = [false, false, false, false, false, false, false];
  int _value = 1;
  // Members Page
  List<Usuario> originalTrainers = [];
  List<Usuario> originalClients = [];
  // Trainers
  List<Usuario> brandTrainersSelected = [];
  bool errorNoTrainerSelected = false;
  // Clients
  bool errorClientsSelected = false;
  List<Usuario> brandClientsSelected = [];
  // Form To Validate User
  final formKeyInfo = GlobalKey<FormState>();
  final formKeyTime = GlobalKey<FormState>();
  final formKeyMembers = GlobalKey<FormState>();
  // Event Bonos
  List<Bono> allBonos = [];
  List<Bono> eventBonos = [];
  List<String> selectedBonos = [];

  @override
  initState() {
    isLoading = true;
    _tabController = TabController(length: 3, vsync: this);
    if (widget.eventId != null) {
      getEventInfo();
    } else {
      initializeEventInfo();
    }
  }

  Future<void> initializeEventInfo() async {
    startDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      startDate.hour+1,
      0,
    );
    // Define Start Date Controller
    startDateController.text = DateFormat('EEEE d/M/y', widget.locale.languageCode).format(startDate);
    startDateController.text = StringUtils().toCapitalized(startDateController.text);
    startTimeController.text = DateFormat('HH:mm', widget.locale.languageCode).format(startDate);
    oneWeek = startDate.add(const Duration(days: 7));
    twoWeek = startDate.add(const Duration(days: 14));
    oneMonth= startDate.add(const Duration(days: 28));
    doneAt = Timestamp.fromDate(startDate);
    titleController.text = currentBrand.name!.replaceAll(RegExp(r"\s+"), "");
    titleString = titleController.text;
    var hour = duration.split(".")[0];
    var min = duration.split(".")[1];
    durationController.text = "${hour}h ${min}min";
    membersController.text = eventMaxMembers.toString();
    brandTrainersSelected.add(currentUser);
    isRandomImage = true;
    // Get Event Bonos
    await getBrandBonos();
    // Get Event Location
    getLocation(currentBrand.baseLocation!);    
  }

  Future<void> getEventInfo() async {
    // Get Event Info
    event = await _eventDataService.getSingleEvent(widget.eventId!);    
    // Event Date
    originalStartDate = DateTime(
      int.parse(event.year!),
      int.parse(event.month!),
      int.parse(event.day!),
      int.parse(event.hour!),
      int.parse(event.minute!),
    );
    startDate = DateTime(
      int.parse(event.year!),
      int.parse(event.month!),
      int.parse(event.day!),
      int.parse(event.hour!),
      int.parse(event.minute!),
    );
    startDateController.text = DateFormat('EEEE d/M/y', widget.locale.languageCode).format(startDate);
    startDateController.text = StringUtils().toCapitalized(startDateController.text);
    startTimeController.text = DateFormat('HH:mm', widget.locale.languageCode).format(startDate);
    oneWeek = startDate.add(const Duration(days: 7));
    twoWeek = startDate.add(const Duration(days: 14));
    oneMonth= startDate.add(const Duration(days: 30));
    doneAt = Timestamp.fromDate(startDate);
    // Event Title
    titleController.text = event.title!;
    titleString = titleController.text;
    // Event Image
    eventImageUrl = event.imageUrl;
    isRandomImage = false;
    // Event Duration
    duration = event.duration!.toStringAsFixed(2);
    durationController.text = StringUtils().durationToString(event.duration!);
    // Event Members
    eventMaxMembers = event.maxMembers!;
    membersController.text = "${event.maxMembers!}";
    await getEventMembers(event.id!);
    // Event Bonos
    await getBrandBonos();
    await getEventBonos();
    // Event Locations
    originalLocationId = event.locationId!;
    await getLocation(event.locationId!);
  }

  Future<void> getBrandBonos() async {
    allBonos = await _brandDataService.getAllBonosFromBrandList(currentBrand.id!);
  }

  Future<void> getEventBonos() async {
    eventBonos = await _eventDataService.getEventBonos(widget.eventId!, currentBrand.id!);
    for (Bono bono in eventBonos) {
      selectedBonos.add(bono.id!);
    }
  }

  Future<void> getEventMembers(String eventId) async {
    List<Usuario> members = await _eventDataService.getEventUsers(eventId);
    for (var m in members) {
      if (m.isTrainer!) {
        brandTrainersSelected.add(m);
        originalTrainers.add(m);
      } else {
        brandClientsSelected.add(m);
        originalClients.add(m);
      }
    }
  }

  Future<void> getLocation(String locationId) async {
    location = await _locationDataService.getSingleLocation(locationId);
    setState(() {
      isLoading = false;
    });
  }

  Future selectDate() async {
    // TODO: AQUI HI HA UN ERROR QUAN SINICIA EL CREATEEVENT A LES XX:59 Y ES CLICKA AIXO A LES XX+1:01
    DateTime? pickedDateTemp =  await showCupertinoModalPopup(
        context: context,
        builder: (_) => SelectDateDialog(
          title: AppLocalizations.of(context)!.selectDay,
          startDate: startDate,
          onlyFuture: true,
          dateOfWeek: true,
        )
    );
    if (pickedDateTemp != null) {
      setState(() {
        errorDate = false;
        startDate = DateTime(
          pickedDateTemp.year,
          pickedDateTemp.month,
          pickedDateTemp.day,
          startDate.hour,
          startDate.minute,
        );
        startDateController.text = DateFormat('EEEE d/M/y', widget.locale.languageCode).format(pickedDateTemp);
        startDateController.text = StringUtils().toCapitalized(startDateController.text);
        oneWeek = pickedDateTemp.add(const Duration(days: 7));
        twoWeek = pickedDateTemp.add(const Duration(days: 14));
        oneMonth= pickedDateTemp.add(const Duration(days: 28));
        if (isRecurrent) {
          values = [false, false, false, false, false, false, false];
          values[startDate.weekday-1] = true;
        }
      });
    }
  }

  Future selectTime() async {
    // TODO: AQUI HI HA UN ERROR QUAN SINICIA EL CREATEEVENT A LES XX:59 Y ES CLICKA AIXO A LES XX+1:01
    if (startDate.isBefore(DateTime.now())) startDate = DateTime.now();
    DateTime? pickedTimeTemp =  await showCupertinoModalPopup(
        context: context,
        builder: (_) => SelectTimeDialog(
          title: AppLocalizations.of(context)!.selectTime,
          startDate: startDate,
          onlyFuture: true,
        )
    );
    if (pickedTimeTemp != null) {
      setState(() {
        errorDate = false;
        startDate = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          pickedTimeTemp.hour,
          pickedTimeTemp.minute,
        );
        startTimeController.text = DateFormat('HH:mm', widget.locale.languageCode).format(startDate);
        oneWeek = pickedTimeTemp.add(const Duration(days: 7));
        twoWeek = pickedTimeTemp.add(const Duration(days: 14));
        oneMonth= pickedTimeTemp.add(const Duration(days: 28));
      });
    }
  }

  Future selectDuration() async {
    String? pickedDuration =  await showCupertinoModalPopup(
        context: context,
        builder: (_) => SelectDurationDialog(
          title: AppLocalizations.of(context)!.selectDuration,
          initialDuration: duration,
        )
    );
    if (pickedDuration != null) {
      setState(() {
        var hour = pickedDuration.split(".")[0];
        var min = pickedDuration.split(".")[1];
        duration = pickedDuration;
        durationController.text = "${hour}h ${min}min";
      });
    }
  }

  Future selectNumberOfMembers() async {
    int? pickedMembers =  await showCupertinoModalPopup(
        context: context,
        builder: (_) => SelectMembersDialog(
          title: AppLocalizations.of(context)!.selectMembers,
          initialMembers: eventMaxMembers-1,
        )
    );
    if (pickedMembers != null) {
      setState(() {
        eventMaxMembers = pickedMembers;
        membersController.text = eventMaxMembers.toString();
      });
    }
  }

  Widget buildAddUserButton(bool isTrainer) {
    if (isTrainer) {
      return GestureDetector(
        onTap: () async {
          List<Usuario>? selectedTrainers = await Navigator.push(
              context,
              CupertinoPageRoute<List<Usuario>>(
                builder: (context) => SelectTrainersEvent(
                  selectedTrainers: brandTrainersSelected,
                ),
              )
          );
          if (selectedTrainers != null) {
            setState(() {
              brandTrainersSelected = selectedTrainers;
              errorNoTrainerSelected = false;
            });
          }
        }, //: null,
        child: Padding(
          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.06, right: 8.0),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.width*0.17,
                  width: MediaQuery.of(context).size.width*0.17,
                  decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                    border: Border.all(
                      width: 1,
                      color: Theme.of(context).primaryColor,
                      style: BorderStyle.solid,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        spreadRadius: 3,
                        blurRadius: 4,
                      ),
                    ],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                        Icons.person_add_alt_1,
                        color: Theme.of(context).primaryColor,
                        size:  MediaQuery.of(context).size.width*0.05
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width*0.025),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.add,
                        style: Theme.of(context).textTheme.bodyText2,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () async {
          List<Usuario>? selectedClients = await Navigator.push(
              context,
              CupertinoPageRoute<List<Usuario>>(
                builder: (context) => SelectClientsEvent(
                  selectedUsers: brandClientsSelected,
                  maxClients: eventMaxMembers,
                ),
              )
          );
          if (selectedClients != null) {
            setState(() {
              brandClientsSelected = selectedClients;
              errorClientsSelected = false;
            });
          }
        },
        child: Padding(
          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.06, right: 8.0),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.width*0.17,
                  width: MediaQuery.of(context).size.width*0.17,
                  decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                    border: Border.all(
                      width: 1,
                      color: Theme.of(context).primaryColor,
                      style: BorderStyle.solid,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        spreadRadius: 3,
                        blurRadius: 4,
                      ),
                    ],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                        Icons.person_add_alt_1,
                        color: Theme.of(context).primaryColor,
                        size:  MediaQuery.of(context).size.width*0.05
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width*0.025),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.add,
                        style: Theme.of(context).textTheme.bodyText2,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? Scaffold(
      appBar: null,
      body: LoadingView(
        text: isRecurrentLoadingText
      ),
    ) :
    Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height*0.12,
        title: widget.eventId == null ? Text(AppLocalizations.of(context)!.addEvent, style: Theme.of(context).appBarTheme.titleTextStyle)
            : Text(AppLocalizations.of(context)!.editEvent, style: Theme.of(context).appBarTheme.titleTextStyle,),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          widget.eventId != null ? IconButton(
              onPressed: () async {
                if (event.eventGroupId == null) {
                  // DeleteDialog
                  var result = await showDialog(
                      context: context,
                      builder: (_) {
                        return DeleteConfirmationDialog(text: AppLocalizations.of(context)!.deleteEventConfirmation);
                      }
                  );
                  if (result) {
                    _deleteEventFunction();
                  }
                } else {
                  var result = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const DeleteRecurrentEventDialog();
                    },
                  );
                  if (result != null) {
                    if (result == 1) {
                      print("Deleting Only This Event..");
                      _deleteEventFunction();
                    } else {
                      print("Delete This Event and the Rest Forward ...");
                      _deleteRecurrentEventFunction();
                    }
                  }
                }
              },
              icon: SizedBox(
                width: MediaQuery.of(context).size.width*0.15,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outlined, color: AppColors.red, size: MediaQuery.of(context).size.width*0.07,),
                  ],
                ),
              )
          ) : SizedBox(
            width: MediaQuery.of(context).size.width*0.15,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.groups,
                  color: Theme.of(context).primaryColor,
                  size: MediaQuery.of(context).size.width*0.05,
                ),
                SizedBox(height: MediaQuery.of(context).size.width*0.01),
                FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                      AppLocalizations.of(context)!.group,
                      style: Theme.of(context).textTheme.bodyText2,
                      textAlign: TextAlign.center
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width*0.03)
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
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
                            Icon(Icons.info_outlined, color: tabs[0] ? Theme.of(context).colorScheme.secondary : Theme.of(context).scaffoldBackgroundColor, size: MediaQuery.of(context).size.width*0.06,)
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
                            Icon(Icons.calendar_today_outlined, color: tabs[1] ? Theme.of(context).colorScheme.secondary : Theme.of(context).scaffoldBackgroundColor, size: MediaQuery.of(context).size.width*0.06,)
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
                            Icon(Icons.group, color: tabs[2] ? Theme.of(context).colorScheme.secondary : Theme.of(context).scaffoldBackgroundColor, size: MediaQuery.of(context).size.width*0.06,)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                LinearProgressIndicator(
                  value: addEventTabValue,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  color: Theme.of(context).colorScheme.secondary,
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
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Scaffold(
                  body: SingleChildScrollView(
                      child: Column(
                        children: [
                          Form(
                              key: formKeyInfo,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                                      child: Column(
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.03),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: <Widget>[
                                                      Text(
                                                        AppLocalizations.of(context)!.title,
                                                        style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                          ),
                                          Padding(
                                              padding: const EdgeInsets.only(top: 0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  Flexible(
                                                    child: TextFormField(
                                                      controller: titleController,
                                                      validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.titleError : null,
                                                      onChanged: (val) {
                                                        setState(() {
                                                          titleString = val;
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
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: <Widget>[
                                                      Text(
                                                        AppLocalizations.of(context)!.description,
                                                        style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                          ),
                                          Padding(
                                              padding: const EdgeInsets.only(top: 0.0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  Flexible(
                                                    child: TextFormField(
                                                      keyboardType: TextInputType.visiblePassword,
                                                      controller: descriptionController,
                                                      minLines: 1,
                                                      maxLines: 4,
                                                      onChanged: (val) {
                                                        setState(() {
                                                          descriptionString = val;
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
                                          Padding(
                                              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.02),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: <Widget>[
                                                      Text(
                                                        AppLocalizations.of(context)!.location,
                                                        style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 15.0),
                                            child: ListTile(
                                              leading: Icon(location.isBaseLocation! ? Icons.home_filled : Icons.location_on_outlined, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.06,),
                                              title: Text(
                                                location.description!,
                                                style: Theme.of(context).textTheme.bodyText2,
                                              ),
                                              trailing: Icon(Icons.swap_horiz, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.06,),
                                              onTap: () async {
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                var result = await Navigator.push(
                                                    context,
                                                    CupertinoPageRoute<String>(
                                                      builder: (context) => MyLocationsSelect(
                                                        brandId: currentBrand.id!,
                                                      ),
                                                    )
                                                );
                                                if (result != null) {
                                                  getLocation(result);
                                                } else {
                                                  setState(() {
                                                    isLoading = false;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                          allBonos.isNotEmpty ? Column(
                                            children: [
                                              Padding(
                                                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.03),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.max,
                                                    children: <Widget>[
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: <Widget>[
                                                          Text(
                                                            AppLocalizations.of(context)!.bonos,
                                                            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01, bottom: MediaQuery.of(context).size.height*0.0),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.max,
                                                    children: <Widget>[
                                                      Flexible(
                                                        child: Text(
                                                          AppLocalizations.of(context)!.bonosDescription,
                                                          style: Theme.of(context).textTheme.caption,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                              ),
                                            ],
                                          ) : Container(),

                                        ],
                                      ),
                                    ),
                                    allBonos.isNotEmpty ? SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.height*0.21,
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          physics: const BouncingScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          itemCount: allBonos.length,
                                          itemBuilder: (context, int index) {
                                            var bono = allBonos[index];
                                            return Row(
                                              children: [
                                                index == 0 ? SizedBox(width: MediaQuery.of(context).size.width * 0.05) : Container(),
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 16.0),
                                                  child: Container(
                                                      width: MediaQuery.of(context).size.width * 0.75,
                                                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.03),
                                                      child: Stack(
                                                        alignment: Alignment.bottomLeft,
                                                        children: [
                                                          Positioned(
                                                            top: 10,
                                                            child: BonoCard(
                                                              height: MediaQuery.of(context).size.height * 0.18,
                                                              width: MediaQuery.of(context).size.width * 0.7,
                                                              bono: bono,
                                                              brand: currentBrand,
                                                              canExpand: false,
                                                              onlyView: true,
                                                            ),
                                                          ),
                                                          Positioned(
                                                            top: -6,
                                                            left: MediaQuery.of(context).size.width * 0.57,
                                                            child: MaterialButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  if (selectedBonos.contains(bono.id!)) {
                                                                    selectedBonos.remove(bono.id!);
                                                                  } else {
                                                                    selectedBonos.add(bono.id!);
                                                                  }
                                                                });
                                                              },
                                                              elevation: 8,
                                                              color: selectedBonos.contains(bono.id!) ? AppColors.mainColor : AppColors.grey,
                                                              textColor: selectedBonos.contains(bono.id!) ? AppColors.mainColor : AppColors.grey,
                                                              child: selectedBonos.contains(bono.id!) ? Icon(Icons.check, color: AppColors.white, size: MediaQuery.of(context).size.width*0.06,) : Container(),
                                                              padding: null,
                                                              shape: const CircleBorder(),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                  ),
                                                ),
                                                index == allBonos.length-1 ? SizedBox(width: MediaQuery.of(context).size.width * 0.01) : Container(),
                                              ],
                                            );
                                          }
                                      ),
                                    ) : Container(),
                                  ]
                              ),
                            ),
                        ],
                      )
                  ),
                  resizeToAvoidBottomInset: true,
                ),
                Scaffold(
                  body: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.width*0.05),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.20,
                                        width: MediaQuery.of(context).size.width * 0.90,
                                        decoration: BoxDecoration(
                                            color: Theme.of(context).backgroundColor,
                                            borderRadius: const BorderRadius.all(const Radius.circular(15.0))
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.05, horizontal: MediaQuery.of(context).size.width*0.05),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Row(
                                                    children: [
                                                      Icon(Icons.calendar_today_outlined, color: Theme.of(context).colorScheme.secondary,size: MediaQuery.of(context).size.width*0.05,),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                                        width: MediaQuery.of(context).size.width*0.45,
                                                        child: GestureDetector(
                                                            onTap: () {
                                                              selectDate();
                                                            },
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.max,
                                                              children: <Widget>[
                                                                Flexible(
                                                                  child: TextFormField(
                                                                    controller: startDateController,
                                                                    readOnly: true,
                                                                    enabled: false,
                                                                    style: Theme.of(context).textTheme.bodyText2,
                                                                    decoration: const InputDecoration(
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
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.schedule, color: Theme.of(context).colorScheme.secondary,size: MediaQuery.of(context).size.width*0.05,),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                                        width: MediaQuery.of(context).size.width*0.25,
                                                        child: GestureDetector(
                                                            onTap: () {
                                                              selectTime();
                                                            },
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.max,
                                                              children: <Widget>[
                                                                Flexible(
                                                                  child: TextFormField(
                                                                    controller: startTimeController,
                                                                    readOnly: true,
                                                                    enabled: false,
                                                                    style: Theme.of(context).textTheme.bodyText2,
                                                                    decoration: const InputDecoration(
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
                                                      ),
                                                    ],
                                                  ),

                                                ],
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Icon(Icons.timer_outlined, color: Theme.of(context).colorScheme.secondary,size: MediaQuery.of(context).size.width*0.05,),
                                                  Container(
                                                    padding: const EdgeInsets.only(left: 20),
                                                    width: MediaQuery.of(context).size.width*0.30,
                                                    child: GestureDetector(
                                                        onTap: () {
                                                          selectDuration();
                                                        },
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.max,
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: <Widget>[
                                                            Flexible(
                                                              child: TextFormField(
                                                                controller: durationController,
                                                                readOnly: true,
                                                                enabled: false,
                                                                style: Theme.of(context).textTheme.bodyText2,
                                                                decoration: const InputDecoration(
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
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      errorDate ? Padding(
                                        padding: const EdgeInsets.only(left: 25, right: 25, top: 10.0),
                                        child: Center(
                                          child: Text(
                                            AppLocalizations.of(context)!.errorDate,
                                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ) : Container(),
                                      widget.eventId == null ? Column(
                                        children: [
                                          Padding(
                                              padding: const EdgeInsets.only(top: 15,),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)!.recurrentEvent,
                                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                  const SizedBox(width: 10,),
                                                  Checkbox(
                                                    checkColor: Colors.white,
                                                    fillColor: MaterialStateProperty.resolveWith((states) => getColor(states)),
                                                    value: isRecurrent,
                                                    onChanged: (bool? value) {
                                                      setState(() {
                                                        if (isRecurrent) {
                                                          values = [false, false, false, false, false, false, false];
                                                        } else {
                                                          values[startDate.weekday-1] = true;
                                                        }
                                                        isRecurrent = value!;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              )
                                          ),
                                          isRecurrent ? Column(
                                            children: [
                                              Padding(
                                                  padding: const EdgeInsets.only(top: 0),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.max,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: Text(
                                                          AppLocalizations.of(context)!.days,
                                                          style: Theme.of(context).textTheme.bodyText2,
                                                        ),
                                                      ),
                                                      WeekdaySelector(
                                                        fillColor: Colors.white,
                                                        selectedFillColor: Theme.of(context).colorScheme.secondary,
                                                        textStyle: Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.black),
                                                        selectedTextStyle: Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.white),
                                                        firstDayOfWeek: 0,
                                                        shortWeekdays: [
                                                          AppLocalizations.of(context)!.mondayLetter,
                                                          AppLocalizations.of(context)!.tuesdarLetter,
                                                          AppLocalizations.of(context)!.wednesdayLetter,
                                                          AppLocalizations.of(context)!.thursdayLetter,
                                                          AppLocalizations.of(context)!.fridayLetter,
                                                          AppLocalizations.of(context)!.saturadayLetter,
                                                          AppLocalizations.of(context)!.sundayLetter,
                                                        ],
                                                        // Working Days disabledFillColor: Colors.red,
                                                        onChanged: (v) {
                                                          setState(() {
                                                            values[v % 7] = !values[v % 7]!;
                                                          });
                                                        },
                                                        selectedElevation: 15,
                                                        elevation: 5,
                                                        disabledElevation: 0,
                                                        values: values,
                                                      ),
                                                    ],
                                                  )
                                              ),
                                              Padding(
                                                  padding: const EdgeInsets.only(top: 10),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.max,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: Text(
                                                          AppLocalizations.of(context)!.during,
                                                          style: Theme.of(context).textTheme.bodyText2,
                                                        ),
                                                      ),
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          ListTile(
                                                            dense: true,
                                                            contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
                                                            title: Text(
                                                              AppLocalizations.of(context)!.thisWeek,
                                                              style: Theme.of(context).textTheme.bodyText2,
                                                            ),
                                                            subtitle: Text(
                                                              AppLocalizations.of(context)!.until(StringUtils().toCapitalized(DateFormat('EEEE - d/M/yy', widget.locale.languageCode).format(oneWeek))),
                                                              style: Theme.of(context).textTheme.caption,
                                                              textAlign: TextAlign.left,
                                                            ),
                                                            leading: Radio(
                                                              value: 1,
                                                              groupValue: _value,
                                                              activeColor: Theme.of(context).colorScheme.secondary,
                                                              fillColor: MaterialStateProperty.resolveWith((states) => getColor(states)),
                                                              onChanged: (value) {
                                                                setState(() {
                                                                  _value = int.parse(value.toString());
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                          ListTile(
                                                            dense: true,
                                                            contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
                                                            title: Text(
                                                              AppLocalizations.of(context)!.nextTwoWeek,
                                                              style: Theme.of(context).textTheme.bodyText2,
                                                            ),
                                                            subtitle: Text(
                                                              AppLocalizations.of(context)!.until(StringUtils().toCapitalized(DateFormat('EEEE - d/M/yy', widget.locale.languageCode).format(twoWeek))),
                                                              style: Theme.of(context).textTheme.caption,
                                                              textAlign: TextAlign.left,
                                                            ),
                                                            leading: Radio(
                                                              value: 2,
                                                              groupValue: _value,
                                                              activeColor: Theme.of(context).colorScheme.secondary,
                                                              fillColor: MaterialStateProperty.resolveWith((states) => getColor(states)),
                                                              onChanged: (value) {
                                                                setState(() {
                                                                  _value = int.parse(value.toString());
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                          ListTile(
                                                            dense: true,
                                                            contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
                                                            title: Text(
                                                              AppLocalizations.of(context)!.wholeMonth,
                                                              style: Theme.of(context).textTheme.bodyText2,
                                                            ),
                                                            subtitle: Text(
                                                              AppLocalizations.of(context)!.until(StringUtils().toCapitalized(DateFormat('EEEE - d/M/yy', widget.locale.languageCode).format(oneMonth))),
                                                              style: Theme.of(context).textTheme.caption,
                                                              textAlign: TextAlign.left,
                                                            ),
                                                            leading: Radio(
                                                              value: 3,
                                                              groupValue: _value,
                                                              activeColor: Theme.of(context).colorScheme.secondary,
                                                              fillColor: MaterialStateProperty.resolveWith((states) => getColor(states)),
                                                              onChanged: (value) {
                                                                setState(() {
                                                                  _value = int.parse(value.toString());
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  )
                                              ),
                                            ],
                                          ) : Container(),
                                          SizedBox(height: MediaQuery.of(context).size.height*0.05)
                                        ],
                                      ) : Container(),
                                      event.eventGroupId != null ? Padding(
                                          padding: const EdgeInsets.only(top: 15,),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)!.recurrentEvent,
                                                style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(width: 10,),
                                              Checkbox(
                                                checkColor: Colors.white,
                                                fillColor: MaterialStateProperty.resolveWith((states) => getColor(states)),
                                                value: true,
                                                onChanged: null,
                                              ),
                                            ],
                                          )
                                      ) : Container(),
                                    ]
                                )
                            ),
                        ],
                      )
                  ),
                  resizeToAvoidBottomInset: true,
                ),
                Scaffold(
                  body: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.03, left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.05),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Text(
                                                    AppLocalizations.of(context)!.designatedTrainers,
                                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width*0.03,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "( "+brandTrainersSelected.length.toString()+" )",
                                                    style: Theme.of(context).textTheme.bodyText2,
                                                  ),
                                                ],
                                              )
                                            ],
                                          )
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.005),
                                        child: SizedBox(
                                          width: MediaQuery.of(context).size.width,
                                          child: SingleChildScrollView(
                                            physics: const BouncingScrollPhysics(),
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                buildAddUserButton(true),
                                                SizedBox(
                                                  height: MediaQuery.of(context).size.height*0.15,
                                                  child: ListView.builder(
                                                      shrinkWrap: true,
                                                      physics: const NeverScrollableScrollPhysics(),
                                                      scrollDirection: Axis.horizontal,
                                                      itemCount: brandTrainersSelected.length,
                                                      itemBuilder: (context, int index) {
                                                        var trainer = brandTrainersSelected[index];
                                                        return GestureDetector(
                                                          onTap: () {
                                                            var temp = brandTrainersSelected;
                                                            temp.remove(trainer);
                                                            setState(() {
                                                              brandTrainersSelected = temp;
                                                            });
                                                          },
                                                          child: Padding(
                                                            padding: !(index == brandTrainersSelected.length-1) ? const EdgeInsets.symmetric(horizontal: 8.0) : EdgeInsets.only(right: brandTrainersSelected.length != 1 ? MediaQuery.of(context).size.width*0.06 : 8.0, left: 8.0),
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Stack(
                                                                  alignment: Alignment.topRight,
                                                                  children: [
                                                                    CircularImage(
                                                                      size: MediaQuery.of(context).size.width*0.17,
                                                                      image: trainer.imageUrl,
                                                                      color: Theme.of(context).primaryColor,
                                                                      borderWidth: 1,
                                                                    ),
                                                                    Positioned(
                                                                      top: 0,
                                                                      left: MediaQuery.of(context).size.width*0.12,
                                                                      child: CircleAvatar(
                                                                        backgroundColor: AppColors.red,
                                                                        radius: MediaQuery.of(context).size.width*0.025,
                                                                        child: Icon(Icons.clear, color: AppColors.white, size: MediaQuery.of(context).size.width*0.035,),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: MediaQuery.of(context).size.width*0.02,
                                                                ),
                                                                SizedBox(
                                                                  width: MediaQuery.of(context).size.width*0.2,
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: [
                                                                      Text(
                                                                        trainer.firstName!,
                                                                        style: Theme.of(context).textTheme.bodyText2,
                                                                        textAlign: TextAlign.center,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      errorNoTrainerSelected ? Padding(
                                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01, left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.05),
                                        child: Center(
                                          child: Text(
                                            AppLocalizations.of(context)!.noTrainerSelectedError,
                                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ) : Container(),

                                      Padding(
                                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.02, left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.05),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Text(
                                                    AppLocalizations.of(context)!.maxNumberClients,
                                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01, left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.05),
                                        child: GestureDetector(
                                          onTap: () {
                                            selectNumberOfMembers();
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              Icon(Icons.person, color: Theme.of(context).colorScheme.secondary, size: MediaQuery.of(context).size.width*0.05,),
                                              Container(
                                                padding: const EdgeInsets.only(left: 20),
                                                width: MediaQuery.of(context).size.width*0.11,
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Flexible(
                                                      child: TextFormField(
                                                        controller: membersController,
                                                        readOnly: true,
                                                        enabled: false,
                                                        style: Theme.of(context).textTheme.bodyText2,
                                                        decoration: const InputDecoration(
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
                                                ),
                                              ),
                                              Text(
                                                AppLocalizations.of(context)!.members.toLowerCase(),
                                                style: Theme.of(context).textTheme.bodyText2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),


                                      Padding(
                                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.03, left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.05),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Text(
                                                    AppLocalizations.of(context)!.addDesignatedClients,
                                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width*0.03,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "( "+brandClientsSelected.length.toString(),
                                                    style: Theme.of(context).textTheme.bodyText2,
                                                  ),
                                                  Text(
                                                    " / ",
                                                    style: Theme.of(context).textTheme.bodyText2,
                                                  ),
                                                  Text(
                                                    eventMaxMembers.toString()+" )",
                                                    style: Theme.of(context).textTheme.bodyText2,
                                                  ),
                                                ],
                                              )
                                            ],
                                          )
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.005),
                                        child: SizedBox(
                                          width: MediaQuery.of(context).size.width,
                                          child: SingleChildScrollView(
                                            physics: const BouncingScrollPhysics(),
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                buildAddUserButton(false),
                                                SizedBox(
                                                  height: MediaQuery.of(context).size.height*0.15,
                                                  child: ListView.builder(
                                                      shrinkWrap: true,
                                                      physics: const NeverScrollableScrollPhysics(),
                                                      scrollDirection: Axis.horizontal,
                                                      itemCount: brandClientsSelected.length,
                                                      itemBuilder: (context, int index) {
                                                        var trainer = brandClientsSelected[index];
                                                        return GestureDetector(
                                                          onTap: () {
                                                            var temp = brandClientsSelected;
                                                            temp.remove(trainer);
                                                            setState(() {
                                                              brandClientsSelected = temp;
                                                            });
                                                          },
                                                          child: Padding(
                                                            padding: !(index == brandClientsSelected.length-1) ? const EdgeInsets.symmetric(horizontal: 8.0) : EdgeInsets.only(right: brandClientsSelected.length != 1 ? MediaQuery.of(context).size.width*0.06 : 8.0, left: 8.0),
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Stack(
                                                                  alignment: Alignment.topRight,
                                                                  children: [
                                                                    CircularImage(
                                                                      size: MediaQuery.of(context).size.width*0.17,
                                                                      image: trainer.imageUrl,
                                                                      color: Theme.of(context).primaryColor,
                                                                      borderWidth: 1,
                                                                    ),
                                                                    Positioned(
                                                                      top: 0,
                                                                      left: MediaQuery.of(context).size.width*0.12,
                                                                      child: CircleAvatar(
                                                                        backgroundColor: AppColors.red,
                                                                        radius: MediaQuery.of(context).size.width*0.025,
                                                                        child: Icon(Icons.clear, color: AppColors.white, size: MediaQuery.of(context).size.width*0.035,),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: MediaQuery.of(context).size.width*0.02,
                                                                ),
                                                                SizedBox(
                                                                  width: MediaQuery.of(context).size.width*0.2,
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: [
                                                                      Text(
                                                                        trainer.firstName!,
                                                                        style: Theme.of(context).textTheme.bodyText2,
                                                                        textAlign: TextAlign.center,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                /*
                                                                    Container(
                                                                      width: MediaQuery.of(context).size.width*0.2,
                                                                      width: MediaQuery.of(context).size.widtdurh*0.2,
                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                            trainer.firstName!,
                                                                            style: Theme.of(context).textTheme.bodyText2,
                                                                            textAlign: TextAlign.center,
                                                                          ),
                                                                          SizedBox(
                                                                            width: MediaQuery.of(context).size.width*0.01,
                                                                          ),
                                                                          SizedBox(
                                                                            width: MediaQuery.of(context).size.width*0.05,
                                                                            child: IconButton(
                                                                              icon: Icon(Icons.remove_circle, color: Theme.of(context).colorScheme.secondary,),
                                                                              onPressed: () {
                                                                              },
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                     */
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      errorClientsSelected ? Padding(
                                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01, left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.05),
                                        child: Center(
                                          child: Text(
                                            AppLocalizations.of(context)!.clientsSelectedError,
                                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ) : Container(),

                                    ]
                                )
                            ),
                        ],
                      )
                  ),
                  resizeToAvoidBottomInset: true,
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
                child: SizedBox(
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
                child: SizedBox(
                  height: 50,
                  child: FloatingActionButton.extended(
                    heroTag: "5",
                    onPressed: () async {
                      if (_selectedIndex == 0) {
                        if (formKeyInfo.currentState!.validate()) {
                          if (eventImageUrl == null && isRandomImage == false) {
                            setState(() {
                              imageError = true;
                            });
                          } else {
                            _tabController!.animateTo(_selectedIndex += 1);
                            setState(() {
                              addEventTabValue += 0.33;
                              tabs[1] = true;
                            });
                          }
                        }
                      } else if (_selectedIndex == 1) {
                        setState(() {
                          errorDate = false;
                        });
                        if (validateDateAndTime(startDate, double.parse(duration))) {
                          _tabController!.animateTo(_selectedIndex += 1);
                          setState(() {
                            addEventTabValue += 0.33;
                            tabs[2] = true;
                          });
                        } else {
                          setState(() {
                            errorDate = true;
                          });
                        }
                      } else if (_selectedIndex == 2) {
                        if (brandTrainersSelected.length == 0) {
                          setState(() {
                            errorNoTrainerSelected = true;
                          });
                        } else if (brandClientsSelected.length > eventMaxMembers) {
                          setState(() {
                            errorClientsSelected = true;
                          });
                        } else {
                          if (widget.eventId == null) {
                            _addEventFunction();
                          } else {
                            if (event.eventGroupId == null) {
                              _updateEventFunction();
                            } else {
                              var result = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return const EditRecurrentEventDialog();
                                },
                              );
                              if (result != null) {
                                if (result == 1) {
                                  print("Edit Only This Event..");
                                  _updateEventFunction();
                                } else {
                                  print("Edit This Event and the Rest Forward ...");
                                  _updateRecurrentEventFunction();
                                }
                              }
                            }
                          }
                        }
                      }
                    },
                    backgroundColor: _selectedIndex == 2 ? Colors.green : Theme.of(context).colorScheme.secondary,
                    icon: Container(),
                    label: widget.eventId == null ? Text(
                      _selectedIndex == 2 ? AppLocalizations.of(context)!.createEvent : AppLocalizations.of(context)!.next,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(color: AppColors.white),) : Text(
                      _selectedIndex == 2 ? AppLocalizations.of(context)!.editEvent : AppLocalizations.of(context)!.next,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(color: AppColors.white),),
                  ),
                ),
              ),
            ],
          ),
      ),
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

  Future<void> _addEventFunction() async {
    setState(() {
      isLoading = true;
    });
    // Get Random Photo if no Image Selected
    if (eventImageUrl == null || (eventImageUrl != null && isRandomImage)) {
      eventImageUrl = await _brandDataService.getRandomBrandPhoto(currentBrand.id!);
    }
    // Event Start Date
    Timestamp doneAt = Timestamp.fromDate(startDate);
    // Event Members
    List<Usuario> eventMembers = List.from(brandTrainersSelected);
    eventMembers.addAll(brandClientsSelected);
    if (!isRecurrent) {
      // Creating Event Object
      Event event = Event(
        isPrivate: false,
        title: titleController.text,
        description: descriptionController.text,
        imageUrl: eventImageUrl,
        doneAt: doneAt,
        createdAt: Timestamp.now(),
        year: startDate.year.toString(),
        month: startDate.month.toString(),
        day: startDate.day.toString(),
        hour: startDate.hour.toString(),
        minute: startDate.minute.toString(),
        duration: double.parse(duration),
        locationId: location.id,
        numClients: brandClientsSelected.length,
        numTrainers: brandTrainersSelected.length,
        maxMembers: eventMaxMembers,
      );
      // Add Event
      String eventId = await _addEventCall(event);
      // Add Event Members
      await _addEventMembersCall(eventId, eventMembers);
      // Add Event Bonos
      _addEventBonosCall(eventId, selectedBonos);
    } else {
      // Recurrent total
      int days = values.where((item) => item == true).length;
      totalEvents = days*_value;
      // Event Group Id
      String eventGroupId = const Uuid().v1();
      // First the First Event
      Event event = Event(
        isPrivate: false,
        eventGroupId: eventGroupId,
        title: titleController.text,
        description: descriptionController.text,
        imageUrl: eventImageUrl,
        doneAt: doneAt,
        createdAt: Timestamp.now(),
        year: startDate.year.toString(),
        month: startDate.month.toString(),
        day: startDate.day.toString(),
        hour: startDate.hour.toString(),
        minute: startDate.minute.toString(),
        duration: double.parse(duration),
        locationId: location.id,
        numClients: brandClientsSelected.length,
        numTrainers: brandTrainersSelected.length,
        maxMembers: eventMaxMembers,
      );
      // Add Event
      String eventId = await _addEventCall(event);
      // Add Event Members
      await _addEventMembersCall(eventId, eventMembers);
      // Add Event Bonos
      _addEventBonosCall(eventId, selectedBonos);
      // Start Recurrence
      List<String> groupEventsIds = [eventId];
      var tempDate = startDate.add(const Duration(days: 1));
      var tempTimestamp = Timestamp.fromDate(tempDate);
      var weekDay = tempDate.weekday;
      if (_value == 1) {
        // One Week
        for (var i=0; i<6; i++) {
          if (values[weekDay-1]!) {
            // Updating Loading Text
            setState(() {
              isRecurrentLoadingText = AppLocalizations.of(context)!.creating +" "+ AppLocalizations.of(context)!.events.toLowerCase() + "... (" + currentEvent.toString()+"/"+totalEvents.toString()+")";
            });
            currentEvent += 1;
            // Change Image Url if IsRecurrent is Selected
            if (isRandomImage) {
              eventImageUrl = await _brandDataService.getRandomBrandPhoto(currentBrand.id!);
            }
            // Event Object
            event = Event(
              isPrivate: false,
              eventGroupId: eventGroupId,
              title: titleController.text,
              description: descriptionController.text,
              imageUrl: eventImageUrl,
              doneAt: tempTimestamp,
              createdAt: Timestamp.now(),
              year: tempDate.year.toString(),
              month: tempDate.month.toString(),
              day: tempDate.day.toString(),
              hour: tempDate.hour.toString(),
              minute: tempDate.minute.toString(),
              duration: double.parse(duration),
              locationId: location.id,
              numClients: brandClientsSelected.length,
              numTrainers: brandTrainersSelected.length,
              maxMembers: eventMaxMembers,
            );
            // Add Event
            String eventId = await _addEventCall(event);
            // Add Event to Group Events
            groupEventsIds.add(eventId);
            // Add Event Members
            await _addEventMembersCall(eventId, eventMembers);
            // Add Event Bonos
            _addEventBonosCall(eventId, selectedBonos);
          }
          tempDate = tempDate.add(const Duration(days: 1));
          tempTimestamp = Timestamp.fromDate(tempDate);
          weekDay = tempDate.weekday;
        }
      } else if (_value == 2) {
        // Two Weeks
        for (var i=0; i<13; i++) {
          if (values[weekDay-1]!) {
            // Updating Loading Text
            setState(() {
              isRecurrentLoadingText = AppLocalizations.of(context)!.creating +" "+ AppLocalizations.of(context)!.events.toLowerCase() + "... (" + currentEvent.toString()+"/"+totalEvents.toString()+")";
            });
            currentEvent += 1;
            // Change Image Url if IsRecurrent is Selected
            if (isRandomImage) {
              eventImageUrl = await _brandDataService.getRandomBrandPhoto(currentBrand.id!);
            }
            // Event Object
            event = Event(
              isPrivate: false,
              eventGroupId: eventGroupId,
              title: titleController.text,
              description: descriptionController.text,
              imageUrl: eventImageUrl,
              doneAt: tempTimestamp,
              createdAt: Timestamp.now(),
              year: tempDate.year.toString(),
              month: tempDate.month.toString(),
              day: tempDate.day.toString(),
              hour: tempDate.hour.toString(),
              minute: tempDate.minute.toString(),
              duration: double.parse(duration),
              locationId: location.id,
              numClients: brandClientsSelected.length,
              numTrainers: brandTrainersSelected.length,
              maxMembers: eventMaxMembers,
            );
            // Add Event
            String eventId = await _addEventCall(event);
            // Add Event to Group Events
            groupEventsIds.add(eventId);
            // Add Event Members
            await _addEventMembersCall(eventId, eventMembers);
            // Add Event Bonos
            _addEventBonosCall(eventId, selectedBonos);
          }
          tempDate = tempDate.add(const Duration(days: 1));
          tempTimestamp = Timestamp.fromDate(tempDate);
          weekDay = tempDate.weekday;
        }
      } else if (_value == 3) {
        // One Month
        for (var i=0; i<27; i++) {
          if (values[weekDay-1]!) {
            // Updating Loading Text
            setState(() {
              isRecurrentLoadingText = AppLocalizations.of(context)!.creating +" "+ AppLocalizations.of(context)!.events.toLowerCase() + "... (" + currentEvent.toString()+"/"+totalEvents.toString()+")";
            });
            currentEvent += 1;
            // Change Image Url if IsRecurrent is Selected
            if (isRandomImage) {
              eventImageUrl = await _brandDataService.getRandomBrandPhoto(currentBrand.id!);
            }
            // Event Object
            event = Event(
              //isPrivate: false,
              eventGroupId: eventGroupId,
              title: titleController.text,
              description: descriptionController.text,
              imageUrl: eventImageUrl,
              doneAt: tempTimestamp,
              createdAt: Timestamp.now(),
              year: tempDate.year.toString(),
              month: tempDate.month.toString(),
              day: tempDate.day.toString(),
              hour: tempDate.hour.toString(),
              minute: tempDate.minute.toString(),
              duration: double.parse(duration),
              locationId: location.id,
              numClients: brandClientsSelected.length,
              numTrainers: brandTrainersSelected.length,
              maxMembers: eventMaxMembers,
            );
            // Add Event
            String eventId = await _addEventCall(event);
            // Add Event to Group Events
            groupEventsIds.add(eventId);
            // Add Event Members
            await _addEventMembersCall(eventId, eventMembers);
            // Add Event Bonos
            _addEventBonosCall(eventId, selectedBonos);
          }
          tempDate = tempDate.add(const Duration(days: 1));
          tempTimestamp = Timestamp.fromDate(tempDate);
          weekDay = tempDate.weekday;
        }
      }
      // Create Entry in /Event Groups
      await _eventDataService.addRecurrentEventGroup(eventGroupId, groupEventsIds);
    }
    Navigator.pop(context);
  }

  Future<void> _deleteEventFunction() async {
    setState(() {
      isLoading = true;
    });
    // Delete Event Call
    await _eventDataService.deleteEvent(widget.eventId!);
    // Event Members
    List<Usuario> eventMembers = List.from(brandTrainersSelected);
    eventMembers.addAll(brandClientsSelected);
    // Delete Event Bonos
    List<String> deleteBonos = [];
    for (Bono bono in eventBonos) {
      deleteBonos.add(bono.id!);
    }
    _deleteEventBonosCall(widget.eventId!);
    // Delete Event Local Notifications
    for (var i=0; i<eventMembers.length; i++) {
      var user = eventMembers[i];
      // Remove Local Notifications Service
      await _deleteEventLocalNotificationsCall(event.id!, user.id!);
    }
    // Delete Event From Event Group Id in Case it has any.
    if (event.eventGroupId != null) {
      // Get Recurrent Group Ids ..
      var eventGroupIds = await _eventDataService.getRecurrentEventGroup(event.eventGroupId!);
      // Delete Only This Event..
      eventGroupIds.removeWhere((element) => element == event.id!);
      // Delete Event From Recurrent Group..
      if (eventGroupIds.isNotEmpty) {
        await _eventDataService.updateRecurrentEventGroup(event.eventGroupId!, eventGroupIds);
      } else {
        await _eventDataService.deleteRecurrentEventGroup(event.eventGroupId!);
      }
    }
    // Pop to Last Page
    Navigator.pop(context, false);
  }

  Future<void> _updateEventFunction() async {
    print("update event");
    setState(() {
      isLoading = true;
    });
    // Get Random Photo if no Image Selected
    if (isRandomImage) {
      eventImageUrl = await _brandDataService.getRandomBrandPhoto(currentBrand.id!);
    }
    // Event Start Date
    Timestamp doneAt = Timestamp.fromDate(startDate);
    // Creating Event Object
    Event event = Event(
      id: widget.eventId!,
      title: titleController.text,
      description: descriptionController.text,
      imageUrl: eventImageUrl,
      doneAt: doneAt,
      createdAt: Timestamp.now(),
      year: startDate.year.toString(),
      month: startDate.month.toString(),
      day: startDate.day.toString(),
      hour: startDate.hour.toString(),
      minute: startDate.minute.toString(),
      duration: double.parse(duration),
      locationId: location.id,
      numClients: brandClientsSelected.length,
      numTrainers: brandTrainersSelected.length,
      maxMembers: eventMaxMembers,
    );
    // Event Members
    List<Usuario> eventTrainers = List.from(brandTrainersSelected);
    List<Usuario> eventTrainersAdded = List.from(eventTrainers);
    List<Usuario> eventClients = List.from(brandClientsSelected);
    List<Usuario> eventClientsAdded = List.from(eventClients);
    // Update Event
    await _eventDataService.updateEvent(event);
    // Update Event Bonos
    List<String> originalBonos = [];
    for (Bono bono in eventBonos) {
      originalBonos.add(bono.id!);
    }
    originalBonos.sort((a,b) {
      return a.compareTo(b);
    });
    selectedBonos.sort((a,b) {
      return a.compareTo(b);
    });
    if (selectedBonos != originalBonos) {
      await _eventDataService.updateEventBonos(event.id!, selectedBonos);
    }
    // Update Event Location
    if (event.locationId! != originalLocationId) {
      await _eventDataService.updateEventLocation(event.id!, event.locationId!, originalLocationId!);
    }
    // Compare Current Members vs Original Members
    /// Start With Trainers
    for (int i = 0; i < eventTrainers.length; i++) {
      var user = eventTrainers[i];
      // Find index in EventTrainers
      int index = originalTrainers.indexWhere((element) => element.id == user.id);
      // Trainer Found
      if (index != -1) {
        // Remove Trainer Left
        eventTrainersAdded.removeWhere((element) => element.id == user.id);
        originalTrainers.removeWhere((element) => element.id == user.id);
        print("Trainer Matched "+user.id.toString());
        if (originalStartDate != startDate) {
          // Remove Old Local Notification
          await _deleteEventLocalNotificationsCall(event.id!, user.id!);
          // Add updated ones now
          await _addEventLocalNotificationsCall(event.id!, user.id!, user.isTrainer!);
        }
      }
    }
    /// Handle Trainers Not Matched
    // Original Trainers Not Matched means that they have been removed from Event
    for (int i = 0; i < originalTrainers.length; i++) {
      var user = originalTrainers[i];
      // Remove Trainer From Event
      await _eventDataService.deleteUserFromEvent(event.id!, user.id!);
      // Remove Event Local Notifications
      await _deleteEventLocalNotificationsCall(event.id!, user.id!);
      print("Trainer Removed "+user.id.toString());
    }
    /// Handle Trainers Added
    // Trainers Added Not Matched means that they have added to the Event
    for (int i = 0; i < eventTrainersAdded.length; i++) {
      var user = eventTrainersAdded[i];
      // Add Trainer to Event
      if (user.id != currentUser.id!) {
        await _eventDataService.addUserToEvent(event.id!, user.id!, true);
      } else {
        await _eventDataService.addUserToEvent(event.id!, user.id!);
      }
      // Add Event Local Notifications
      await _addEventLocalNotificationsCall(event.id!, user.id!, user.isTrainer!);
      print("Trainer Added "+user.id.toString());
    }
    /// Continue With Clients
    for (int i = 0; i < eventClients.length; i++) {
      var user = eventClients[i];
      // Find index in EventClients
      int index = originalClients.indexWhere((element) => element.id == user.id);
      // Client Found
      if (index != -1) {
        // Remove Trainer Left
        eventClientsAdded.removeWhere((element) => element.id == user.id);
        originalClients.removeWhere((element) => element.id == user.id);
        print("Client Matched "+user.id.toString());
        if (originalStartDate != startDate) {
          // Remove Old Local Notification
          await _deleteEventLocalNotificationsCall(event.id!, user.id!);
          // Add updated ones now
          await _addEventLocalNotificationsCall(event.id!, user.id!, user.isTrainer!);
        }
      }
    }
    // Handle Clients Not Matched
    // Original Clients Not Matched means that they have been removed from Event
    for (int i = 0; i < originalClients.length; i++) {
      var user = originalClients[i];
      // Remove Client From Event
      await _eventDataService.deleteUserFromEvent(event.id!, user.id!);
      // Send Client Left Event
      _notificationService.userLeaveEvent(user.id!, currentBrand.id!, event.id!);
      // Remove Event Local Notifications
      await _deleteEventLocalNotificationsCall(event.id!, user.id!);
      print("Client Removed "+user.id.toString());
    }
    // Handle Clients Added
    // Clients Added Not Matched means that they have added to the Event
    for (int i = 0; i < eventClientsAdded.length; i++) {
      var user = eventClientsAdded[i];
      // Add Clients to Event
      await _eventDataService.addUserToEvent(event.id!, user.id!, true);
      // Add Event Local Notifications
      await _addEventLocalNotificationsCall(event.id!, user.id!, user.isTrainer!);
      print("Client Added "+user.id.toString());
    }
    Navigator.pop(context, true);
  }

  // Recurrent Events

  Future<void> _deleteRecurrentEventFunction() async {
    setState(() {
      isLoading = true;
    });
    // Get Recurrent Group Ids ..
    var eventGroupIds = await _eventDataService.getRecurrentEventGroup(event.eventGroupId!);
    List<String> eventGroupIdsList = eventGroupIds.cast<String>();
    // Find index of Current Event
    int index = eventGroupIdsList.indexWhere((element) => element == event.id!);
    // Update Recurrent Event Group
    if (index == 0) {
      await _eventDataService.deleteRecurrentEventGroup(event.eventGroupId!);
    } else {
      eventGroupIds = eventGroupIds.sublist(0, index);
      await _eventDataService.updateRecurrentEventGroup(event.eventGroupId!, eventGroupIds);
    }
    // Recurrent total
    totalEvents = eventGroupIdsList.length - index;
    // Delete All Events After The Index
    for (var i=index; i<eventGroupIdsList.length; i++) {
      // Updating Loading Text
      setState(() {
        isRecurrentLoadingText = AppLocalizations.of(context)!.deleting +" "+ AppLocalizations.of(context)!.events.toLowerCase() + "... (" + currentEvent.toString()+"/"+totalEvents.toString()+")";
      });
      currentEvent += 1;
      // Event Id
      String eventId = eventGroupIdsList[i];
      // Delete Event Call
      await _eventDataService.deleteEvent(eventId);
      // Delete Event Bonos
      _deleteEventBonosCall(eventId);
      // Delete Event Members
      List<Usuario> eventMembers = await _eventDataService.getEventUsers(eventId);
      // Delete Event Local Notifications
      for (var i=0; i<eventMembers.length; i++) {
        var user = eventMembers[i];
        // Remove Local Notifications Service
        await _deleteEventLocalNotificationsCall(event.id!, user.id!);
      }
    }
    // Pop to Last Page
    Navigator.pop(context, false);
  }

  Future<void> _updateRecurrentEventFunction() async {
    setState(() {
      isLoading = true;
    });
    // Get Recurrent Group Ids ..
    var eventGroupIds = await _eventDataService.getRecurrentEventGroup(event.eventGroupId!);
    List<String> eventGroupIdsList = eventGroupIds.cast<String>();
    // Find index of Current Event
    int index = eventGroupIdsList.indexWhere((element) => element == event.id!);
    // Recurrent total
    totalEvents = eventGroupIdsList.length - index;
    // Update All Events After The Index
    for (var i=index; i<eventGroupIdsList.length; i++) {
      // Updating Loading Text
      setState(() {
        isRecurrentLoadingText = AppLocalizations.of(context)!.editing +" "+ AppLocalizations.of(context)!.events.toLowerCase() + "... (" + currentEvent.toString()+"/"+totalEvents.toString()+")";
      });
      currentEvent += 1;
      // Event Id
      String eventId = eventGroupIdsList[i];
      // Get Random Photo if no Image Selected
      if (isRandomImage) {
        eventImageUrl = await _brandDataService.getRandomBrandPhoto(currentBrand.id!);
      }
      // Original Event Data
      Event originalEvent = await _eventDataService.getSingleEvent(eventId);
      List<Usuario> originalUsers = await _eventDataService.getEventUsers(eventId);
      List<Usuario> originalTrainers = [];
      List<Usuario> originalClients = [];
      for (var u in originalUsers) {
        if (u.isTrainer!) {
          originalTrainers.add(u);
        } else {
          originalClients.add(u);
        }
      }
      // Event Start Date
      var originalStartDate = DateTime(
        int.parse(originalEvent.year!),
        int.parse(originalEvent.month!),
        int.parse(originalEvent.day!),
        int.parse(originalEvent.hour!),
        int.parse(originalEvent.minute!),
      );
      var updatedStartDate = DateTime(
        int.parse(originalEvent.year!),
        int.parse(originalEvent.month!),
        int.parse(originalEvent.day!),
        startDate.hour,
        startDate.minute,
      );
      Timestamp doneAt = Timestamp.fromDate(updatedStartDate);
      // Creating Event Object
      Event updatedEvent = Event(
        id: eventId,
        title: titleController.text,
        description: descriptionController.text,
        imageUrl: eventImageUrl,
        doneAt: doneAt,
        createdAt: Timestamp.now(),
        year: updatedStartDate.year.toString(),
        month: updatedStartDate.month.toString(),
        day: updatedStartDate.day.toString(),
        hour: updatedStartDate.hour.toString(),
        minute: updatedStartDate.minute.toString(),
        duration: double.parse(duration),
        locationId: location.id,
        numClients: brandClientsSelected.length,
        numTrainers: brandTrainersSelected.length,
        maxMembers: eventMaxMembers,
      );
      // Update Event
      await _eventDataService.updateEvent(updatedEvent);
      // Update Event Bonos
      List<Bono> eventBonosOrg = await _eventDataService.getEventBonos(eventId, currentBrand.id!);
      List<String> originalBonos = [];
      for (Bono bono in eventBonosOrg) {
        originalBonos.add(bono.id!);
      }
      originalBonos.sort((a,b) {
        return a.compareTo(b);
      });
      selectedBonos.sort((a,b) {
        return a.compareTo(b);
      });
      if (selectedBonos != originalBonos) {
        await _eventDataService.updateEventBonos(eventId, selectedBonos);
      }
      // Update Event Location
      if (event.locationId! != originalEvent.locationId!) {
        await _eventDataService.updateEventLocation(eventId, event.locationId!, originalEvent.locationId!);
      }
      // Event Members
      List<Usuario> eventTrainers = List.from(brandTrainersSelected);
      List<Usuario> eventTrainersAdded = List.from(eventTrainers);
      List<Usuario> eventClients = List.from(brandClientsSelected);
      List<Usuario> eventClientsAdded = List.from(eventClients);
      // Compare Current Members vs Original Members
      /// Start With Trainers
      for (int i = 0; i < eventTrainers.length; i++) {
        var user = eventTrainers[i];
        // Find index in EventTrainers
        int index = originalTrainers.indexWhere((element) => element.id == user.id);
        // Trainer Found
        if (index != -1) {
          // Remove Trainer Left
          eventTrainersAdded.removeWhere((element) => element.id == user.id);
          originalTrainers.removeWhere((element) => element.id == user.id);
          print("Trainer Matched "+user.id.toString());
          if (originalStartDate != updatedStartDate) {
            // Remove Old Local Notification
            await _deleteEventLocalNotificationsCall(event.id!, user.id!);
            // Add updated ones now
            await _addEventLocalNotificationsCall(event.id!, user.id!, user.isTrainer!);
          }
        }
      }
      /// Handle Trainers Not Matched
      // Original Trainers Not Matched means that they have been removed from Event
      for (int i = 0; i < originalTrainers.length; i++) {
        var user = originalTrainers[i];
        // Remove Trainer From Event
        await _eventDataService.deleteUserFromEvent(eventId, user.id!);
        // Remove Event Local Notifications
        await _deleteEventLocalNotificationsCall(eventId, user.id!);
        print("Trainer Removed "+user.id.toString());
      }
      // Handle Trainers Added
      // Trainers Added Not Matched means that they have added to the Event
      for (int i = 0; i < eventTrainersAdded.length; i++) {
        var user = eventTrainersAdded[i];
        // Add Trainer to Event
        if (user.id != currentUser.id!) {
          await _eventDataService.addUserToEvent(event.id!, user.id!, true);
        } else {
          await _eventDataService.addUserToEvent(event.id!, user.id!);
        }
        // Add Event Local Notifications
        await _addEventLocalNotificationsCall(eventId, user.id!, user.isTrainer!);
        print("Trainer Added "+user.id.toString());
      }
      /// Continue With Clients
      for (int i = 0; i < eventClients.length; i++) {
        var user = eventClients[i];
        // Find index in EventClients
        int index = originalClients.indexWhere((element) => element.id == user.id);
        // Client Found
        if (index != -1) {
          // Remove Trainer Left
          eventClientsAdded.removeWhere((element) => element.id == user.id);
          originalClients.removeWhere((element) => element.id == user.id);
          print("Client Matched "+user.id.toString());
          if (originalStartDate != updatedStartDate) {
            // Remove Old Local Notification
            await _deleteEventLocalNotificationsCall(event.id!, user.id!);
            // Add updated ones now
            await _addEventLocalNotificationsCall(event.id!, user.id!, user.isTrainer!);
          }
        }
      }
      // Handle Clients Not Matched
      // Original Clients Not Matched means that they have been removed from Event
      for (int i = 0; i < originalClients.length; i++) {
        var user = originalClients[i];
        // Remove Client From Event
        await _eventDataService.deleteUserFromEvent(eventId, user.id!);
        // Send Client Left Event
        _notificationService.userLeaveEvent(user.id!, currentBrand.id!, eventId);
        // Remove Event Local Notifications
        await _deleteEventLocalNotificationsCall(eventId, user.id!);
        print("Client Removed "+user.id.toString());
      }
      // Handle Clients Added
      // Clients Added Not Matched means that they have added to the Event
      for (int i = 0; i < eventClientsAdded.length; i++) {
        var user = eventClientsAdded[i];
        // Add Clients to Event
        await _eventDataService.addUserToEvent(eventId, user.id!, true);
        // Add Event Local Notifications
        await _addEventLocalNotificationsCall(eventId, user.id!, user.isTrainer!);
        print("Client Added "+user.id.toString());
      }
    }
    // Pop to Get Back
    Navigator.pop(context, true);
  }

  // Firebase Calls

  Future<String> _addEventCall(Event event) async {
    // Add Event
    String eid = await _eventDataService.addEvent(event);
    return eid;
  }

  Future<void> _addEventMembersCall(String eventId, List<Usuario> eventMembers) async {
    // Add Event Members
    for (var i=0; i<eventMembers.length; i++) {
      var user = eventMembers[i];
      if (user.isTrainer!) {
        print("Notifications Trainer "+user.name!);
        // Firebase Call
        if (user.id != currentUser.id!) {
          await _eventDataService.addUserToEvent(eventId, user.id!, true);
        } else {
          await _eventDataService.addUserToEvent(eventId, user.id!);
        }
        // Local Notifications
        await _addEventLocalNotificationsCall(eventId, user.id!, user.isTrainer!);
      } else {
        print("Notifications Client "+user.name!);
        // Firebase Call
        await _eventDataService.addUserToEvent(eventId, user.id!, true);
        // Notifications Service, this also send Notifications to Trainers
        _notificationService.userJoinEvent(user.id!, currentBrand.id!, eventId);
        // Local Notifications Service
        await _addEventLocalNotificationsCall(eventId, user.id!, user.isTrainer!);
      }
    }
  }

  Future<void> _addEventBonosCall(String eventId, List<String> bonoIds) async {
    // Add Event Members
    await _eventDataService.addEventBonos(eventId, bonoIds);
  }

  Future<void> _deleteEventBonosCall(String eventId) async {
    // Add Event Members
    await _eventDataService.deleteEventBonos(eventId);
  }

  Future<void> _addEventLocalNotificationsCall(String eventId, String userId, bool isTrainer) async {
    // Local Notifications Service
    if (userId == currentUser.id!) {
      await _localNotificationService.addEventLocalNotifications(context, eventId, isTrainer);
    } else {
      await _localNotificationService.addRemoteEventLocalNotifications(context, eventId, userId, isTrainer);
    }
  }

  Future<void> _deleteEventLocalNotificationsCall(String eventId, String userId) async {
    if (userId == currentUser.id!) {
      await _localNotificationService.deleteEventLocalNotifications(eventId);
    } else {
      await _localNotificationService.deleteRemoteEventLocalNotifications(eventId, userId);
    }
  }

}
