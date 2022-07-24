import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Notifications/RecievedNotification.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/LocalNotificationService.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/CancelRequestConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/JoinConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/SendRequestConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/LeaveConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingViewPurple.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/ProfileView/ProfileUserView.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Data/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class EventPageClient extends StatefulWidget {
  String eventId;
  bool? onlyView;
  EventPageClient({Key? key, required this.eventId, this.onlyView}) : super(key: key);

  @override
  _EventPageClientState createState() => _EventPageClientState();
}

class _EventPageClientState extends State<EventPageClient> with SingleTickerProviderStateMixin {
  // Acceso a Base de Datos
  var _userDataService = new UserDataService();
  var _brandDataService = new BrandDataService();
  var _eventDataService = new EventDataService();
  // Acceso a Base de Datos
  NotificationService _notificationService = NotificationService();
  LocalNotificationService localNotificationService = LocalNotificationService();
  // Screen Dimensions
  var safeAreaHeight;
  var safeAreaWidth;
  // Boolean Loading
  bool isFirstBuild = true;
  bool isLoading = true;
  bool isLoadingBody = false;
  // Boolean isUpdated
  bool isEditing = false;
  bool canJoin = true;
  // Title Controller
  var titleController = TextEditingController();
  String? titleString;
  // Description Controller
  var descriptionController = TextEditingController();
  String? descriptionString;
  // Starting Date and Time
  String datetitle = "";
  DateTime startDate = DateTime.now();
  TextEditingController startDateController = TextEditingController();
  bool errorDate = false;
  // Duration
  TextEditingController durationController = TextEditingController();
  String duration = "1.00";
  List<String> durations = ["0.30","1.00","1.30","2.00","2.30","3.00","3.30","4.00"];
  // Location
  Location location = Location();
  Set<Marker> markers = new Set<Marker>();
  CameraPosition _initialPosition = CameraPosition(target: LatLng(26.8206, 30.8025));
  GoogleMapController? mapController;
  Completer<GoogleMapController> _controller = Completer();
  // Participants
  TextEditingController membersController = TextEditingController();
  int members = 1;
  int membersMax = 100;
  // Members Page
  bool isFull = false;
  bool isJoined = false;
  List<Usuario> allUsers = [];
  List<Usuario> eventTrainers = [];
  List<Usuario> eventClients = [];
  List<double?> eventClientsFeedback = [];
  // Form To Validate User
  final formKeyInfo = GlobalKey<FormState>();
  final formKeyTime = GlobalKey<FormState>();
  final formKeyMembers = GlobalKey<FormState>();
  // Event Retrieved From BD
  Brand? brand;
  Event? event;
  var placeDetails;
  // BackGround image
  Image? theImage;
  // String Deleted Photo
  String deletedObject = "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/not-found-image.jpg?alt=media&token=70687295-6a17-4735-9c0a-e5749c777319";
  // Request To Brand
  String brandIdRequest = "";
  RequestToBrand? request;

