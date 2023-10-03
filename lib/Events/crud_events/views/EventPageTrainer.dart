import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Events/crud_events/cubit/CrudEventCubit.dart';
import 'package:mamba_castelldefels/Events/crud_events/views/AddOrEditEvent.dart';
import 'package:mamba_castelldefels/Events/crud_events/widgets/LocationView.dart';
import 'package:mamba_castelldefels/Globals/Providers/ThemeProvider.dart';
import 'package:mamba_castelldefels/Globals/Utils/DynamicLinks/DynamicLinkUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/BonoCard.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/AddEditEvent/AddOrEditPrivateEvent.dart';
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
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class EventPageTrainer extends StatefulWidget {

  EventPageTrainer({Key? key}) : super(key: key);

  @override
  _EventPageTrainerState createState() => _EventPageTrainerState();
}

class _EventPageTrainerState extends State<EventPageTrainer> with SingleTickerProviderStateMixin {

  // Acceso a Base de Datos
  final _dynamicLinkUtils = DynamicLinkUtils();
  // Screen Dimensions
  double safeAreaHeight = 0;
  double safeAreaWidth = 0;
  // App Bar and Scroll View
  ScrollController? _scrollController;
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    return _scrollController!.hasClients && _scrollController!.offset > (MediaQuery.of(context).size.height*0.23 - kToolbarHeight);
  }
  // Boolean Loading
  bool isFirstBuild = true;
  bool isLoading = true;
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
  List<String> durations = ["0.30","0.45","1.00","1.15","1.30","1.45","2.00","2.15","2.30","2.45","3.00"];

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
  List<String> userIsBlockedBy = [];

  @override
  initState() {
    super.initState();
    _scrollController = ScrollController()
    ..addListener(() => _isAppBarExpanded ?
    context.read<CrudEventCubit>().setAppBarExpanded(true) :
    context.read<CrudEventCubit>().setAppBarExpanded(false)
    );
    isLoading = false;
  }

  // Init Device Sizes
  initDeviceSizes() {
    safeAreaHeight = MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.bottom;
    safeAreaWidth = MediaQuery.of(context).size.width;
    print("Device H and W: "+MediaQuery.of(context).size.height.toString()+" "+MediaQuery.of(context).size.width.toString());
    print("SafeArea H and W: "+safeAreaHeight.toString()+" "+safeAreaWidth.toString());
  }

  void setEventVariables(CrudEventLoaded eventLoaded) async {
    event = eventLoaded.event;
    isFull = eventLoaded.isFull;
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
      isBeforeEdit = false;
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
    userIsBlockedBy = eventLoaded.userIsBlockedBy;
    eventTrainers = eventLoaded.eventTrainers;
    eventTrainersIds = eventLoaded.eventTrainersIds;
    eventClients = eventLoaded.eventClients;
    placesLeft = members - eventClients.length;
    eventBonos = eventLoaded.eventBonos;
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
                Icons.person,
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
        fit: BoxFit.contain,
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
    return BlocBuilder<CrudEventCubit, CrudEventState>(
      builder: (context, state) {
        switch (state.runtimeType) {
          case CrudEventLoaded:
            setEventVariables(state as CrudEventLoaded);
            return Scaffold(
              appBar: null,
              resizeToAvoidBottomInset: true,
              body: BlocSelector<CrudEventCubit, CrudEventState, Event>(
                  selector: (state) {
                    if(state is CrudEventLoaded) {
                      return state.event;
                    }
                    return Event();
                  },
                  builder: (context, eventCubit) {
                    event = eventCubit;
                    return ExtendedNestedScrollView(
                        pinnedHeaderSliverHeightBuilder: () {
                          return MediaQuery.of(context).size.height*0.10;
                        },
                        physics: const BouncingScrollPhysics(),
                        controller: _scrollController,
                        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                          return <Widget>[
                            BlocSelector<CrudEventCubit, CrudEventState, bool>(
                                selector: (state) {

                                  if(state is CrudEventLoaded) {
                                    return state.appBarExpanded;
                                  }
                                  return false;
                                },
                                builder: (context, appBarExpandedCubit) {
                                  appBarExpanded = appBarExpandedCubit;
                                  return SliverAppBar(
                                    expandedHeight: MediaQuery.of(context).size.height*0.22,
                                    elevation: 0,
                                    systemOverlayStyle: returnSystemBarColor(),
                                    floating: false,
                                    pinned: true,
                                    centerTitle: true,
                                    title: AnimatedOpacity(
                                        opacity: appBarExpanded ? 1.0 : 0.0,
                                        duration: const Duration(milliseconds: 100),
                                        child: Text(
                                            titleController.text,
                                            style: Theme.of(context).appBarTheme.titleTextStyle
                                        )
                                    ),
                                    flexibleSpace: FlexibleSpaceBar(
                                      background: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: event!.id != ''? CachedNetworkImageProvider(event!.imageUrl!) ,
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
                                            onTap: () => Navigator.pop(context, isUpdated),
                                          ),
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      isLoadingBody == false && isBeforeEdit && event!.isPrivate! == false ? Padding(
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
                                      ) : !isBeforeEdit ? Padding(
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
                                      ) : Container(),
                                    ],
                                  );
                                }
                            ),
                          ];
                        },
                        body: !isLoadingBody ? SafeArea(
                          top: false,
                          bottom: false,
                          child: Builder(
                            builder: (context) => CustomScrollView(
                              physics: const ClampingScrollPhysics(),
                              slivers: [
                                SliverToBoxAdapter(child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(height: MediaQuery.of(context).size.height*0.03),
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
                                                      CircularImage(
                                                        size: MediaQuery.of(context).size.width*0.15,
                                                        image: currentBrand.logoUrl,
                                                        color: Theme.of(context).primaryColor,
                                                        borderWidth: 0.5,
                                                      ),
                                                      SizedBox(width: MediaQuery.of(context).size.width*0.03),
                                                      Expanded(
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              titleController.text,
                                                              style: Theme.of(context).textTheme.headline1?.copyWith(fontWeight: FontWeight.bold),
                                                              textAlign: TextAlign.start,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            const SizedBox(height: 2),
                                                            Text(
                                                              currentBrand.name!,
                                                              style: Theme.of(context).textTheme.caption,
                                                              textAlign: TextAlign.start,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
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
                                              width: MediaQuery.of(context).size.width * 0.9,
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
                                              width: MediaQuery.of(context).size.width * 0.9,
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
                                                          event!.isPrivate! ? Icons.person : Icons.groups,
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
                                      LocationView(context, false, event!),
                                      Column(
                                        children: [
                                          eventBonos.isNotEmpty ? Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(height: MediaQuery.of(context).size.height*0.025),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: 10),
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
                                              SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                                                child: ListView.builder(
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    padding: EdgeInsets.zero,
                                                    shrinkWrap: true,
                                                    itemCount: eventBonos.length,
                                                    itemBuilder: (context, int index) {
                                                      var bono = eventBonos[index];
                                                      return SizedBox(
                                                        height: MediaQuery.of(context).size.height * 0.075,
                                                        width: MediaQuery.of(context).size.width * 0.9,
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
                                                          ],
                                                        ),
                                                      );
                                                    }
                                                ),
                                              ),
                                            ],
                                          ) : Container(),
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
                                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width*0.92,
                                            child: GridView.builder(
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              physics: const NeverScrollableScrollPhysics(),
                                              scrollDirection: Axis.vertical,
                                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 4,
                                                childAspectRatio: 0.75,
                                              ),
                                              itemCount: eventTrainers.length,
                                              itemBuilder: (context, int index) {
                                                var trainer = eventTrainers[index];
                                                return GestureDetector(
                                                  onTap: () {
                                                    mixpanel!.track('event_view_trainer_tap', properties: {'isPrivate': event!.isPrivate!});
                                                    Navigator.push(context, CupertinoPageRoute<void>(
                                                        builder: (context) => ProfileViewUser(userID: trainer.id!, viewOnly: false,)));
                                                  },
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Stack(
                                                        alignment: Alignment.bottomCenter,
                                                        children: [
                                                          SizedBox(
                                                            height: MediaQuery.of(context).size.width*0.22,
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                CircularImage(
                                                                  size: MediaQuery.of(context).size.width*0.2,
                                                                  image: trainer.imageUrl,
                                                                  color: Theme.of(context).primaryColor,
                                                                  borderWidth: 1,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Container(
                                                        width: MediaQuery.of(context).size.width*0.3,
                                                        margin: const EdgeInsets.only(top: 3),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Flexible(
                                                              child: Text(
                                                                trainer.name! != AppLocalizations.of(context)!.notFoundUser ? trainer.firstName! : trainer.name!,
                                                                style: Theme.of(context).textTheme.bodyText2,
                                                                textAlign: TextAlign.center,
                                                                softWrap: true,
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
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
                                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: 15),
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
                                          eventClients.isEmpty ? Row(
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
                                          ) : SizedBox(
                                            width: MediaQuery.of(context).size.width*0.92,
                                            child: GridView.builder(
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              physics: const NeverScrollableScrollPhysics(),
                                              scrollDirection: Axis.vertical,
                                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 4,
                                                childAspectRatio: 0.75,
                                              ),
                                              itemCount: eventClients.length,
                                              itemBuilder: (context, int index) {
                                                var client = eventClients[index];
                                                if (userIsBlockedBy.contains(client.id)) {
                                                  client.isPrivate = true;
                                                }
                                                var clientFeedback = eventClientsFeedback[index];
                                                return GestureDetector(
                                                  onTap: () {
                                                    mixpanel!.track('event_view_client_tap', properties: {
                                                      'isPrivate': event!.isPrivate!,
                                                      'hasFeedback': clientFeedback != null ? true : false,
                                                    });
                                                    Navigator.push(context, CupertinoPageRoute<void>(builder: (context) => ProfileViewUser(userID: client.id!, viewOnly: false)));
                                                  },
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Stack(
                                                        alignment: Alignment.bottomCenter,
                                                        children: [
                                                          SizedBox(
                                                            height: MediaQuery.of(context).size.width*0.22,
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                CircularImage(
                                                                  size: MediaQuery.of(context).size.width*0.2,
                                                                  image: client.imageUrl,
                                                                  color: Theme.of(context).primaryColor,
                                                                  borderWidth: 1,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          clientFeedback != null ? Container(
                                                            constraints: BoxConstraints(
                                                              maxWidth: MediaQuery.of(context).size.width*0.15,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              color: Theme.of(context).scaffoldBackgroundColor,
                                                              borderRadius: BorderRadius.circular(15),
                                                              border: Border.all(
                                                                width: 0.5,
                                                                color: Theme.of(context).primaryColor,
                                                              ),
                                                            ),
                                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                            child: Row(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Flexible(
                                                                  child: Text(
                                                                      clientFeedback.toString(),
                                                                      style: Theme.of(context).textTheme.bodyText2,
                                                                      maxLines: 1,
                                                                      softWrap: true,
                                                                      textAlign: TextAlign.center
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: MediaQuery.of(context).size.width*0.04,
                                                                  child: Image.asset(Constants.fireEmojiImage),
                                                                ),
                                                              ],
                                                            ),
                                                          ) : Container(),
                                                        ],
                                                      ),
                                                      Container(
                                                        width: MediaQuery.of(context).size.width*0.3,
                                                        margin: const EdgeInsets.only(top: 3),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Flexible(
                                                              child: Text(
                                                                client.name! != AppLocalizations.of(context)!.notFoundUser ? client.firstName! : client.name!,
                                                                style: Theme.of(context).textTheme.bodyText2,
                                                                textAlign: TextAlign.center,
                                                                softWrap: true,
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
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
                                          canEdit ? SizedBox(height: MediaQuery.of(context).size.height*0.2) : SizedBox(height: MediaQuery.of(context).size.height*0.05),
                                        ],
                                      ),
                                    ],
                                  ),
                                ))
                              ],
                            ),
                          ),
                        ) : SafeArea(
                          top: false,
                          bottom: false,
                          child: Builder(
                            builder: (context) => CustomScrollView(
                              physics: const ClampingScrollPhysics(),
                              slivers: [
                                SliverFillRemaining(
                                    child: Center(
                                        child: LoadingView()
                                    )
                                ),
                              ],
                            ),
                          ),
                        )
                    );
                  }
              ),
              floatingActionButton: whichFloatingActionButton(context),
            );
          default:
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
                          color: Theme.of(context).scaffoldBackgroundColor
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
                          physics: const NeverScrollableScrollPhysics(),
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
                                    Row(
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
                                        SizedBox(width: MediaQuery.of(context).size.height*0.02),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
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
                                                height: MediaQuery.of(context).size.height * 0.02,
                                                width: MediaQuery.of(context).size.width*0.3,
                                                decoration: const BoxDecoration(
                                                    color: AppColors.grey,
                                                    borderRadius: BorderRadius.all(Radius.circular(15.0))
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height*0.02),
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
                                            width: MediaQuery.of(context).size.width*0.7,
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
                                            width: MediaQuery.of(context).size.width*0.7,
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
                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: MediaQuery.of(context).size.height*0.02),
                                    Shimmer.fromColors(
                                      baseColor: AppColors.grey,
                                      highlightColor: AppColors.grey.withOpacity(0.5),
                                      child: Container(
                                        height: MediaQuery.of(context).size.height*0.13,
                                        width: MediaQuery.of(context).size.width*0.9,
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
            );
        }
      },
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
                child: isBeforeEdit ? FloatingActionButton.extended(
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
                ) : Container(),
              ),
              SizedBox(height: MediaQuery.of(context).size.width*0.03),
              SizedBox(
                width: MediaQuery.of(context).size.width*0.25,
                child: FloatingActionButton.extended(
                  heroTag: "10",
                  onPressed: () async {
                    if(!brandIsActive) {
                      await navigateToPayWall(context);
                    }
                    else {
                      mixpanel!.track('event_view_edit_button',
                          properties: {'isPrivate': event!.isPrivate!});
                      bool? result;
                      if (event!.isPrivate!) {
                        result = await Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) =>
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      FocusScopeNode currentFocus = FocusScope
                                          .of(context);
                                      if (!currentFocus.hasPrimaryFocus &&
                                          currentFocus.focusedChild != null) {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      }
                                    },
                                    child: AddOrEditPrivateEvent(
                                      locale: Localizations.localeOf(context),
                                      eventId: event!.id!,
                                      isBeforeEdit: isBeforeEdit
                                    ),
                                  ),
                            )
                        );
                      } else {
                        result = await Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) =>
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      FocusScopeNode currentFocus = FocusScope
                                          .of(context);
                                      if (!currentFocus.hasPrimaryFocus &&
                                          currentFocus.focusedChild != null) {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      }
                                    },
                                    child: AddOrEditEvent(
                                      locale: Localizations.localeOf(context),
                                      eventId: event!.id!,
                                      isBeforeEdit: isBeforeEdit
                                    ),
                                  ),
                            )
                        );
                      }
                      if (result != null && result) {
                        setState(() {
                          isLoading = true;
                          isUpdated = true;
                        });
                        //TODO UPDATE EVENT getEventInfo();
                        print("Updating Event ...");
                      } else if (result != null && !result) {
                        print("Deleting Event ...");
                        Navigator.pop(context, false);
                      }
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

