import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/Promotions/PromotionsDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Subscription.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectDaysDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectMembersDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectTimeDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/PayWall/ActiveSubscription.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/PayWall/PayWall.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/012-Logo/Logo.dart';

import '../../../../../Globals/Widgets/GroupOfComponents/PayWall/cubitSuscription/BrandSuscriptionCubit.dart';

// Tus Datos Widget.
class BrandInfo extends StatefulWidget {
  Locale? locale;
  String brandId;
  bool pinned;
  ValueChanged<bool?> pinnedChanged;
  BrandInfo({Key? key, this.locale, required this.brandId, required this.pinned, required this.pinnedChanged}) : super(key: key);

  @override
  _BrandInfoState createState() => _BrandInfoState();
}

class _BrandInfoState extends State<BrandInfo> with SingleTickerProviderStateMixin {

  DateFormat formatter = DateFormat('dd/MM/yy');
  // DataBase Access
  final _brandDataService = BrandDataService();
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
  // Max Members Brand
  TextEditingController membersController = TextEditingController();
  int members = 1;
  int membersMax = 30;
  bool errorMembers = false;
  // Time Picker Horari de Trabajo
  DateTime startTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 0);
  DateTime endTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 22, 0);
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  final List<double> _workShift = [];
  int? errorTime;
  // Descansos
  DateTime breakStartTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 13, 0);
  DateTime breakEndTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 14, 0);
  TimeOfDay _breakStartTime = const TimeOfDay(hour: 13, minute: 00);
  TimeOfDay _breakEndTime = const TimeOfDay(hour: 14, minute: 00);
  TextEditingController breakStartTimeController = TextEditingController();
  TextEditingController breakEndTimeController = TextEditingController();
  final List<TimeOfDay> _breakList = [];
  List<int> removedIndex = [];
  int breakLimit = 2;
  bool errorBreakTime = false;
  List<int> startBreaks = [];
  // Booking Window
  int bookingWindow = 3;
  int difference = 0;

  bool ShowTextExpired = true;

  // App Bar and Scroll View
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    return _scrollController!.hasClients && _scrollController!.offset > (MediaQuery.of(context).size.height*0.15 - kToolbarHeight);
  }

  @override
  void initState() {
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
    canEdit = currentUser.brandRole < 2 ? true : false;
    initBrand();
  }

  // Gets the user info from firebase.
  void initBrand() {
    // Name Description
    nameBrandController.text = currentBrand.name!;
    descriptionController.text = currentBrand.description!;
    // Members Deprecated
    members = currentBrand.maxMembers!;
    membersController.text = currentBrand.maxMembers.toString();
    // Start Time
    var startHourWS = int.parse(currentBrand.workShift[0].toStringAsFixed(2).split(".")[0]);
    var startMinWS = int.parse(currentBrand.workShift[0].toStringAsFixed(2).split(".")[1]);
    startTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, startHourWS, startMinWS);
    startTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, startHourWS, startMinWS,));
    //print(startHourWS);
    //print(startMinWS);
    //print(startTime.toString());
    // End Time
    var endHourWS = int.parse(currentBrand.workShift[1].toStringAsFixed(2).split(".")[0]);
    var endMinWS = int.parse(currentBrand.workShift[1].toStringAsFixed(2).split(".")[1]);
    endTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, endHourWS, endMinWS);
    endTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, endHourWS, endMinWS,));
    //print(endHourWS);
    //print(endMinWS);
    //print(endTime.toString());
    /* Break Time
    for (var i=2; i < currentBrand.workShift.length ; i+=2) {
      var start = currentBrand.workShift[i];
      int s = start.toInt();
      startBreaks.add(s);
      var startHour = int.parse(start.toStringAsFixed(2).split(".")[0]);
      var startMin = int.parse(start.toStringAsFixed(2).split(".")[1]);
      var end = currentBrand.workShift[i+1];
      int e = end.toInt();
      startBreaks.add(e);
      var endHour = int.parse(end.toStringAsFixed(2).split(".")[0]);
      var endMin = int.parse(end.toStringAsFixed(2).split(".")[1]);
      breakStartTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, startHour, startMin);
      _breakStartTime = TimeOfDay(hour: startHour, minute: startMin);
      breakEndTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, endHour, endMin);
      _breakEndTime = TimeOfDay(hour: endHour, minute: endMin);
      // Array of Breaks
      _breakList.add(_breakStartTime);
      _breakList.add(_breakEndTime);
    }
    breakStartTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 13, 0,));
    breakEndTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 14, 0,));
    */
    // Booking Window
    bookingWindow = currentBrand.bookingWindow!;
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
    print("saved");
  }

  Future<void> navigateToEditLogoScreen() async {
    if (canEdit) {
      mixpanel!.track('brand_info_logo_change');
      await Navigator.push(
          context,
          CupertinoPageRoute<void>(
            builder: (context) => Logo(
                brandId: currentBrand.id!
            ),
          )
      ).whenComplete(() async {
        await getBrand();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      var startHourWS = int.parse(currentBrand.workShift[0].toStringAsFixed(2).split(".")[0]);
      var startMinWS = int.parse(currentBrand.workShift[0].toStringAsFixed(2).split(".")[1]);
      var endHourWS = int.parse(currentBrand.workShift[1].toStringAsFixed(2).split(".")[0]);
      var endMinWS = int.parse(currentBrand.workShift[1].toStringAsFixed(2).split(".")[1]);
      if (nameBrandControllerTemp.trim() != currentBrand.name! && nameBrandControllerTemp != "") {
        print(1);
        isUpdated = true;
        mixpanel!.track('brand_info_name_change');
      } else if (descriptionControllerTemp.trim() != currentBrand.description! && descriptionControllerTemp != "") {
        print(2);
        isUpdated = true;
        mixpanel!.track('brand_info_description_change');
      } else if (startTimeController.text != DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, startHourWS, startMinWS,)) || endTimeController.text != DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, endHourWS, endMinWS,))) {
        print(3);
        isUpdated = true;
        mixpanel!.track('brand_info_workshit_change');
      } else if (currentBrand.bookingWindow! != bookingWindow) {
        print(4);
        isUpdated = true;
        mixpanel!.track('brand_info_booking_window_change');
      } else {
        isUpdated = false;
      }
    }
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.darkGrey,
            expandedHeight: MediaQuery.of(context).size.height*0.15,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            elevation: 4,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.darkGrey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.025),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.information,
                            style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white,),
                          ),
                          FittedBox(
                            fit: BoxFit.fitHeight,
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height*0.08,
                              width: MediaQuery.of(context).size.width*0.11,
                              child: TextButton(
                                onPressed: null,
                                child: Icon(
                                  Icons.filter_list,
                                  color: AppColors.darkGrey,
                                  size: MediaQuery.of(context).size.width*0.07,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.01,),
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
            title: appBarExpanded ? Text(AppLocalizations.of(context)!.information, style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(color: AppColors.white,)) : Container(),
            centerTitle: true,
            leading: Builder(
              builder: (BuildContext innerContext) => Padding(
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.02),
                child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: AppColors.white,
                      size: MediaQuery.of(context).size.height*0.04,
                    ),
                    onPressed: () => mambaProScaffoldKey.currentState?.openDrawer()
                ),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.01),
                child: IconButton(
                  icon: Icon(
                    widget.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: widget.pinned ? AppColors.red :  AppColors.white.withOpacity(0.5),
                    size: MediaQuery.of(context).size.width*0.06,
                  ),
                  onPressed: () {
                    if (widget.pinned == true) {
                      mixpanel!.track('brand_info_pinned_off');
                    } else {
                      mixpanel!.track('brand_info_pinned_on');
                    }
                    setState(() {
                      widget.pinned = !widget.pinned;
                    });
                    widget.pinnedChanged(widget.pinned);
                  },
                ),
              ),
            ],
          ),
          isLoading ? SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                Expanded(
                  child: SizedBox(
                      height: MediaQuery.of(context).size.height*0.65,
                      child: Center(
                          child: LoadingView()
                      )
                  ),
                ),
              ],
            ),
          ) : SliverToBoxAdapter(
            child: Column(
              children: [
                currentUser.brandRole < 2 ? BlocBuilder<BrandSuscriptionCubit, BrandSuscriptionState>(
                    builder: (context, state) {
                      switch (state.runtimeType) {
                        case BrandSuscriptionInitial:
                          return const SizedBox(height: 10);
                        case BrandSuscriptionLoading:
                          return const SizedBox(height: 10);
                        case BrandSuscriptionLoadedTrue:
                          final suscriptionState = state as BrandSuscriptionLoadedTrue;
                          difference = suscriptionState.subscription.endDate!.toDate().difference(DateTime.now()).inDays;
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height*0.03),
                                Text(
                                  AppLocalizations.of(context)!.yourPlan,
                                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height*0.03),
                                suscriptionState.subscription.subscriptionId  == '7DAYSTRIAL'? freeTrialMamba() : GestureDetector(
                                  onTap: () async {
                                    mixpanel!.track('brand_see_active_subscription');
                                    await Navigator.push(
                                        context,
                                        CupertinoPageRoute<bool?>(
                                          builder: (context) =>
                                              ActiveSubscription(
                                                brandId: currentBrand.id!,
                                                subscription: suscriptionState.subscription,
                                              ),
                                        )
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.04),
                                    height: MediaQuery.of(context).size.height*0.1,
                                    width: MediaQuery.of(context).size.width*0.9,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                      border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 2),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                            borderRadius: BorderRadius.circular(0),
                                            child: Image.asset(Constants.subscriptionImage, width: MediaQuery.of(context).size.width*0.12, fit: BoxFit.cover,)
                                        ),
                                        SizedBox(width: MediaQuery.of(context).size.width*0.05),
                                        Flexible(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                suscriptionState.subscription.title!,
                                                style: Theme.of(context).textTheme.headline3!.copyWith(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                              Text(
                                                AppLocalizations.of(context)!.seeyourSub,
                                                style: Theme.of(context).textTheme.caption!.copyWith(color: Theme.of(context).colorScheme.secondary),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: MediaQuery.of(context).size.width*0.05),
                                      ],
                                    ),
                                  ),

                                ),
                                SizedBox(height: MediaQuery.of(context).size.height*0.03),
                                Divider(color: Theme.of(context).backgroundColor, thickness: 2, indent: MediaQuery.of(context).size.width*0.05, endIndent: MediaQuery.of(context).size.width*0.05),
                                //SizedBox(height: MediaQuery.of(context).size.height*0.01),
                              ],
                            ),
                          );
                        case BrandSuscriptionLoadedFalse:
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height*0.03),
                                Text(
                                  AppLocalizations.of(context)!.yourPlan,
                                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height*0.03),
                                GestureDetector(
                                  onTap: navigateToSubscriptionsScreen,
                                  child: Container(
                                    padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.05),
                                    height: MediaQuery.of(context).size.height*0.1,
                                    width: MediaQuery.of(context).size.width*0.9,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                      border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 2),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          Icons.new_releases,
                                          color: Theme.of(context).colorScheme.secondary,
                                          size: MediaQuery.of(context).size.width*0.10,
                                        ),
                                        SizedBox(width: MediaQuery.of(context).size.width*0.05),
                                        Flexible(
                                          child:  textToShow(),
                                        ),
                                        SizedBox(width: MediaQuery.of(context).size.width*0.05),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height*0.03),
                                Divider(color: Theme.of(context).backgroundColor, thickness: 2, indent: MediaQuery.of(context).size.width*0.05, endIndent: MediaQuery.of(context).size.width*0.05),
                                //SizedBox(height: MediaQuery.of(context).size.height*0.01),
                              ],
                            ),
                          );
                        default:
                          return const SizedBox(height: 10);
                      }
                    }
                ) : const SizedBox(height: 10),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.width*0.07),
                    child: Form(
                      key: formKeyInfo,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.logo,
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.28,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: GestureDetector(
                                onTap: navigateToEditLogoScreen,
                                child: CircularImage(
                                  size: MediaQuery.of(context).size.height * 0.25,
                                  image: currentBrand.logoUrl!,
                                  borderWidth: 1,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.02),
                          Text(
                            AppLocalizations.of(context)!.nameBrand,
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Flexible(
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: nameBrandController,
                              onChanged: (value) {
                                setState(() {
                                  nameBrandControllerTemp = value;
                                });
                              },
                              validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.nameBrandError : null,
                              style: Theme.of(context).textTheme.headline1?.copyWith(fontWeight: FontWeight.normal),
                              textAlign: TextAlign.center,
                              textCapitalization: TextCapitalization.words,
                              enabled: canEdit,
                              decoration: InputDecoration(
                                hintStyle: Theme.of(context).textTheme.caption,
                                hintText: AppLocalizations.of(context)!.nameBrandError,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!.createBrandDescDescription,
                                  style: Theme.of(context).textTheme.caption,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.02),
                          Text(
                            AppLocalizations.of(context)!.description,
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Flexible(
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: descriptionController,
                              onChanged: (value) {
                                setState(() {
                                  descriptionControllerTemp = value;
                                });
                              },
                              validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.descriptionError : null,
                              minLines: 1,
                              maxLines: 5,
                              maxLength: 250,
                              enabled: canEdit,
                              style: Theme.of(context).textTheme.bodyText2,
                              decoration: InputDecoration(
                                hintStyle: Theme.of(context).textTheme.caption,
                                hintText: AppLocalizations.of(context)!.descriptionError,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.04),
                          /*
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.maxNumberClientsError,
                                style: Theme.of(context).textTheme.caption,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.02),
                        Text(
                          AppLocalizations.of(context)!.maxNumberClients,
                          style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.01),
                        GestureDetector(
                            onTap: () {
                              selectSlot(context, 2, null);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                new Flexible(
                                  child: TextFormField(
                                    controller: membersController,
                                    minLines: 1,
                                    readOnly: true,
                                    enabled: false,
                                    style: Styles.purpleTextStyle,
                                    decoration: InputDecoration(
                                      hintStyle: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Colors.grey),
                                      hintText: AppLocalizations.of(context)!.maxNumberClientsError,
                                      labelStyle: Styles.purpleTextStyle,
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
                        errorMembers ? Text(
                          AppLocalizations.of(context)!.maxNumberClientsError,
                          style: Styles.redTextStyle.copyWith(fontSize: 12),
                        ) : new Container(),
                        SizedBox(height: MediaQuery.of(context).size.height*0.03),
                        */
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!.createBrandWorkshiftDescription,
                                  style: Theme.of(context).textTheme.caption,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.02),
                          Text(
                            AppLocalizations.of(context)!.workingHours,
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              TextButton(
                                onPressed: canEdit ? () async {
                                  DateTime? pickedTimeTemp =  await showCupertinoModalPopup(
                                      context: context,
                                      builder: (_) => SelectTimeDialog(
                                        title: AppLocalizations.of(context)!.selectTime,
                                        startDate: startTime,
                                        onlyFuture: false,
                                      )
                                  );
                                  if (pickedTimeTemp != null) {
                                    setState(() {
                                      startTime = pickedTimeTemp;
                                      startTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, startTime.hour, startTime.minute,));
                                    });
                                  }
                                } : null,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                                    border: Border.all(color: Theme.of(context).primaryColor, width: 1.0),
                                    color: Colors.transparent,
                                  ),
                                  child: Text(
                                    startTimeController.text,
                                    style: Theme.of(context).textTheme.headline3,
                                  ),
                                ),
                              ),
                              Text("-",
                                  style: Theme.of(context).textTheme.headline3),
                              TextButton(
                                onPressed: canEdit ? () async {
                                  DateTime? pickedTimeTemp =  await showCupertinoModalPopup(
                                      context: context,
                                      builder: (_) => SelectTimeDialog(
                                        title: AppLocalizations.of(context)!.selectTime,
                                        startDate: endTime,
                                        onlyFuture: false,
                                      )
                                  );
                                  if (pickedTimeTemp != null) {
                                    setState(() {
                                      endTime = pickedTimeTemp;
                                      endTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, endTime.hour, endTime.minute,));
                                    });
                                  }
                                } : null,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(const Radius.circular(5)),
                                    border: Border.all(color: Theme.of(context).primaryColor, width: 1.0),
                                    color: Colors.transparent,
                                  ),
                                  child: Text(
                                      endTimeController.text,
                                      style: Theme.of(context).textTheme.headline3
                                  ),
                                ),
                              ),
                            ],
                          ),
                          errorTime != null ? Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10, top: 5.0, bottom: 0),
                            child: Text(
                              errorTime == 1 ? AppLocalizations.of(context)!.workingHoursError : AppLocalizations.of(context)!.workingHoursError1,
                              style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                              textAlign: TextAlign.center,
                            ),
                          ) : Container(),
                          SizedBox(height: MediaQuery.of(context).size.height*0.04),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!.bookingWindowDescription,
                                  style: Theme.of(context).textTheme.caption,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.02),
                          Text(
                            AppLocalizations.of(context)!.bookingWindow,
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.02),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: GestureDetector(
                              onTap: canEdit ? () {
                                selectNumberOfDays();
                              } : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                                  border: Border.all(color: Theme.of(context).primaryColor, width: 1.0),
                                  color: Colors.transparent,
                                ),
                                height: MediaQuery.of(context).size.width*0.1,
                                width: MediaQuery.of(context).size.width*0.2,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      bookingWindow.toString()+" "+AppLocalizations.of(context)!.days.toLowerCase(),
                                      style: Theme.of(context).textTheme.headline3,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          /*
                        SizedBox(height: MediaQuery.of(context).size.height*0.04),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.createBrandBreakDescription,
                                style: Theme.of(context).textTheme.caption,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.02),
                        Text(
                          AppLocalizations.of(context)!.lunchBreak,
                          style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.01),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width * 0.43,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  TextButton(
                                    onPressed: _breakList.length < breakLimit ? () async {
                                      DateTime? pickedTimeTemp =  await showCupertinoModalPopup(
                                          context: context,
                                          builder: (_) => SelectTimeDialog(
                                            title: AppLocalizations.of(context)!.selectTime,
                                            startDate: breakStartTime,
                                            onlyFuture: false,
                                          )
                                      );
                                      if (pickedTimeTemp != null) {
                                        setState(() {
                                          breakStartTime = pickedTimeTemp;
                                          breakStartTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, breakStartTime.hour, breakStartTime.minute,));
                                        });
                                      }
                                    } : null,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(const Radius.circular(5)),
                                        border: Border.all(color: _breakList.length < breakLimit ? Theme.of(context).primaryColor : Colors.grey, width: 1.0),
                                        color: Colors.transparent,
                                      ),
                                      child: Text(
                                        breakStartTimeController.text,
                                        style: Theme.of(context).textTheme.headline3?.copyWith(color: _breakList.length < breakLimit ? Theme.of(context).primaryColor : Colors.grey),
                                      ),
                                    ),
                                  ),
                                  Text("-", style: Theme.of(context).textTheme.headline3?.copyWith(color: _breakList.length < breakLimit ? Theme.of(context).primaryColor : Colors.grey),),
                                  TextButton(
                                    onPressed: _breakList.length < breakLimit ? () async {
                                      DateTime? pickedTimeTemp = await showCupertinoModalPopup(
                                          context: context,
                                          builder: (_) => SelectTimeDialog(
                                            title: AppLocalizations.of(context)!.selectTime,
                                            startDate: breakEndTime,
                                            onlyFuture: false,
                                          )
                                      );
                                      if (pickedTimeTemp != null) {
                                        setState(() {
                                          breakEndTime = pickedTimeTemp;
                                          breakEndTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, breakEndTime.hour, breakEndTime.minute,));
                                        });
                                      }
                                    } : null,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(const Radius.circular(5)),
                                        border: Border.all(color: _breakList.length < breakLimit ? Theme.of(context).primaryColor : Colors.grey, width: 1.0),
                                        color: Colors.transparent,
                                      ),
                                      child: Text(
                                        breakEndTimeController.text,
                                        style: Theme.of(context).textTheme.headline3?.copyWith(color: _breakList.length < breakLimit ? Theme.of(context).primaryColor : Colors.grey),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _breakList.length < breakLimit ? Padding(
                              padding: const EdgeInsets.only(left: 0.0),
                              child: OutlinedButton(
                                onPressed: () {
                                  double toDouble(DateTime myTime) => myTime.hour + myTime.minute/100.0;
                                  if (toDouble(DateFormat('HH:mm', widget.locale!.languageCode).parse(breakStartTimeController.text)) > toDouble(DateFormat('HH:mm', widget.locale!.languageCode).parse(breakEndTimeController.text))){
                                    setState(() {
                                      errorBreakTime = true;
                                    });
                                  } else {
                                    DateTime start = DateFormat('HH:mm', widget.locale!.languageCode).parse(breakStartTimeController.text);
                                    DateTime end = DateFormat('HH:mm', widget.locale!.languageCode).parse(breakEndTimeController.text);
                                    _breakStartTime = TimeOfDay(hour: start.hour, minute: start.minute);
                                    _breakEndTime = TimeOfDay(hour: end.hour, minute: end.minute);
                                    setState(() {
                                      errorBreakTime = false ;
                                      _breakList.clear();
                                      _breakList.add(_breakStartTime);
                                      _breakList.add(_breakEndTime);
                                    });
                                  }
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon( Icons.add, color: Colors.white, size: 30,),
                                  ],
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  elevation: 3,
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(5),
                                ),
                              ),
                            ) : Container(),
                          ],
                        ),
                        errorBreakTime ? Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10, top: 5.0, bottom: 0),
                          child: Text(
                            AppLocalizations.of(context)!.workingHoursError1,
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                            textAlign: TextAlign.center,
                          ),
                        ) : Container(),
                        SizedBox(height: MediaQuery.of(context).size.height*0.01),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _breakList.length,
                          itemBuilder: (context, int index) {
                            if(index.isEven && !removedIndex.contains(index)) {
                              return Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.43,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        TextButton(
                                          onPressed: false ? () {
                                          } : null,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.all(const Radius.circular(5)),
                                              border: Border.all(color: Colors.green, width: 1.0),
                                              color: Colors.transparent,
                                            ),
                                            child: Text(
                                              '${_breakList[index].format(context)}',
                                              style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.green),
                                            ),
                                          ),
                                        ),
                                        Text("-", style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.green),),
                                        TextButton(
                                          onPressed: false ? () {
                                          } : null,
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.all(const Radius.circular(5)),
                                              border: Border.all(color: Colors.green, width: 1.0),
                                              color: Colors.transparent,
                                            ),
                                            child: Text(
                                              '${_breakList[index+1].format(context)}',
                                              style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.green),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 0.0),
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          removedIndex.add(index);
                                          removedIndex.add(index+1);
                                          breakLimit += 2;
                                        });
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon( Icons.remove, color: Colors.white, size: 30,),
                                        ],
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        elevation: 3,
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(5),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(AppLocalizations.of(context)!.lunchBreakAdded, style: Theme.of(context).textTheme.bodyText2?.copyWith(fontStyle: FontStyle.italic), textAlign: TextAlign.center,),
                                  ),
                                ],
                              );
                            } else {
                              return Container();
                            }
                          },
                          shrinkWrap: true,
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.01),
                        _breakList.length < breakLimit ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.createBrandAddDescription,
                                style: Theme.of(context).textTheme.bodyText2,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ) : Container(),
                         */
                          SizedBox(height: MediaQuery.of(context).size.height*0.10),
                        ],
                      ),
                    )
                ),
              ],
            ),
          ),

        ],
      ),
      floatingActionButton: isUpdated ? Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
        child: FloatingActionButton.extended(
          heroTag: "81",
          onPressed: () async {
            if (validateInfo()) {
              setState(() {
                errorTime == null;
                errorBreakTime == false;
                isLoading = true;
              });
              DateTime start = DateFormat('HH:mm', widget.locale!.languageCode).parse(startTimeController.text);
              DateTime end = DateFormat('HH:mm', widget.locale!.languageCode).parse(endTimeController.text);
              double toDouble(DateTime myTime) => myTime.hour + myTime.minute/100;
              // Reset Workshift
              _workShift.clear();
              _workShift.add(toDouble(start));
              _workShift.add(toDouble(end));
              /*
              for (var i=0; i < _breakList.length; i+=2) {
                if(!removedIndex.contains(i)) {
                  _workShift.add(toDouble2(_breakList[i]));
                  _workShift.add(toDouble2(_breakList[i+1]));
                }
              }
               */
              await _brandDataService.updateBrandInfo(widget.brandId, nameBrandController.text, descriptionController.text, members, _workShift, bookingWindow);
              await getBrand();
              mixpanel!.track('brand_info_changes_done');
            }
          },
          backgroundColor: Colors.green,
          icon: Icon(Icons.save_rounded, color: Colors.white, size: MediaQuery.of(context).size.width*0.05,),
          label: Text(AppLocalizations.of(context)!.save,
            style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.white),),
        ),
      ) : Container(),
    );
  }

  Future selectNumberOfDays() async {
    int? pickedMembers =  await showCupertinoModalPopup(
        context: context,
        builder: (_) => SelectDaysDialog(
          title: AppLocalizations.of(context)!.select+" "+AppLocalizations.of(context)!.days.toLowerCase()
          ,
          intialDays: bookingWindow-1,
        )
    );
    if (pickedMembers != null) {
      setState(() {
        bookingWindow = pickedMembers;
      });
    }
  }

  Future<void> navigateToSubscriptionsScreen() async {
      mixpanel!.track('brand_see_paywall');
      await navigateToPayWall(context);
  }

  Widget textToShow()
  {
    return   Text(ShowTextExpired? AppLocalizations.of(context)!.subscriptionExpired : AppLocalizations.of(context)!.noSubscription,  style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).colorScheme.secondary), textAlign: TextAlign.center,);
  }

  bool validateInfo() {
    DateTime start = DateFormat('HH:mm', widget.locale!.languageCode).parse(startTimeController.text);
    DateTime end = DateFormat('HH:mm', widget.locale!.languageCode).parse(endTimeController.text);
    double toDouble(DateTime myTime) => myTime.hour + myTime.minute / 100.0;
    if (!formKeyInfo.currentState!.validate()) {
      return false;
    }
    if (membersController.text.isEmpty) {
      setState(() {
      errorMembers = true;
      });
      return false;
    }
    if (TimeOfDay(hour: start.hour, minute: start.minute) == const TimeOfDay(hour: 0, minute: 00) && TimeOfDay(hour: end.hour, minute: end.minute) == const TimeOfDay(hour: 23, minute: 00)) {
      setState(() {
        errorTime = 1;
      });
      return false;
    }
    if (toDouble(start) > toDouble(end)) {
      setState(() {
        errorTime = 2;
      });
      return false;
    }
    setState(() {
      errorTime == null;
      errorMembers = false;
    });
    return true;
  }

  Widget freeTrialMamba()
  {
    return GestureDetector(
      onTap: () async {
        await navigateToPayWall(context);
      },
      child: Container(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.01),
        height: MediaQuery.of(context).size.height*0.1,
        width: MediaQuery.of(context).size.width*0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
          border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.6), width: 2),
        ),
        child: Center(
          child: ListTile(
            title: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width*0.01),
              child: Text(
                  AppLocalizations.of(context)!.chooseYourPlan,
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyText1!.copyWith(color: AppColors.mainColor, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left
              ),
            ),
            subtitle: Text(
              AppLocalizations.of(context)!.freeTrialDaysLeft(difference.toString()),
              style: Theme
                  .of(context)
                  .textTheme
                  .caption!.copyWith(color: AppColors.mainColor, fontWeight: FontWeight.normal, fontSize: 12),
            ),
            trailing: GestureDetector(
              onTap: () async {
                await navigateToPayWall(context);
              },
              child: Container(
                height: MediaQuery.of(context).size.height*0.05,
                width: MediaQuery.of(context).size.width*0.2,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Center(child: Text(
                  AppLocalizations.of(context)!.subscriptionsAppBar,
                  style: Theme
                      .of(context)
                      .textTheme
                      .caption!.copyWith(color:  AppColors.white, fontWeight: FontWeight.bold, fontSize: 15),
                )),
              ),
            ),
            dense: true,
          ),
        ),
      ),
    );
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
            context,
            CupertinoPageRoute<bool?>(
              builder: (context) =>
                  PayWall(
                    brandId: currentBrand.id!,
                  ),
            )
        );
      },
      child: Material(
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.35,
            maxWidth: MediaQuery.of(context).size.width*0.9,
            minWidth: MediaQuery.of(context).size.width*0.9,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(15.0)),// BorderRadius
          ),// BoxDecoration
          child: Container(
            margin: const EdgeInsetsDirectional.only(start: 1, end: 1, bottom: 1, top: 1),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height,
              maxWidth: MediaQuery.of(context).size.width*0.9,
              minWidth: MediaQuery.of(context).size.width*0.9,
            ),
            padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(15.0)),// BorderRadius
            ),// BoxDecoration
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      Constants.subscriptionImage,),

                  ),
                  title: Text(
                      'Disfruta de MAMBA SIN LIMITE',
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyText1,
                      textAlign: TextAlign.left
                  ),
                  subtitle: Text(
                      'Tienes hasta el ' + ' ' + formatter.format(currentBrand.endDatePay!.toDate()).toString() + ' para suscribirte a un plan',
                      style: Theme
                          .of(context)
                          .textTheme
                          .caption
                  ),
                  dense: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}

