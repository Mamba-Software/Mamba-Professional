import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/Event/EventDataService.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/notifications/NotificationService/LocalNotificationService.dart';
import 'package:mamba/notifications/NotificationService/NotificationService.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/commons/utils/Strings/StringUtils.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Dialogs/ActionDialogs/CancelRequestConfirmationDialog.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Dialogs/ActionDialogs/JoinConfirmationDialog.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Dialogs/ActionDialogs/SendRequestConfirmationDialog.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Dialogs/ActionDialogs/LeaveConfirmationDialog.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/ProfileView/ProfileUserView.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/events/crud_events/models/Event.dart';
import 'package:mamba/data/Models/Location.dart';
import 'package:mamba/data/Models/RequestToBrand.dart';
import 'package:mamba/data/Models/Usuario.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mamba/commons/managers/language_manager.dart';

class EventPageClient extends StatefulWidget {
  String eventId;
  bool? onlyView;
  EventPageClient({super.key, required this.eventId, this.onlyView});

  @override
  _EventPageClientState createState() => _EventPageClientState();
}

class _EventPageClientState extends State<EventPageClient>
    with SingleTickerProviderStateMixin {
  // Acceso a Base de Datos
  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();
  final _eventDataService = EventDataService();
  // Acceso a Base de Datos
  final NotificationService _notificationService = NotificationService();
  LocalNotificationService localNotificationService =
      LocalNotificationService();
  // Screen Dimensions
  double safeAreaHeight = 0;
  double safeAreaWidth = 0;
  // App Bar and Scroll View
  ScrollController? _scrollController;
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    return _scrollController!.hasClients &&
        _scrollController!.offset >
            (MediaQuery.of(context).size.height * 0.25 - kToolbarHeight);
  }

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
  List<String> durations = [
    "0.30",
    "1.00",
    "1.30",
    "2.00",
    "2.30",
    "3.00",
    "3.30",
    "4.00"
  ];
  // Location
  Location location = Location();
  Set<Marker> markers = <Marker>{};
  CameraPosition _initialPosition =
      const CameraPosition(target: LatLng(26.8206, 30.8025));
  GoogleMapController? mapController;
  final Completer<GoogleMapController> _controller = Completer();
  // Participants
  TextEditingController membersController = TextEditingController();
  int members = 1;
  int membersMax = 100;
  // Members Page
  bool isFull = false;
  bool isJoined = false;
  int placesLeft = 0;
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
  String deletedObject =
      "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/not-found-image.jpg?alt=media&token=70687295-6a17-4735-9c0a-e5749c777319";
  // Request To Brand
  String brandIdRequest = "";
  RequestToBrand? request;

  @override
  initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(
        () => _isAppBarExpanded
            ? setState(() {
                appBarExpanded = true;
              })
            : setState(() {
                appBarExpanded = false;
              }),
      );
    isLoading = true;
    getEventInfo();
  }

  // Init Device Sizes
  initDeviceSizes() {
    safeAreaHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    print(
        "Device H and W: ${MediaQuery.of(context).size.height} ${MediaQuery.of(context).size.width}");
    print("SafeArea H and W: $safeAreaHeight $safeAreaWidth");
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
    startDateController.text = DateFormat(
            'EEEE d/M/y - HH:mm', Localizations.localeOf(context).languageCode)
        .format(startDate);
    datetitle =
        DateFormat('EEEE d MMMM', Localizations.localeOf(context).languageCode)
            .format(startDate);
    startDateController.text =
        StringUtils().toCapitalized(startDateController.text);
    duration = event!.duration!.toStringAsFixed(2);
    var hour = event!.duration.toString().split(".")[0];
    var min = event!.duration!.toStringAsFixed(2).split(".")[1];
    durationController.text = "${hour}h ${min}min";
    members = event!.maxMembers!;
    membersController.text =
        "${event!.numClients.toString()} / ${event!.maxMembers.toString()}";
    setState(() {
      isFull = (event!.numClients! / event!.maxMembers! == 1);
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
    bool isJoinedTemp = false;
    for (var i = 0; i < allUsers.length; i++) {
      var user = allUsers[i];
      if (user.isTrainer!) {
        trainers.add(user);
      } else {
        if (currentUser.id! == user.id!) {
          // User has joined the event
          clients.insert(0, user);
          isJoinedTemp = true;
          double? feedbackClient = await _eventDataService.getEventUserFeedback(
              event!.id!, user.id!);
          eventClientsFeedback.insert(0, feedbackClient);
        } else {
          clients.add(user);
          double? feedbackClient = await _eventDataService.getEventUserFeedback(
              event!.id!, user.id!);
          eventClientsFeedback.add(feedbackClient);
        }
      }
    }
    clients = orderClientsPrivateLast(clients);
    if (mounted) {
      setState(() {
        placesLeft = members - eventClients.length;
        eventTrainers = trainers;
        eventClients = clients;
        isJoined = isJoinedTemp;
      });
    }
  }

  List<Usuario> orderClientsPrivateLast(List<Usuario> clients) {
    List<Usuario> orderedUsers = [];
    List<Usuario> privateUsers = [];
    for (var i = 0; i < clients.length; i++) {
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

  // Get user pending requests
  Future<void> getUserPendingRequests() async {
    List<RequestToBrand> req =
        await _userDataService.getUserRequests(currentUser.id!);
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

  void initCameraPosition() {
    setState(() {
      _initialPosition = CameraPosition(
          target: LatLng(location.latitude!, location.longitude!));
    });
  }

  void createMarker() async {
    Marker marker = Marker(
      markerId: const MarkerId('1'),
      position: LatLng(location.latitude!, location.longitude!),
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
    MapsLauncher.launchCoordinates(
        location.latitude!, location.longitude!, location.description!);
  }

  Widget buildPlacesLeftWidget(int places) {
    return FittedBox(
      fit: BoxFit.fitHeight,
      child: Container(
        height: MediaQuery.of(context).size.width * 0.14,
        padding: const EdgeInsets.only(top: 4, bottom: 8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                places.toString(),
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(color: isFull ? AppColors.red : Colors.green),
                textAlign: TextAlign.center,
              ),
              Text(
                places == 1 ? context.l10n.slot : context.l10n.slots,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 5, color: isFull ? AppColors.red : Colors.green),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build EventFeedback Value
  Widget buildEventFeedbackIcon(double eventFeedbackValue) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.1,
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.05,
              child: Image.asset(Assets.fireEmojiImage),
            ),
            Text(eventFeedbackValue.toString(),
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center),
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

    return isLoading
        ? Scaffold(
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
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background),
                ),
                Positioned(
                    top: MediaQuery.of(context).size.height * 0.32,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.05),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.04),
                                  Shimmer.fromColors(
                                    baseColor: AppColors.grey,
                                    highlightColor:
                                        AppColors.grey.withOpacity(0.5),
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.04,
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      decoration: const BoxDecoration(
                                          color: AppColors.grey,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0))),
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01),
                                  Shimmer.fromColors(
                                    baseColor: AppColors.grey,
                                    highlightColor:
                                        AppColors.grey.withOpacity(0.5),
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03,
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      decoration: const BoxDecoration(
                                          color: AppColors.grey,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0))),
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.04),
                                  Shimmer.fromColors(
                                    baseColor: AppColors.grey,
                                    highlightColor:
                                        AppColors.grey.withOpacity(0.5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.07,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.15,
                                          decoration: const BoxDecoration(
                                              color: AppColors.grey,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15.0))),
                                        ),
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.07,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                          decoration: const BoxDecoration(
                                              color: AppColors.grey,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15.0))),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02),
                                  Shimmer.fromColors(
                                    baseColor: AppColors.grey,
                                    highlightColor:
                                        AppColors.grey.withOpacity(0.5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.07,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.15,
                                          decoration: const BoxDecoration(
                                              color: AppColors.grey,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15.0))),
                                        ),
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.07,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                          decoration: const BoxDecoration(
                                              color: AppColors.grey,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15.0))),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.05),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02),
                                  Shimmer.fromColors(
                                    baseColor: AppColors.grey,
                                    highlightColor:
                                        AppColors.grey.withOpacity(0.5),
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.2,
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      decoration: const BoxDecoration(
                                          color: AppColors.grey,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0))),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.05),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.025),
                                  Shimmer.fromColors(
                                    baseColor: AppColors.grey,
                                    highlightColor:
                                        AppColors.grey.withOpacity(0.5),
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03,
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      decoration: const BoxDecoration(
                                          color: AppColors.grey,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0))),
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.025),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.height *
                                        0.26,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Shimmer.fromColors(
                                          baseColor: AppColors.grey,
                                          highlightColor:
                                              AppColors.grey.withOpacity(0.5),
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.08,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.08,
                                            decoration: const BoxDecoration(
                                              color: AppColors.grey,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                        Shimmer.fromColors(
                                          baseColor: AppColors.grey,
                                          highlightColor:
                                              AppColors.grey.withOpacity(0.5),
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.08,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.08,
                                            decoration: const BoxDecoration(
                                              color: AppColors.grey,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                        Shimmer.fromColors(
                                          baseColor: AppColors.grey,
                                          highlightColor:
                                              AppColors.grey.withOpacity(0.5),
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.08,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.08,
                                            decoration: const BoxDecoration(
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
                    )),
              ],
            ),
          )
        : Scaffold(
            appBar: null,
            resizeToAvoidBottomInset: true,
            body: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
                  toolbarHeight: MediaQuery.of(context).size.height * 0.1,
                  expandedHeight: MediaQuery.of(context).size.height * 0.22,
                  elevation: 0,
                  //systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5)),
                  floating: false,
                  pinned: true,
                  centerTitle: true,
                  title: appBarExpanded
                      ? Text(titleController.text,
                          style: Theme.of(context).appBarTheme.titleTextStyle)
                      : Container(),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: CachedNetworkImageProvider(event!.imageUrl!),
                          )),
                      child: const Center(),
                    ),
                    titlePadding: EdgeInsets.zero,
                    //centerTitle: true,
                  ),
                  leadingWidth: MediaQuery.of(context).size.width * 0.2,
                  leading: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Material(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: InkWell(
                          child: Padding(
                            padding: const EdgeInsets.all(13),
                            child: Icon(
                              Icons.arrow_back,
                              size: MediaQuery.of(context).size.width * 0.06,
                            ),
                          ),
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    canJoin
                        ? Padding(
                            padding: EdgeInsets.only(
                                right:
                                    MediaQuery.of(context).size.width * 0.05),
                            child: Container(
                              height: MediaQuery.of(context).size.width * 0.06,
                              width: MediaQuery.of(context).size.width * 0.12,
                              decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  shape: BoxShape.circle),
                              child: buildPlacesLeftWidget(placesLeft),
                            ),
                          )
                        : Container(),
                  ],
                ),
                !isLoadingBody
                    ? SliverToBoxAdapter(
                        child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.05),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01),
                                  Form(
                                    key: formKeyInfo,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: titleController,
                                                readOnly: true,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayLarge
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                decoration: InputDecoration(
                                                  hintStyle: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                  hintText: context.l10n
                                                      .titleHint,
                                                  border: InputBorder.none,
                                                  focusedBorder:
                                                      InputBorder.none,
                                                  enabledBorder:
                                                      InputBorder.none,
                                                  errorBorder: InputBorder.none,
                                                  disabledBorder:
                                                      InputBorder.none,
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .background,
                                              ),
                                              child: event!.isPrivate!
                                                  ? Row(
                                                      children: [
                                                        Text(
                                                            context
                                                                .l10n.private,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium,
                                                            textAlign: TextAlign
                                                                .right),
                                                        SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.01),
                                                        Icon(
                                                          Icons.person,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          size: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.05,
                                                        ),
                                                      ],
                                                    )
                                                  : Row(
                                                      children: [
                                                        Text(context.l10n.group,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium,
                                                            textAlign: TextAlign
                                                                .right),
                                                        SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.01),
                                                        Icon(
                                                          Icons.groups,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          size: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.05,
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: <Widget>[
                                                Flexible(
                                                  child: TextFormField(
                                                    controller:
                                                        descriptionController,
                                                    readOnly: true,
                                                    minLines: 1,
                                                    maxLines: 4,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium,
                                                    decoration: InputDecoration(
                                                      hintStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodySmall,
                                                      hintText: context
                                                          .l10n.noDescription,
                                                      border: InputBorder.none,
                                                      focusedBorder:
                                                          InputBorder.none,
                                                      enabledBorder:
                                                          InputBorder.none,
                                                      errorBorder:
                                                          InputBorder.none,
                                                      disabledBorder:
                                                          InputBorder.none,
                                                      contentPadding:
                                                          const EdgeInsets.all(
                                                              0),
                                                    ),
                                                    textAlign:
                                                        TextAlign.justify,
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02),
                                  errorDate
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Center(
                                            child: Text(
                                              context.l10n.errorDate,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                      color: AppColors.red),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.08,
                                    width: MediaQuery.of(context).size.width *
                                        0.90,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5.0))),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.07,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.07,
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withOpacity(0.08),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(5.0))),
                                          child: Center(
                                              child: Text(event!.day.toString(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .displayLarge
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary),
                                                  textAlign: TextAlign.center)),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.08,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.64,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Flexible(
                                                    child: TextFormField(
                                                      controller:
                                                          startDateController,
                                                      readOnly: true,
                                                      enabled: false,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                      decoration:
                                                          InputDecoration(
                                                        labelStyle: Theme.of(
                                                                context)
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                        border:
                                                            InputBorder.none,
                                                        focusedBorder:
                                                            InputBorder.none,
                                                        enabledBorder:
                                                            InputBorder.none,
                                                        errorBorder:
                                                            InputBorder.none,
                                                        disabledBorder:
                                                            InputBorder.none,
                                                      ),
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02),
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.08,
                                    width: MediaQuery.of(context).size.width *
                                        0.90,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5.0))),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.07,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.07,
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withOpacity(0.08),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(5.0))),
                                          child: Center(
                                              child: Icon(
                                            Icons.timer_outlined,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.06,
                                          )),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.08,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.64,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Flexible(
                                                    child: TextFormField(
                                                      controller:
                                                          durationController,
                                                      readOnly: true,
                                                      enabled: false,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium,
                                                      decoration:
                                                          const InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        focusedBorder:
                                                            InputBorder.none,
                                                        enabledBorder:
                                                            InputBorder.none,
                                                        errorBorder:
                                                            InputBorder.none,
                                                        disabledBorder:
                                                            InputBorder.none,
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                      ),
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02),
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.2,
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(15.0))),
                                  child: Stack(
                                    children: <Widget>[
                                      Center(
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
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
                                              initialCameraPosition:
                                                  _initialPosition,
                                              scrollGesturesEnabled: false,
                                              zoomGesturesEnabled: false,
                                              rotateGesturesEnabled: false,
                                              mapToolbarEnabled: false,
                                              zoomControlsEnabled: false,
                                              minMaxZoomPreference:
                                                  const MinMaxZoomPreference(
                                                      17, 17),
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
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor),
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Icon(
                                                Icons.location_on,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                                size: 15,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5.0),
                                                child: Text(
                                                  location.description!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
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
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.0),
                              child: Column(
                                children: [
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.025),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                        vertical: 10),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Text(
                                          context.l10n.trainers,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.15,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.99,
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              scrollDirection: Axis.horizontal,
                                              itemCount: eventTrainers.length,
                                              itemBuilder:
                                                  (context, int index) {
                                                var trainer =
                                                    eventTrainers[index];
                                                return GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        CupertinoPageRoute<
                                                                Null>(
                                                            builder: (context) =>
                                                                ProfileViewUser(
                                                                  userID:
                                                                      trainer
                                                                          .id!,
                                                                  viewOnly:
                                                                      false,
                                                                )));
                                                  },
                                                  child: Padding(
                                                    padding: !(index == 0 ||
                                                            index ==
                                                                eventTrainers
                                                                        .length -
                                                                    1)
                                                        ? const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 8.0)
                                                        : (index == 0)
                                                            ? EdgeInsets.only(
                                                                left: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.06,
                                                                right: 8.0)
                                                            : EdgeInsets.only(
                                                                right: eventTrainers
                                                                            .length !=
                                                                        1
                                                                    ? MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.06
                                                                    : 8.0,
                                                                left: 8.0),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        CircularImage(
                                                          size: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.18,
                                                          image:
                                                              trainer.imageUrl,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          borderWidth: 1,
                                                        ),
                                                        SizedBox(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.01),
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.2,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  trainer.name! !=
                                                                          context
                                                                              .l10n
                                                                              .notFoundUser
                                                                      ? trainer
                                                                          .firstName!
                                                                      : trainer
                                                                          .name!,
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyMedium,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                        vertical: 10),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Text(
                                          context.l10n.clients,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 16),
                                        (event!.isPrivate! == false)
                                            ? Row(
                                                children: [
                                                  Text(
                                                    "( ${event!.numClients}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium,
                                                  ),
                                                  Text(
                                                    " / ",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium,
                                                  ),
                                                  Text(
                                                    "${event!.maxMembers} )",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium,
                                                  ),
                                                ],
                                              )
                                            : Row(
                                                children: [
                                                  Text(
                                                    "( ${event!.numClients} )",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium,
                                                  ),
                                                ],
                                              ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 0),
                                    child: eventClients.isEmpty
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Column(
                                                children: [
                                                  SizedBox(
                                                      height: 100,
                                                      child: Image.asset(
                                                          Assets.emptyPeople)),
                                                  Text(
                                                    context
                                                        .l10n.noClientJoining,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.15,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        const BouncingScrollPhysics(),
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount:
                                                        eventClients.length,
                                                    itemBuilder:
                                                        (context, int index) {
                                                      var client =
                                                          eventClients[index];
                                                      var clientFeedback =
                                                          eventClientsFeedback[
                                                              index];
                                                      if (client.isPrivate! &&
                                                          client.id !=
                                                              currentUser.id) {
                                                        return GestureDetector(
                                                          onTap: () {},
                                                          child: Padding(
                                                            padding: !(index ==
                                                                        0 ||
                                                                    index ==
                                                                        eventClients.length -
                                                                            1)
                                                                ? const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8.0)
                                                                : (index == 0)
                                                                    ? EdgeInsets.only(
                                                                        left: MediaQuery.of(context).size.width *
                                                                            0.06,
                                                                        right:
                                                                            8.0)
                                                                    : EdgeInsets.only(
                                                                        right: eventClients.length !=
                                                                                1
                                                                            ? MediaQuery.of(context).size.width *
                                                                                0.06
                                                                            : 8.0,
                                                                        left:
                                                                            8.0),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                CircularImage(
                                                                  size: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.18,
                                                                  image: client
                                                                      .noImageUrl,
                                                                  color: Colors
                                                                      .grey,
                                                                  borderWidth:
                                                                      1,
                                                                ),
                                                                SizedBox(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        0.01),
                                                                SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.2,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          client.name! != context.l10n.notFoundUser
                                                                              ? client.firstName!
                                                                              : client.name!,
                                                                          style: Theme.of(context)
                                                                              .textTheme
                                                                              .bodySmall,
                                                                          textAlign:
                                                                              TextAlign.center,
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
                                                            Navigator.push(
                                                                context,
                                                                CupertinoPageRoute<
                                                                        Null>(
                                                                    builder: (context) => ProfileViewUser(
                                                                        userID: client
                                                                            .id!,
                                                                        viewOnly:
                                                                            false)));
                                                          },
                                                          child: Padding(
                                                            padding: !(index ==
                                                                        0 ||
                                                                    index ==
                                                                        eventClients.length -
                                                                            1)
                                                                ? const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8.0)
                                                                : (index == 0)
                                                                    ? EdgeInsets.only(
                                                                        left: MediaQuery.of(context).size.width *
                                                                            0.06,
                                                                        right:
                                                                            8.0)
                                                                    : EdgeInsets.only(
                                                                        right: eventClients.length !=
                                                                                1
                                                                            ? MediaQuery.of(context).size.width *
                                                                                0.06
                                                                            : 8.0,
                                                                        left:
                                                                            8.0),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                CircularImage(
                                                                  size: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.18,
                                                                  image: client
                                                                      .imageUrl,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                                  borderWidth:
                                                                      1,
                                                                ),
                                                                SizedBox(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        0.01),
                                                                SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.2,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          client.name! != context.l10n.notFoundUser
                                                                              ? client.firstName!
                                                                              : client.name!,
                                                                          style: Theme.of(context)
                                                                              .textTheme
                                                                              .bodyMedium,
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        0.01),
                                                                clientFeedback !=
                                                                        null
                                                                    ? SizedBox(
                                                                        height: MediaQuery.of(context).size.height *
                                                                            0.02,
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.1,
                                                                        child: FittedBox(
                                                                            fit:
                                                                                BoxFit.fitHeight,
                                                                            child: buildEventFeedbackIcon(clientFeedback)),
                                                                      )
                                                                    : Container(),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    }),
                                              ),
                                            ],
                                          ),
                                  ),
                                  canJoin || (widget.onlyView != null)
                                      ? SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.14)
                                      : SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.05),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ))
                    : SliverFillRemaining(child: Center(child: LoadingView())),
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
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.40,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.03),
                          child: FloatingActionButton.extended(
                            shape: const StadiumBorder(),
                            heroTag: "1",
                            onPressed: () async {
                              var result = await showDialog(
                                  context: context,
                                  builder: (_) {
                                    return CancelRequestConfirmationDialog(
                                      text: context
                                          .l10n.cancelRequestConfirmation,
                                      brand: brand!,
                                    );
                                  });
                              if (result) {
                                setState(() {
                                  brandIdRequest = "";
                                });
                                NotificationService().userCancelRequestToBrand(
                                    currentUser.id!, request!.brandId!);
                                // New DataBase
                                _userDataService.deleteRequestToBrand(request!);
                                getUserPendingRequests();
                              }
                            },
                            backgroundColor: Colors.red,
                            icon: Icon(
                              Icons.schedule_send,
                              color: Colors.white,
                              size: MediaQuery.of(context).size.width * 0.05,
                            ),
                            label: Text(
                              context.l10n.sent,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Padding(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.40,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.03),
                          child: FloatingActionButton.extended(
                            shape: const StadiumBorder(),
                            heroTag: "2",
                            onPressed: () async {
                              var result = await showDialog(
                                  context: context,
                                  builder: (_) {
                                    return SendRequestConfirmationDialog(
                                      text:
                                          context.l10n.sendRequestConfirmation,
                                      brand: brand!,
                                    );
                                  });
                              if (result) {
                                setState(() {
                                  brandIdRequest = brand!.id!;
                                });
                                // New DataBase
                                await _userDataService.sendRequestToBrand(
                                    brand!.id!,
                                    currentUser.name!,
                                    currentUser.isTrainer!);
                                NotificationService().userSendRequestToBrand(
                                    currentUser.id!, brand!.id!);
                                getUserPendingRequests();
                              }
                            },
                            backgroundColor: Colors.green,
                            icon: Icon(
                              Icons.send_outlined,
                              color: Colors.white,
                              size: MediaQuery.of(context).size.width * 0.05,
                            ),
                            label: Text(
                              context.l10n.join,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: Colors.white),
                            ),
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
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.40,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.03),
                        child: FloatingActionButton.extended(
                          shape: const StadiumBorder(),
                          heroTag: "6",
                          onPressed: () async {
                            var result = await showDialog(
                                context: context,
                                builder: (_) {
                                  return JoinConfirmationDialog(
                                      text: context.l10n.joinEventConfirmation);
                                });
                            if (result) {
                              // Join Event
                              setState(() {
                                isLoadingBody = true;
                              });
                              // Schedule Local Notifications
                              localNotificationService
                                  .addEventLocalNotifications(
                                      context, event!.id!, false);
                              // Add To Data Base
                              await _eventDataService.addUserToEvent(
                                  event!.id!, currentUser.id!, "");
                              // Update Events collection, so that Cloud Functions does not have to do it
                              await _eventDataService.updateEventNumberMembers(
                                  event!.id!,
                                  (eventClients.length + 1),
                                  eventTrainers.length);
                              // Send Notification Service
                              _notificationService.userJoinEvent(
                                  currentUser.id!, event!.brandID!, event!.id!);
                              // Get New Event Info
                              await getEventInfo();
                              setState(() {
                                isJoined = true;
                                isLoadingBody = false;
                              });
                            }
                          },
                          backgroundColor: Colors.green,
                          icon: const Icon(
                            Icons.event_available_outlined,
                            color: Colors.white,
                          ),
                          label: Text(
                            context.l10n.book,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (isJoined) {
            return Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.40,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.03),
                        child: FloatingActionButton.extended(
                          shape: const StadiumBorder(),
                          heroTag: "51",
                          onPressed: () async {
                            var result = await showDialog(
                                context: context,
                                builder: (_) {
                                  return LeaveConfirmationDialog(
                                      text:
                                          context.l10n.leaveEventConfirmation);
                                });
                            if (result) {
                              // Leave Event
                              setState(() {
                                isLoadingBody = true;
                              });
                              // Schedule Local Notifications
                              localNotificationService
                                  .deleteEventLocalNotifications(event!.id!);
                              // Base de Dades
                              await _eventDataService.deleteUserFromEvent(
                                  event!.id!, currentUser.id!);
                              // Update Events collection, so that Cloud Functions does not have to do it
                              await _eventDataService.updateEventNumberMembers(
                                  event!.id!,
                                  (eventClients.length - 1),
                                  eventTrainers.length);
                              // Send Local Notifications
                              _notificationService.userLeaveEvent(
                                  currentUser.id!, event!.brandID!, event!.id!);
                              // Get New Event Info
                              await getEventInfo();
                              setState(() {
                                isJoined = false;
                                isLoadingBody = false;
                              });
                            }
                          },
                          backgroundColor: Colors.red,
                          icon: const Icon(
                            Icons.event_busy_outlined,
                            color: Colors.white,
                          ),
                          label: Text(
                            context.l10n.leave,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: Colors.white),
                          ),
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
