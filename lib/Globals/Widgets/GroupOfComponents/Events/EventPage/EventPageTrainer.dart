import 'dart:async';
import 'dart:math';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/AddEditEvent/AddOrEditEvent.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/AddEditEvent/AddOrEditPrivateEvent.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Location/LocationDataService.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/DeleteConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingViewPurple.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LocationAutoComplete/MyLocationsSelect.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/ProfileView/ProfileUserView.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class EventPageTrainer extends StatefulWidget {
  String eventId;
  EventPageTrainer({Key? key, required this.eventId}) : super(key: key);

  @override
  _EventPageTrainerState createState() => _EventPageTrainerState();
}

class _EventPageTrainerState extends State<EventPageTrainer> with SingleTickerProviderStateMixin {
  // Acceso a Base de Datos
  var _brandDataService = new BrandDataService();
  var _eventDataService = new EventDataService();
  var _locationDataService = new LocationDataService();
  // Screen Dimensions
  var safeAreaHeight;
  var safeAreaWidth;
  // Boolean Loading
  bool isFirstBuild = true;
  bool isLoading = true;
  bool isLoadingBody = false;
  // Boolean isUpdated
  bool isEditing = false;
  bool canEdit = true;
  // Title Controller
  var titleController = TextEditingController();
  String? titleString;
  // Description Controller
  var descriptionController = TextEditingController();
  String? descriptionString;
  // Starting Date and Time
  String datetitle = "";
  TextEditingController startDateController = TextEditingController();
  bool errorDate = false;
  // Duration
  TextEditingController durationController = TextEditingController();
  String duration = "1.00";
  List<String> durations = ["0.30","0.45","1.00","1.15","1.30","1.45","2.00","2.15","2.30","2.45","3.00"];
  // Location
  Location location = Location();
  Set<Marker> markers = new Set<Marker>();
  CameraPosition _initialPosition = CameraPosition(target: LatLng(26.8206, 30.8025));
  GoogleMapController? mapController;
  Completer<GoogleMapController> _controller = Completer();
  // Participants
  TextEditingController membersController = TextEditingController();
  int members = 1;
  int membersMax = currentBrand.maxMembers!;
  // Members Page
  bool isFull = false;
  List<Usuario> allUsers = [];
  List<Usuario> allTrainers = [];
  List<Usuario> eventTrainers = [];
  List<Usuario> eventClients = [];
  List<double?> eventClientsFeedback = [];
  List<String> eventTrainersIds = [];
  List<bool> eventTrainersBool = [];
  bool errorNoTrainerSelected = false;
  // Form To Validate User
  final formKeyInfo = GlobalKey<FormState>();
  final formKeyTime = GlobalKey<FormState>();
  final formKeyMembers = GlobalKey<FormState>();
  // Event Retrieved From BD
  Event? event;
  var placeDetails;
  // BackGround image
  Image? theImage;
  // String Deleted Photo
  String deletedObject = "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/not-found-image.jpg?alt=media&token=70687295-6a17-4735-9c0a-e5749c777319";

  var eventFeedbackValue;

  @override
  initState() {
    super.initState();
    isLoading = true;
    theImage = buildRandomImage();
    getEventInfo();
  }

  // Init Device Sizes
  initDeviceSizes() {
    safeAreaHeight = MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    print("Device H and W: "+MediaQuery.of(context).size.height.toString()+" "+MediaQuery.of(context).size.width.toString());
    print("SafeArea H and W: "+safeAreaHeight.toString()+" "+safeAreaWidth.toString());
  }

