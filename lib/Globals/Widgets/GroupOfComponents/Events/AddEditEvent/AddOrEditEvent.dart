import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Location/LocationDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Purchase/PurchaseDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/LocalNotificationService.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Images/ImageUtils.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectDateDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectDurationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectMembersDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectTimeDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/TopSnackBar/TopSnackBarDef.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/BonoCard.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/DeleteConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/DeleteRecurrentEventDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/EditRecurrentEventDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/LeaveConfirmationDialogBonos.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/SelectEventUsers/SelectClientsEvent.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/SelectEventUsers/SelectTrainersEvent.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LocationAutoComplete/MyLocationsSelect.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:uuid/uuid.dart';
import 'package:weekday_selector/weekday_selector.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../Data/Models/Bono.dart';

class AddOrEditEvent extends StatefulWidget {
  Locale locale;
  String? eventId;
  DateTime? dateTime;
  bool isBeforeEdit;

  AddOrEditEvent({Key? key, required this.locale, this.eventId, this.dateTime, required this.isBeforeEdit}) : super(key: key);

  @override
  _AddOrEditEventState createState() => _AddOrEditEventState();
}

class _AddOrEditEventState extends State<AddOrEditEvent> with SingleTickerProviderStateMixin {
  // Acceso a Base de Datos
  final _eventDataService = EventDataService();
  //JMF_AddUser_BEGIN
  final _purchaseDataService = PurchaseDataService();
  TopSnackBarDef topSnackBarComp = TopSnackBarDef();
  //JMF_AddUser_END
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
  FocusNode focusNodetitleController = FocusNode();
  String? titleString;
  // Description Controller
  var descriptionController = TextEditingController();
  FocusNode focusNodeDescController = FocusNode();
  String? descriptionString;
  // Event Image
  bool isRandomImage = true;
  bool imageError = true;
  String? eventImageUrl;
  // Location
  String? originalLocationId;
  Location location = Location();
  Set<Marker> markers = <Marker>{};
  CameraPosition _initialPosition = const CameraPosition(target: LatLng(26.8206, 30.8025));
  GoogleMapController? mapController;
  final Completer<GoogleMapController> _controller = Completer();
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
      mixpanel!.track('edit_event_info', properties: {'isPrivate': false});
    } else {
      initializeEventInfo();
      focusNodetitleController.requestFocus();
      mixpanel!.track('add_event_info', properties: {'isPrivate': false});
    }
  }

  Future<void> initializeEventInfo() async {
    if (widget.dateTime == null || widget.dateTime!.isBefore(DateTime.now())) {
      startDate = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        startDate.hour+1,
        0,
      );
    } else {
      startDate = DateTime(
        widget.dateTime!.year,
        widget.dateTime!.month,
        widget.dateTime!.day,
        widget.dateTime!.hour,
        0,
      );
    }
    // Define Start Date Controller
    startDateController.text = DateFormat('EEEE d/M/y', widget.locale.languageCode).format(startDate);
    startDateController.text = StringUtils().toCapitalized(startDateController.text);
    startTimeController.text = DateFormat('HH:mm', widget.locale.languageCode).format(startDate);
    oneWeek = startDate.add(const Duration(days: 7));
    twoWeek = startDate.add(const Duration(days: 14));
    oneMonth= startDate.add(const Duration(days: 28));
    doneAt = Timestamp.fromDate(startDate);
    /*
    titleController.text = currentBrand.name!.replaceAll(RegExp(r"\s+"), "");
    titleString = titleController.text;
     */
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
    // Event Description
    descriptionController.text = event.description!;
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
    allBonos.removeWhere((element) => element.isActive == false);
    allBonos.sort((a,b) {
      var aSessions =  a.sessions;
      var bSessions =  b.sessions;
      return aSessions!.compareTo(bSessions!);
    });
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
    _initialPosition = CameraPosition(target: LatLng(location.latitude!,location.longitude!));
    Marker marker = Marker(
      markerId: const MarkerId('1'),
      position: LatLng(location.latitude!,location.longitude!),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      onTap: () {},
    );
    markers.add(marker);
    setState(() {
      isLoading = false;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!_controller.isCompleted) {
      _controller.complete(controller);
      setState(() {
        mapController = controller;
      });
    }
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
          title: AppLocalizations.of(context)!.maxNumberClients,
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
                    spreadRadius: 2,
                    blurRadius: 2,
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
    );
  }

  //JMF_AddUser_BEGIN
  Widget buildAddClientButton() {
    return GestureDetector(
      onTap: () async {
        List<Usuario>? selectedClients = await Navigator.push(
            context,
            CupertinoPageRoute<List<Usuario>>(
              builder: (context) => SelectClientsEvent(
                 selectedUsers: brandClientsSelected,
                  selectedBonos: selectedBonos,
                  bonos: filterBonosByIds(), event: event,
              ),
            )
        );
        if (selectedClients != null) {
          setState(() {
            brandClientsSelected = selectedClients;
            errorNoTrainerSelected = false;
          });
        }
      }, //: null,
      child: Padding(
        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.06, right: 8.0),
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
                    spreadRadius: 2,
                    blurRadius: 2,
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
    );
  }
  //JMF_AddUser_END

  @override
  Widget build(BuildContext context) {
    return isLoading ? Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height*0.08,
        title: widget.eventId == null ? Text(AppLocalizations.of(context)!.createEvent, style: Theme.of(context).appBarTheme.titleTextStyle)
            : Text(AppLocalizations.of(context)!.editEvent, style: Theme.of(context).appBarTheme.titleTextStyle,),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          SizedBox(
            width: MediaQuery.of(context).size.width*0.15,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.groups,
                  color: Theme.of(context).primaryColor,
                  size: MediaQuery.of(context).size.width*0.06,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.1,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                        AppLocalizations.of(context)!.group,
                        style: Theme.of(context).textTheme.bodyText2,
                        textAlign: TextAlign.center
                    ),
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
    ) :
    Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height*0.08,
        title: widget.eventId == null ? Text(AppLocalizations.of(context)!.createEvent, style: Theme.of(context).appBarTheme.titleTextStyle)
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
                      return DeleteRecurrentEventDialog(
                        isCompleted: !widget.isBeforeEdit,
                      );
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
                    Icon(Icons.delete_outlined, color: AppColors.red, size: MediaQuery.of(context).size.width*0.07,)
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
                  size: MediaQuery.of(context).size.width*0.06,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.1,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                        AppLocalizations.of(context)!.group,
                        style: Theme.of(context).textTheme.bodyText2,
                        textAlign: TextAlign.center
                    ),
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
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Scaffold(
                  body: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
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
                                                        style: Theme.of(context).textTheme.headline1,
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
                                                      focusNode: focusNodetitleController,
                                                      controller: titleController,
                                                      validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.titleError : null,
                                                      onChanged: (val) {
                                                        setState(() {
                                                          titleString = val;
                                                        });
                                                      },
                                                      onEditingComplete: () {
                                                        if (descriptionController.text.isEmpty) {
                                                          focusNodeDescController.requestFocus();
                                                        } else {
                                                          focusNodetitleController.unfocus();
                                                        }
                                                      },
                                                      style: Theme.of(context).textTheme.bodyText2,
                                                      decoration: InputDecoration(
                                                        hintStyle: Theme.of(context).textTheme.caption,
                                                        errorStyle: Theme.of(context).textTheme.caption?.copyWith(color: AppColors.red),
                                                        hintText: AppLocalizations.of(context)!.titleHint,
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
                                                      enabled: true,
                                                    ),
                                                  ),
                                                ],
                                              )
                                          ),
                                          Padding(
                                              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.05),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: <Widget>[
                                                      Text(
                                                        AppLocalizations.of(context)!.description,
                                                        style: Theme.of(context).textTheme.headline1,
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
                                                      focusNode: focusNodeDescController,
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
                                                        hintText: AppLocalizations.of(context)!.descriptionHint,
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
                                              )
                                          ),
                                          Padding(
                                              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.05),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: <Widget>[
                                                      Text(
                                                        AppLocalizations.of(context)!.location,
                                                        style: Theme.of(context).textTheme.headline1,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.018),
                                            child: GestureDetector(
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
                                              child: Material(
                                                elevation: 4,
                                                borderRadius: BorderRadius.circular(15),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context).scaffoldBackgroundColor,
                                                      border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                                                      borderRadius: const BorderRadius.all(Radius.circular(15.0))
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                        height: MediaQuery.of(context).size.height*0.1,
                                                        width: MediaQuery.of(context).size.height*0.1,
                                                        decoration: const BoxDecoration(
                                                          borderRadius: BorderRadius.only(
                                                            topLeft: Radius.circular(15),
                                                            bottomLeft: Radius.circular(15),
                                                          ),
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius: const BorderRadius.only(
                                                            topLeft: Radius.circular(15),
                                                            bottomLeft: Radius.circular(15),
                                                          ),
                                                          child: GoogleMap(
                                                            onMapCreated: _onMapCreated,
                                                            initialCameraPosition: _initialPosition,
                                                            scrollGesturesEnabled: false,
                                                            zoomGesturesEnabled: false,
                                                            rotateGesturesEnabled: false,
                                                            mapToolbarEnabled: false,
                                                            zoomControlsEnabled: false,
                                                            minMaxZoomPreference: const MinMaxZoomPreference(16,16),
                                                            myLocationButtonEnabled: false,
                                                            mapType: MapType.satellite,
                                                            markers: markers,
                                                            trafficEnabled: false,
                                                            indoorViewEnabled: false,
                                                            buildingsEnabled: false,
                                                            onTap: null,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              location.description!,
                                                              style: Theme.of(context).textTheme.bodyText2,
                                                            ),
                                                            location.isBaseLocation! ? Text(
                                                              AppLocalizations.of(context)!.baseLocation,
                                                              style: Theme.of(context).textTheme.caption?.copyWith(height: 1.5),
                                                            ) : Container(),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                                                      Icon(Icons.swap_horiz, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.08),
                                                      SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    allBonos.isNotEmpty ? Padding(
                                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                                      child: Column(
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.05),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: <Widget>[
                                                      Text(
                                                        AppLocalizations.of(context)!.bonos,
                                                        style: Theme.of(context).textTheme.headline1,
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
                                          selectedBonos.isEmpty ? Container(
                                            width: MediaQuery.of(context).size.width*0.9,
                                            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.025, bottom: MediaQuery.of(context).size.height*0.01),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppColors.red.withOpacity(0.2),
                                              borderRadius: const BorderRadius.all(
                                                Radius.circular(10),
                                              ),
                                              border: Border.all(color: AppColors.red, width: 2),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.info_outlined, color: AppColors.red, size:  MediaQuery.of(context).size.width*0.08,),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  child: Text(
                                                    AppLocalizations.of(context)!.bonosDescriptionWarning,
                                                    textAlign: TextAlign.left,
                                                    style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red, height: 1.3),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ) : Container(
                                            width: MediaQuery.of(context).size.width*0.9,
                                            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.025, bottom: MediaQuery.of(context).size.height*0.01),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(0.2),
                                              borderRadius: const BorderRadius.all(
                                                Radius.circular(10),
                                              ),
                                              border: Border.all(color: Colors.green, width: 2),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.info_outlined, color: Colors.green, size:  MediaQuery.of(context).size.width*0.08,),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  child: Text(
                                                    AppLocalizations.of(context)!.bonosDescriptionGreat,
                                                    textAlign: TextAlign.left,
                                                    style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.green, height: 1.3),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                child: Text(
                                                  AppLocalizations.of(context)!.selectAll,
                                                  style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.w700),
                                                ),
                                                style: TextButton.styleFrom(
                                                  primary: Theme.of(context).primaryColor,
                                                ),
                                                onPressed: () async {
                                                  FocusScopeNode currentFocus = FocusScope.of(context);
                                                  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                                                    FocusManager.instance.primaryFocus?.unfocus();
                                                  }
                                                  for (var bono in allBonos) {
                                                    int index = selectedBonos.indexWhere((element) => element == bono.id);
                                                    if (index == -1) {
                                                      setState(() {
                                                        selectedBonos.add(bono.id!);
                                                      });
                                                    }
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                          ListView.builder(
                                              physics: const NeverScrollableScrollPhysics(),
                                              padding: EdgeInsets.zero,
                                              shrinkWrap: true,
                                              itemCount: allBonos.length,
                                              itemBuilder: (context, int index) {
                                                var bono = allBonos[index];
                                                return Container(
                                                  height: MediaQuery.of(context).size.height * 0.075,
                                                  width: MediaQuery.of(context).size.width * 0.9,
                                                  margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            BonoCard(
                                                              height: MediaQuery.of(context).size.height * 0.05,
                                                              width: MediaQuery.of(context).size.width * 0.18,
                                                              bono: bono,
                                                              brand: currentBrand,
                                                              canExpand: false,
                                                              onlyView: true,
                                                              hideActive: true,
                                                            ),
                                                          ]
                                                      ),
                                                      SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              bono.title!.toUpperCase(),
                                                              style: Theme.of(context).textTheme.bodyText1,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            Flexible(
                                                              child: Text(
                                                                (bono.sessions! == 10000 ? AppLocalizations.of(context)!.sessions+" "+AppLocalizations.of(context)!.ilimitadas : bono.sessions!.toString()+" "+AppLocalizations.of(context)!.sessions.toLowerCase())
                                                                    +" desde "+bono.price!.toStringAsFixed(2)+"€",
                                                                style: Theme.of(context).textTheme.caption,
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                                                      SizedBox(
                                                        height: MediaQuery.of(context).size.height * 0.034,
                                                        width: MediaQuery.of(context).size.width * 0.1,
                                                        child: MaterialButton(
                                                          elevation: 4,
                                                          color: selectedBonos.contains(bono.id!) ? Theme.of(context).primaryColor : Theme.of(context).backgroundColor,
                                                          textColor: selectedBonos.contains(bono.id!) ? Theme.of(context).primaryColor : Theme.of(context).backgroundColor,
                                                          child: selectedBonos.contains(bono.id!) ? Icon(Icons.check, color: Theme.of(context).primaryColorDark, size: MediaQuery.of(context).size.width*0.05) : SizedBox(height: MediaQuery.of(context).size.width*0.03, width: MediaQuery.of(context).size.width*0.03,),
                                                          padding: EdgeInsets.zero,
                                                          shape: const CircleBorder(),
                                                          onPressed: () {
                                                            FocusScopeNode currentFocus = FocusScope.of(context);
                                                            if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                                                              FocusManager.instance.primaryFocus?.unfocus();
                                                            }
                                                            setState(() {
                                                              if (selectedBonos.contains(bono.id!)) {
                                                                selectedBonos.remove(bono.id!);
                                                              } else {
                                                                selectedBonos.add(bono.id!);
                                                              }
                                                            });
                                                          },
                                                        ),
                                                      ),

                                                    ],
                                                  ),
                                                );
                                              }
                                          ),
                                        ],
                                      ),
                                    ) : Container(),
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.15),
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
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.width*0.05),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Date and Time
                                    Padding(
                                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
                                      child: Text(
                                        AppLocalizations.of(context)!.selectDayTime,
                                        style: Theme.of(context).textTheme.headline1,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_today_outlined, color: AppColors.grey, size: MediaQuery.of(context).size.width*0.06,),
                                              SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                                              Flexible(
                                                child: GestureDetector(
                                                    onTap: () {
                                                      if(widget.isBeforeEdit) {
                                                        selectDate();
                                                      }
                                                    },
                                                    child: TextFormField(
                                                      controller: startDateController,
                                                      readOnly: true,
                                                      enabled: false,
                                                      style: widget.isBeforeEdit ? Theme.of(context).textTheme.bodyText2 : Theme.of(context).textTheme.caption,
                                                      decoration: const InputDecoration(
                                                        border: InputBorder.none,
                                                        focusedBorder: InputBorder.none,
                                                        enabledBorder: InputBorder.none,
                                                        errorBorder: InputBorder.none,
                                                        disabledBorder: InputBorder.none,
                                                      ),
                                                      textAlign: TextAlign.start,
                                                    )
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: MediaQuery.of(context).size.width * 0.01),
                                          Row(
                                            children: [
                                              Icon(Icons.schedule, color: AppColors.grey, size: MediaQuery.of(context).size.width*0.06,),
                                              SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                                              Flexible(
                                                child: GestureDetector(
                                                    onTap: () {
                                                      if(widget.isBeforeEdit) {
                                                        selectTime();
                                                      }
                                                    },
                                                    child: TextFormField(
                                                      controller: startTimeController,
                                                      readOnly: true,
                                                      enabled: false,
                                                      style: widget.isBeforeEdit ? Theme.of(context).textTheme.bodyText2 : Theme.of(context).textTheme.caption,
                                                      decoration: const InputDecoration(
                                                        border: InputBorder.none,
                                                        focusedBorder: InputBorder.none,
                                                        enabledBorder: InputBorder.none,
                                                        errorBorder: InputBorder.none,
                                                        disabledBorder: InputBorder.none,
                                                      ),
                                                      textAlign: TextAlign.start,
                                                    )
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: MediaQuery.of(context).size.width * 0.01),
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              Icon(Icons.timer_outlined, color: AppColors.grey, size: MediaQuery.of(context).size.width*0.06,),
                                              SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                                              Flexible(
                                                child: GestureDetector(
                                                    onTap: () {
                                                      if(widget.isBeforeEdit) {
                                                        selectDuration();
                                                      }

                                                    },
                                                    child: TextFormField(
                                                      controller: durationController,
                                                      readOnly: true,
                                                      enabled: false,
                                                      style: widget.isBeforeEdit ? Theme.of(context).textTheme.bodyText2 : Theme.of(context).textTheme.caption,
                                                      decoration: const InputDecoration(
                                                        border: InputBorder.none,
                                                        focusedBorder: InputBorder.none,
                                                        enabledBorder: InputBorder.none,
                                                        errorBorder: InputBorder.none,
                                                        disabledBorder: InputBorder.none,
                                                      ),
                                                      textAlign: TextAlign.start,
                                                    )
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    errorDate && widget.isBeforeEdit ? Padding(
                                      padding: const EdgeInsets.only(left: 25, right: 25, top: 10.0),
                                      child: Center(
                                        child: Text(
                                          AppLocalizations.of(context)!.errorDate,
                                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ) : Container(),
                                    !widget.isBeforeEdit ? Padding(
                                      padding: const EdgeInsets.only(left: 25, right: 25, top: 10.0),
                                      child: Center(
                                        child: Text(
                                          AppLocalizations.of(context)!.cantEditText,
                                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ) : Container(),
                                    // Recurrent Event
                                    widget.eventId == null ? Column(
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)!.recurrentEvent,
                                                  style: Theme.of(context).textTheme.headline1,
                                                ),
                                                SizedBox(
                                                  height: MediaQuery.of(context).size.height * 0.035,
                                                  width: MediaQuery.of(context).size.width * 0.1,
                                                  child: CupertinoSwitch(
                                                    value: isRecurrent,
                                                    onChanged: (bool newVal) {
                                                      if(widget.isBeforeEdit) {
                                                        setState(() {
                                                          if (isRecurrent) {
                                                            values = [
                                                              false,
                                                              false,
                                                              false,
                                                              false,
                                                              false,
                                                              false,
                                                              false
                                                            ];
                                                          } else {
                                                            values[startDate
                                                                .weekday - 1] =
                                                            true;
                                                          }
                                                          isRecurrent = newVal;
                                                        });
                                                      }
                                                    },
                                                    trackColor: Colors.green.withOpacity(0.4),
                                                    thumbColor: AppColors.white,
                                                    activeColor: Colors.green,
                                                  ),
                                                ),
                                              ],
                                            )
                                        ),
                                        isRecurrent ? Column(
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
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
                                                      fillColor: Theme.of(context).backgroundColor,
                                                      textStyle: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).primaryColor),
                                                      selectedFillColor: Theme.of(context).primaryColor,

                                                      selectedTextStyle: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).primaryColorDark),
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
                                                        if(widget.isBeforeEdit) {
                                                          setState(() {
                                                            values[v % 7] = !values[v % 7]!;
                                                          });
                                                        }
                                                      },
                                                      selectedElevation: 8,
                                                      elevation: 4,
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
                                                              if(widget.isBeforeEdit) {
                                                                setState(() {
                                                                  _value = int.parse(value.toString());
                                                                });
                                                              }
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
                                                              if(widget.isBeforeEdit) {
                                                                setState(() {
                                                                  _value = int.parse(value.toString());
                                                                });
                                                              }
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
                                                              if(widget.isBeforeEdit) {
                                                                setState(() {
                                                                  _value = int.parse(value.toString());
                                                                });
                                                              }
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
                                    ) : event.eventGroupId != null ? Padding(
                                        padding: const EdgeInsets.only(top: 15,),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!.recurrentEvent,
                                              style: Theme.of(context).textTheme.headline1,
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(context).size.height * 0.035,
                                              width: MediaQuery.of(context).size.width * 0.1,
                                              child: CupertinoSwitch(
                                                value: true,
                                                onChanged: null,
                                                trackColor: Colors.green.withOpacity(0.4),
                                                thumbColor: AppColors.white,
                                                activeColor: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        )
                                    ) : Padding(
                                        padding: const EdgeInsets.only(top: 15,),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!.recurrentEvent,
                                              style: Theme.of(context).textTheme.headline1,
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(context).size.height * 0.035,
                                              width: MediaQuery.of(context).size.width * 0.1,
                                              child: CupertinoSwitch(
                                                value: false,
                                                onChanged: null,
                                                trackColor: Colors.green.withOpacity(0.4),
                                                thumbColor: AppColors.white,
                                                activeColor: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        )
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.15),
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
                      physics: const ClampingScrollPhysics(),
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
                                                    AppLocalizations.of(context)!.staff,
                                                    style: Theme.of(context).textTheme.headline1,
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
                                                    AppLocalizations.of(context)!.clients,
                                                    style: Theme.of(context).textTheme.headline1,
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
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              Icon(Icons.person, color: AppColors.grey, size: MediaQuery.of(context).size.width*0.08,),
                                              SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width * 0.05,
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
                                                      contentPadding: EdgeInsets.zero
                                                  ),
                                                  textAlign: TextAlign.start,
                                                ),
                                              ),
                                              Text(
                                                membersController.text == "1" ? AppLocalizations.of(context)!.asistants.toLowerCase().substring(0,AppLocalizations.of(context)!.asistants.length-1) : AppLocalizations.of(context)!.asistants.toLowerCase(),
                                                style: Theme.of(context).textTheme.bodyText2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      //JMF_AddUser_BEGIN
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
                                                buildAddClientButton(),
                                                SizedBox(
                                                  height: MediaQuery.of(context).size.height*0.15,
                                                  child: ListView.builder(
                                                      shrinkWrap: true,
                                                      physics: const NeverScrollableScrollPhysics(),
                                                      scrollDirection: Axis.horizontal,
                                                      itemCount: brandClientsSelected.length,
                                                      itemBuilder: (context, int index) {
                                                        var client = brandClientsSelected[index];
                                                        return GestureDetector(
                                                          onTap: () async {
                                                            //JMF_AddUser_BEGIN
                                                            var result = await showDialog(
                                                                context: context,
                                                                builder: (_) {
                                                                  return LeaveConfirmationDialogBonos(
                                                                    text: AppLocalizations.of(context)!.joinEventConfirmation,
                                                                    event: event,
                                                                    brand: currentBrand,
                                                                    bonos: filterBonosByIds(), purchaseId: client.purchaseId!, user: client,
                                                                  );
                                                                }
                                                            );
                                                            if (result != null && result) {
                                                              var temp = brandClientsSelected;
                                                              temp.remove(
                                                                  client);
                                                              setState(() {
                                                                brandClientsSelected =
                                                                    temp;
                                                              });
                                                            }

                                                            //JMF_AddUser_END
                                                          },
                                                          child: Padding(
                                                            padding: !(index == brandClientsSelected.length-1) ? const EdgeInsets.symmetric(horizontal: 8.0) : EdgeInsets.only(right: brandTrainersSelected.length != 1 ? MediaQuery.of(context).size.width*0.06 : 8.0, left: 8.0),
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Stack(
                                                                  alignment: Alignment.topRight,
                                                                  children: [
                                                                    CircularImage(
                                                                      size: MediaQuery.of(context).size.width*0.17,
                                                                      image: client.imageUrl,
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
                                                                        client.firstName!,
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
                                      //JMF_AddUser_END
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
      floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _selectedIndex != 0 ? Padding(
              padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.01, left: MediaQuery.of(context).size.width*0.09),
              child: SizedBox(
                height: 50,
                child: FloatingActionButton.extended(
                  heroTag: "47",
                  onPressed: () {
                    if (_selectedIndex == 1) {
                      if (widget.eventId != null) {
                        mixpanel!.track('edit_event_info', properties: {'isPrivate': false});
                      } else {
                        mixpanel!.track('add_event_info', properties: {'isPrivate': false});
                      }
                      setState(() {
                        tabs[1] = false;
                      });
                    } else if (_selectedIndex == 2) {
                      if (widget.eventId != null) {
                        mixpanel!.track('edit_event_datetime', properties: {'isPrivate': false});
                      } else {
                        mixpanel!.track('add_event_datetime', properties: {'isPrivate': false});
                      }
                      setState(() {
                        tabs[2] = false;
                      });
                    }
                    _tabController!.animateTo(_selectedIndex -= 1);
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus &&
                        currentFocus.focusedChild != null) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    }
                    setState(() {
                        addEventTabValue -= 0.33;
                    }
                    );

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
                  heroTag: "48",
                  onPressed: () async {
                    if (_selectedIndex == 0) {
                      if (formKeyInfo.currentState!.validate()) {
                        if (widget.eventId != null) {
                          mixpanel!.track('edit_event_datetime', properties: {'isPrivate': false});
                        } else {
                          mixpanel!.track('add_event_datetime', properties: {'isPrivate': false});
                        }
                          _tabController!.animateTo(_selectedIndex += 1);
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus &&
                            currentFocus.focusedChild != null) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        }
                        setState(() {
                            addEventTabValue += 0.33;
                            tabs[1] = true;
                        });
                      } else {
                        if (widget.eventId != null) {
                          mixpanel!.track('edit_event_info_error', properties: {'isPrivate': false});
                        } else {
                          mixpanel!.track('add_event_info_error', properties: {'isPrivate': false});
                        }
                      }
                    } else if (_selectedIndex == 1) {
                      setState(() {
                        errorDate = false;
                      });
                      if (validateDateAndTime(startDate, double.parse(duration))) {
                        if (widget.eventId != null) {
                          mixpanel!.track('edit_event_members', properties: {'isPrivate': false});
                        } else {
                          mixpanel!.track('add_event_members', properties: {'isPrivate': false});
                        }
                        _tabController!.animateTo(_selectedIndex += 1);
                        setState(() {
                          addEventTabValue += 0.33;
                          tabs[2] = true;
                        });
                      } else {
                        if (widget.eventId != null) {
                          mixpanel!.track('edit_event_datetime_error', properties: {'isPrivate': false});
                        } else {
                          mixpanel!.track('add_event_datetime_error', properties: {'isPrivate': false});
                        }
                        setState(() {
                          errorDate = true;
                        });
                      }
                    } else if (_selectedIndex == 2) {
                      if (brandTrainersSelected.isEmpty) {
                        setState(() {
                          errorNoTrainerSelected = true;
                        });
                        if (widget.eventId != null) {
                          mixpanel!.track('edit_event_trainers_error', properties: {'isPrivate': false});
                        } else {
                          mixpanel!.track('add_event_trainers_error', properties: {'isPrivate': false});
                        }
                      } else if (brandClientsSelected.length > eventMaxMembers) {
                        setState(() {
                          errorClientsSelected = true;
                        });
                        if (widget.eventId != null) {
                          mixpanel!.track('edit_event_clients_error', properties: {'isPrivate': false});
                        } else {
                          mixpanel!.track('add_event_clients_error', properties: {'isPrivate': false});
                        }
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
                                return EditRecurrentEventDialog(
                                  isCompleted: !widget.isBeforeEdit,
                                );
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
    );
  }

  bool validateDateAndTime(DateTime startTime, double duration) {
    if(!widget.isBeforeEdit) return true;
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
    return Theme.of(context).primaryColor;
  }

  Future<void> _addEventFunction() async {
    mixpanel!.timeEvent("add_event_completed");
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
      // Updating Loading Text
      setState(() {
        isRecurrentLoadingText = AppLocalizations.of(context)!.creating +" "+ AppLocalizations.of(context)!.events.toLowerCase() + "... (" + currentEvent.toString()+"/"+currentEvent.toString()+")";
      });
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
      mixpanel!.track('add_event_completed', properties: {
        'descriptionLength': event.description!.length.toString(),
        'isPrivate': false,
        'isRecurrent': false,
        'doneAt': event.doneAt!.toDate().toString(),
        'duration': event.duration.toString(),
        'numClients': event.numClients!.toString(),
        'numTrainers': event.numTrainers!.toString(),
        'maxMembers': event.maxMembers!.toString(),
      });
    } else {
      // Recurrent total
      int days = values.where((item) => item == true).length;
      totalEvents = days*_value;
      if (_value == 3) {
        totalEvents += days;
      }
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
      }
      // Create Entry in /Event Groups
      await _eventDataService.addRecurrentEventGroup(eventGroupId, groupEventsIds);
      mixpanel!.track('add_event_completed', properties: {
        'descriptionLength': event.description!.length.toString(),
        'isPrivate': false,
        'isRecurrent': true,
        'doneAt': event.doneAt!.toDate().toString(),
        'duration': event.duration.toString(),
        'numClients': event.numClients!.toString(),
        'numTrainers': event.numTrainers!.toString(),
        'maxMembers': event.maxMembers!.toString(),
      });
    }
    Navigator.pop(context);
  }

  Future<void> _deleteEventFunction() async {
    mixpanel!.timeEvent("delete_event_completed");
    setState(() {
      isLoading = true;
      // Updating Loading Text
      isRecurrentLoadingText = AppLocalizations.of(context)!.deleting +" "+ AppLocalizations.of(context)!.events.toLowerCase() + "... (" + currentEvent.toString()+"/"+currentEvent.toString()+")";
    });
    // Delete Event Call
    await _eventDataService.deleteEvent(widget.eventId!);
    // Event Members
    List<Usuario> eventMembers = List.from(brandTrainersSelected);
    eventMembers.addAll(brandClientsSelected);
    // Delete Event Bonos
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
    mixpanel!.track('delete_event_completed', properties: {'isPrivate': false, 'isRecurrent': false});
    // Pop to Last Page
    Navigator.pop(context, false);
  }

  void _setValueToOriginal(Usuario user)
  {
    int index = originalTrainers.indexWhere((element) => element.id == user.id);
    // Trainer Found
    if (index != -1) {
      originalTrainers[index].purchaseId = user.purchaseId;
    }
  }

  Future<void> _updateEventFunction() async {
    mixpanel!.timeEvent("edit_event_completed");
    setState(() {
      isLoading = true;
      // Updating Loading Text
      isRecurrentLoadingText = AppLocalizations.of(context)!.editing +" "+ AppLocalizations.of(context)!.events.toLowerCase() + "... (" + currentEvent.toString()+"/"+currentEvent.toString()+")";
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
        await _eventDataService.addUserToEvent(event.id!, user.id!, "", true);
      } else {
        await _eventDataService.addUserToEvent(event.id!, user.id!, "");
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
      // Remove Client From Purchase
      //JMF_AddUser_BEGIN
      if(selectedBonos.isNotEmpty) {
          await _purchaseDataService.deletedPurchaseUserFromEvent(
              user, widget.eventId!);

      }
      //JMF_AddUser_END
      // Send Client Left Event
      _notificationService.userLeaveEvent(user.id!, currentBrand.id!, event.id!);
      // Remove Event Local Notifications
      await _deleteEventLocalNotificationsCall(event.id!, user.id!);
      print("Client Removed "+user.id.toString());
    }

    //JMF_AddUser_Begin
    //Update purchase
    await UpdateUserPurchase(event.id!);
    //JMF_AddUser_End

    // Handle Clients Added
    // Clients Added Not Matched means that they have added to the Event
    for (int i = 0; i < eventClientsAdded.length; i++) {
      var user = eventClientsAdded[i];
      // Add Clients to Event
      await _eventDataService.addUserToEvent(event.id!, user.id!, user.purchaseId!, true);

      //JMF_AddUser_BEGIN
      if(selectedBonos.isNotEmpty) {
          await _purchaseDataService.addEventToPurchase(
              eventClientsAdded[i].purchaseId!, widget.eventId!);

      }
      //JMF_AddUser_END

      // Add Event Local Notifications
      await _addEventLocalNotificationsCall(event.id!, user.id!, user.isTrainer!);
      print("Client Added "+user.id.toString());
    }
    mixpanel!.track('edit_event_completed', properties: {
      'descriptionLength': event.description!.length.toString(),
      'isPrivate': false,
      'isRecurrent': false,
      'doneAt': event.doneAt!.toDate().toString(),
      'duration': event.duration.toString(),
      'numClients': event.numClients!.toString(),
      'numTrainers': event.numTrainers!.toString(),
      'maxMembers': event.maxMembers!.toString(),
    });
    Navigator.pop(context, true);
  }

  // Recurrent Events

  Future<void> _deleteRecurrentEventFunction() async {
    mixpanel!.timeEvent("delete_event_completed");
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
    mixpanel!.track('delete_event_completed', properties: {'isPrivate': false, 'isRecurrent': true});
    // Pop to Last Page
    Navigator.pop(context, false);
  }

  Future<void> _updateRecurrentEventFunction() async {
    mixpanel!.timeEvent('edit_event_completed');
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
        numClients: originalClients.length,
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
          await _eventDataService.addUserToEvent(event.id!, user.id!, "", true);
        } else {
          await _eventDataService.addUserToEvent(event.id!, user.id!, "");
        }
        // Add Event Local Notifications
        await _addEventLocalNotificationsCall(eventId, user.id!, user.isTrainer!);
        print("Trainer Added "+user.id.toString());
      }
      /*
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
      }*/
      // Handle Clients Added
      // Clients Added Not Matched means that they have added to the Event
      for (int i = 0; i < eventClientsAdded.length; i++) {
        var user = eventClientsAdded[i];
        // Add Clients to Event
        await _eventDataService.addUserToEvent(eventId, user.id!, user.purchaseId!, true);

        //JMF_AddUser_BEGIN
        if(selectedBonos.isNotEmpty) {
          await _purchaseDataService.addEventToPurchase(
              eventClientsAdded[i].purchaseId!, widget.eventId!);

        }
        //JMF_AddUser_END

        // Add Event Local Notifications
        await _addEventLocalNotificationsCall(eventId, user.id!, user.isTrainer!);
        print("Client Added "+user.id.toString());
      }

    }
    mixpanel!.track('edit_event_completed', properties: {
      'descriptionLength': event.description!.length.toString(),
      'isPrivate': false,
      'isRecurrent': true,
      'doneAt': event.doneAt!.toDate().toString(),
      'duration': event.duration.toString(),
      'numClients': event.numClients!.toString(),
      'numTrainers': event.numTrainers!.toString(),
      'maxMembers': event.maxMembers!.toString(),
    });
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
      // Firebase Call
      if (user.id != currentUser.id!) {
        await _eventDataService.addUserToEvent(eventId, user.id!, "",true);
      } else {
        await _eventDataService.addUserToEvent(eventId, user.id!, "");
      }
      // Local Notifications
      await _addEventLocalNotificationsCall(eventId, user.id!, user.isTrainer!);
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

  List<Bono> filterBonosByIds() {
    return allBonos.where((bono) => selectedBonos.contains(bono.id)).toList();
  }

  Future<void> UpdateUserPurchase(String eventId) async {
    for(int i = 0; i < originalClients.length; ++i)
      {
        int index =  brandClientsSelected.indexWhere((element) => element.id == originalClients[i].id);
        if(index != -1) {
          if(brandClientsSelected[index].purchaseId != originalClients[i].purchaseId)
            {
              await _eventDataService.updateEventUserPurchase(eventId, originalClients[i].id!, brandClientsSelected[index].purchaseId!);
            }
        }

      }
  }

}
