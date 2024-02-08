import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Auth/views/mobile/SplashScreen.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Promotions/PromotionsDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Room/RoomDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Date/DateTimeUtils.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Badges/BetaBadge.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectDaysDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectHoursDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectTimeDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/TopSnackBar/TopSnackBarDef.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/ConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/DeleteBrandDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Notifications/Unread/widgets/askSupport.dart';
import 'package:mamba_castelldefels/Notifications/Unread/widgets/profileImage.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/012-Logo/Logo.dart';
import 'package:mamba_castelldefels/Notifications/Unread/widgets/unreadChats.dart';
import 'package:mamba_castelldefels/Notifications/Unread/widgets/unreadNotifications.dart';
import 'package:mamba_castelldefels/Stripe/Data/data_repository/stripe_connect_repository.dart';
import 'package:mamba_castelldefels/Stripe/bloc/stripe_connect_bloc/stripe_connect_cubit.dart';
import 'package:mamba_castelldefels/Stripe/models/user_stripe_model.dart';
import 'package:mamba_castelldefels/Stripe/utils/routes.dart';
import 'package:mamba_castelldefels/Stripe/views/onboarding_webview.dart';

import '../../../../../Globals/Widgets/Components/CupertinoSelect/SelectOtherDialog.dart';

// Tus Datos Widget.
class BrandInfo extends StatefulWidget {
  Locale? locale;
  String brandId;
  bool pinned;
  ValueChanged<bool?> pinnedChanged;
  BrandInfo(
      {super.key,
      this.locale,
      required this.brandId,
      required this.pinned,
      required this.pinnedChanged});

  @override
  _BrandInfoState createState() => _BrandInfoState();
}

