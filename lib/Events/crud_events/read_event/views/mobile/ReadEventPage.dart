import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba/events/crud_events/read_event/cubit/ReadEventCubit.dart';
import 'package:mamba/events/crud_events/views/mobile/AddorEdtiEvent.dart';
import 'package:mamba/app/theme/ThemeProvider.dart';
import 'package:mamba/commons/utils/DynamicLinks/DynamicLinkUtils.dart';
import 'package:mamba/commons/widgets/Components/TopSnackBar/TopSnackBarDef.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Bonos/BonoCard.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/Event/EventDataService.dart';
import 'package:mamba/data/DataService/Location/LocationDataService.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/commons/utils/Strings/StringUtils.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/ProfileView/ProfileUserView.dart';
import 'package:mamba/events/crud_events/models/Event.dart';
import 'package:mamba/data/Models/Location.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mamba/l10n/language_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EventPage extends StatelessWidget {
  final String eventId;

  const EventPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReadEventCubit>(
        lazy: false,
        create: (context) => ReadEventCubit(eventId),
        child: EventPageUpdate(
          eventId: eventId,
        ));
  }
}

class EventPageUpdate extends StatelessWidget {
  final String eventId;

  const EventPageUpdate({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CrudEventCubit, CrudEventLoaded>(
      listener: (context, state) {
        if (state.mustUpdateParent) {
          context
              .read<ReadEventCubit>()
              .getEventInfo(context.read<ReadEventCubit>().state.event.id!);
          context.read<CrudEventCubit>().setMustUpdateToFalse();
        }
      },
      child: EventPageTrainer(
        eventId: eventId,
      ),
    );
  }
}

class EventPageTrainer extends StatefulWidget {
  final String eventId;

  const EventPageTrainer({super.key, required this.eventId});

  @override
  _EventPageTrainerState createState() => _EventPageTrainerState();
}

class _EventPageTrainerState extends State<EventPageTrainer>
    with SingleTickerProviderStateMixin {
  // Acceso a Base de Datos
  final _brandDataService = BrandDataService();
  final _eventDataService = EventDataService();
  final _locationDataService = LocationDataService();
  final _dynamicLinkUtils = DynamicLinkUtils();
  final _userDataService = UserDataService();

  final _topSnackBar = TopSnackBarDef();

  // Screen Dimensions
  double safeAreaHeight = 0;
  double safeAreaWidth = 0;
  // App Bar and Scroll View
  ScrollController? _scrollController;

  bool get _isAppBarExpanded {
    return _scrollController!.hasClients &&
        _scrollController!.offset >
            (MediaQuery.of(context).size.height * 0.23 - kToolbarHeight);
  }

  final ValueNotifier<bool> appBarExpanded = ValueNotifier<bool>(false);
  // Boolean Loading
  bool isFirstBuild = true;
  bool isLoading = false;
  bool? isUpdated;
  bool isLoadingBody = false;
  // Boolean isUpdated
  bool canEdit = true;
  bool isBeforeEdit = true;
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
  List<String> durations = [
    "0.30",
    "0.45",
    "1.00",
    "1.15",
    "1.30",
    "1.45",
    "2.00",
    "2.15",
    "2.30",
    "2.45",
    "3.00"
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
  int placesLeft = 0;
  int membersMax = currentBrand.maxMembers!;
  // Members Page
  bool isFull = false;

  // Form To Validate User
  final formKeyInfo = GlobalKey<FormState>();
  final formKeyTime = GlobalKey<FormState>();
  final formKeyMembers = GlobalKey<FormState>();
  // Event Retrieved From BD
  Event event = Event();
  // String Deleted Photo
  String deletedObject =
      "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/not-found-image.jpg?alt=media&token=70687295-6a17-4735-9c0a-e5749c777319";

  List<String> userIsBlockedBy = [];

  @override
  initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(
        () => _isAppBarExpanded
            ? appBarExpanded.value = true
            : appBarExpanded.value = false,
      );
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

  void setEventInfo(Event event) async {
    titleController.text = "${event.title}";
    titleString = "${event.title}";
    descriptionController.text = "${event.description}";
    descriptionString = "${event.description}";

    location = event.location!;

    if (currentUser.brandRole > 2) {
      canEdit = false;
    }
    startDateController.text = DateFormat(
            'EEEE d/M/y - HH:mm', Localizations.localeOf(context).languageCode)
        .format(event.startDate!);
    datetitle =
        DateFormat('EEEE d MMMM', Localizations.localeOf(context).languageCode)
            .format(event.startDate!);
    startDateController.text =
        StringUtils().toCapitalized(startDateController.text);
    duration = event.duration!.toStringAsFixed(2);
    var hour = event.duration.toString().split(".")[0];
    var min = event.duration!.toStringAsFixed(2).split(".")[1];
    durationController.text = "${hour}h ${min}min";
    members = event.maxMembers!;
    membersController.text =
        "${event.numClients.toString()} / ${event.maxMembers.toString()}";
    placesLeft = event.maxMembers! - event.numClients!;
    isFull = (event.numClients! / event.maxMembers! == 1);
  }

  Future<void> getLocationFromId(String locationId) async {
    location = await _locationDataService.getSingleLocation(locationId);
    createMarker();
    mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(location.latitude!, location.longitude!), zoom: 17)));
    var temp = location;
    setState(() {
      location = temp;
    });
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