  // Did Change Dependencies
  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(theImage!.image, context);
  }

  Image buildRandomImage() {
    Random random = new Random();
    int randomNumber = random.nextInt(15);

    switch(randomNumber) {
      case 0: {
        return Image.asset(Constants.eventBackground);
      }
      case 1: {
        return Image.asset(Constants.eventBackground1);
      }
      case 2: {
        return Image.asset(Constants.eventBackground2);
      }
      case 3: {
        return Image.asset(Constants.eventBackground3);
      }
      case 4: {
        return Image.asset(Constants.eventBackground4);
      }
      case 5: {
        return Image.asset(Constants.eventBackground5);
      }
      case 6: {
        return Image.asset(Constants.eventBackground6);
      }
      case 7: {
        return Image.asset(Constants.eventBackground7);
      }
      case 8: {
        return Image.asset(Constants.eventBackground8);
      }
      case 9: {
        return Image.asset(Constants.eventBackground9);
      }
      case 10: {
        return Image.asset(Constants.eventBackground10);
      }
      case 11: {
        return Image.asset(Constants.eventBackground11);
      }
      case 12: {
        return Image.asset(Constants.eventBackground12);
      }
      case 13: {
        return Image.asset(Constants.eventBackground13);
      }
      case 14: {
        return Image.asset(Constants.eventBackground14);
      }
      case 15: {
        return Image.asset(Constants.eventBackground15);
      }
      default: {
        return Image.asset(Constants.eventBackground);
      }
    }
  }

  void getEventInfo() async {
    event = await _eventDataService.getSingleEvent(widget.eventId);
    print(event?.id);
    titleController.text = "${event!.title}";
    titleString = "${event!.title}";
    descriptionController.text = "${event!.description}";
    descriptionString = "${event!.description}";
    var startDate = DateTime(
      int.parse(event!.year!),
      int.parse(event!.month!),
      int.parse(event!.day!),
      int.parse(event!.hour!),
      int.parse(event!.minute!),
    );
    if (startDate.isBefore(DateTime.now())) {
      canEdit = false;
    }
    startDateController.text = DateFormat('EEEE d/M/y - HH:mm', Localizations.localeOf(context).languageCode).format(startDate);
    datetitle = DateFormat('EEEE d MMMM', Localizations.localeOf(context).languageCode).format(startDate);
    startDateController.text = StringUtils().toCapitalized(startDateController.text);
    duration = event!.duration!.toStringAsFixed(2);
    var hour = event!.duration.toString().split(".")[0];
    var min = event!.duration!.toStringAsFixed(2).split(".")[1];
    durationController.text = "${hour}h ${min}min";
    members = event!.maxMembers!;
    membersController.text = "${event!.numClients.toString()} / ${event!.maxMembers.toString()}";
    setState(() {
      isFull = (event!.numClients!/event!.maxMembers! == 1);
    });
    await getEventUsers();
    await getEventLocation(event!.id!);
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          isLoading = false;
          isLoadingBody = false;
          isEditing = false;
        });
      });
    }
  }

  Future<void> getEventUsers() async {
    allUsers = await _eventDataService.getEventUsers(event!.id!);
    allTrainers = await _brandDataService.getBrandTrainers(currentBrand.id!);
    List<Usuario> trainers = [];
    List<String> trainersIds = [];
    List<Usuario> clients = [];
    for (var i=0; i < allUsers.length; i++) {
      var user = allUsers[i];
      if (user.isTrainer!) {
        if (currentUser.id! == user.id!) {
          // User has joined the event
          trainers.insert(0, user);
          trainersIds.insert(0, user.id!);
        } else {
          trainers.add(user);
          trainersIds.add(user.id!);
        }
      } else {        
        clients.add(user);
        double? feedbackClient = await _eventDataService.getEventUserFeedback(event!.id!, user.id!);
        eventClientsFeedback.add(feedbackClient);
      }
    }
    eventTrainersBool = [];
    for (var i=0; i < allTrainers.length; i++) {
      var trainer = allTrainers[i];
      if (trainersIds.contains(trainer.id!)) {
        eventTrainersBool.add(true);
      } else {
        eventTrainersBool.add(false);
      }
    }

    if (mounted) {
      setState(() {
        eventTrainers = trainers;
        eventTrainersIds = trainersIds;
        eventClients = clients;
      });
    }
  }
  
  Future<void> getEventLocation(String eventId) async {
    location = await _eventDataService.getEventLocation(eventId);
    initCameraPosition();
    createMarker();
    var temp = location;
    setState(() {
      location = temp;
    });
  }

  void initCameraPosition() {
    setState(() {
      _initialPosition = CameraPosition(target: LatLng(location.latitude!,location.longitude!));
    });
  }

  void createMarker() async{
    Marker marker = new Marker(
      markerId: MarkerId('1'),
      position: LatLng(location.latitude!,location.longitude!),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      onTap: () {},
    );
    setState(() {
      markers.add(marker);
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

  void _onLaunchCoordinates(LatLng) {
    MapsLauncher.launchCoordinates(location.latitude!, location.longitude!, location.description!);
  }

  Future<void> getLocationFromId(String locationId) async {
    location = await _locationDataService.getSingleLocation(locationId);
    createMarker();
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(location.latitude!,location.longitude!), zoom: 17)
      )
    );
    var temp = location;
    setState(() {
      location = temp;
    });
  }

  Future<void> selectSlot(ctx, type) {
    // Initial Vars
    var startDate = DateTime.now();
    var minimumDate = DateTime.now().subtract(Duration(days: 365));
    var maximumDate = DateTime.now().add(Duration(days: 365));
    var title;
    var initialDuration = 1;
    var initialMembers = 1;
    var totalMembers = (membersMax) - event!.numClients!;
    var widgetPicker;
    // Init for differnt types
    if (type == 0) {
      startDate = DateFormat('EEEE d/M/y - HH:mm', Localizations.localeOf(context).languageCode).parse(StringUtils().undoCapitalized(startDateController.text));
      // Calcular el horari de la marca
      // Hora Inactiva Matí
      var startHourWS = int.parse(currentBrand.workShift[0].toStringAsFixed(2).split(".")[0]);
      var startMinWS = int.parse(currentBrand.workShift[0].toStringAsFixed(2).split(".")[1]);
      minimumDate = DateTime(startDate.year, startDate.month, startDate.day, startHourWS, startMinWS);
      // Hora Inactiva Nit
      var endHourWS = int.parse(currentBrand.workShift[1].toStringAsFixed(2).split(".")[0]);
      var endMinWS = int.parse(currentBrand.workShift[1].toStringAsFixed(2).split(".")[1]);
      var temp = DateTime(startDate.year, startDate.month, startDate.day, endHourWS, endMinWS);
      maximumDate = temp.add(Duration(days: 365));
    } else if (type == 1) {
      initialDuration = durations.indexWhere((element) => element == duration);
    } else if (type == 2) {
      initialMembers = 0;
    }
    // Different types of pickers
    Widget dateTimePicker = CupertinoTheme(
      data: CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
            dateTimePickerTextStyle: Theme.of(context).textTheme.bodyText2,
          )
      ),
      child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.dateAndTime,
          initialDateTime: DateTime(startDate.year, startDate.month, startDate.day, startDate.hour,0),
          minimumDate: minimumDate,
          maximumDate: maximumDate,
          use24hFormat: true,
          minuteInterval: 15,
          onDateTimeChanged: (val) {
            setState(() {
              startDateController.text = DateFormat('EEEE d/M/y - HH:mm', Localizations.localeOf(context).languageCode).format(val);
              startDateController.text = StringUtils().toCapitalized(startDateController.text);
            });
          }
      )
    );
    Widget durationPicker = CupertinoTheme(
      data: CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
            dateTimePickerTextStyle: Theme.of(context).textTheme.bodyText2,
          )
      ),
      child: CupertinoPicker(
          scrollController: new FixedExtentScrollController(
              initialItem: initialDuration
          ),
          itemExtent: 40.0,
          backgroundColor: Colors.transparent,
          onSelectedItemChanged: (int index) {
            setState(() {
              duration = durations[index];
              var hour = durations[index].split(".")[0];
              var min = durations[index].split(".")[1];
              durationController.text = "${hour}h ${min}min";
            });
          },
          children: new List<Widget>.generate(
              durations.length, (int index) {
            var item = durations[index];
            var hour = item.split(".")[0];
            var min = item.split(".")[1];
            return new Center(
              child: new Text(
                  "${hour}h ${min}min",
                style: Theme.of(context).textTheme.bodyText1,
              ),
            );
          }
          )
      )
    );
    Widget membersPicker = CupertinoTheme(
      data: CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
            dateTimePickerTextStyle: Theme.of(context).textTheme.bodyText2,
          )
      ),
      child: CupertinoPicker(
          scrollController: new FixedExtentScrollController(
              initialItem: initialMembers
          ),
          itemExtent: 40.0,
          backgroundColor: Colors.transparent,
          onSelectedItemChanged: (int index) {
            setState(() {
              members = event!.numClients!+index;
              membersController.text = "${event!.numClients.toString()} / ${members.toString()}";
            });
          },
          children: new List<Widget>.generate(totalMembers.toInt(), (int index) {
            var member = event!.numClients!+index;
            return new Center(
              child: new Text(
                  "${member.toString()}",
                style: Theme.of(context).textTheme.bodyText1,
              ),
            );
          }
        )
      )
    );
    if (type == 0) {
      title = AppLocalizations.of(context)!.selectDayTime;
      widgetPicker = dateTimePicker;
    } else if (type == 1) {
      title = AppLocalizations.of(context)!.selectDuration;
      widgetPicker = durationPicker;
    } else if (type == 2) {
      title = AppLocalizations.of(context)!.selectMembers;
      widgetPicker = membersPicker;
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
    if (
    // Can´t create event in the past
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
    return Theme.of(context).accentColor;
  }

  // Build EventFeedback Value
  Widget buildEventFeedbackIcon(double eventFeedbackValue) {
    return Container(
      width: MediaQuery.of(context).size.width*0.1,
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: MediaQuery.of(context).size.width*0.05,
              child: Image.asset(Constants.fireEmojiImage),
            ),
            Text(
                eventFeedbackValue.toString(),
                style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.center
            ),
          ],
        ),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    if (isFirstBuild) {
      initDeviceSizes();
      isFirstBuild = false;
    }

    return isLoading ?
    Scaffold(
      appBar: null,
      resizeToAvoidBottomInset: true,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.26,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height*0.23,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height:  MediaQuery.of(context).size.height*0.1,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height*0.10,
                minHeight: MediaQuery.of(context).size.height*0.10,
              ),
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height:  MediaQuery.of(context).size.height*0.1,
                    child: Material(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))
                      ),
                      elevation: 4,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.01),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Shimmer.fromColors(
                              baseColor: AppColors.grey,
                              highlightColor: AppColors.grey.withOpacity(0.5),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                                child: Container(
                                  height:  MediaQuery.of(context).size.height*0.1,
                                  child: Center(
                                    child: Container(
                                      height: MediaQuery.of(context).size.height * 0.04,
                                      width: MediaQuery.of(context).size.width * 0.1,
                                      decoration: BoxDecoration(
                                          color: AppColors.grey,
                                          borderRadius: BorderRadius.all(Radius.circular(15.0))
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Shimmer.fromColors(
                              baseColor: AppColors.grey,
                              highlightColor: AppColors.grey.withOpacity(0.5),
                              child: Container(
                                height: MediaQuery.of(context).size.height * 0.04,
                                width: MediaQuery.of(context).size.width*0.3,
                                decoration: BoxDecoration(
                                    color: AppColors.grey,
                                    borderRadius: BorderRadius.all(Radius.circular(15.0))
                                ),
                              ),
                            ),
                            Shimmer.fromColors(
                              baseColor: AppColors.grey,
                              highlightColor: AppColors.grey.withOpacity(0.5),
                              child:  Padding(
                                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.05, left: MediaQuery.of(context).size.width*0.05),
                                child: Container(
                                  height: MediaQuery.of(context).size.height * 0.04,
                                  width: MediaQuery.of(context).size.width * 0.1,
                                  decoration: BoxDecoration(
                                      color: AppColors.grey,
                                      borderRadius: BorderRadius.all(Radius.circular(15.0))
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height*0.32,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height*0.04),
                          Shimmer.fromColors(
                            baseColor: AppColors.grey,
                            highlightColor: AppColors.grey.withOpacity(0.5),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.04,
                              width: MediaQuery.of(context).size.width*0.4,
                              decoration: BoxDecoration(
                                  color: AppColors.grey,
                                  borderRadius: BorderRadius.all(Radius.circular(15.0))
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Shimmer.fromColors(
                            baseColor: AppColors.grey,
                            highlightColor: AppColors.grey.withOpacity(0.5),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.03,
                              width: MediaQuery.of(context).size.width*0.6,
                              decoration: BoxDecoration(
                                  color: AppColors.grey,
                                  borderRadius: BorderRadius.all(Radius.circular(15.0))
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.04),
                          Shimmer.fromColors(
                            baseColor: AppColors.grey,
                            highlightColor: AppColors.grey.withOpacity(0.5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.07,
                                  width: MediaQuery.of(context).size.width*0.15,
                                  decoration: BoxDecoration(
                                      color: AppColors.grey,
                                      borderRadius: BorderRadius.all(Radius.circular(15.0))
                                  ),
                                ),
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.07,
                                  width: MediaQuery.of(context).size.width*0.7,
                                  decoration: BoxDecoration(
                                      color: AppColors.grey,
                                      borderRadius: BorderRadius.all(Radius.circular(15.0))
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.02),
                          Shimmer.fromColors(
                            baseColor: AppColors.grey,
                            highlightColor: AppColors.grey.withOpacity(0.5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.07,
                                  width: MediaQuery.of(context).size.width*0.15,
                                  decoration: BoxDecoration(
                                      color: AppColors.grey,
                                      borderRadius: BorderRadius.all(Radius.circular(15.0))
                                  ),
                                ),
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.07,
                                  width: MediaQuery.of(context).size.width*0.7,
                                  decoration: BoxDecoration(
                                      color: AppColors.grey,
                                      borderRadius: BorderRadius.all(Radius.circular(15.0))
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.02),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height*0.02),
                          Shimmer.fromColors(
                            baseColor: AppColors.grey,
                            highlightColor: AppColors.grey.withOpacity(0.5),
                            child: Container(
                              height: MediaQuery.of(context).size.height*0.2,
                              width: MediaQuery.of(context).size.width*0.9,
                              decoration: BoxDecoration(
                                  color: AppColors.grey,
                                  borderRadius: BorderRadius.all(Radius.circular(15.0))
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height*0.025),
                          Shimmer.fromColors(
                            baseColor: AppColors.grey,
                            highlightColor: AppColors.grey.withOpacity(0.5),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.03,
                              width: MediaQuery.of(context).size.width*0.3,
                              decoration: BoxDecoration(
                                  color: AppColors.grey,
                                  borderRadius: BorderRadius.all(Radius.circular(15.0))
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.025),
                          Container(
                            width: MediaQuery.of(context).size.height * 0.26,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Shimmer.fromColors(
                                  baseColor: AppColors.grey,
                                  highlightColor: AppColors.grey.withOpacity(0.5),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height * 0.08,
                                    width: MediaQuery.of(context).size.height * 0.08,
                                    decoration: BoxDecoration(
                                      color: AppColors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Shimmer.fromColors(
                                  baseColor: AppColors.grey,
                                  highlightColor: AppColors.grey.withOpacity(0.5),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height * 0.08,
                                    width: MediaQuery.of(context).size.height * 0.08,
                                    decoration: BoxDecoration(
                                      color: AppColors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Shimmer.fromColors(
                                  baseColor: AppColors.grey,
                                  highlightColor: AppColors.grey.withOpacity(0.5),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height * 0.08,
                                    width: MediaQuery.of(context).size.height * 0.08,
                                    decoration: BoxDecoration(
                                      color: AppColors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ),
        ],
      ),
    )
        :
    Scaffold(
      appBar: null,
      resizeToAvoidBottomInset: true,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: MediaQuery.of(context).size.height*0.26,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: theImage!.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              /*
              Container(
                height: MediaQuery.of(context).size.height*0.26,
                decoration: new BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  gradient: LinearGradient(
                      begin: FractionalOffset.bottomCenter,
                      end: FractionalOffset.topCenter,
                      colors: [
                        Theme.of(context).scaffoldBackgroundColor.withOpacity(0.1),
                        Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
                      ],
                      stops: [
                        0.8,
                        1
                      ]
                  ),
                ),
                child: Center(),
              ),
               */
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).size.height*0.23,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height*0.10,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height*0.10,
                minHeight: MediaQuery.of(context).size.height*0.10,
              ),
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Material(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))
                    ),
                    elevation: 4,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back, color: !isEditing ? Theme.of(context).primaryColor : Theme.of(context).scaffoldBackgroundColor, size: MediaQuery.of(context).size.width*0.06),
                              onPressed: !isEditing ? () {
                               Navigator.pop(context);
                              } : null,
                            ),
                          ),
                          isEditing ? Text(AppLocalizations.of(context)!.editEvent, style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold)) : Text(datetitle, style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold)),
                          (!canEdit || event!.isPrivate!) ? Padding(
                            padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.08, left: MediaQuery.of(context).size.width*0.08),
                            child: Container(),
                          ) :
                          Padding(
                            padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.05, left: MediaQuery.of(context).size.width*0.05),
                            child: Column(
                              children: [
                                !isEditing ? Icon(isFull ? Icons.lock_outline : Icons.lock_open, color: isFull ? Colors.red : Color(0xFFA8C76C), size: MediaQuery.of(context).size.width*0.05,) : Icon(Icons.lock_open, color: Theme.of(context).scaffoldBackgroundColor, size: MediaQuery.of(context).size.width*0.05,),
                                !isEditing ? Text(isFull ? AppLocalizations.of(context)!.full : AppLocalizations.of(context)!.available, style:  Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold, color: isFull ? Colors.red : Color(0xFFA8C76C))) : Text(AppLocalizations.of(context)!.full, style:  Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).scaffoldBackgroundColor),),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height*0.32,
            bottom: 0,
            left: 0,
            right: 0,
            child: !isLoadingBody ? Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height*0.01),
                            Form(
                              key: formKeyInfo,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      isEditing ? new Expanded(
                                        child: new TextFormField(
                                          controller: titleController,
                                          validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.titleError : null,
                                          style: Theme.of(context).textTheme.headline1?.copyWith(fontWeight: FontWeight.bold),
                                          decoration: InputDecoration(
                                              hintStyle: Theme.of(context).textTheme.caption,
                                              hintText:AppLocalizations.of(context)!.titleError,
                                              enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.grey,
                                                      width: 1.0
                                                  )
                                              ),
                                              focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.grey,
                                                      width: 1.0
                                                  )
                                              ),
                                              errorBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.red,
                                                      width: 1.0
                                                  )
                                              ),
                                              disabledBorder: InputBorder.none,
                                              contentPadding: EdgeInsets.all(0)
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ) : new Expanded(
                                        child: new TextField(
                                          controller: titleController,
                                          readOnly: true,
                                          style: Theme.of(context).textTheme.headline1?.copyWith(fontWeight: FontWeight.bold),
                                          decoration: InputDecoration(
                                            hintStyle: Theme.of(context).textTheme.caption,
                                            hintText:AppLocalizations.of(context)!.titleError,
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          color: Theme.of(context).backgroundColor,
                                        ),
                                        child: event!.isPrivate! ? Row(
                                          children: [
                                            Text(
                                                AppLocalizations.of(context)!.private,
                                                style: Theme.of(context).textTheme.bodyText2,
                                                textAlign: TextAlign.right
                                            ),
                                            SizedBox(width: MediaQuery.of(context).size.width*0.01),
                                            Icon(
                                              Icons.lock_outlined,
                                              color: Theme.of(context).primaryColor,
                                              size: MediaQuery.of(context).size.width*0.05,
                                            ),
                                          ],
                                        ) : Row(
                                          children: [
                                            Text(
                                                AppLocalizations.of(context)!.group,
                                                style: Theme.of(context).textTheme.bodyText2,
                                                textAlign: TextAlign.right
                                            ),
                                            SizedBox(width: MediaQuery.of(context).size.width*0.01),
                                            Icon(
                                              Icons.groups,
                                              color: Theme.of(context).primaryColor,
                                              size: MediaQuery.of(context).size.width*0.05,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 0),
                                      child: new Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          isEditing ? new Flexible(
                                            child: new TextFormField(
                                              controller: descriptionController,
                                              minLines: 1,
                                              maxLines: 6,
                                              style: Theme.of(context).textTheme.bodyText2,
                                              decoration: InputDecoration(
                                                hintStyle: Theme.of(context).textTheme.caption,
                                                hintText:AppLocalizations.of(context)!.noDescription,
                                                enabledBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.grey,
                                                        width: 1.0
                                                    )
                                                ),
                                                focusedBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.grey,
                                                        width: 1.0
                                                    )
                                                ),
                                                errorBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.red,
                                                        width: 1.0
                                                    )
                                                ),
                                                disabledBorder: InputBorder.none,
                                              ),
                                              textAlign: TextAlign.justify,
                                            ),
                                          ) : new Flexible(
                                            child: new TextFormField(
                                              controller: descriptionController,
                                              readOnly: true,
                                              minLines: 1,
                                              maxLines: 4,
                                              style: Theme.of(context).textTheme.bodyText2,
                                              decoration: InputDecoration(
                                                hintStyle: Theme.of(context).textTheme.caption,
                                                hintText:AppLocalizations.of(context)!.noDescription,
                                                border: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                errorBorder: InputBorder.none,
                                                disabledBorder: InputBorder.none,
                                                contentPadding: EdgeInsets.all(0),
                                              ),
                                              textAlign: TextAlign.justify,
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.02),
                            errorDate ? Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.errorDate,
                                    style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ): Container(),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.08,
                              width: MediaQuery.of(context).size.width * 0.90,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.all(Radius.circular(5.0))
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.07,
                                    width: MediaQuery.of(context).size.height * 0.07,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).accentColor.withOpacity(0.08),
                                        borderRadius: BorderRadius.all(Radius.circular(5.0))
                                    ),
                                    child: Center(
                                        child: Text(
                                            event!.day.toString(),
                                            style: Theme.of(context).textTheme.headline1?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).accentColor),
                                            textAlign: TextAlign.center
                                        )
                                    ),
                                  ),
                                  SizedBox(width: MediaQuery.of(context).size.width*0.04),
                                  Container(
                                      height: MediaQuery.of(context).size.height * 0.08,
                                      width: MediaQuery.of(context).size.width*0.64,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            isEditing ? new Flexible(
                                              child: TextFormField(
                                                controller: startDateController,
                                                readOnly: true,
                                                onTap: () {
                                                  if (isEditing) selectSlot(context, 0);
                                                },
                                                style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                                decoration: InputDecoration(
                                                  labelStyle: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                                  border: InputBorder.none,
                                                  enabledBorder: UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: errorDate ? Colors.red : Colors.grey,
                                                          width: 1.0
                                                      )
                                                  ),
                                                  focusedBorder: UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: errorDate ? Colors.red : Colors.grey,
                                                          width: 1.0
                                                      )
                                                  ),
                                                  disabledBorder: InputBorder.none,
                                                ),
                                                textAlign: TextAlign.start,
                                              ),
                                            ) : new Flexible(
                                              child: TextFormField(
                                                controller: startDateController,
                                                readOnly: true,
                                                enabled: false,
                                                style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                                decoration: InputDecoration(
                                                  labelStyle: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
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
                                      )
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.02),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.08,
                              width: MediaQuery.of(context).size.width * 0.90,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.all(Radius.circular(5.0))
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.07,
                                    width: MediaQuery.of(context).size.height * 0.07,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).accentColor.withOpacity(0.08),
                                        borderRadius: BorderRadius.all(Radius.circular(5.0))
                                    ),
                                    child: Center(
                                        child: Icon(Icons.timer_outlined, color: Theme.of(context).accentColor, size: MediaQuery.of(context).size.width*0.06,)
                                    ),
                                  ),
                                  SizedBox(width: MediaQuery.of(context).size.width*0.04),
                                  Container(
                                      height: MediaQuery.of(context).size.height * 0.08,
                                      width: MediaQuery.of(context).size.width*0.64,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            isEditing ? new Flexible(
                                              child: TextFormField(
                                                controller: durationController,
                                                onTap: () {
                                                  if (isEditing) selectSlot(context, 1);
                                                },
                                                readOnly: true,
                                                style: Theme.of(context).textTheme.bodyText2,
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  enabledBorder: UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: errorDate ? Colors.red : Colors.grey,
                                                          width: 1.0
                                                      )
                                                  ),
                                                  focusedBorder: UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: errorDate ? Colors.red : Colors.grey,
                                                          width: 1.0
                                                      )
                                                  ),
                                                  disabledBorder: InputBorder.none,
                                                  contentPadding: EdgeInsets.zero,
                                                ),
                                                textAlign: TextAlign.start,
                                              ),
                                            ) : new Flexible(
                                              child: TextFormField(
                                                controller: durationController,
                                                readOnly: true,
                                                enabled: false,
                                                style: Theme.of(context).textTheme.bodyText2,
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  focusedBorder: InputBorder.none,
                                                  enabledBorder: InputBorder.none,
                                                  errorBorder: InputBorder.none,
                                                  disabledBorder: InputBorder.none,
                                                  contentPadding: EdgeInsets.zero,
                                                ),
                                                textAlign: TextAlign.start,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.02),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height*0.02),
                          Container(
                            height: MediaQuery.of(context).size.height*0.2,
                            width: MediaQuery.of(context).size.width*0.9,
                            decoration: BoxDecoration(
                                color: Theme.of(context).backgroundColor,
                                borderRadius: BorderRadius.all(Radius.circular(15.0))
                            ),
                            child: Stack(
                              children: <Widget>[
                                Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                      bottomRight: Radius.circular(15),
                                      bottomLeft: Radius.circular(15),
                                    ),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      heightFactor: 1,
                                      widthFactor: 2.5,
                                      child: GoogleMap(
                                        onMapCreated: _onMapCreated,
                                        initialCameraPosition: _initialPosition,
                                        scrollGesturesEnabled: false,
                                        zoomGesturesEnabled: false,
                                        rotateGesturesEnabled: false,
                                        mapToolbarEnabled: false,
                                        zoomControlsEnabled: false,
                                        minMaxZoomPreference: MinMaxZoomPreference(17,17),
                                        myLocationButtonEnabled: false,
                                        markers: markers,
                                        mapType: MapType.hybrid,
                                        onTap: isEditing ? (LatLng) async {
                                          var result = await Navigator.push(
                                              context,
                                              CupertinoPageRoute<String>(
                                                builder: (context) => MyLocationsSelect(
                                                  brandId: currentBrand.id!,
                                                ),
                                              )
                                          );
                                          if (result != null) {
                                            await getLocationFromId(result);
                                            setState(() {
                                              isLoading = false;
                                            });
                                          }
                                        } : _onLaunchCoordinates,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 5.0,
                                  bottom: 5.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Theme.of(context).scaffoldBackgroundColor
                                    ),
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.location_on,
                                          color: Theme.of(context).accentColor,
                                          size: 15,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5.0),
                                          child: Text(
                                            location.description!,
                                            style: Theme.of(context).textTheme.bodyText2,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          isEditing ? Padding(
                            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.05, top:MediaQuery.of(context).size.width*0.03),
                            child: Container(
                              height: 1,
                              width: MediaQuery.of(context).size.width*0.9,
                              color: AppColors.grey,
                            ),
                          ) : Container(),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.0),
                        child: Column(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height*0.025),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      AppLocalizations.of(context)!.trainers,
                                      style: Theme.of(context).textTheme.bodyText1!.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  isEditing ? Container(
                                    height: MediaQuery.of(context).size.height*0.15,
                                    width: MediaQuery.of(context).size.width*0.99,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: AlwaysScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: allTrainers.length,
                                        itemBuilder: (context, int index) {
                                          var trainer = allTrainers[index];
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                eventTrainersBool[index] = !eventTrainersBool[index];
                                              });
                                            },
                                            child: Padding(
                                              padding: !(index == 0 || index == allTrainers.length-1) ? EdgeInsets.symmetric(horizontal: 8.0) : (index == 0) ? EdgeInsets.only(left: MediaQuery.of(context).size.width*0.06, right: 8.0) : EdgeInsets.only(right: allTrainers.length != 1 ? MediaQuery.of(context).size.width*0.06 : 8.0, left: 8.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  CircularImage(
                                                    size: MediaQuery.of(context).size.width*0.18,
                                                    image: trainer.imageUrl,
                                                    color: Theme.of(context).primaryColor,
                                                    borderWidth: 1,
                                                  ),
                                                  Container(
                                                    width: MediaQuery.of(context).size.width*0.2,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          StringUtils().splitCommonName(trainer.name!),
                                                          style: Theme.of(context).textTheme.bodyText2,
                                                          textAlign: TextAlign.center,
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width*0.01,
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width*0.05,
                                                          child: Checkbox(
                                                            checkColor: Colors.white,
                                                            fillColor: MaterialStateProperty.resolveWith(getColor),
                                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                            value: eventTrainersBool[index],
                                                            shape: CircleBorder(
                                                                side: BorderSide.none
                                                            ),
                                                            onChanged: (bool? value) {
                                                              setState(() {
                                                                eventTrainersBool[index] = !eventTrainersBool[index];
                                                              });
                                                            },
                                                          ),
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
                                  ) :
                                  Container(
                                    height: MediaQuery.of(context).size.height*0.15,
                                    width: MediaQuery.of(context).size.width*0.99,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: BouncingScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: eventTrainers.length,
                                        itemBuilder: (context, int index) {
                                          var trainer = eventTrainers[index];
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(context, CupertinoPageRoute<Null>(
                                                builder: (context) => ProfileViewUser(userID: trainer.id!, viewOnly: false)));
                                            },
                                            child: Padding(
                                              padding: !(index == 0 || index == eventTrainers.length-1) ? EdgeInsets.symmetric(horizontal: 8.0) : (index == 0) ? EdgeInsets.only(left: MediaQuery.of(context).size.width*0.06, right: 8.0) : EdgeInsets.only(right: eventTrainers.length != 1 ? MediaQuery.of(context).size.width*0.06 : 8.0, left: 8.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  CircularImage(
                                                    size: MediaQuery.of(context).size.width*0.18,
                                                    image: trainer.imageUrl,
                                                    color: Theme.of(context).primaryColor,
                                                    borderWidth: 1,
                                                  ),
                                                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                                  Container(
                                                    width: MediaQuery.of(context).size.width*0.2,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            trainer.name! != AppLocalizations.of(context)!.notFoundUser ? StringUtils().splitCommonName(trainer.name!) : trainer.name!,
                                                            style: Theme.of(context).textTheme.bodyText2,
                                                            textAlign: TextAlign.center,
                                                          ),
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
                              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: 10),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Text(
                                    AppLocalizations.of(context)!.clients,
                                    style: Theme.of(context).textTheme.bodyText1!.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 16),
                                  (event!.isPrivate! == false) ? Row(
                                    children: [
                                      Text(
                                        "( "+event!.numClients.toString(),
                                        style: Theme.of(context).textTheme.bodyText2,
                                      ),
                                      Text(
                                        " / ",
                                        style: Theme.of(context).textTheme.bodyText2,
                                      ),
                                      Text(
                                        event!.maxMembers.toString()+" )",
                                        style: Theme.of(context).textTheme.bodyText2,
                                      ),
                                    ],
                                  ) : Row(
                                    children: [
                                      Text(
                                        "( "+event!.numClients.toString()+" )",
                                        style: Theme.of(context).textTheme.bodyText2,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            isEditing ? Padding(
                              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01, left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.05),
                              child: GestureDetector(
                                onTap: () {
                                  selectSlot(context, 2);
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(Icons.person, color: Theme.of(context).accentColor, size: MediaQuery.of(context).size.width*0.06),
                                    Container(
                                      padding: EdgeInsets.only(left: 20),
                                      width: MediaQuery.of(context).size.width*0.18,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          new Flexible(
                                            child: TextFormField(
                                              controller: membersController,
                                              readOnly: true,
                                              enabled: false,
                                              style: Theme.of(context).textTheme.bodyText2,
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
                                    Text(
                                      AppLocalizations.of(context)!.members.toLowerCase(),
                                      style: Theme.of(context).textTheme.bodyText2,
                                    ),
                                  ],
                                ),
                              ),
                            ) : Padding(
                              padding: EdgeInsets.only(top: 0),
                              child:
                              eventClients.isEmpty ?
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                          height: 100,
                                          child: Image.asset(Constants.emptyPeople)
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!.noClientJoining,
                                        style: Theme.of(context).textTheme.caption,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ],
                              ) :
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height*0.15,
                                    width: MediaQuery.of(context).size.width,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: BouncingScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: eventClients.length,
                                        itemBuilder: (context, int index) {
                                          var client = eventClients[index];
                                          var clientFeedback = eventClientsFeedback[index];
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(context, CupertinoPageRoute<Null>(
                                                builder: (context) => ProfileViewUser(userID: client.id!, viewOnly: false)));
                                            },
                                            child: Padding(
                                              padding: !(index == 0 || index == eventClients.length-1) ? EdgeInsets.symmetric(horizontal: 8.0) : (index == 0) ? EdgeInsets.only(left: MediaQuery.of(context).size.width*0.06, right: 8.0) : EdgeInsets.only(right: eventClients.length != 1 ? MediaQuery.of(context).size.width*0.06 : 8.0, left: 8.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  CircularImage(
                                                    size: MediaQuery.of(context).size.width*0.18,
                                                    image: client.imageUrl,
                                                    color: Theme.of(context).primaryColor,
                                                    borderWidth: 1,
                                                  ),
                                                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                                  Container(
                                                    width: MediaQuery.of(context).size.width*0.2,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            client.name! != AppLocalizations.of(context)!.notFoundUser ? StringUtils().splitCommonName(client.name!) : client.name!,
                                                            style: Theme.of(context).textTheme.bodyText2,
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                                  clientFeedback != null ? Container(
                                                    height: MediaQuery.of(context).size.height*0.02,
                                                    width: MediaQuery.of(context).size.width*0.1,
                                                    child: FittedBox(
                                                        fit: BoxFit.fitHeight,
                                                        child: buildEventFeedbackIcon(clientFeedback)
                                                    ),
                                                  ) : Container(),
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
                            isEditing ? SizedBox(height: MediaQuery.of(context).size.height*0.10) : SizedBox(height: MediaQuery.of(context).size.height*0.02),
                            canEdit ? SizedBox(height: MediaQuery.of(context).size.height*0.12) : SizedBox(height: MediaQuery.of(context).size.height*0.05),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
            ) : Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.13),
                child: LoadingViewPurple()),
          ),
        ],
      ),
      floatingActionButton: whichFloatingActionButton(context),
    );
  }

  Widget whichFloatingActionButton(BuildContext context) {
    if (isLoadingBody) {
      return Container();
    } else {
      if (canEdit) {
        return Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
          child: Container(
            width: MediaQuery.of(context).size.width*0.25,
            child: FloatingActionButton.extended(
              heroTag: "9",
              onPressed: () async {
                bool? result;
                if (event!.isPrivate!) {
                  result = await Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => AddOrEditPrivateEvent(
                          locale: Localizations.localeOf(context),
                          eventId: event!.id!,
                        ),
                      )
                  );
                } else {
                  result = await Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => AddOrEditEvent(
                          locale: Localizations.localeOf(context),
                          eventId: event!.id!,
                        ),
                      )
                  );
                }
                if (result != null && result) {
                  setState(() {
                    isLoading = true;
                  });
                  getEventInfo();
                  print("Updating Event ...");
                } else if (result != null && !result) {
                  print("Deleting Event ...");
                  Navigator.pop(context);
                }
              },
              backgroundColor: Colors.green,
              icon: Icon(Icons.edit, color: Colors.white, size: MediaQuery.of(context).size.width*0.05,),
              label: Text(AppLocalizations.of(context)!.edit,
                style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.white),),
            ),
          ),
        );
      } else {
        return Container();
      }
    }
  }
}