class _BrandInfoState extends State<BrandInfo>
    with SingleTickerProviderStateMixin {
  DateFormat formatter = DateFormat('dd/MM/yy');
  // DataBase Access
  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();
  final _eventDataService = EventDataService();
  final _roomDataService = RoomDataService();
  final _promotionDataService = PromotionsDataService();
  // Boolean isLoading
  bool isLoading = false;
  bool isUpdated = false;
  // Form To Validate
  final formKeyInfo = GlobalKey<FormState>();
  ScrollController? _scrollController;
  bool canEdit = false;
  // Name Brand Controller
  // Logo Image
  var nameBrandController = TextEditingController();
  String nameBrandControllerTemp = "";
  // Description Controller
  var descriptionController = TextEditingController();
  String descriptionControllerTemp = "";
  // Admin Usuario
  Usuario admin = currentUser;
  // Max Members Brand
  TextEditingController membersController = TextEditingController();
  int members = 1;
  int membersMax = 30;
  bool errorMembers = false;
  // Time Picker Horari de Trabajo
  DateTime startTime = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 0);
  DateTime endTime = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 22, 0);
  DateTime dateJoinedBrand = DateTime.now();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  final List<double> _workShift = [];
  int? errorTime;
  // Descansos
  TextEditingController breakStartTimeController = TextEditingController();
  TextEditingController breakEndTimeController = TextEditingController();
  DateTime breakStartTime = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0);
  DateTime breakEndTime = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0);
  TimeOfDay _breakStartTime = const TimeOfDay(hour: 00, minute: 00);
  TimeOfDay _breakEndTime = const TimeOfDay(hour: 00, minute: 00);
  int? errorBreakTime;
  // Booking Window
  int bookingWindow = 3;
  int bookingWindowMin = 1;
  // Purchase
  bool freeSession = false;
  bool directPurchase = false;
  int gracePeriodDays = 7;
  int cancelationsPerWeek = 7;
  List<bool> isSelectedTerms = [false, false, true];
  bool isStripeActive = false;

  StripeConnectRepository stripeConnectRepository = StripeConnectRepository();

  // Subscription
  int difference = 0;
  bool ShowTextExpired = true;
  final _topSnackBar = TopSnackBarDef();

  // App Bar and Scroll View
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    if (!_scrollController!.hasClients) {
      return false;
    }
    // Use the same condition as before to check if AppBar is expanded.
    return _scrollController!.offset >
        (MediaQuery.of(context).size.height * 0.13 - kToolbarHeight);
    return _scrollController!.offset >
        (MediaQuery.of(context).size.height * 0.13 - kToolbarHeight);
  }

  @override
  void initState() {
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
    canEdit = currentUser.brandRole < 2 ? true : false;
    initBrand();
  }

  // Gets the user info from firebase.
  Future<void> initBrand() async {
    // Name Description
    nameBrandController.text = currentBrand.name!;
    descriptionController.text = currentBrand.description!;
    // Admin ID
    if (admin.id != currentBrand.adminID) {
      admin = await _userDataService.getUserCoverDetails(currentBrand.adminID!);
    }
    // Created at
    var dateJoinedSplit = currentBrand.dateJoined!.split("-");
    dateJoinedBrand = DateTime(int.parse(dateJoinedSplit[2]),
        int.parse(dateJoinedSplit[1]), int.parse(dateJoinedSplit[0]), 0, 0);
    dateJoinedBrand = DateTime(int.parse(dateJoinedSplit[2]),
        int.parse(dateJoinedSplit[1]), int.parse(dateJoinedSplit[0]), 0, 0);
    // Members Deprecated
    members = currentBrand.maxMembers!;
    membersController.text = currentBrand.maxMembers.toString();
    // Start Time
    var startHourWS =
        int.parse(currentBrand.workShift[0].toStringAsFixed(2).split(".")[0]);
    var startMinWS =
        int.parse(currentBrand.workShift[0].toStringAsFixed(2).split(".")[1]);
    startTime = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, startHourWS, startMinWS);
    startTimeController.text =
        DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      startHourWS,
      startMinWS,
    ));
    startTime = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, startHourWS, startMinWS);
    startTimeController.text =
        DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      startHourWS,
      startMinWS,
    ));
    // End Time
    var endHourWS =
        int.parse(currentBrand.workShift[1].toStringAsFixed(2).split(".")[0]);
    var endMinWS =
        int.parse(currentBrand.workShift[1].toStringAsFixed(2).split(".")[1]);
    endTime = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, endHourWS, endMinWS);
    endTimeController.text =
        DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      endHourWS,
      endMinWS,
    ));
    // Break Hours
    if (currentBrand.workShift.length > 2) {
      var start = currentBrand.workShift[2];
      int s = start.toInt();
      var startHour = int.parse(start.toStringAsFixed(2).split(".")[0]);
      var startMin = int.parse(start.toStringAsFixed(2).split(".")[1]);
      var end = currentBrand.workShift[3];
      int e = end.toInt();
      var endHour = int.parse(end.toStringAsFixed(2).split(".")[0]);
      var endMin = int.parse(end.toStringAsFixed(2).split(".")[1]);
      breakStartTime = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, startHour, startMin);
      _breakStartTime = TimeOfDay(hour: startHour, minute: startMin);
      breakEndTime = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, endHour, endMin);
      _breakEndTime = TimeOfDay(hour: endHour, minute: endMin);
    }
    breakStartTimeController.text =
        DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      _breakStartTime.hour,
      _breakStartTime.minute,
    ));
    breakEndTimeController.text =
        DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      _breakEndTime.hour,
      _breakEndTime.minute,
    ));
    // Booking Window
    bookingWindow = currentBrand.bookingWindow!;
    bookingWindowMin = currentBrand.bookingWindowMin!;
    // Direct Purchase
    if (currentBrand.directPurchase != null) {
      directPurchase = currentBrand.directPurchase!;
    } else {
      currentBrand.directPurchase = false;
    }
    // Free Session
    if (currentBrand.freeSession != null) {
      freeSession = currentBrand.freeSession!;
    } else {
      currentBrand.freeSession = false;
    }
    //Grace period
    if (currentBrand.gracePeriod != null) {
      gracePeriodDays = currentBrand.gracePeriod!;
    } else {
      currentBrand.gracePeriod = 7;
    }
    //Max cancel per week
    if (currentBrand.maxCanWeek != null) {
      cancelationsPerWeek = currentBrand.maxCanWeek!;
    } else {
      currentBrand.maxCanWeek = 7;
    }
    if (currentBrand.paymentTerms != null) {
      isSelectedTerms[0] = false;
      isSelectedTerms[1] = false;
      isSelectedTerms[2] = false;
      isSelectedTerms[currentBrand.paymentTerms!] = true;
    } else {
      currentBrand.paymentTerms = 2;
    }
    if (currentBrand.stripeActivated != null && currentBrand.stripeActivated!) {
      isStripeActive = true;
    } else {
      currentBrand.stripeActivated = false;
    }
  }

  // Gets the user info from firebase.
  Future<void> getBrand() async {
    var basicData = await _brandDataService.getBrandDetails(widget.brandId);
    var userList = await _brandDataService.getBrandUsers(widget.brandId);
    setState(() {
      currentBrand.setBasicData = basicData;
      currentBrand.setUserList = userList;
      isLoading = false;
    });
    initBrand();
  }

  Future<void> navigateToEditLogoScreen() async {
    if (canEdit) {
      mixpanel!.track('brand_info_logo_change');
      await Navigator.push(
          context,
          CupertinoPageRoute<void>(
            builder: (context) => Logo(brandId: currentBrand.id!),
          )).whenComplete(() async {
        await getBrand();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      // Working Hours
      var startHourWS =
          int.parse(currentBrand.workShift[0].toStringAsFixed(2).split(".")[0]);
      var startMinWS =
          int.parse(currentBrand.workShift[0].toStringAsFixed(2).split(".")[1]);
      var endHourWS =
          int.parse(currentBrand.workShift[1].toStringAsFixed(2).split(".")[0]);
      var endMinWS =
          int.parse(currentBrand.workShift[1].toStringAsFixed(2).split(".")[1]);
      if (nameBrandControllerTemp.trim() != currentBrand.name! &&
          nameBrandControllerTemp != "") {
        isUpdated = true;
        mixpanel!.track('brand_info_name_change');
      } else if (descriptionControllerTemp.trim() !=
              currentBrand.description! &&
          descriptionControllerTemp != "") {
        isUpdated = true;
        mixpanel!.track('brand_info_description_change');
      } else if (startTimeController.text !=
              DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
                startHourWS,
                startMinWS,
              )) ||
          endTimeController.text !=
              DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
                endHourWS,
                endMinWS,
              ))) {
        isUpdated = true;
        mixpanel!.track('brand_info_workshit_change');
      } else if (breakStartTimeController.text !=
              DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
                _breakStartTime.hour,
                _breakStartTime.minute,
              )) ||
          breakEndTimeController.text !=
              DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
                _breakEndTime.hour,
                _breakEndTime.minute,
              ))) {
        isUpdated = true;
        mixpanel!.track('brand_info_break_hours_change');
      } else if (currentBrand.bookingWindow! != bookingWindow) {
        isUpdated = true;
        mixpanel!.track('brand_info_booking_window_change');
      } else if (currentBrand.bookingWindowMin! != bookingWindowMin) {
        isUpdated = true;
        mixpanel!.track('brand_info_booking_window_change');
      } else if (currentBrand.directPurchase! != directPurchase) {
        isUpdated = true;
        mixpanel!.track('brand_info_direct_purchase_change');
      } else if (currentBrand.freeSession != freeSession) {
        isUpdated = true;
        mixpanel!.track('brand_info_free_session_change');
      } else {
        isUpdated = false;
      }
      if (currentBrand.gracePeriod != gracePeriodDays) {
        isUpdated = true;
      }
      if (currentBrand.maxCanWeek != cancelationsPerWeek) {
        isUpdated = true;
      }
      if (currentBrand.paymentTerms! == 0) {
        if (isSelectedTerms[0] == false) {
          isUpdated = true;
        }
      } else if (currentBrand.paymentTerms! == 1) {
        if (isSelectedTerms[1] == false) {
          isUpdated = true;
        }
      } else if (currentBrand.paymentTerms! == 2) {
        if (isSelectedTerms[2] == false) {
          isUpdated = true;
        }
      }
      if (currentBrand.stripeActivated != isStripeActive) {
        isUpdated = true;
      }
    }
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            surfaceTintColor: AppColors.darkGrey,
            backgroundColor: AppColors.darkGrey,
            expandedHeight: MediaQuery.of(context).size.height * 0.15,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            elevation: 4,
            floating: false,
            pinned: true,
            //snap: true,
            title: AnimatedOpacity(
                opacity: appBarExpanded ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Text(AppLocalizations.of(context)!.settings,
                    style:
                        Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                              color: AppColors.white,
                            ))),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.darkGrey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.05,
                          right: MediaQuery.of(context).size.width * 0.025),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.settings,
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                  color: AppColors.white,
                                ),
                          ),
                          FittedBox(
                            fit: BoxFit.fitHeight,
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.08,
                              width: MediaQuery.of(context).size.width * 0.11,
                              child: TextButton(
                                onPressed: null,
                                child: Icon(
                                  Icons.filter_list,
                                  color: AppColors.darkGrey,
                                  size:
                                      MediaQuery.of(context).size.width * 0.07,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    Container(
                      color: AppColors.grey,
                      height: 1.0,
                    ),
                  ],
                ),
              ),
              titlePadding: EdgeInsets.zero,
              //centerTitle: true,
            ),
            centerTitle: false,
            leading: Builder(
              builder: (BuildContext innerContext) => Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.02),
                child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: AppColors.white,
                      size: MediaQuery.of(context).size.height * 0.04,
                    ),
                    onPressed: () =>
                        mambaProScaffoldKey.currentState?.openDrawer()),
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  askSupport(context),
                  unreadNotifications(context),
                  unreadChats(context),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.025),
                  profileImage(context),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                ],
              ),
            ],
          ),
          if (isLoading)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  Expanded(
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.65,
                        child: Center(child: LoadingView())),
                  ),
                ],
              ),
            )
          else
            SliverToBoxAdapter(
              child: Column(
                children: [
                  /// INFO
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: Column(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                        Row(
                          children: [
                            Icon(
                              Icons.info_outlined,
                              color: AppColors.grey,
                              size: MediaQuery.of(context).size.width * 0.05,
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.02),
                            Text(
                              AppLocalizations.of(context)!.information,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(color: AppColors.grey),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: Form(
                      key: formKeyInfo,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// LOGO
                          Text(
                            AppLocalizations.of(context)!.logo,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.015),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.16,
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: navigateToEditLogoScreen,
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      SizedBox(
                                        height: canEdit
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.16
                                            : MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.15,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            CircularImage(
                                              size: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.15,
                                              image: currentBrand.logoUrl!,
                                              borderWidth: 1,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                      canEdit
                                          ? Material(
                                              elevation: 4,
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              child: Container(
                                                constraints: BoxConstraints(
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.1,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .background,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4,
                                                        vertical: 4),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.06,
                                                      child: Icon(
                                                        Icons.edit,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        size: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.035,
                                                      ),
                                                    ),
                                                    Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .edit,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium,
                                                        maxLines: 1,
                                                        softWrap: true,
                                                        textAlign:
                                                            TextAlign.center)
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.03),

                          /// NAME
                          Text(
                            AppLocalizations.of(context)!.firstName,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.015),
                          Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(15.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    controller: nameBrandController,
                                    onChanged: (value) {
                                      setState(() {
                                        nameBrandControllerTemp = value;
                                      });
                                    },
                                    validator: (val) => val!.isEmpty
                                        ? AppLocalizations.of(context)!
                                            .nameBrandError
                                        : null,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.start,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    enabled: canEdit,
                                    decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Theme.of(context)
                                            .colorScheme
                                            .background,
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        hintText: AppLocalizations.of(context)!
                                            .nameBrandError,
                                        border: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.transparent,
                                              width: 1.5),
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.transparent,
                                              width: 1.5),
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.transparent,
                                              width: 1.5),
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.transparent,
                                              width: 1.5),
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                                12, 8, 12, 8)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.015),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .createBrandCoverDescription,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.03),

                          /// DESCRIPTION
                          Text(
                            AppLocalizations.of(context)!.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.015),
                          Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(15.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.background,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      controller: descriptionController,
                                      onChanged: (value) {
                                        setState(() {
                                          descriptionControllerTemp = value;
                                        });
                                      },
                                      //validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.descriptionError : null,
                                      minLines: 1,
                                      maxLines: 5,
                                      maxLength: 250,
                                      enabled: canEdit,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Theme.of(context)
                                              .colorScheme
                                              .background,
                                          hintText:
                                              AppLocalizations.of(context)!
                                                  .descriptionHint,
                                          counter: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical:
                                                    5.0), // adjust as needed
                                            child: Text(
                                              "${descriptionController.text.length}/250", // replace 250 with your max length
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(fontSize: 12.5),
                                            ),
                                          ),
                                          hintStyle: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                          border: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.transparent,
                                                width: 1.5),
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.transparent,
                                                width: 1.5),
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.transparent,
                                                width: 1.5),
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.transparent,
                                                width: 1.5),
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  12, 8, 12, 8)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.015),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .createBrandDescDescription,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.03),

                          /// CREATED AT
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  "${AppLocalizations.of(context)!.createdBy(admin.name!)} el ${DateTimeUtils().formatDateTimeToStringDDMMMMYYYY(dateJoinedBrand, Localizations.localeOf(context).languageCode)}",
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.03),
                        ],
                      ),
                    ),
                  ),

                  /// CALENDAR
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: Column(
                      children: [
                        const Divider(color: AppColors.grey, thickness: 1),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_month_outlined,
                                  color: AppColors.grey,
                                  size:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.02),
                                Text(
                                  AppLocalizations.of(context)!.bookings,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(color: AppColors.grey),
                                ),
                              ],
                            ),
                            timeZoneName != null
                                ? Flexible(
                                    child: Text(
                                      "GMT: ${timeZoneName!}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(fontSize: 12.5),
                                      textAlign: TextAlign.right,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// WORKING HOURS
                        Text(
                          AppLocalizations.of(context)!.workingHours,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            TextButton(
                              onPressed: canEdit
                                  ? () async {
                                      DateTime? pickedTimeTemp =
                                          await showCupertinoModalPopup(
                                              context: context,
                                              builder: (_) => SelectTimeDialog(
                                                    title: AppLocalizations.of(
                                                            context)!
                                                        .selectTime,
                                                    startDate: startTime,
                                                    onlyFuture: false,
                                                  ));
                                      if (pickedTimeTemp != null) {
                                        setState(() {
                                          errorTime = null;
                                          startTime = pickedTimeTemp;
                                          startTimeController.text = DateFormat(
                                                  'HH:mm',
                                                  widget.locale!.languageCode)
                                              .format(DateTime(
                                            DateTime.now().year,
                                            DateTime.now().month,
                                            DateTime.now().day,
                                            startTime.hour,
                                            startTime.minute,
                                          ));
                                        });
                                      }
                                    }
                                  : null,
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 30),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  alignment: Alignment.centerLeft),
                              child: Material(
                                elevation: 4,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 12, 16, 12),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background,
                                  ),
                                  child: Text(
                                    startTimeController.text,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text("-",
                                  style:
                                      Theme.of(context).textTheme.displaySmall),
                            ),
                            TextButton(
                              onPressed: canEdit
                                  ? () async {
                                      DateTime? pickedTimeTemp =
                                          await showCupertinoModalPopup(
                                              context: context,
                                              builder: (_) => SelectTimeDialog(
                                                    title: AppLocalizations.of(
                                                            context)!
                                                        .selectTime,
                                                    startDate: endTime,
                                                    onlyFuture: false,
                                                  ));
                                      if (pickedTimeTemp != null) {
                                        setState(() {
                                          errorTime = null;
                                          endTime = pickedTimeTemp;
                                          endTimeController.text = DateFormat(
                                                  'HH:mm',
                                                  widget.locale!.languageCode)
                                              .format(DateTime(
                                            DateTime.now().year,
                                            DateTime.now().month,
                                            DateTime.now().day,
                                            endTime.hour,
                                            endTime.minute,
                                          ));
                                        });
                                      }
                                    }
                                  : null,
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 30),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  alignment: Alignment.centerLeft),
                              child: Material(
                                elevation: 4,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 12, 16, 12),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background,
                                  ),
                                  child: Text(
                                    endTimeController.text,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        errorTime != null
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    left: 0, right: 0, top: 10.0, bottom: 0),
                                child: Text(
                                  errorTime == 1
                                      ? AppLocalizations.of(context)!
                                          .workingHoursError
                                      : AppLocalizations.of(context)!
                                          .workingHoursError1,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppColors.red),
                                  textAlign: TextAlign.left,
                                ),
                              )
                            : Container(),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!
                                    .createBrandWorkshiftDescription,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),

                        /// BREAK HOURS
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.lunchBreak,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            TextButton(
                              onPressed: canEdit
                                  ? () async {
                                      if (breakStartTime.hour == 0) {
                                        breakStartTime = DateTime(
                                            DateTime.now().year,
                                            DateTime.now().month,
                                            DateTime.now().day,
                                            13,
                                            0);
                                      }
                                      DateTime? pickedTimeTemp =
                                          await showCupertinoModalPopup(
                                              context: context,
                                              builder: (_) => SelectTimeDialog(
                                                    title: AppLocalizations.of(
                                                            context)!
                                                        .selectTime,
                                                    startDate: breakStartTime,
                                                    onlyFuture: false,
                                                  ));
                                      if (pickedTimeTemp != null) {
                                        setState(() {
                                          errorBreakTime = null;
                                          breakStartTime = pickedTimeTemp;
                                          breakStartTimeController
                                              .text = DateFormat('HH:mm',
                                                  widget.locale!.languageCode)
                                              .format(DateTime(
                                            DateTime.now().year,
                                            DateTime.now().month,
                                            DateTime.now().day,
                                            breakStartTime.hour,
                                            breakStartTime.minute,
                                          ));
                                        });
                                      }
                                    }
                                  : null,
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 30),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  alignment: Alignment.centerLeft),
                              child: Material(
                                elevation: 4,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 12, 16, 12),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background,
                                  ),
                                  child: Text(
                                    breakStartTimeController.text,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text("-",
                                  style:
                                      Theme.of(context).textTheme.displaySmall),
                            ),
                            TextButton(
                              onPressed: canEdit
                                  ? () async {
                                      if (breakEndTime.hour == 0) {
                                        breakEndTime = DateTime(
                                            DateTime.now().year,
                                            DateTime.now().month,
                                            DateTime.now().day,
                                            14,
                                            0);
                                      }
                                      DateTime? pickedTimeTemp =
                                          await showCupertinoModalPopup(
                                              context: context,
                                              builder: (_) => SelectTimeDialog(
                                                    title: AppLocalizations.of(
                                                            context)!
                                                        .selectTime,
                                                    startDate: breakEndTime,
                                                    onlyFuture: false,
                                                  ));
                                      if (pickedTimeTemp != null) {
                                        setState(() {
                                          errorBreakTime = null;
                                          breakEndTime = pickedTimeTemp;
                                          breakEndTimeController
                                              .text = DateFormat('HH:mm',
                                                  widget.locale!.languageCode)
                                              .format(DateTime(
                                            DateTime.now().year,
                                            DateTime.now().month,
                                            DateTime.now().day,
                                            breakEndTime.hour,
                                            breakEndTime.minute,
                                          ));
                                        });
                                      }
                                    }
                                  : null,
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 30),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  alignment: Alignment.centerLeft),
                              child: Material(
                                elevation: 4,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 12, 16, 12),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background,
                                  ),
                                  child: Text(
                                    breakEndTimeController.text,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.05),
                            GestureDetector(
                              onTap: breakStartTime.hour == 0 ||
                                      breakEndTime.hour == 0
                                  ? null
                                  : () async {
                                      setState(() {
                                        errorBreakTime = null;
                                      });
                                      breakStartTime = DateTime(
                                          DateTime.now().year,
                                          DateTime.now().month,
                                          DateTime.now().day,
                                          0,
                                          0);
                                      breakStartTimeController.text =
                                          DateFormat('HH:mm',
                                                  widget.locale!.languageCode)
                                              .format(DateTime(
                                        DateTime.now().year,
                                        DateTime.now().month,
                                        DateTime.now().day,
                                        breakStartTime.hour,
                                        breakStartTime.minute,
                                      ));
                                      breakEndTime = DateTime(
                                          DateTime.now().year,
                                          DateTime.now().month,
                                          DateTime.now().day,
                                          0,
                                          0);
                                      breakEndTimeController.text = DateFormat(
                                              'HH:mm',
                                              widget.locale!.languageCode)
                                          .format(DateTime(
                                        DateTime.now().year,
                                        DateTime.now().month,
                                        DateTime.now().day,
                                        breakEndTime.hour,
                                        breakEndTime.minute,
                                      ));
                                    },
                              child: Icon(
                                Icons.clear,
                                color: breakStartTime.hour == 0 ||
                                        breakEndTime.hour == 0
                                    ? Colors.transparent
                                    : AppColors.grey,
                                size: MediaQuery.of(context).size.width * 0.05,
                              ),
                            ),
                          ],
                        ),
                        errorBreakTime != null
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    left: 0, right: 0, top: 10.0, bottom: 0),
                                child: Text(
                                  errorBreakTime == 1
                                      ? AppLocalizations.of(context)!
                                          .workingHoursError2
                                      : AppLocalizations.of(context)!
                                          .workingHoursError1,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppColors.red),
                                  textAlign: TextAlign.left,
                                ),
                              )
                            : Container(),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!
                                    .createBrandBreakDescription,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),

                        /// BOOKING WINDOW
                        Text(
                          AppLocalizations.of(context)!.bookingWindow,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015),
                        GestureDetector(
                          onTap: canEdit
                              ? () {
                                  selectNumberOfDays();
                                }
                              : null,
                          child: Material(
                            elevation: 4,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                                color: Theme.of(context).colorScheme.background,
                              ),
                              height: MediaQuery.of(context).size.width * 0.1,
                              width: MediaQuery.of(context).size.width * 0.2,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "$bookingWindow ${AppLocalizations.of(context)!.days.toLowerCase()}",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!
                                    .bookingWindowDescription,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),

                        /// MINIMUM BOOKING WINDOW
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .minimumBookingWindow,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015),
                        GestureDetector(
                          onTap: canEdit
                              ? () {
                                  selectNumberOfHours();
                                }
                              : null,
                          child: Material(
                            elevation: 4,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                                color: Theme.of(context).colorScheme.background,
                              ),
                              height: MediaQuery.of(context).size.width * 0.1,
                              width: MediaQuery.of(context).size.width * 0.2,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    bookingWindowMin > 1
                                        ? "$bookingWindowMin ${AppLocalizations.of(context)!.hoursString.toLowerCase()}"
                                        : "$bookingWindowMin ${AppLocalizations.of(context)!.hour.toLowerCase()}",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!
                                    .minimumBookingWindowDescription,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),

                        /// FREE SESSION
                        Padding(
                            padding: EdgeInsets.only(
                                right:
                                    MediaQuery.of(context).size.height * 0.01),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.freeSession,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.035,
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                  child: CupertinoSwitch(
                                    value: freeSession,
                                    onChanged: canEdit
                                        ? (bool newVal) {
                                            setState(() {
                                              freeSession = newVal;
                                            });
                                          }
                                        : null,
                                    trackColor: Colors.green.withOpacity(0.4),
                                    thumbColor: AppColors.white,
                                    activeColor: Colors.green,
                                  ),
                                ),
                              ],
                            )),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!
                                    .freeSessionDescription,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                      ],
                    ),
                  ),

                  /// PURCHASES
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: Column(
                      children: [
                        const Divider(color: AppColors.grey, thickness: 1),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                        Row(
                          children: [
                            Icon(
                              Icons.confirmation_number_outlined,
                              color: AppColors.grey,
                              size: MediaQuery.of(context).size.width * 0.05,
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.02),
                            Text(
                              StringUtils().toCapitalized(
                                  AppLocalizations.of(context)!.payments),
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(color: AppColors.grey),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// DIRECT PURCHASE
                        Padding(
                            padding: EdgeInsets.only(
                                right:
                                    MediaQuery.of(context).size.height * 0.01),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!
                                      .directPurchasetext,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.035,
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                  child: CupertinoSwitch(
                                    value: directPurchase,
                                    onChanged: canEdit
                                        ? (bool newVal) {
                                            setState(() {
                                              directPurchase = newVal;
                                            });
                                          }
                                        : null,
                                    trackColor: Colors.green.withOpacity(0.4),
                                    thumbColor: AppColors.white,
                                    activeColor: Colors.green,
                                  ),
                                ),
                              ],
                            )),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!
                                    .directPurchaseDescription,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),

                        ///CONEXION CON STRIPE
                        stripeActivatedGlobal ? conectionStripe() : Container(),

                        ///PERIODO DE GRACIA
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.gracePeriodTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                                onTap: () {
                                  _topSnackBar.showSnackBarBottom(
                                      context,
                                      AppLocalizations.of(context)!.betaFeature,
                                      5);
                                },
                                child: const BetaBadge())
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015),
                        GestureDetector(
                          onTap: canEdit
                              ? () {
                                  selectNumberOfDaysGracePeriod();
                                }
                              : null,
                          child: Material(
                            elevation: 4,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                                color: Theme.of(context).colorScheme.background,
                              ),
                              height: MediaQuery.of(context).size.width * 0.1,
                              width: MediaQuery.of(context).size.width * 0.2,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "$gracePeriodDays ${AppLocalizations.of(context)!.days.toLowerCase()}",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!
                                    .gracePeriodDescription,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
/*
                        ///CANCELACIONES MAXIMAS POR SEMANA
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .maximumCancellationsPerWeekTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                                onTap: () {
                                  _topSnackBar.showSnackBarBottom(
                                      context,
                                      AppLocalizations.of(context)!.betaFeature,
                                      5);
                                },
                                child: const BetaBadge())
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015),
                        GestureDetector(
                          onTap: canEdit
                              ? () {
                                  selectNumberOfTimesCancelationsPerWeek();
                                }
                              : null,
                          child: Material(
                            elevation: 4,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                                color: Theme.of(context).colorScheme.background,
                              ),
                              height: MediaQuery.of(context).size.width * 0.1,
                              width: MediaQuery.of(context).size.width * 0.2,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "$cancelationsPerWeek ${AppLocalizations.of(context)!.times.toLowerCase()}",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!
                                    .maximumCancellationsPerWeekDescription,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
*/
                        ///TERMINOS DE PAGO
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.paymentTermsTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                                onTap: () {
                                  _topSnackBar.showSnackBarBottom(
                                      context,
                                      AppLocalizations.of(context)!.betaFeature,
                                      5);
                                },
                                child: const BetaBadge())
                          ],
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.015),
                                selectedTerms(
                                    2,
                                    AppLocalizations.of(context)!
                                        .exactDaysTitle,
                                    AppLocalizations.of(context)!
                                        .exactDaysTitleDescription),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.015),
                                selectedTerms(
                                    1,
                                    AppLocalizations.of(context)!
                                        .midMonthPaymentTitle,
                                    AppLocalizations.of(context)!
                                        .midMonthPaymentDescription),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.015),
                                selectedTerms(
                                    0,
                                    AppLocalizations.of(context)!
                                        .proratedPaymentTitle,
                                    AppLocalizations.of(context)!
                                        .proratedPaymentDescription),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.015),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!
                                    .paymentTermsDescription,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                      ],
                    ),
                  ),

                  /// DELETE BRAND
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: Column(
                      children: [
                        const Divider(color: AppColors.grey, thickness: 1),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                        Row(
                          children: [
                            Icon(
                              Icons.settings_outlined,
                              color: AppColors.grey,
                              size: MediaQuery.of(context).size.width * 0.05,
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.02),
                            Text(
                              AppLocalizations.of(context)!.others,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(color: AppColors.grey),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.025),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// LEAVE BRAND
                        !canEdit
                            ? Column(
                                children: [
                                  Padding(
                                      padding: EdgeInsets.only(
                                          right: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.01),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .exitBrand,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.red),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.logout,
                                              color: AppColors.red,
                                              size: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.07,
                                            ),
                                            alignment: Alignment.centerRight,
                                            padding: EdgeInsets.zero,
                                            onPressed: () async {
                                              mixpanel!.track(
                                                  'exit_brand_dialog_open');
                                              // Leaves Brand
                                              var result = await showDialog(
                                                  context: context,
                                                  builder: (_) {
                                                    return ConfirmationDialog(
                                                        text: AppLocalizations
                                                                .of(context)!
                                                            .exitBrandConfirm);
                                                  });
                                              if (result) {
                                                mixpanel!.track(
                                                    'exit_brand_confirmed');
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                pageIndex = 10;
                                                NotificationService()
                                                    .userLeavesBrand(
                                                        currentUser.id!,
                                                        currentBrand.id!);
                                                await _eventDataService
                                                    .deleteUserFromUpcomingEvents(
                                                        currentUser.id!,
                                                        currentUser.isTrainer!);
                                                await _brandDataService
                                                    .deleteUserFromBrand(
                                                        currentUser.id!,
                                                        currentBrand.id!);
                                                Navigator.pushReplacement(
                                                    context,
                                                    CupertinoPageRoute<void>(
                                                      builder: (context) =>
                                                          const SplashScreen(),
                                                      settings:
                                                          const RouteSettings(
                                                              name:
                                                                  'SplashScreen'),
                                                    ));
                                              }
                                            },
                                          ),
                                        ],
                                      )),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .exitBrandDesc,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03),
                                ],
                              )
                            : Column(
                                children: [
                                  Padding(
                                      padding: EdgeInsets.only(
                                          right: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.01),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!
                                                .deleteBrand,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.red),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete_outlined,
                                              color: AppColors.red,
                                              size: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.07,
                                            ),
                                            alignment: Alignment.centerRight,
                                            padding: EdgeInsets.zero,
                                            onPressed: () async {
                                              mixpanel!.track(
                                                  'delete_brand_dialog_open');
                                              var result = await showDialog(
                                                  context: context,
                                                  builder: (_) {
                                                    return const DeleteBrandDialog();
                                                  });
                                              if (result) {
                                                mixpanel!.track(
                                                    'delete_brand_confirmed');
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                // New DataBase
                                                await _brandDataService
                                                    .deleteBrand(
                                                        currentBrand.id!);
                                                await _roomDataService
                                                    .deleteRoom(
                                                        currentBrand.roomId!);
                                                currentUser.setBrandList = [];
                                                await Future.delayed(
                                                    const Duration(seconds: 4));
                                                Navigator.pushReplacement(
                                                    context,
                                                    CupertinoPageRoute<void>(
                                                      builder: (context) =>
                                                          const SplashScreen(),
                                                      settings:
                                                          const RouteSettings(
                                                              name:
                                                                  'SplashScreen'),
                                                    ));
                                              }
                                            },
                                          ),
                                        ],
                                      )),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .deleteBrandDesc,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03),
                                ],
                              ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.10),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: isUpdated
          ? Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
              child: FloatingActionButton.extended(
                shape: const StadiumBorder(),
                heroTag: "81",
                onPressed: () async {
                  if (validateInfo()) {
                    setState(() {
                      appBarExpanded = false;
                      isLoading = true;
                    });
                    DateTime start =
                        DateFormat('HH:mm', widget.locale!.languageCode)
                            .parse(startTimeController.text);
                    DateTime end =
                        DateFormat('HH:mm', widget.locale!.languageCode)
                            .parse(endTimeController.text);
                    DateTime breakStart =
                        DateFormat('HH:mm', widget.locale!.languageCode)
                            .parse(breakStartTimeController.text);
                    DateTime breakEnd =
                        DateFormat('HH:mm', widget.locale!.languageCode)
                            .parse(breakEndTimeController.text);
                    double toDouble(DateTime myTime) =>
                        myTime.hour + myTime.minute / 100;
                    // Reset Workshift
                    _workShift.clear();
                    _workShift.add(toDouble(start));
                    _workShift.add(toDouble(end));
                    _workShift.add(toDouble(breakStart));
                    _workShift.add(toDouble(breakEnd));
                    print(_workShift);

                    int termsSelected = 0;

                    if (isSelectedTerms[1]) {
                      termsSelected = 1;
                    } else if (isSelectedTerms[2]) {
                      termsSelected = 2;
                    }
                    // Update Brand Info
                    await _brandDataService.updateBrandInfo(
                        widget.brandId,
                        nameBrandController.text,
                        descriptionController.text,
                        members,
                        _workShift,
                        bookingWindow,
                        bookingWindowMin,
                        directPurchase,
                        freeSession,
                        gracePeriodDays,
                        cancelationsPerWeek,
                        termsSelected,
                        isStripeActive);
                    await getBrand();
                    mixpanel!.track('brand_info_changes_done');
                  }
                },
                backgroundColor: Colors.green,
                icon: Icon(
                  Icons.save_rounded,
                  color: Colors.white,
                  size: MediaQuery.of(context).size.width * 0.05,
                ),
                label: Text(
                  AppLocalizations.of(context)!.save,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Colors.white),
                ),
              ),
            )
          : Container(),
    );
  }

  Future selectNumberOfDays() async {
    int? pickedMembers = await showCupertinoModalPopup(
        context: context,
        builder: (_) => SelectDaysDialog(
              title:
                  "${AppLocalizations.of(context)!.select} ${AppLocalizations.of(context)!.days.toLowerCase()}",
              intialDays: bookingWindow - 1,
            ));
    if (pickedMembers != null) {
      setState(() {
        bookingWindow = pickedMembers;
      });
    }
  }

  Future selectNumberOfDaysGracePeriod() async {
    int? gracePeriodDaysAux = await showCupertinoModalPopup(
        context: context,
        builder: (_) => SelectOtherDialog(
              title:
                  "${AppLocalizations.of(context)!.select} ${AppLocalizations.of(context)!.days.toLowerCase()}",
              intialDays: gracePeriodDays,
            ));
    if (gracePeriodDaysAux != null) {
      setState(() {
        gracePeriodDays = gracePeriodDaysAux;
      });
    }
  }

  Future selectNumberOfTimesCancelationsPerWeek() async {
    int? cancelationsPerWeekAux = await showCupertinoModalPopup(
        context: context,
        builder: (_) => SelectOtherDialog(
              title:
                  "${AppLocalizations.of(context)!.select} ${AppLocalizations.of(context)!.times.toLowerCase()}",
              intialDays: cancelationsPerWeek,
            ));
    if (cancelationsPerWeekAux != null) {
      setState(() {
        cancelationsPerWeek = cancelationsPerWeekAux;
      });
    }
  }

  Future selectNumberOfHours() async {
    int? pickedMembers = await showCupertinoModalPopup(
        context: context,
        builder: (_) => SelectHoursDialog(
              title:
                  "${AppLocalizations.of(context)!.select} ${AppLocalizations.of(context)!.hoursString.toLowerCase()}",
              intialDays: bookingWindowMin,
            ));
    if (pickedMembers != null) {
      setState(() {
        bookingWindowMin = pickedMembers;
      });
    }
  }

  Future<void> navigateToSubscriptionsScreen() async {
    mixpanel!.track('brand_see_paywall');
    await navigateToPayWall(context);
    mixpanel!.track('brand_see_paywall');
    await navigateToPayWall(context);
  }

  Widget textToShow() {
    return Text(
      ShowTextExpired
          ? AppLocalizations.of(context)!.subscriptionExpired
          : AppLocalizations.of(context)!.noSubscription,
      style: Theme.of(context)
          .textTheme
          .bodyMedium!
          .copyWith(color: Theme.of(context).colorScheme.secondary),
      textAlign: TextAlign.center,
    );
  }

  bool validateInfo() {
    DateTime start = DateFormat('HH:mm', widget.locale!.languageCode)
        .parse(startTimeController.text);
    DateTime end = DateFormat('HH:mm', widget.locale!.languageCode)
        .parse(endTimeController.text);
    DateTime startBreak = DateFormat('HH:mm', widget.locale!.languageCode)
        .parse(breakStartTimeController.text);
    DateTime endBreak = DateFormat('HH:mm', widget.locale!.languageCode)
        .parse(breakEndTimeController.text);
    double toDouble(DateTime myTime) => myTime.hour + myTime.minute / 100.0;
    if (!formKeyInfo.currentState!.validate()) {
      return false;
    }
    if (membersController.text.isEmpty) {
      setState(() {
        errorMembers = true;
        errorMembers = true;
      });
      return false;
    }
    if (toDouble(start) >= toDouble(end)) {
      setState(() {
        errorTime = 2;
      });
      return false;
    }
    if (startBreak.hour != 0 && endBreak.hour != 0) {
      if (start.isAfter(startBreak) || end.isBefore(endBreak)) {
        setState(() {
          errorBreakTime = 1;
        });
        return false;
      }
      if (toDouble(startBreak) >= toDouble(endBreak)) {
        setState(() {
          errorBreakTime = 2;
        });
        return false;
      }
    } else {
      if (startBreak.hour == 0 && endBreak.hour != 0) {
        setState(() {
          errorBreakTime = 1;
        });
        return false;
      }
      if (startBreak.hour != 0 && endBreak.hour == 0) {
        setState(() {
          errorBreakTime = 1;
        });
        return false;
      }
    }
    setState(() {
      errorTime == null;
      errorBreakTime = null;
      errorMembers = false;
    });
    return true;
  }

  Widget freeTrialMamba() {
    return GestureDetector(
      onTap: () async {
        await navigateToPayWall(context);
      },
      child: Container(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
        height: MediaQuery.of(context).size.height * 0.1,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
          border: Border.all(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
              width: 2),
        ),
        child: Center(
          child: ListTile(
            title: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.width * 0.01),
              child: Text(AppLocalizations.of(context)!.chooseYourPlan,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: AppColors.mainColor, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left),
            ),
            subtitle: Text(
              AppLocalizations.of(context)!
                  .freeTrialDaysLeft(difference.toString()),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: AppColors.mainColor,
                  fontWeight: FontWeight.normal,
                  fontSize: 12),
            ),
            trailing: GestureDetector(
              onTap: () async {
                await navigateToPayWall(context);
              },
              child: Container(
                height: MediaQuery.of(context).size.height * 0.05,
                width: MediaQuery.of(context).size.width * 0.2,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Center(
                    child: Text(
                  AppLocalizations.of(context)!.subscriptionsAppBar,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                )),
              ),
            ),
            dense: true,
          ),
        ),
      ),
    );
  }

  Widget selectedTerms(int index, String title, String description) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        width: MediaQuery.of(context).size.width * 0.9,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Theme.of(context).primaryColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isSelectedTerms[index] == true
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            Text(
                              description,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        )
                      : Container(),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.034,
              width: MediaQuery.of(context).size.height * 0.06,
              child: MaterialButton(
                elevation: 2,
                color: isSelectedTerms[index] == true
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.background,
                padding: EdgeInsets.zero,
                shape: const CircleBorder(),
                onPressed: () {
                  isSelectedTerms[0] = false;
                  isSelectedTerms[1] = false;
                  isSelectedTerms[2] = false;

                  isSelectedTerms[index] = true;
                  setState(() {});
                },
                child: isSelectedTerms[index] == true
                    ? Icon(Icons.check,
                        color: Theme.of(context).primaryColorDark,
                        size: MediaQuery.of(context).size.width * 0.05)
                    : SizedBox(
                        height: MediaQuery.of(context).size.width * 0.03,
                        width: MediaQuery.of(context).size.width * 0.03,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get buttonText {
    if (currentBrand.stripeAccountId == null ||
        currentBrand.stripeAccountId == '') {
      return 'Connect with Stripe';
    } else if (!currentBrand.isVerified) {
      return 'Complete your profile';
    } else {
      return 'update your profile';
    }
  }

  Widget conectionStripe() {
    return Column(
      children: [
        Padding(
            padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.height * 0.01),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  AppLocalizations.of(context)!.stripeAccountText,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.035,
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: CupertinoSwitch(
                    value: isStripeActive,
                    onChanged: canEdit
                        ? (bool newVal) async {
                            if (newVal) {
                              context
                                  .read<StripeConnectCubit>()
                                  .getLink(currentBrand);

                              var result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => OnboardingWebView()),
                              );
                              /*
                              if (result != null) {
                                currentBrand.isVerified = result.isVerified;
                                currentBrand.stripeAccountId =
                                    result.stripeAccountId;
                                currentBrand.stripeActivated = true;
                                isStripeActive = true;
                              }*/
                              currentBrand.stripeAccountId =
                                  await _brandDataService
                                      .getBrandStripeAccount(currentBrand.id!);
                              if (currentBrand.stripeAccountId != '') {
                                isStripeActive = true;
                              }
                            } else {
                              if (isStripeActive && !currentBrand.isVerified) {
                                context
                                    .read<StripeConnectCubit>()
                                    .getLink(currentBrand);

                                var result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          OnboardingWebView()),
                                );
                                if (result != null &&
                                    result is UserStripeModel) {
                                  currentBrand = currentBrand;
                                }
                                currentBrand.stripeAccountId =
                                    await _brandDataService
                                        .getBrandStripeAccount(
                                            currentBrand.id!);
                                if (currentBrand.stripeAccountId != '') {
                                  isStripeActive = true;
                                }
                              } else {
                                isStripeActive = newVal;
                              }
                            }
                            setState(() {});
                          }
                        : null,
                    trackColor: Colors.green.withOpacity(0.4),
                    thumbColor: AppColors.white,
                    activeColor: currentBrand.stripeActivated == null
                        ? Colors.green.withOpacity(0.4)
                        : currentBrand.stripeActivated! &&
                                currentBrand.isVerified
                            ? Colors.green
                            : Colors.yellow,
                  ),
                ),
              ],
            )),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.stripeAccountDescription,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
      ],
    );
  }
}
