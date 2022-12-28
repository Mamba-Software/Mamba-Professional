import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Globals/Providers/ThemeProvider.dart';
import 'package:mamba_castelldefels/Globals/Utils/DynamicLinks/DynamicLinkUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/BonoCard.dart';
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
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/ProfileView/ProfileUserView.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
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
  final _brandDataService = BrandDataService();
  final _eventDataService = EventDataService();
  final _locationDataService = LocationDataService();
  final _dynamicLinkUtils = DynamicLinkUtils();
  // Screen Dimensions
  double safeAreaHeight = 0;
  double safeAreaWidth = 0;
  // App Bar and Scroll View
  ScrollController? _scrollController;
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    return _scrollController!.hasClients && _scrollController!.offset > (MediaQuery.of(context).size.height*0.25 - kToolbarHeight);
  }
  // Boolean Loading
  bool isFirstBuild = true;
  bool isLoading = true;
  bool isLoadingBody = false;
  // Boolean isUpdated
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
  Set<Marker> markers = <Marker>{};
  CameraPosition _initialPosition = const CameraPosition(target: LatLng(26.8206, 30.8025));
  GoogleMapController? mapController;
  final Completer<GoogleMapController> _controller = Completer();
  // Participants
  TextEditingController membersController = TextEditingController();
  int members = 1;
  int placesLeft = 0;
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
  // String Deleted Photo
  String deletedObject = "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/not-found-image.jpg?alt=media&token=70687295-6a17-4735-9c0a-e5749c777319";
  // Event Bonos
  List<Bono> eventBonos = [];

  @override
  initState() {
    super.initState();
    _scrollController = ScrollController()
    ..addListener(() => _isAppBarExpanded ?
    setState(() {
      appBarExpanded = true;
    }) :
    setState(() {
      appBarExpanded = false;
    }),
    );
    isLoading = true;
    getEventInfo();
  }

  // Init Device Sizes
  initDeviceSizes() {
    safeAreaHeight = MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    print("Device H and W: "+MediaQuery.of(context).size.height.toString()+" "+MediaQuery.of(context).size.width.toString());
    print("SafeArea H and W: "+safeAreaHeight.toString()+" "+safeAreaWidth.toString());
  }

  void getEventInfo() async {
    event = await _eventDataService.getSingleEvent(widget.eventId);
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
    if (currentUser.brandRole > 2) {
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
    await getEventBonos();
    await getEventLocation(event!.id!);
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          isLoading = false;
          isLoadingBody = false;
        });
      });
    }
  }

  Future<void> getEventBonos() async {
    eventBonos = await _eventDataService.getEventBonos(widget.eventId, currentBrand.id!);
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
        placesLeft = members - eventClients.length;
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

  void initCameraPosition() {
    setState(() {
      _initialPosition = CameraPosition(target: LatLng(location.latitude!,location.longitude!));
    });
  }

  void createMarker() async{
    Marker marker = Marker(
      markerId: const MarkerId('1'),
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

  void _onLaunchCoordinates(latLng) {
    mixpanel!.track('event_view_location_tap', properties: {'isPrivate': event!.isPrivate!});
    MapsLauncher.launchCoordinates(location.latitude!, location.longitude!, location.description!);
  }

  // Build EventFeedback Value
  Widget buildEventFeedbackIcon(double eventFeedbackValue) {
    return SizedBox(
      width: MediaQuery.of(context).size.width*0.1,
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
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

  // Build Places Left Event
  Widget buildPlacesLeftWidget(int places) {
    return FittedBox(
      fit: BoxFit.fitHeight,
      child: isFull == false ? Container(
          height: MediaQuery.of(context).size.width*0.1,
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                places.toString(),
                style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.green),
                textAlign: TextAlign.center,
              ),
              Text(
                places == 1 ? AppLocalizations.of(context)!.slot : AppLocalizations.of(context)!.slots,
                style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 5, color: Colors.green),
                textAlign: TextAlign.center,
              ),
            ],
          )
      ) : Container(
        height: MediaQuery.of(context).size.width*0.1,
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                Icons.lock_outlined,
                size: MediaQuery.of(context).size.width * 0.05,
                color: AppColors.red,
              ),
              Text(
                AppLocalizations.of(context)!.full,
                style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 5, color: AppColors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build Places Left Event
  Widget buildAverageFeedbackWidget() {
    if (event!.averageIntensityScore != null) {
      return FittedBox(
        fit: BoxFit.fitHeight,
        child: Container(
            height: MediaQuery.of(context).size.width*0.1,
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      event!.averageIntensityScore!.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodyText2,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.03,
                      child: Image.asset(Constants.fireEmojiImage),
                    ),
                  ],
                ),
                Text(
                  AppLocalizations.of(context)!.average,
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 5),
                  textAlign: TextAlign.center,
                ),
              ],
            )
        ),
      );
    } else {
      return FittedBox(
        fit: BoxFit.fitHeight,
        child: Container(
            height: MediaQuery.of(context).size.width*0.1,
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      "-- ",
                      style: Theme.of(context).textTheme.bodyText2,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.03,
                      child: Image.asset(Constants.fireEmojiImage),
                    ),
                  ],
                ),
                Text(
                  AppLocalizations.of(context)!.average,
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 5),
                  textAlign: TextAlign.center,
                ),
              ],
            )
        ),
      );
    }
  }

  // Build Places Left Event
  SystemUiOverlayStyle returnSystemBarColor() {
    if (Platform.isAndroid) {
      return SystemUiOverlayStyle.light;
    } else {
      bool isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
      if (isDark) {
        return SystemUiOverlayStyle.light;
      } else {
        return !appBarExpanded ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
      }
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
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor
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
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.08),
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
                                decoration: const BoxDecoration(
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
                                decoration: const BoxDecoration(
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
                                    decoration: const BoxDecoration(
                                        color: AppColors.grey,
                                        borderRadius: BorderRadius.all(Radius.circular(15.0))
                                    ),
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.07,
                                    width: MediaQuery.of(context).size.width*0.66,
                                    decoration: const BoxDecoration(
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
                                    decoration: const BoxDecoration(
                                        color: AppColors.grey,
                                        borderRadius: BorderRadius.all(Radius.circular(15.0))
                                    ),
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.07,
                                    width: MediaQuery.of(context).size.width*0.66,
                                    decoration: const BoxDecoration(
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
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.08),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height*0.02),
                            Shimmer.fromColors(
                              baseColor: AppColors.grey,
                              highlightColor: AppColors.grey.withOpacity(0.5),
                              child: Container(
                                height: MediaQuery.of(context).size.height*0.13,
                                width: MediaQuery.of(context).size.width*0.84,
                                decoration: const BoxDecoration(
                                    color: AppColors.grey,
                                    borderRadius: BorderRadius.all(Radius.circular(15.0))
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.08),
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
                                decoration: const BoxDecoration(
                                    color: AppColors.grey,
                                    borderRadius: BorderRadius.all(Radius.circular(15.0))
                                ),
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.025),
                            SizedBox(
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
                                      decoration: const BoxDecoration(
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
                                      decoration: const BoxDecoration(
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
              )
          ),
        ],
      ),
    )
        :
    Scaffold(
      appBar: null,
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height*0.22,
            elevation: 0,
            systemOverlayStyle: returnSystemBarColor(),
            floating: true,
            pinned: true,
            centerTitle: true,
            title: appBarExpanded ? Text(
                titleController.text,
                style: Theme.of(context).appBarTheme.titleTextStyle
            ) : Container(),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(event!.imageUrl!),
                    )
                ),
                child: const Center(),
              ),
              titlePadding: EdgeInsets.zero,
              //centerTitle: true,
            ),
            leadingWidth: MediaQuery.of(context).size.width*0.2,
            leading: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Material(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: InkWell(
                    child: Padding(
                      padding: const EdgeInsets.all(13),
                      child : Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width * 0.06,),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
            actions: [
              isLoadingBody == false && canEdit && event!.isPrivate! == false ? Padding(
                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.05),
                child: Container(
                  height: MediaQuery.of(context).size.width*0.06,
                  width: MediaQuery.of(context).size.width*0.12,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shape: BoxShape.circle
                  ),
                  child: buildPlacesLeftWidget(placesLeft),
                ),
              ) : Padding(
                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.05),
                child: Container(
                  height: MediaQuery.of(context).size.width*0.06,
                  width: MediaQuery.of(context).size.width*0.12,
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: BoxShape.circle
                  ),
                  child: buildAverageFeedbackWidget(),
                ),
              ),
            ],
          ),
          !isLoadingBody ? SliverToBoxAdapter(child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.08),
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
                                    child: TextField(
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
                                ],
                              ),
                              Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Flexible(
                                        child: TextFormField(
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
                                            contentPadding: const EdgeInsets.all(0),
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
                          width: MediaQuery.of(context).size.width * 0.84,
                          decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: const BorderRadius.all(Radius.circular(5.0))
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                height: MediaQuery.of(context).size.height * 0.06,
                                width: MediaQuery.of(context).size.height * 0.06,
                                decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.08),
                                    borderRadius: const BorderRadius.all(Radius.circular(5.0))
                                ),
                                child: Center(
                                    child: Text(
                                        event!.day.toString(),
                                        style: Theme.of(context).textTheme.headline1?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
                                        textAlign: TextAlign.center
                                    )
                                ),
                              ),
                              SizedBox(width: MediaQuery.of(context).size.width*0.04),
                              SizedBox(
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
                        Container(
                          height: MediaQuery.of(context).size.height * 0.08,
                          width: MediaQuery.of(context).size.width * 0.84,
                          decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: const BorderRadius.all(Radius.circular(5.0))
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                height: MediaQuery.of(context).size.height * 0.06,
                                width: MediaQuery.of(context).size.height * 0.06,
                                decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.08),
                                    borderRadius: const BorderRadius.all(Radius.circular(5.0))
                                ),
                                child: Center(
                                    child: Icon(Icons.timer_outlined, color: Theme.of(context).colorScheme.secondary, size: MediaQuery.of(context).size.width*0.06,)
                                ),
                              ),
                              SizedBox(width: MediaQuery.of(context).size.width*0.04),
                              SizedBox(
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
                                            decoration: const InputDecoration(
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
                        Container(
                          height: MediaQuery.of(context).size.height * 0.08,
                          width: MediaQuery.of(context).size.width * 0.90,
                          decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: const BorderRadius.all(Radius.circular(5.0))
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                height: MediaQuery.of(context).size.height * 0.06,
                                width: MediaQuery.of(context).size.height * 0.06,
                                decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.08),
                                    borderRadius: const BorderRadius.all(Radius.circular(5.0))
                                ),
                                child: Center(
                                    child: Icon(
                                      event!.isPrivate! ? Icons.lock_outlined : Icons.groups,
                                      color: Theme.of(context).colorScheme.secondary,
                                      size: MediaQuery.of(context).size.width*0.06,
                                    )
                                ),
                              ),
                              SizedBox(width: MediaQuery.of(context).size.width*0.04),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.08,
                                  width: MediaQuery.of(context).size.width*0.64,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: TextFormField(
                                            initialValue: event!.isPrivate! ? AppLocalizations.of(context)!.privateEvent : AppLocalizations.of(context)!.groupEvent,
                                            readOnly: true,
                                            enabled: false,
                                            style: Theme.of(context).textTheme.bodyText2,
                                            decoration: const InputDecoration(
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
                        height: MediaQuery.of(context).size.height*0.13,
                        width: MediaQuery.of(context).size.width*0.84,
                        decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                            borderRadius: const BorderRadius.all(Radius.circular(15.0))
                        ),
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
                                    initialCameraPosition: _initialPosition,
                                    scrollGesturesEnabled: false,
                                    zoomGesturesEnabled: false,
                                    rotateGesturesEnabled: false,
                                    mapToolbarEnabled: false,
                                    zoomControlsEnabled: false,
                                    minMaxZoomPreference: const MinMaxZoomPreference(17,17),
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
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.location_on,
                                      color: Theme.of(context).colorScheme.secondary,
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
                  Column(
                    children: [
                      eventBonos.isNotEmpty ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height*0.025),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.08, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Text(
                                  AppLocalizations.of(context)!.bonosNecesarios,
                                  style: Theme.of(context).textTheme.bodyText1!.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.02),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.08),
                            child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: eventBonos.length,
                                itemBuilder: (context, int index) {
                                  var bono = eventBonos[index];
                                  return SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.06,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        BonoCard(
                                          height: MediaQuery.of(context).size.height * 0.04,
                                          width: MediaQuery.of(context).size.width * 0.14,
                                          bono: bono,
                                          brand: currentBrand,
                                          canExpand: false,
                                          onlyView: true,
                                        ),
                                        SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                                        SizedBox(
                                          height: MediaQuery.of(context).size.height * 0.04,
                                          child: Text(
                                            bono.title!.toUpperCase(),
                                            style: Theme.of(context).textTheme.bodyText1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                            ),
                          ),
                        ],
                      ) : Container(),
                      SizedBox(height: MediaQuery.of(context).size.height*0.015),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.08, vertical: 10),
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
                        padding: const EdgeInsets.only(top: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height*0.15,
                              width: MediaQuery.of(context).size.width*0.99,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: eventTrainers.length,
                                  itemBuilder: (context, int index) {
                                    var trainer = eventTrainers[index];
                                    return GestureDetector(
                                      onTap: () {
                                        mixpanel!.track('event_view_trainer_tap', properties: {'isPrivate': event!.isPrivate!});
                                        Navigator.push(context, CupertinoPageRoute<void>(
                                            builder: (context) => ProfileViewUser(userID: trainer.id!, viewOnly: false)));
                                      },
                                      child: Padding(
                                        padding: !(index == 0 || index == eventTrainers.length-1) ? const EdgeInsets.symmetric(horizontal: 8.0) : (index == 0) ? EdgeInsets.only(left: MediaQuery.of(context).size.width*0.08, right: 8.0) : EdgeInsets.only(right: eventTrainers.length != 1 ? MediaQuery.of(context).size.width*0.08 : 8.0, left: 8.0),
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
                                            SizedBox(
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
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.08, vertical: 15),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context)!.clients,
                              style: Theme.of(context).textTheme.bodyText1!.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 16),
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
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child:
                        eventClients.isEmpty ?
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                SizedBox(
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
                            SizedBox(
                              height: MediaQuery.of(context).size.height*0.15,
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: eventClients.length,
                                  itemBuilder: (context, int index) {
                                    var client = eventClients[index];
                                    var clientFeedback = eventClientsFeedback[index];
                                    return GestureDetector(
                                      onTap: () {
                                        mixpanel!.track('event_view_client_tap', properties: {
                                          'isPrivate': event!.isPrivate!,
                                          'hasFeedback': clientFeedback != null ? true : false,
                                        });
                                        Navigator.push(context, CupertinoPageRoute<void>(
                                            builder: (context) => ProfileViewUser(userID: client.id!, viewOnly: false)));
                                      },
                                      child: Padding(
                                        padding: !(index == 0 || index == eventClients.length-1) ? const EdgeInsets.symmetric(horizontal: 8.0) : (index == 0) ? EdgeInsets.only(left: MediaQuery.of(context).size.width*0.08, right: 8.0) : EdgeInsets.only(right: eventClients.length != 1 ? MediaQuery.of(context).size.width*0.08 : 8.0, left: 8.0),
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
                                            SizedBox(
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
                                            clientFeedback != null ? SizedBox(
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
                      canEdit ? SizedBox(height: MediaQuery.of(context).size.height*0.2) : SizedBox(height: MediaQuery.of(context).size.height*0.05),
                    ],
                  ),
                ],
              ),
          )) : SliverFillRemaining(
              child: Center(
                  child: LoadingView()
              )
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width*0.37,
                child: FloatingActionButton.extended(
                  heroTag: "9",
                  onPressed: () async {
                    // Create Dynamic Link
                    Uri eventLink = await _dynamicLinkUtils.createDynamicLinkEventId(event!.id!, event!.isPrivate!, event!.imageUrl!, event!.title!, currentBrand.name!, currentUser.firstName!);
                    await Share.share(eventLink.toString(), subject: event!.imageUrl!);
                    mixpanel!.track('event_view_invite_clients_button', properties: {'isPrivate': event!.isPrivate!});
                  },
                  backgroundColor: Theme.of(context).primaryColor,
                  icon: Icon(Icons.person_add, color: Theme.of(context).primaryColorDark, size: MediaQuery.of(context).size.width*0.05,),
                  label: Text(AppLocalizations.of(context)!.invite+" "+AppLocalizations.of(context)!.clients.toLowerCase(),
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).primaryColorDark),),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.width*0.03),
              SizedBox(
                width: MediaQuery.of(context).size.width*0.25,
                child: FloatingActionButton.extended(
                  heroTag: "9",
                  onPressed: () async {
                    mixpanel!.track('event_view_edit_button', properties: {'isPrivate': event!.isPrivate!});
                    bool? result;
                    if (event!.isPrivate!) {
                      result = await Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                FocusScopeNode currentFocus = FocusScope.of(context);
                                if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                }
                              },
                              child:  AddOrEditPrivateEvent(
                                locale: Localizations.localeOf(context),
                                eventId: event!.id!,
                              ),
                            ),
                          )
                      );
                    } else {
                      result = await Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                FocusScopeNode currentFocus = FocusScope.of(context);
                                if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                }
                              },
                              child:  AddOrEditEvent(
                                locale: Localizations.localeOf(context),
                                eventId: event!.id!,
                              ),
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
            ],
          ),
        );
      } else {
        return Container();
      }
    }
  }
}