  void _onLaunchCoordinates() {
    mixpanel!.track('event_view_location_tap',
        properties: {'isPrivate': event.isPrivate!});
    MapsLauncher.launchCoordinates(
        location.latitude!, location.longitude!, location.description!);
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

  // Build Places Left Event
  Widget buildPlacesLeftWidget(int places) {
    return FittedBox(
        fit: BoxFit.contain,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: isFull == false
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      places.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(color: Colors.green),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      places == 1 ? context.l10n.slot : context.l10n.slots,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 5, color: Colors.green),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : Container(
                  margin: const EdgeInsets.all(4),
                  child: Center(
                    child: Icon(
                      Icons.lock_outlined,
                      size: MediaQuery.of(context).size.width * 0.04,
                      color: AppColors.red,
                    ),
                  ),
                ),
        ));
  }

  // Build Places Left Event
  Widget buildAverageFeedbackWidget() {
    if (event.averageIntensityScore != null) {
      return FittedBox(
        fit: BoxFit.contain,
        child: Container(
            height: MediaQuery.of(context).size.width * 0.1,
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      event.averageIntensityScore!.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.03,
                      child: Image.asset(Assets.fireEmojiImage),
                    ),
                  ],
                ),
                Text(
                  context.l10n.average,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 5),
                  textAlign: TextAlign.center,
                ),
              ],
            )),
      );
    } else {
      return FittedBox(
        fit: BoxFit.fitHeight,
        child: Container(
            height: MediaQuery.of(context).size.width * 0.1,
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      "-- ",
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.03,
                      child: Image.asset(Assets.fireEmojiImage),
                    ),
                  ],
                ),
                Text(
                  context.l10n.average,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 5),
                  textAlign: TextAlign.center,
                ),
              ],
            )),
      );
    }
  }

  // Build Places Left Event
  SystemUiOverlayStyle returnSystemBarColor(bool appBarExpandedValue) {
    if (Platform.isAndroid) {
      return SystemUiOverlayStyle.light;
    } else {
      bool isDark =
          Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
      if (isDark) {
        return SystemUiOverlayStyle.light;
      } else {
        return !appBarExpandedValue
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark;
      }
    }
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
                Shimmer.fromColors(
                  baseColor: AppColors.grey,
                  highlightColor: AppColors.grey.withOpacity(0.5),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor),
                  ),
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
                                  Row(
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
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Shimmer.fromColors(
                                            baseColor: AppColors.grey,
                                            highlightColor:
                                                AppColors.grey.withOpacity(0.5),
                                            child: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.04,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.4,
                                              decoration: const BoxDecoration(
                                                  color: AppColors.grey,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              15.0))),
                                            ),
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.01),
                                          Shimmer.fromColors(
                                            baseColor: AppColors.grey,
                                            highlightColor:
                                                AppColors.grey.withOpacity(0.5),
                                            child: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.02,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3,
                                              decoration: const BoxDecoration(
                                                  color: AppColors.grey,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              15.0))),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
                                              0.13,
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
        : BlocBuilder<ReadEventCubit, ReadEventLoaded>(
            builder: (context, state) {
            if (!state.isLoaded) {
              return Scaffold(
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
                    Shimmer.fromColors(
                      baseColor: AppColors.grey,
                      highlightColor: AppColors.grey.withOpacity(0.5),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.3,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor),
                      ),
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
                                          MediaQuery.of(context).size.width *
                                              0.05),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.04),
                                      Row(
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
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.02),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Shimmer.fromColors(
                                                baseColor: AppColors.grey,
                                                highlightColor: AppColors.grey
                                                    .withOpacity(0.5),
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.04,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.4,
                                                  decoration: const BoxDecoration(
                                                      color: AppColors.grey,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  15.0))),
                                                ),
                                              ),
                                              SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.01),
                                              Shimmer.fromColors(
                                                baseColor: AppColors.grey,
                                                highlightColor: AppColors.grey
                                                    .withOpacity(0.5),
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.02,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.3,
                                                  decoration: const BoxDecoration(
                                                      color: AppColors.grey,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  15.0))),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02),
                                      Shimmer.fromColors(
                                        baseColor: AppColors.grey,
                                        highlightColor:
                                            AppColors.grey.withOpacity(0.5),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.03,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.6,
                                          decoration: const BoxDecoration(
                                              color: AppColors.grey,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15.0))),
                                        ),
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
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
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              15.0))),
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
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              15.0))),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
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
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              15.0))),
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
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              15.0))),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.05),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02),
                                      Shimmer.fromColors(
                                        baseColor: AppColors.grey,
                                        highlightColor:
                                            AppColors.grey.withOpacity(0.5),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.13,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
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
                                          MediaQuery.of(context).size.width *
                                              0.05),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.025),
                                      Shimmer.fromColors(
                                        baseColor: AppColors.grey,
                                        highlightColor:
                                            AppColors.grey.withOpacity(0.5),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.03,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          decoration: const BoxDecoration(
                                              color: AppColors.grey,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15.0))),
                                        ),
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.025),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.height *
                                                0.26,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Shimmer.fromColors(
                                              baseColor: AppColors.grey,
                                              highlightColor: AppColors.grey
                                                  .withOpacity(0.5),
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
                                              highlightColor: AppColors.grey
                                                  .withOpacity(0.5),
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
                                              highlightColor: AppColors.grey
                                                  .withOpacity(0.5),
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
              );
            } else {
              event = state.event;
              setEventInfo(event);
              return Scaffold(
                appBar: null,
                resizeToAvoidBottomInset: true,
                body: ExtendedNestedScrollView(
                  pinnedHeaderSliverHeightBuilder: () {
                    return MediaQuery.of(context).size.height * 0.10;
                  },
                  physics: const BouncingScrollPhysics(),
                  controller: _scrollController,
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      ValueListenableBuilder<bool>(
                          valueListenable: appBarExpanded,
                          builder: (context, appBarExpandedValue, child) {
                            return SliverAppBar(
                              surfaceTintColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              expandedHeight:
                                  MediaQuery.of(context).size.height * 0.22,
                              elevation: 0,
                              systemOverlayStyle:
                                  returnSystemBarColor(appBarExpandedValue),
                              floating: false,
                              pinned: true,
                              centerTitle: true,
                              title: AnimatedOpacity(
                                  opacity: appBarExpandedValue ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 100),
                                  child: Text(titleController.text,
                                      style: Theme.of(context)
                                          .appBarTheme
                                          .titleTextStyle)),
                              flexibleSpace: FlexibleSpaceBar(
                                background: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(
                                            event.imageUrl!),
                                      )),
                                  child: const Center(),
                                ),
                                titlePadding: EdgeInsets.zero,
                                //centerTitle: true,
                              ),
                              leadingWidth:
                                  MediaQuery.of(context).size.width * 0.2,
                              leading: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Material(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    child: InkWell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(13),
                                          child: Icon(
                                            Icons.arrow_back,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.06,
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.pop(context, isUpdated);
                                        }),
                                  ),
                                ),
                              ),
                              actions: [
                                isLoadingBody == false &&
                                        isBeforeEdit &&
                                        event.isPrivate! == false
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.05),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.12,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.12,
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              shape: BoxShape.circle),
                                          child:
                                              buildPlacesLeftWidget(placesLeft),
                                        ),
                                      )
                                    : !isBeforeEdit
                                        ? Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.12,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.12,
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                shape: BoxShape.circle),
                                            child: buildAverageFeedbackWidget(),
                                          )
                                        : Container(),
                              ],
                            );
                          }),
                    ];
                  },
                  body: SafeArea(
                    top: false,
                    bottom: false,
                    child: Builder(
                      builder: (context) => CustomScrollView(
                        physics: const ClampingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                              child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.03),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.05),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.01),
                                      Form(
                                        key: formKeyInfo,
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                CircularImage(
                                                  size: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.15,
                                                  image: currentBrand.logoUrl,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  borderWidth: 0.5,
                                                ),
                                                SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.03),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        titleController.text,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .displayLarge
                                                            ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                        textAlign:
                                                            TextAlign.start,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        currentBrand.name!,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall,
                                                        textAlign:
                                                            TextAlign.start,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.02),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
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
                                                        decoration:
                                                            InputDecoration(
                                                          hintStyle:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall,
                                                          hintText: context.l10n
                                                              .noDescription,
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
                                                              const EdgeInsets
                                                                  .all(0),
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
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
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
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.08,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            borderRadius:
                                                const BorderRadius.all(
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
                                                  0.06,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.06,
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withOpacity(0.08),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              5.0))),
                                              child: Center(
                                                  child: Text(
                                                      event.day.toString(),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .displayLarge
                                                          ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .secondary),
                                                      textAlign:
                                                          TextAlign.center)),
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
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Flexible(
                                                        child: TextFormField(
                                                          controller:
                                                              startDateController,
                                                          readOnly: true,
                                                          enabled: false,
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyLarge
                                                              ?.copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                          decoration:
                                                              InputDecoration(
                                                            labelStyle: Theme
                                                                    .of(context)
                                                                .textTheme
                                                                .bodyLarge
                                                                ?.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                            border: InputBorder
                                                                .none,
                                                            focusedBorder:
                                                                InputBorder
                                                                    .none,
                                                            enabledBorder:
                                                                InputBorder
                                                                    .none,
                                                            errorBorder:
                                                                InputBorder
                                                                    .none,
                                                            disabledBorder:
                                                                InputBorder
                                                                    .none,
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
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.08,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            borderRadius:
                                                const BorderRadius.all(
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
                                                  0.06,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.06,
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withOpacity(0.08),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              5.0))),
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Flexible(
                                                        child: TextFormField(
                                                          controller:
                                                              durationController,
                                                          readOnly: true,
                                                          enabled: false,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium,
                                                          decoration:
                                                              const InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            focusedBorder:
                                                                InputBorder
                                                                    .none,
                                                            enabledBorder:
                                                                InputBorder
                                                                    .none,
                                                            errorBorder:
                                                                InputBorder
                                                                    .none,
                                                            disabledBorder:
                                                                InputBorder
                                                                    .none,
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
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.08,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.90,
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            borderRadius:
                                                const BorderRadius.all(
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
                                                  0.06,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.06,
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withOpacity(0.08),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              5.0))),
                                              child: Center(
                                                  child: Icon(
                                                event.isPrivate!
                                                    ? Icons.person
                                                    : Icons.groups,
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Flexible(
                                                        child: TextFormField(
                                                          initialValue: event
                                                                  .isPrivate!
                                                              ? context.l10n
                                                                  .privateEvent
                                                              : context.l10n
                                                                  .groupEvent,
                                                          readOnly: true,
                                                          enabled: false,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium,
                                                          decoration:
                                                              const InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            focusedBorder:
                                                                InputBorder
                                                                    .none,
                                                            enabledBorder:
                                                                InputBorder
                                                                    .none,
                                                            errorBorder:
                                                                InputBorder
                                                                    .none,
                                                            disabledBorder:
                                                                InputBorder
                                                                    .none,
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
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.01),
                                    GestureDetector(
                                      onTap: _onLaunchCoordinates,
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.13,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .background,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(15.0)),
                                          image: DecorationImage(
                                            image: AssetImage(Assets.mapsImg),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.all(10),
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
                                                    size: 20,
                                                  ),
                                                  const SizedBox(
                                                      width:
                                                          5), // Provides a consistent space between the icon and text
                                                  Expanded(
                                                    // Allows the text to wrap and occupy the available space
                                                    child: Text(
                                                      location.description!,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    event.bonos.isNotEmpty
                                        ? Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.025),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.05,
                                                    vertical: 10),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: <Widget>[
                                                    Text(
                                                      context
                                                          .l10n.bonosNecesarios,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.01),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.05),
                                                child: ListView.builder(
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    padding: EdgeInsets.zero,
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        event.bonos.length,
                                                    itemBuilder:
                                                        (context, int index) {
                                                      var bono =
                                                          event.bonos[index];
                                                      return SizedBox(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.075,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.9,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  BonoCard(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        0.05,
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.18,
                                                                    bono: bono,
                                                                    brand:
                                                                        currentBrand,
                                                                    canExpand:
                                                                        false,
                                                                    onlyView:
                                                                        true,
                                                                    hideActive:
                                                                        true,
                                                                  ),
                                                                ]),
                                                            SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.04),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    bono.title!
                                                                        .toUpperCase(),
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyLarge,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                  Flexible(
                                                                    child: Text(
                                                                      "${"${bono.sessions! == 10000 ? context.l10n.sessions + " " + context.l10n.ilimitadas : bono.sessions!.toString() + " " + context.l10n.sessions.toLowerCase()} desde " + bono.price!.toStringAsFixed(2)}€",
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodySmall,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }),
                                              ),
                                            ],
                                          )
                                        : Container(),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.025),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
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
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.01),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.92,
                                      child: GridView.builder(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.vertical,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 4,
                                          childAspectRatio: 0.75,
                                        ),
                                        itemCount:
                                            event.selectedTrainersList!.length,
                                        itemBuilder: (context, int index) {
                                          var trainer = event
                                              .selectedTrainersList![index];
                                          return GestureDetector(
                                            onTap: () {
                                              mixpanel!.track(
                                                  'event_view_trainer_tap',
                                                  properties: {
                                                    'isPrivate':
                                                        event.isPrivate!
                                                  });
                                              Navigator.push(
                                                  context,
                                                  CupertinoPageRoute<void>(
                                                      builder: (context) =>
                                                          ProfileViewUser(
                                                            userID: trainer.id!,
                                                            viewOnly: false,
                                                          )));
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Stack(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  children: [
                                                    SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.22,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          CircularImage(
                                                            size: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.2,
                                                            image: trainer
                                                                .imageUrl,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            borderWidth: 1,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.3,
                                                  margin: const EdgeInsets.only(
                                                      top: 3),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          trainer.name! !=
                                                                  context.l10n
                                                                      .notFoundUser
                                                              ? trainer
                                                                  .firstName!
                                                              : trainer.name!,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium,
                                                          textAlign:
                                                              TextAlign.center,
                                                          softWrap: true,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.05,
                                          vertical: 15),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Text(
                                            context.l10n.clients,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                          const SizedBox(width: 16),
                                          (event.isPrivate! == false)
                                              ? Row(
                                                  children: [
                                                    Text(
                                                      "( ${event.numClients}",
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
                                                      "${event.maxMembers} )",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium,
                                                    ),
                                                  ],
                                                )
                                              : Row(
                                                  children: [
                                                    Text(
                                                      "( ${event.numClients} )",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium,
                                                    ),
                                                  ],
                                                ),
                                        ],
                                      ),
                                    ),
                                    event.joinedMembersList!.isEmpty
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
                                        : SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.92,
                                            child: GridView.builder(
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              scrollDirection: Axis.vertical,
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 4,
                                                childAspectRatio: 0.75,
                                              ),
                                              itemCount: event
                                                  .joinedMembersList!.length,
                                              itemBuilder:
                                                  (context, int index) {
                                                var client = event
                                                    .joinedMembersList![index];
                                                if (userIsBlockedBy
                                                    .contains(client.id)) {
                                                  client.isPrivate = true;
                                                }
                                                var clientFeedback =
                                                    state.eventClientsFeedback[
                                                        index];
                                                return GestureDetector(
                                                  onTap: () {
                                                    mixpanel!.track(
                                                        'event_view_client_tap',
                                                        properties: {
                                                          'isPrivate':
                                                              event.isPrivate!,
                                                          'hasFeedback':
                                                              clientFeedback !=
                                                                      null
                                                                  ? true
                                                                  : false,
                                                        });
                                                    Navigator.push(
                                                        context,
                                                        CupertinoPageRoute<
                                                                void>(
                                                            builder: (context) =>
                                                                ProfileViewUser(
                                                                    userID:
                                                                        client
                                                                            .id!,
                                                                    viewOnly:
                                                                        false)));
                                                  },
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Stack(
                                                        alignment: Alignment
                                                            .bottomCenter,
                                                        children: [
                                                          SizedBox(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.22,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                CircularImage(
                                                                  size: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.2,
                                                                  image: client
                                                                      .imageUrl,
                                                                  color: client.freeSession !=
                                                                              null &&
                                                                          client
                                                                              .freeSession!
                                                                      ? Colors
                                                                          .green
                                                                      : Theme.of(
                                                                              context)
                                                                          .primaryColor,
                                                                  borderWidth:
                                                                      client.freeSession != null &&
                                                                              client.freeSession!
                                                                          ? 5
                                                                          : 1,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          clientFeedback != null
                                                              ? Container(
                                                                  constraints:
                                                                      BoxConstraints(
                                                                    maxWidth: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.15,
                                                                  ),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: client.freeSession !=
                                                                                null &&
                                                                            client
                                                                                .freeSession!
                                                                        ? Colors
                                                                            .green
                                                                        : Theme.of(context)
                                                                            .scaffoldBackgroundColor,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      width:
                                                                          0.5,
                                                                      color: client.freeSession != null &&
                                                                              client
                                                                                  .freeSession!
                                                                          ? Colors
                                                                              .green
                                                                          : Theme.of(context)
                                                                              .primaryColor,
                                                                    ),
                                                                  ),
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          4,
                                                                      vertical:
                                                                          2),
                                                                  child: Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Flexible(
                                                                        child: Text(
                                                                            clientFeedback
                                                                                .toString(),
                                                                            style:
                                                                                Theme.of(context).textTheme.bodyMedium?.copyWith(color: client.freeSession != null && client.freeSession! ? AppColors.white : Theme.of(context).primaryColor),
                                                                            maxLines: 1,
                                                                            softWrap: true,
                                                                            textAlign: TextAlign.center),
                                                                      ),
                                                                      SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.04,
                                                                        child: Image.asset(
                                                                            Assets.fireEmojiImage),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                              : client.freeSession !=
                                                                          null &&
                                                                      client
                                                                          .freeSession!
                                                                  ? Container(
                                                                      constraints:
                                                                          BoxConstraints(
                                                                        maxWidth:
                                                                            MediaQuery.of(context).size.width *
                                                                                0.15,
                                                                      ),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .green,
                                                                        borderRadius:
                                                                            BorderRadius.circular(15),
                                                                        border:
                                                                            Border.all(
                                                                          width:
                                                                              1,
                                                                          color:
                                                                              Colors.green,
                                                                        ),
                                                                      ),
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              5,
                                                                          vertical:
                                                                              2),
                                                                      child:
                                                                          Text(
                                                                        StringUtils().toCapitalized(context
                                                                            .l10n
                                                                            .freeSession
                                                                            .split(" ")[2]),
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyMedium
                                                                            ?.copyWith(color: AppColors.white),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        softWrap:
                                                                            true,
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                    )
                                                                  : Container(),
                                                        ],
                                                      ),
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                        margin: const EdgeInsets
                                                            .only(top: 3),
                                                        child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Flexible(
                                                                child: Text(
                                                                  client.name! !=
                                                                          context
                                                                              .l10n
                                                                              .notFoundUser
                                                                      ? client
                                                                          .firstName!
                                                                      : client
                                                                          .name!,
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyMedium,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  softWrap:
                                                                      true,
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              )
                                                            ]),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                    canEdit
                                        ? SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.25)
                                        : SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.05),
                                  ],
                                ),
                              ],
                            ),
                          ))
                        ],
                      ),
                    ),
                  ),
                ),
                floatingActionButton: whichFloatingActionButton(context),
              );
            }
          });
  }

  Widget whichFloatingActionButton(BuildContext context) {
    if (isLoadingBody) {
      return Container();
    } else {
      if (canEdit) {
        return Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.37,
                child: isBeforeEdit
                    ? FloatingActionButton.extended(
                        heroTag: "9",
                        shape: const StadiumBorder(),
                        onPressed: () async {
                          // Create Dynamic Link
                          Uri eventLink =
                              await _dynamicLinkUtils.createDynamicLinkEventId(
                                  event.id!,
                                  event.isPrivate!,
                                  event.imageUrl!,
                                  event.title!,
                                  currentBrand.name!,
                                  currentUser.firstName!);
                          await Share.share(eventLink.toString(),
                              subject: event.imageUrl!);
                          mixpanel!.track('event_view_invite_clients_button',
                              properties: {'isPrivate': event.isPrivate!});
                        },
                        backgroundColor: Theme.of(context).primaryColor,
                        icon: Icon(
                          Icons.person_add,
                          color: Theme.of(context).primaryColorDark,
                          size: MediaQuery.of(context).size.width * 0.05,
                        ),
                        label: Text(
                          "${context.l10n.invite} ${context.l10n.clients.toLowerCase()}",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: Theme.of(context).primaryColorDark),
                        ),
                      )
                    : Container(),
              ),
              SizedBox(height: MediaQuery.of(context).size.width * 0.03),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.25,
                child: FloatingActionButton.extended(
                  heroTag: "10",
                  shape: const StadiumBorder(),
                  onPressed: () async {
                    if (context.read<CrudEventCubit>().state.isWorking >= 100) {
                      context.read<CrudEventCubit>().populateNewEvent(event);
                      if (!brandIsActive) {
                        await navigateToPayWall(context);
                      } else {
                        mixpanel!.track('event_view_edit_button',
                            properties: {'isPrivate': event.isPrivate!});
                        bool? result;
                        result = await Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  FocusScopeNode currentFocus =
                                      FocusScope.of(context);
                                  if (!currentFocus.hasPrimaryFocus &&
                                      currentFocus.focusedChild != null) {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  }
                                },
                                child: AddOrEditEvent(
                                  locale: Localizations.localeOf(context),
                                ),
                              ),
                            ));

                        if (result != null && result) {
                          context.read<ReadEventCubit>().resetEvent();
                        }
                        if (result != null && !result) {
                          Navigator.pop(context, false);
                        }
                        //TODO

                        //TODO EDIT HERE
                        /*
                      if (result != null && result) {
                        setState(() {
                          isLoading = true;
                          isUpdated = true;
                        });
                        getEventInfo();
                        print("Updating Event ...");
                      } else if (result != null && !result) {
                        print("Deleting Event ...");
                        Navigator.pop(context, false);
                      }*/
                      }
                    } else {
                      _topSnackBar.showSnackBarTop(
                          context, context.l10n.processOnWork, AppColors.red);
                    }
                  },
                  backgroundColor: Colors.green,
                  icon: Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.width * 0.05,
                  ),
                  label: Text(
                    context.l10n.edit,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Colors.white),
                  ),
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