  @override
  initState() {
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

  Future getEventInfo() async {
    // Get Event
    event = await _eventDataService.getSingleEvent(widget.eventId);
    // Get Brand
    brand = await _brandDataService.getBrandDetails(event!.brandID!);
    titleController.text = "${event!.title}";
    titleString = "${event!.title}";
    descriptionController.text = "${event!.description}";
    descriptionString = "${event!.description}";
    startDate = DateTime(
      int.parse(event!.year!),
      int.parse(event!.month!),
      int.parse(event!.day!),
      int.parse(event!.hour!),
      int.parse(event!.minute!),
    );
    if (startDate.isBefore(DateTime.now()) || widget.onlyView == true) {
      canJoin = false;
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
    if (widget.onlyView != null) {
      if (widget.onlyView!) await getUserPendingRequests();
    }
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 1000), () {
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
    List<Usuario> trainers = [];
    List<Usuario> clients = [];
    bool _isJoined = false;
    for (var i=0; i < allUsers.length; i++) {
      var user = allUsers[i];
      if (user.isTrainer!) {
        trainers.add(user);
      } else {
        if (currentUser.id! == user.id!) {
          // User has joined the event
          clients.insert(0, user);
          _isJoined = true;
          double? feedbackClient = await _eventDataService.getEventUserFeedback(event!.id!, user.id!);
          eventClientsFeedback.insert(0, feedbackClient);
        } else {
          clients.add(user);
          double? feedbackClient = await _eventDataService.getEventUserFeedback(event!.id!, user.id!);
          eventClientsFeedback.add(feedbackClient);
        }
      }
    }
    clients = orderClientsPrivateLast(clients);
    if (mounted) {
      setState(() {
        eventTrainers = trainers;
        eventClients = clients;
        isJoined = _isJoined;
      });
    }
  }

  List<Usuario> orderClientsPrivateLast(List<Usuario> clients) {
    List<Usuario> orderedUsers = [];
    List<Usuario> privateUsers = [];
    for (var i=0; i< clients.length; i++) {
      Usuario client = clients[i];
      if (client.id == currentUser.id) {
        orderedUsers.insert(0, client);
      } else {
        if (client.isPrivate!) {
          privateUsers.add(client);
        } else {
          orderedUsers.add(client);
        }
      }
    }
    orderedUsers.addAll(privateUsers);
    return orderedUsers;
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

  // Get user pending requests
  Future<void> getUserPendingRequests() async {
    List<RequestToBrand> req = await _userDataService.getUserRequests(currentUser.id!);
    if (req.isNotEmpty) {
      // At this moment, only 1 requests possible
      setState(() {
        request = req[0];
        brandIdRequest = request!.brandId!;
      });
    } else {
      setState(() {
        request = null;
      });
    }
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
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height*0.10,
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
                          (!canJoin || event!.isPrivate!) ? Padding(
                            padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.08, left: MediaQuery.of(context).size.width*0.08),
                            child: Container(),
                          ) :
                          Padding(
                            padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.05, left: MediaQuery.of(context).size.width*0.05),
                            child: Column(
                              children: [
                                !isEditing ? Icon(isFull ? Icons.lock_outline : Icons.lock_open, color: isFull ? Colors.red : Color(0xFFA8C76C)) : Icon(Icons.lock_open, color: Theme.of(context).scaffoldBackgroundColor),
                                !isEditing ? Text(isFull ? AppLocalizations.of(context)!.full : AppLocalizations.of(context)!.available, style:  Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold, color: isFull ? Colors.red : Color(0xFFA8C76C))) : Text(AppLocalizations.of(context)!.full, style:  Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).scaffoldBackgroundColor)),
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
                                      Expanded(
                                        child: new TextField(
                                          controller: titleController,
                                          readOnly: true,
                                          style: Theme.of(context).textTheme.headline1?.copyWith(fontWeight: FontWeight.bold),
                                          decoration: InputDecoration(
                                            labelStyle: Theme.of(context).textTheme.bodyText2,
                                            hintText:AppLocalizations.of(context)!.noDescription,
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
                                          Flexible(
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
                                            Flexible(
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
                                            Flexible(
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
                                        onTap: _onLaunchCoordinates,
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
                                                builder: (context) => ProfileViewUser(userID: trainer.id!, viewOnly: false,)));
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
                                                            trainer.name! != AppLocalizations.of(context)!.notFoundUser ? trainer.firstName! : trainer.name!,
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
                                  !isEditing ? Row(
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
                                  ) : Container(),
                                ],
                              ),
                            ),
                            Padding(
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
                                          if (client.isPrivate! && client.id != currentUser.id) {
                                            return GestureDetector(
                                              onTap: () {

                                              },
                                              child: Padding(
                                                padding: !(index == 0 || index == eventClients.length-1) ? EdgeInsets.symmetric(horizontal: 8.0) : (index == 0) ? EdgeInsets.only(left: MediaQuery.of(context).size.width*0.06, right: 8.0) : EdgeInsets.only(right: eventClients.length != 1 ? MediaQuery.of(context).size.width*0.06 : 8.0, left: 8.0),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    CircularImage(
                                                      size: MediaQuery.of(context).size.width*0.18,
                                                      image: client.noImageUrl,
                                                      color: Colors.grey,
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
                                                              client.name! != AppLocalizations.of(context)!.notFoundUser ? client.firstName! : client.name!,
                                                              style: Theme.of(context).textTheme.caption,
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
                                          } else {
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
                                                              client.name! != AppLocalizations.of(context)!.notFoundUser ? client.firstName! : client.name!,
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

                                        }
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            canJoin || (widget.onlyView != null) ? SizedBox(height: MediaQuery.of(context).size.height*0.14) : SizedBox(height: MediaQuery.of(context).size.height*0.05),
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
      floatingActionButton: whichFloatingActionButton(),
    );
  }

  Widget whichFloatingActionButton() {
    if (isLoadingBody) {
      return Container();
    } else {
      if (widget.onlyView != null) {
        if (widget.onlyView!) {
          if (request == null || brandIdRequest == brand!.id!) {
            if (brandIdRequest == brand!.id!) {
              return Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width*0.40,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03),
                          child: FloatingActionButton.extended(
                            heroTag: "1",
                            onPressed: () async {
                              var result = await showDialog(
                                  context: context,
                                  builder: (_) {
                                    return CancelRequestConfirmationDialog(
                                      text: AppLocalizations.of(context)!.cancelRequestConfirmation,
                                      brand: brand!,
                                    );
                                  }
                              );
                              if (result) {
                                setState(() {
                                  brandIdRequest = "";
                                });
                                NotificationService().userCancelRequestToBrand(currentUser.id!, request!.brandId!);
                                // New DataBase
                                _userDataService.deleteRequestToBrand(request!);
                                getUserPendingRequests();
                              }
                            },
                            backgroundColor: Colors.red,
                            icon: Icon(Icons.schedule_send, color: Colors.white, size: MediaQuery.of(context).size.width*0.05,),
                            label: Text(
                              AppLocalizations.of(context)!.sent,
                              style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.white),),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width*0.40,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03),
                          child: FloatingActionButton.extended(
                            heroTag: "2",
                            onPressed: () async {
                              var result = await showDialog(
                                  context: context,
                                  builder: (_) {
                                    return SendRequestConfirmationDialog(
                                      text: AppLocalizations.of(context)!.sendRequestConfirmation,
                                      brand: brand!,
                                    );
                                  }
                              );
                              if (result) {
                                setState(() {
                                  brandIdRequest = brand!.id!;
                                });
                                // New DataBase
                                await _userDataService.sendRequestToBrand(brand!.id!, currentUser.name! ,currentUser.isTrainer!);
                                NotificationService().userSendRequestToBrand(currentUser.id!, brand!.id!);
                                getUserPendingRequests();
                              }
                            },
                            backgroundColor: Colors.green,
                            icon: Icon(Icons.send_outlined, color: Colors.white, size: MediaQuery.of(context).size.width*0.05,),
                            label: Text(
                              AppLocalizations.of(context)!.join,
                              style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.white),),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }
        }
      } else {
        if (canJoin) {
          if (!isJoined && !isFull) {
            return Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width*0.40,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03),
                        child: FloatingActionButton.extended(
                          heroTag: "6",
                          onPressed: () async {
                            var result = await showDialog(
                                context: context,
                                builder: (_) {
                                  return JoinConfirmationDialog(text: AppLocalizations.of(context)!.joinEventConfirmation);
                                }
                            );
                            if (result) {
                              // Join Event
                              setState(() {
                                isLoadingBody = true;
                              });
                              // Schedule Local Notifications
                              localNotificationService.addEventLocalNotifications(context, event!.id!, false);
                              // Add To Data Base
                              await _eventDataService.addUserToEvent(event!.id!, currentUser.id!);
                              // Update Events collection, so that Cloud Functions does not have to do it
                              await _eventDataService.updateEventNumberMembers(event!.id!,(eventClients.length+1), eventTrainers.length);
                              // Send Notification Service
                              _notificationService.userJoinEvent(currentUser.id!, event!.brandID!, event!.id!);
                              // Get New Event Info
                              await getEventInfo();
                              setState(() {
                                isJoined = true;
                                isLoadingBody = false;
                              });
                            }
                          },
                          backgroundColor: Colors.green,
                          icon: Icon(Icons.event_available_outlined, color: Colors.white,),
                          label: Text(
                            AppLocalizations.of(context)!.book,
                            style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.white),),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (isJoined) {
            return Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width*0.40,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03),
                        child: FloatingActionButton.extended(
                          heroTag: "50",
                          onPressed: () async {
                            var result = await showDialog(
                                context: context,
                                builder: (_) {
                                  return LeaveConfirmationDialog(text: AppLocalizations.of(context)!.leaveEventConfirmation);
                                }
                            );
                            if (result) {
                              // Leave Event
                              setState(() {
                                isLoadingBody = true;
                              });
                              // Schedule Local Notifications
                              localNotificationService.deleteEventLocalNotifications(event!.id!);
                              // Base de Dades
                              await _eventDataService.deleteUserFromEvent(event!.id!, currentUser.id!);
                              // Update Events collection, so that Cloud Functions does not have to do it
                              await _eventDataService.updateEventNumberMembers(event!.id!,(eventClients.length-1), eventTrainers.length);
                              // Send Local Notifications
                              _notificationService.userLeaveEvent(currentUser.id!, event!.brandID!, event!.id!);
                              // Get New Event Info
                              await getEventInfo();
                              setState(() {
                                isJoined = false;
                                isLoadingBody = false;
                              });
                            }
                          },
                          backgroundColor: Colors.red,
                          icon: Icon(Icons.event_busy_outlined, color: Colors.white,),
                          label: Text(
                            AppLocalizations.of(context)!.leave,
                            style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.white),),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Container();
          }
        }
      }
      return Container();
    }
  }
}

