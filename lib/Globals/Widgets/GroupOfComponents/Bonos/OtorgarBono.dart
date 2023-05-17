import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Payments/PaymentDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Payments/Purchase/PurchaseDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/BonoRequest.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Utils/Date/DateTimeUtils.dart';
import 'package:mamba_castelldefels/Globals/Utils/MultipleBrands/MultipleBrandsUtils.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/BonoCard.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/ClientBonoCard.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Calendars/SelectCalendar/SelectCalendarDate.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/ProfileView/ProfileUserView.dart';
import '../../../../Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/CalendarPopUpView.dart';
import '../../Components/TopSnackBar/TopSnackBar.dart';


class OtorgarBono extends StatefulWidget {
  Usuario user;
  Brand brand;
  bool? edit;
  Bono? bono;
  BonoRequest? bonoRequest;


  OtorgarBono({Key? key, required this.user, required this.brand, this.edit, this.bono, this.bonoRequest})
      : super(key: key);

  @override
  _OtorgarBonoState createState() => _OtorgarBonoState();
}

class _OtorgarBonoState extends State<OtorgarBono> {
  // Brand Service
  final _brandDataService = BrandDataService();
  final _paymentDataService = PaymentDataService();
  final _userDataService = UserDataService();
  final _purchaseDataService = PurchaseDataService();

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  DateTime dateJoined = DateTime.now();

  final NotificationService _notificationService = NotificationService();

  final formKeyInfo = GlobalKey<FormState>();

  // Title Controller
  var titleController = TextEditingController();
  FocusNode focusNodetitleController = FocusNode();
  var descriptionController = TextEditingController();
  FocusNode focusNodeDescController = FocusNode();
  var sessionsController = TextEditingController();
  FocusNode focusNodeSessionsController = FocusNode();
  var priceController = TextEditingController();
  FocusNode focusNodePriceController = FocusNode();
  var freeCancellController = TextEditingController();
  FocusNode focusNodeFreeCancelController = FocusNode();
  var weeklyController = TextEditingController();
  FocusNode focusNodeWeeklyController = FocusNode();
  var monthlyController = TextEditingController();
  var daysSelectorController = TextEditingController();

  // Booleans
  bool isLoading = false;
  bool isFirstBuild = true;

  // Payment Method
  Purchase purchase = Purchase();
  int? paymentMethod;
  String originalPaymentString = "";

  // Bottom Sheet
  bool canConfirm = false;

  Usuario user = Usuario();

  List<Bono> bonos = [];
  List<Bono> userBonos = [];

  Bono bonoSelected = Bono();
  bool isBonoSelected = false;

  int indexBono = 0;
  var _topSnackBar = TopSnackBar();

  bool editBono = false;
  bool seeConditions = false;

  List<bool> isSelectedDays = [false, false, false, false, false];

  bool noSessions = false;
  bool weekSessions = false;
  bool cancelTimeSessions = false;
  bool isBonoRequest = false;

  // Page View Controller
  int _numPages = 0;
  int? _currentPage;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    // EDIT BONO OR PURCHASE
    if (widget.edit != null && widget.edit == true) {
      mixpanel!.track('edit_bono_view');
      editBono = true;
    }
    // ACCEPT PURCHASE
    if (widget.bonoRequest != null) {
      mixpanel!.track('bono_confirmation_view');
      isBonoRequest = true;
      paymentMethod = widget.bonoRequest?.paymentMethod;
    } else {
      // GIFT BONO
      mixpanel!.track('give_bono_view');
      paymentMethod = 2;
    }
    getBonos();
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: isActive ? 6.0 : 4.0,
      width: isActive ? 6.0 : 4.0,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.5),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  Future<void> getPurchase() async {
    purchase = await _purchaseDataService.getPurchaseInfo(bonoSelected.purchaseId!);
    startDate = purchase.purchasedAt!.toDate();
    paymentMethod = purchase.paymentMethod;
    isFirstBuild = true;
    setConditionsBono(bonoSelected);
  }

  Future<void> getBonos() async {
    // Otorgar Bono
    if (!editBono && !isBonoRequest) {
      bonos = await _brandDataService.getAllBonosFromBrandList(currentBrand.id!);
      userBonos = await _userDataService.getUserBonos(user.id!);
      Bono bonoDelete;
      for (int i = 0; i < userBonos.length; ++i) {
        bonoDelete = bonos.firstWhere((element) => element.id == userBonos[i].id);
        if (bonoDelete.id != '') {
          bonos.remove(bonoDelete);
        }
      }
      bonos.removeWhere((element) => element.isActive == false);
      _numPages = bonos.length;
      if (bonos.isNotEmpty) {
        bonoSelected.setBasicData = bonos[0];
        bonoSelected.setConditionsData = bonos[0].condition!;
        _currentPage = 0;
        isBonoSelected = true;
        setConditionsBono(bonoSelected);
      }
    } else {
      // Edit Bono && Bono Request
      bonos.add(widget.bono!);
      bonoSelected.setBasicData = bonos[0];
      bonoSelected.setConditionsData = bonos[0].condition!;
      isBonoSelected = true;
      // Accept Bono Request
      if (isBonoRequest) {
        seeConditions = false;
        setConditionsBono(bonoSelected);
      } else {
        // Edit Bono Request
        seeConditions = true;
        await getPurchase();
      }
    }
    Future.delayed(Duration.zero, () async {
      dateJoined = DateTimeUtils().formatStringToDateTimeDDMMYY(user.dateJoined!, Localizations.localeOf(context).languageCode);
    });
    setState(() {});
  }

  void setConditionsBono(Bono _bono) {
    int? days = _bono.condition?.expirationTime!;
    priceController.text = _bono.price.toString();
    if(_bono.sessions! > 5000) {
      sessionsController.text = '';
      noSessions = true;
    } else {
      sessionsController.text = _bono.sessions.toString();
      noSessions = false;
    }
    freeCancellController.text = (_bono.condition?.cancelTime!).toString();
    weeklyController.text = (_bono.condition?.weeklySessions!).toString();
    sessionsController.text = (_bono.sessions!).toString();
    priceController.text = (_bono.price!).toStringAsFixed(2);
    isSelectedDays[0] = false;
    isSelectedDays[1] = false;
    isSelectedDays[2] = false;
    isSelectedDays[3] = false;
    isSelectedDays[4] = false;
    if (_bono.condition?.expirationTime == 0) {
      isSelectedDays[0] = true;
    } else {
      isSelectedDays[4] = true;
      endDate = startDate.add(Duration(days: days!));
    }
  }

  double roundDouble(double value, int places) {
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstBuild) {
      originalPaymentString = AppLocalizations.of(context)!.giftPaymentMethod;
      if (paymentMethod == 0) {
        originalPaymentString = AppLocalizations.of(context)!.cashPaymentMethod;
      } else if(paymentMethod == 1) {
        originalPaymentString = AppLocalizations.of(context)!.transferPaymentMethod;
      }
      isFirstBuild = false;
    }
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.1,
        title: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Container(
              height: MediaQuery.of(context).size.height * 0.007,
              width: MediaQuery.of(context).size.width * 0.15,
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.07,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                        editBono? AppLocalizations.of(context)!.editBono : AppLocalizations.of(context)!.acceptBono,
                        style: Theme.of(context).textTheme.headline1,
                        textAlign: TextAlign.left),
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 2,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child:  Text(!editBono? AppLocalizations.of(context)!.acceptBonoDesc : AppLocalizations.of(context)!.editBonoClientDesc,
                        style: Theme.of(context)
                            .textTheme
                            .caption
                            ?.copyWith(height: 1.5),
                        textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            /// USER
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: Text(AppLocalizations.of(context)!.user,
                        style: Theme.of(context).textTheme.headline1,
                        textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(10))
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  minLeadingWidth: MediaQuery.of(context).size.width * 0.1,
                  leading: CircularImage(
                    size: MediaQuery.of(context).size.width * 0.15,
                    image: widget.user.imageUrl,
                    color: Theme.of(context).primaryColor,
                    borderWidth: 1.0,
                  ),
                  title: Text(
                    widget.user.name!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.lastEventAt == null ? AppLocalizations.of(context)!.lastActiveIn(DateTimeUtils().formatDateTimeToStringMMMYYYY(dateJoined, Localizations.localeOf(context).languageCode)) :
                        AppLocalizations.of(context)!.lastActiveIn(DateTimeUtils().formatDateTimeToStringMMMYYYY(user.lastEventAt!.toDate(), Localizations.localeOf(context).languageCode)),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: isBonoRequest ? Theme.of(context).primaryColor : Theme.of(context).backgroundColor,
                      size: MediaQuery.of(context).size.height * 0.02,
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(0),
                    onPressed: false ? () {} : null,
                  ),
                  onTap: () async {
                    if (isBonoRequest) {
                      mixpanel!.track('bono_confirmation_user_page');
                      await Navigator.push(
                          context,
                          CupertinoPageRoute<bool?>(
                              builder: (context) =>
                                  ProfileViewUser(
                                    userID: widget.user.id!,
                                    viewOnly: false,
                                  )));
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            /// BONOS
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: Text(
                        AppLocalizations.of(context)!.bono,
                        style: Theme.of(context).textTheme.headline1,
                        textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
            bonos.length > 1 ? Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicator(),
                ),
                SizedBox(
                    height: MediaQuery.of(context).size.height*0.01
                ),
              ],
            ) : SizedBox(height: MediaQuery.of(context).size.height*0.01),
            !editBono || purchase.id == null ? Container(
              width: MediaQuery.of(context).size.width,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height*0.22,
                minHeight: MediaQuery.of(context).size.height*0.22,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: PageView.builder(
                        physics: const BouncingScrollPhysics(),
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(()  {
                            bonoSelected.setBasicData = bonos[page];
                            bonoSelected.setConditionsData = bonos[page].condition!;
                            isBonoSelected = true;
                            setConditionsBono(bonoSelected);
                            _currentPage = page;
                          });
                        },
                        itemCount: bonos.length,
                        itemBuilder: (context, index) {
                          Bono bono = bonos[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.08),
                            child:  BonoCard(
                                height: MediaQuery.of(context).size.height * 0.22,
                                width: MediaQuery.of(context).size.width * 0.84,
                                bono: bono,
                                brand: widget.brand,
                                canExpand: false,
                                onlyView: true,
                                hideActive: true,
                            ),
                          );
                        }
                    ),
                  ),
                ],
              ),
            ) :
            Container(
              width: MediaQuery.of(context).size.width,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height*0.22,
                minHeight: MediaQuery.of(context).size.height*0.22,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.08),
                    child: ClientBonoCard(
                      height: MediaQuery.of(context).size.height*0.22,
                      width: MediaQuery.of(context).size.width*0.84,
                      bono: bonoSelected,
                      brand: purchase.brand!,
                      purchase: purchase,
                      isExpanded: false,
                      canExpand: false,
                      onlyView: true,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            /// CONDITIONS
            !editBono ? Padding(
              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04, right: MediaQuery.of(context).size.width * 0.04),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    child: Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.personalizeBonoUser(widget.user.firstName!),
                          //style: Theme.of(context).textTheme.bodyText1?.copyWith(decoration: TextDecoration.underline, height: 1.5),
                          style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.normal),
                        ),
                        Icon(seeConditions ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: MediaQuery.of(context).size.width*0.08, color: Theme.of(context).primaryColor),
                      ],
                    ),
                    style: TextButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                    ),
                    onPressed: editBono? null : () async {
                      setState(() {
                        seeConditions = !seeConditions;
                      });
                    },
                  ),
                ],
              ),
            ) : Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.03,
                  left: MediaQuery.of(context).size.width * 0.05,
                  right: MediaQuery.of(context).size.width * 0.05,
                  bottom: MediaQuery.of(context).size.height * 0.02
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.conditions,
                    //style: Theme.of(context).textTheme.bodyText1?.copyWith(decoration: TextDecoration.underline, height: 1.5),
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ],
              ),
            ),
            seeConditions ? Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Form(
                key: formKeyInfo,
                child: Column(
                  children: [
                    /// SESSIONS
                    Container(
                      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                      decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          borderRadius: const BorderRadius.all(Radius.circular(10))
                      ),
                      child: optionTextWrite(
                          TextInputType.number,
                          AppLocalizations.of(context)!.sessions,
                          AppLocalizations.of(context)!.sesionsBonoDesc,
                          AppLocalizations.of(context)!.sessionHint,
                          AppLocalizations.of(context)!.sessionPlease,
                          true,
                          sessionsController,
                          focusNodeSessionsController,
                          false,
                          'ses',
                      false),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    /// PRICE
                    Container(
                      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                      decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          borderRadius: const BorderRadius.all(Radius.circular(10))
                      ),
                      child: optionTextWrite(
                          const TextInputType.numberWithOptions(decimal: true),
                          AppLocalizations.of(context)!.price,
                          "",
                          AppLocalizations.of(context)!.priceHint,
                          AppLocalizations.of(context)!.pricePlease,
                          true,
                          priceController,
                          focusNodePriceController,
                          false,
                          'price',
                      false),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    /// EXPIRATION DATE
                    Container(
                      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                      decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        borderRadius: const BorderRadius.all(Radius.circular(10))
                      ),
                      child: optionConditionsWrite(
                        TextInputType.text,
                        AppLocalizations.of(context)!.expireDate,
                        AppLocalizations.of(context)!.expiresAtDesc,
                        AppLocalizations.of(context)!.titleError,
                        AppLocalizations.of(context)!.titleError,
                        AppLocalizations.of(context)!.titleError,
                        true,
                        titleController,
                        null,
                        'expEdit',
                        false
                      )
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    /// WEEKLY SESSIONS
                    Container(
                      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                      decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          borderRadius: const BorderRadius.all(Radius.circular(10))
                      ),
                      child: optionConditionsWrite(
                          TextInputType.number,
                          AppLocalizations.of(context)!.trainsPerWeek,
                          AppLocalizations.of(context)!.trainsPerWeekDesc,
                          AppLocalizations.of(context)!.sessionHint,
                          AppLocalizations.of(context)!.sessionPlease,
                          AppLocalizations.of(context)!.trainsPerWeekError,
                          true,
                          weeklyController,
                          focusNodeWeeklyController,
                          'maxw',
                          false
                      ),
                    ),
                    /// CANCEL TIME
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Container(
                      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                      decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        borderRadius: const BorderRadius.all(Radius.circular(10))
                      ),
                      child: optionConditionsWrite(
                          TextInputType.number,
                          AppLocalizations.of(context)!.freeCancel,
                          AppLocalizations.of(context)!.freeCancelDesc,
                          AppLocalizations.of(context)!.freeCancelHint,
                          AppLocalizations.of(context)!.freeCancelError,
                          AppLocalizations.of(context)!.freeCancelErrorSecond,
                          true,
                          freeCancellController,
                          focusNodeFreeCancelController,
                          'canFree',
                          false
                      ),
                    ),
                  ],
                ),
              )
            ) : Container(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            /// PAYMENT METHOD
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: Text(
                        AppLocalizations.of(context)!.paymentMethod,
                        style: Theme.of(context).textTheme.headline1,
                        textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
            !editBono ? Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyText2,
                  children: [
                    TextSpan(
                        text: widget.user.firstName! + AppLocalizations.of(context)!.paymentIndication,
                        style: Theme.of(context).textTheme.caption?.copyWith(height: 1.5)),
                    TextSpan(
                      text: originalPaymentString,
                      style: Theme.of(context).textTheme.caption?.copyWith(fontWeight: FontWeight.bold, height: 1.5),
                    ),
                    TextSpan(
                        text: ". " + AppLocalizations.of(context)!.paymentMethodConfirm,
                        style: Theme.of(context).textTheme.caption?.copyWith(height: 1.5)
                    ),
                  ],
                ),
              ),
            ) :
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyText2,
                  children: [
                    TextSpan(
                        text: AppLocalizations.of(context)!.paymentMethodOriginal,
                        style: Theme.of(context).textTheme.caption?.copyWith(height: 1.5)),
                    TextSpan(
                      text: originalPaymentString,
                      style: Theme.of(context).textTheme.caption?.copyWith(fontWeight: FontWeight.bold, height: 1.5),
                    ),
                    TextSpan(
                        text: ". " + AppLocalizations.of(context)!.paymentMethodEdit,
                        style: Theme.of(context).textTheme.caption?.copyWith(height: 1.5)
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        paymentMethod = 0;
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.05),
                          height:
                              MediaQuery.of(context).size.width * 0.25,
                          width:
                              MediaQuery.of(context).size.width * 0.25,
                          decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: paymentMethod == 0 ? 5 : 1),
                          ),
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: Image(
                              image: AssetImage(Constants.imageCash),
                              opacity: AlwaysStoppedAnimation(
                                  paymentMethod == 1 ? 100 : 1),
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height *
                                0.01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .cashPaymentMethod,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline3
                                  ?.copyWith(
                                      color: paymentMethod == 1
                                          ? Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.5)
                                          : Theme.of(context)
                                              .primaryColor),
                              textAlign: TextAlign.center,
                            ),
                            paymentMethod == 0
                                ? Icon(
                                    Icons.check_circle,
                                    color:
                                        Theme.of(context).primaryColor,
                                  )
                                : Container(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        paymentMethod = 1;
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.05),
                          height:
                              MediaQuery.of(context).size.width * 0.25,
                          width:
                              MediaQuery.of(context).size.width * 0.25,
                          decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: paymentMethod == 1 ? 5 : 1),
                          ),
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: Image(
                              image:
                                  AssetImage(Constants.imageTransfer),
                              opacity: AlwaysStoppedAnimation(
                                  paymentMethod == 0 ? 100 : 1),
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height *
                                0.01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .transferPaymentMethod,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline3
                                  ?.copyWith(
                                      color: paymentMethod == 0
                                          ? Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.5)
                                          : Theme.of(context)
                                              .primaryColor),
                              textAlign: TextAlign.center,
                            ),
                            paymentMethod == 1
                                ? Icon(
                                    Icons.check_circle,
                                    color:
                                        Theme.of(context).primaryColor,
                                  )
                                : Container(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        paymentMethod = 2;
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.05),
                          height:
                              MediaQuery.of(context).size.width * 0.25,
                          width:
                              MediaQuery.of(context).size.width * 0.25,
                          decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: paymentMethod == 2 ? 5 : 1),
                          ),
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: Image(
                              image: AssetImage(Constants.imageGift),
                              opacity: AlwaysStoppedAnimation(
                                  paymentMethod != 2 ? 100 : 1),
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height *
                                0.01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .giftPaymentMethod,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline3
                                  ?.copyWith(
                                      color: paymentMethod != 2
                                          ? Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.5)
                                          : Theme.of(context)
                                              .primaryColor),
                              textAlign: TextAlign.center,
                            ),
                            paymentMethod == 2
                                ? Icon(
                                    Icons.check_circle,
                                    color:
                                        Theme.of(context).primaryColor,
                                  )
                                : Container(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            /// DELETE BONO REQUEST
            isBonoRequest ? Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.015),
              child: TextButton(
                  child: Text(AppLocalizations.of(context)!.delete+" "+AppLocalizations.of(context)!.request.toLowerCase(), style: Theme.of(context).textTheme.bodyText2?.copyWith(decoration: TextDecoration.underline), ),
                  onPressed: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {
                      isLoading = true;
                    });
                    await _brandDataService.deleteBrandBonoRequest(widget.brand.id!, widget.user.id!, widget.bonoRequest?.id!);
                    mixpanel!.track('bono_confirmation_deleted');
                    Navigator.of(context).pop();
                  }
              ),
            ) : SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            /// CONFIRMATION BUTTON
            isBonoSelected ? GestureDetector(
              onTap: isLoading ? null : () async {
                if (checkIfAllBonoConditionsAreCorrect()) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  setState(() {
                    isLoading = true;
                  });
                  if (noSessions) {
                    bonoSelected.sessions = 10000;
                  }
                  if (editBono) {
                    mixpanel!.track('edit_bono_confirmed');
                    _userDataService.updateUserBono(user.id!, currentBrand.id!, bonoSelected);
                    await Future.delayed(const Duration(seconds: 1));
                  } else if (isBonoRequest) {
                    // Build Purchase Object
                    Purchase purchase = Purchase();
                    purchase.purchasedAt = Timestamp.now();
                    purchase.brandId = widget.brand.id!;
                    purchase.bonoId = widget.bonoRequest?.bonoId;
                    purchase.price = bonoSelected.price;
                    purchase.userId = widget.bonoRequest?.userId!;
                    purchase.paymentMethod = paymentMethod;
                    //Add user to brand
                    Brand? userBrand = await _userDataService.getUserBrandsToAdd( widget.user.id!, widget.brand.id!);
                    if (userBrand == null) {
                      NotificationService().userJoinsBrand(widget.user.id!, widget.brand.id!);
                      _brandDataService.addUserToBrand(widget.user.id!, widget.brand.id!, 0);
                    }
                    // Notifications Service
                    _notificationService.userBuysBono(widget.user.id!, widget.brand.id!, bonoSelected);
                    // Build Purchase Object
                    await _paymentDataService.addPurchaseToPayments(purchase, bonoSelected);
                    await _brandDataService.deleteBrandBonoRequest(widget.brand.id!, widget.user.id!, widget.bonoRequest?.id!);
                    await _brandDataService.updateBonoCompras(widget.brand.id!, purchase.bonoId!);
                    mixpanel!.track('bono_confirmation_accepted', properties: {'Payment Method': purchase.paymentMethod.toString()});
                  } else {
                    // Build Purchase Object
                    Purchase purchase = Purchase();
                    purchase.purchasedAt = Timestamp.now();
                    purchase.brandId = widget.brand.id!;
                    purchase.bonoId = bonoSelected.id!;
                    purchase.price = bonoSelected.price!;
                    purchase.userId = user.id!;
                    purchase.paymentMethod = paymentMethod;
                    // Build Purchase Object
                    _notificationService.userBuysBono(widget.user.id!, widget.brand.id!, bonoSelected);
                    await _paymentDataService.addPurchaseToPayments(purchase, bonoSelected);
                    await _brandDataService.updateBonoCompras(widget.brand.id!, bonoSelected.id!);
                    await Future.delayed(const Duration(seconds: 3));
                    mixpanel!.track('give_bono_view', properties: {'Payment Method': purchase.paymentMethod.toString()});
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Container(
                  height: MediaQuery.of(context).size.height*0.09,
                  width: double.infinity,
                  color: Theme.of(context).primaryColor,
                  child: isLoading
                      ? Center(
                          child: Container(
                            padding: EdgeInsets.only(bottom: Platform.isIOS ? MediaQuery.of(context).size.height * 0.01 : 0),
                            height: MediaQuery.of(context).size.width * 0.08,
                            width: MediaQuery.of(context).size.width * 0.06,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColorDark,
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
                      : Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: Platform.isIOS ? MediaQuery.of(context).size.height * 0.01 : 0),
                            child: Text(
                              AppLocalizations.of(context)!.confirm,
                              style: Theme.of(context).textTheme.headline1?.copyWith(color: Theme.of(context).primaryColorDark,),
                            ),
                          ),
                        )
              ),
            ) :
            Container(
              height: MediaQuery.of(context).size.height*0.09,
              width: double.infinity,
              color: Theme.of(context).primaryColor,
              child: isLoading ? Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width *
                            0.06,
                        height:
                            MediaQuery.of(context).size.height *
                                0.03,
                        child: CircularProgressIndicator(
                          color:
                              Theme.of(context).primaryColorDark,
                          strokeWidth: 2.5,
                        ),
                      ),
                    ) : Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context)
                                    .size
                                    .height *
                                0.00),
                        child: Text(
                          'No hay bonos para otorgar a este usuario',
                          style: Theme.of(context)
                              .textTheme
                              .headline1
                              ?.copyWith(
                                color: Theme.of(context)
                                    .primaryColorDark,
                              ),
                        ),
                      ),
                    )
            ),
          ],
        ),
      ),
    );
  }

  bool checkIfAllBonoConditionsAreCorrect() {
    if (formKeyInfo.currentState!.validate()) {
      return true;
    } else {
      if (weekSessions && !cancelTimeSessions) {
        if (weeklyController.text.isNotEmpty) {
          return true;
        }
      }
      if (!weekSessions && cancelTimeSessions) {
        if (freeCancellController.text.isNotEmpty) {
          return true;
        }
      }
      return false;
    }
  }

  Widget optionTextWrite(
      var keyboard,
      var titleText,
      var subtitleText,
      var hintText,
      var errorText,
      bool editable,
      var controller,
      var focusNode,
      bool checkBox,
      var variable,
      bool wantPadding) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: wantPadding ? MediaQuery.of(context).size.height * 0.03 : 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              !checkBox && variable != 'ses' ? Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      titleText,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1?.copyWith(fontWeight: FontWeight.bold)
                    ),
                    subtitleText != "" ?  Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        subtitleText,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ) :  Container(),
                  ],
                ),
              ) : Container(),
              variable == 'ses' ? Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      titleText,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.copyWith(
                          fontWeight: FontWeight.bold)
                    ),
                    subtitleText != "" ?
                    variable != 'ses' ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        subtitleText,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ) : Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              subtitleText,
                              style: Theme.of(context)
                                  .textTheme
                                  .caption,
                            ),
                          ),
                          Container(
                              margin: const EdgeInsets.only(left: 4.0),
                              child: CupertinoSwitch(
                                value: noSessions,
                                onChanged: setSeeSessions,
                                thumbColor: AppColors.white,
                                activeColor: editable ? Colors.green : Colors.green.withOpacity(0.4),
                                trackColor: editable ? Colors.green.withOpacity(0.4) : Theme.of(context).disabledColor,
                              )
                          )
                        ],
                      ),
                    )
                        : Container(),
                  ],
                ),
              ) : Container(),
            ],
          )
        ),
        !checkBox && variable != 'ses' ?
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.00),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Flexible(
                    child: TextFormField(
                      focusNode: focusNode,
                      keyboardType: keyboard,
                      inputFormatters:
                      variable == 'ses' || variable == 'price' ? [FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),] : null,
                      minLines: 1,
                      controller: controller,
                      validator: (val) => val!.isEmpty ? errorText : null,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (val) {
                        setState(() {
                          if (variable == 'ses') {
                            bonoSelected.sessions = int.parse(val);
                          } else if (variable == 'price') {
                            double price = double.parse(val.replaceAll(',', '.'));
                            bonoSelected.price = roundDouble(price, 2);
                          }
                        });
                      },
                      style: editable ? Theme.of(context).textTheme.bodyText1 : Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).disabledColor),
                      decoration: InputDecoration(
                        suffixText: variable == 'ses' ? AppLocalizations.of(context)!.sessions.toLowerCase() : variable == 'price' ? "euros (€)" : "",
                        suffixStyle: Theme.of(context).textTheme.caption,
                        hintStyle: Theme.of(context).textTheme.caption,
                        hintText: hintText,
                        errorBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        disabledBorder: InputBorder.none,
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      enabled: editable,
                    ),
                  ),
                ],
              )
            ),
            variable == 'price' && priceController.text.isNotEmpty && priceController.text != "0" && sessionsController.text != "" && sessionsController.text != "0" && noSessions == false  ? Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
              child: Text(
                (bonoSelected.price! / bonoSelected.sessions!).toStringAsFixed(2) + " € / " + AppLocalizations.of(context)!.session,
                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.left,
              ),
            ) : Container(),
          ],
        )
        : variable == 'ses' && !noSessions ?
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.00),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Flexible(
                    child: TextFormField(
                      focusNode: focusNode,
                      keyboardType: keyboard,
                      inputFormatters:
                      variable == 'ses' || variable == 'price'
                          ? [
                        FilteringTextInputFormatter.allow(
                            RegExp('[0-9.,]')),
                      ]
                          : null,
                      maxLines: variable == 'desc' ? 5 : null,
                      minLines: 1,
                      maxLength: variable == 'title'
                          ? 20
                          : variable == 'desc'
                          ? 100
                          : null,
                      controller:
                       controller,
                      validator: (val) =>
                      val!.isEmpty ? errorText : null,
                      textCapitalization: variable == 'title'
                          ? TextCapitalization.words
                          : TextCapitalization.sentences,
                      onChanged: (val) {
                        setState(() {
                          if (variable == 'ses') {
                            bonoSelected.sessions = int.parse(val);
                          } else if (variable == 'price') {
                            double price = double.parse(
                                val.replaceAll(',', '.'));
                            print(roundDouble(price, 2));
                            bonoSelected.price = roundDouble(price, 2);
                          }
                        });
                      },
                      style: editable? Theme.of(context).textTheme.bodyText1 : Theme.of(context).textTheme.bodyText1?.copyWith(
                          color: Theme.of(context).disabledColor),
                      decoration: InputDecoration(
                        suffixText: variable == 'ses'
                            ? "sesiones"
                            : variable == 'price'
                            ? "euros (€)"
                            : "",
                        hintStyle:
                        Theme.of(context).textTheme.caption,
                        hintText: hintText,
                        //border: InputBorder.none,
                        errorBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        disabledBorder: InputBorder.none,
                        enabledBorder: const UnderlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.grey),
                        ),
                      ),
                      enabled: editable,
                    ),
                  ),
                ],
              )
            ),
          ],
        )
        : Container(),
      ],
    );
  }

  Widget optionConditionsWrite(
      var keyboard,
      var titleText,
      var subtitleText,
      var hintText,
      var errorText,
      var errorTextSecond,
      bool editable,
      var controller,
      var focusNode,
      var variable,
      bool wantPadding) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: wantPadding ? MediaQuery.of(context).size.height * 0.03 : 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      titleText,
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    variable == 'exp' || variable == 'expEdit' ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        subtitleText,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ) :
                    variable == 'canFree' ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: noSessions == true ? Text(
                                  AppLocalizations.of(context)!.freeCancelInfo,
                                  style: Theme.of(context).textTheme.caption,
                                ) : Text(
                                  subtitleText,
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption,
                                ),
                              ),
                              Container(
                                  margin: const EdgeInsets.only(left: 4.0),
                                  child: CupertinoSwitch(
                                    value: cancelTimeSessions,
                                    onChanged: noSessions == true ? null : setCancelHours,
                                    thumbColor: AppColors.white,
                                    activeColor: editable ? Colors.green : Colors.green.withOpacity(0.4),
                                    trackColor: !noSessions && editable ? Colors.green.withOpacity(0.4) : Theme.of(context).disabledColor,
                                  )
                              )
                            ],
                          ),
                        ],
                      ),
                    ) :
                    variable == 'maxw' ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              subtitleText,
                              style: Theme.of(context)
                                  .textTheme
                                  .caption,
                            ),
                          ),
                          Container(
                              margin: const EdgeInsets.only(left: 4.0),
                              child: CupertinoSwitch(
                                value: weekSessions,
                                onChanged: setWeekSessions,
                                thumbColor: AppColors.white,
                                activeColor: editable ? Colors.green : Colors.green.withOpacity(0.4),
                                trackColor: editable ? Colors.green.withOpacity(0.4) : Theme.of(context).disabledColor,
                              )
                          )
                        ],
                      ),
                    ) :
                    Container(),
                  ],
                ),
              ),
            ],
          )
        ),
        variable == 'exp' ?
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.015),
            daysSelectorWidget(0, '0', editable, noSessions),
            daysSelectorWidget(1, '30', editable, false),
            daysSelectorWidget(2, '60', editable, false),
            daysSelectorWidget(3, '90', editable, false),
          ],
        )
        : variable == 'expEdit' ?
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.015),
            daysSelectorWidget(0, '0', editable, noSessions),
            daysSelectorWidget(4, 'Edit', editable, false),
          ],
        )
        : variable == 'canFree' && cancelTimeSessions ?
        Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Flexible(
              child: TextFormField(
                keyboardType: keyboard,
                focusNode: focusNode,
                controller: controller,
                maxLines: null,
                minLines: 1,
                validator: (val) => val!.isEmpty ? errorText : int.parse(val) > 72 ? errorTextSecond : null,
                onChanged: (val) {
                  setState(() {
                    if (variable == 'maxw') {
                      bonoSelected.condition?.weeklySessions = int.parse(val);
                    } else if (variable == 'canFree') {
                      bonoSelected.condition?.cancelTime = int.parse(val);
                    }
                  });
                },
                style: editable ? Theme.of(context).textTheme.bodyText1 : Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).disabledColor),
                decoration: InputDecoration(
                  suffixText: variable == 'maxw' ? AppLocalizations.of(context)!.trainsPerWeek.toLowerCase() : variable == 'canFree' ? AppLocalizations.of(context)!.hoursString.toLowerCase() : "",
                  suffixStyle: Theme.of(context).textTheme.caption,
                  hintStyle: Theme.of(context).textTheme.caption,
                  hintText: hintText,
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  disabledBorder: InputBorder.none,
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                enabled: editable,
              ),
            ),
          ],
        )
        : variable == 'maxw' && weekSessions ?
        Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Flexible(
              child: TextFormField(
                keyboardType: keyboard,
                focusNode: focusNode,
                controller: controller,
                maxLines: null,
                minLines: 1,
                validator: (val) => val!.isEmpty ? errorText : null,
                onChanged: (val) {
                  setState(() {
                    if (variable == 'maxw') {
                      bonoSelected.condition?.weeklySessions = int.parse(val);
                    } else if (variable == 'canFree') {
                      bonoSelected.condition?.cancelTime = int.parse(val);
                    }
                  });
                },
                style: editable ? Theme.of(context).textTheme.bodyText1 : Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).disabledColor),
                decoration: InputDecoration(
                  suffixText: variable == 'maxw' ? AppLocalizations.of(context)!.sessions.toLowerCase() : variable == 'canFree' ? AppLocalizations.of(context)!.hoursString.toLowerCase() : "",
                  suffixStyle: Theme.of(context).textTheme.caption,
                  hintStyle: Theme.of(context).textTheme.caption,
                  hintText: hintText,
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  disabledBorder: InputBorder.none,
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                enabled: editable,
              ),
            ),
          ],
        )
        : Container(),
      ],
    );
  }

  void setSeeSessions(bool? seeSes) {
    noSessions = seeSes!;
    if (noSessions) {
      sessionsController.text = '';
      freeCancellController.text = '0';
      bonoSelected.condition?.cancelTime = 0;
      if (isSelectedDays[0]) {
        isSelectedDays[0] = false;
        isSelectedDays[1] = true;
      }
    } else {
      sessionsController.text = '';
      focusNodeSessionsController.requestFocus();
    }
    setState(() {});
  }

  void setWeekSessions(bool? seeSes) {
    weekSessions = seeSes!;
    if (weekSessions) {
      weeklyController.text = '';
      focusNodeWeeklyController.requestFocus();
    } else {
      weeklyController.text = '';
      focusNodeWeeklyController.unfocus();
      bonoSelected.condition?.weeklySessions = 0;
    }
    setState(() {});
  }

  void setCancelHours(bool? seeSes) {
    cancelTimeSessions = seeSes!;
    if (cancelTimeSessions) {
      freeCancellController.text = '';
      focusNodeFreeCancelController.requestFocus();
    } else {
      freeCancellController.text = '';
      bonoSelected.condition?.cancelTime = 0;
      focusNodeFreeCancelController.unfocus();
    }
    setState(() {});
  }

  Widget daysSelectorWidget(int index, String numberDays, bool editable, bool notShow) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.06,
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
                numberDays == "Edit" ? InkWell(
                  onTap: _show,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          AppLocalizations.of(context)!.from+" "+StringUtils().toCapitalized(DateFormat('EEEE - d/M/yy', Localizations.localeOf(context).languageCode).format(startDate))
                          +" "+AppLocalizations.of(context)!.to.toLowerCase()+" "+StringUtils().toCapitalized(DateFormat('EEEE - d/M/yy', Localizations.localeOf(context).languageCode).format(endDate)),
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: notShow == false ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ) :
                Text(
                  numberDays != "0" ? numberDays+" "+AppLocalizations.of(context)!.days.toLowerCase() : "No expira",
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(color: notShow == false ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                numberDays != "0" && numberDays != "Edit" ? Text(
                AppLocalizations.of(context)!.until(StringUtils().toCapitalized(DateFormat('EEEE - d/M/yy', Localizations.localeOf(context).languageCode).format(startDate.add(Duration(days: int.parse(numberDays)))))),

                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.left,
                ) : Container(),
              ],
            ),
          ),
          notShow == false ? SizedBox(
            height: MediaQuery.of(context).size.height * 0.034,
            width: MediaQuery.of(context).size.height * 0.06,
            child: MaterialButton(
              elevation: 2,
              color: isSelectedDays[index] == true ? editable ? Theme.of(context).primaryColor : Theme.of(context).disabledColor : Theme.of(context).scaffoldBackgroundColor,
              child: isSelectedDays[index] == true ? Icon(Icons.check, color: Theme.of(context).primaryColorDark, size: MediaQuery.of(context).size.width*0.06) : SizedBox(height: MediaQuery.of(context).size.width*0.03, width: MediaQuery.of(context).size.width*0.03,),
              padding: EdgeInsets.zero,
              shape: const CircleBorder(),
              onPressed: editable == false ? () {} : () {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                  FocusManager.instance.primaryFocus?.unfocus();
                }
                isSelectedDays[0] = false;
                isSelectedDays[1] = false;
                isSelectedDays[2] = false;
                isSelectedDays[3] = false;
                isSelectedDays[4] = false;
                isSelectedDays[index] = true;
                if (isSelectedDays[0]) {
                  bonoSelected.condition!.expirationTime = 0;
                }
                if (isSelectedDays[1]) {
                  bonoSelected.condition!.expirationTime = 30;
                }
                if (isSelectedDays[2]) {
                  bonoSelected.condition!.expirationTime = 60;
                }
                if (isSelectedDays[3]) {
                  bonoSelected.condition!.expirationTime = 90;
                }
                if (isSelectedDays[4]) {
                  bonoSelected.condition?.expirationTime = endDate.difference(startDate).inDays + 1;
                }
                setState(() {});
              },
            ),
          ) : Container(),
        ],
      ),
    );
  }

  void _show() async {
    FocusManager.instance.primaryFocus?.unfocus();
    List<DateTime>? result = await showModalBottomSheet<List<DateTime>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.935,
          child: SelectCalendarDate(
            dateRange: [startDate, endDate],
            dateJoined: dateJoined,
            isFuture: true,
          ),
        );
      },
    );
    if (result != null) {
      startDate = result.first;
      endDate = result.last;
      isSelectedDays[0] = false;
      isSelectedDays[1] = false;
      isSelectedDays[2] = false;
      isSelectedDays[3] = false;
      isSelectedDays[4] = false;
      isSelectedDays[4] = true;
      if (isSelectedDays[0]) {
        bonoSelected.condition!.expirationTime = 0;
      }
      if (isSelectedDays[1]) {
        bonoSelected.condition!.expirationTime = 30;
      }
      if (isSelectedDays[2]) {
        bonoSelected.condition!.expirationTime = 60;
      }
      if (isSelectedDays[3]) {
        bonoSelected.condition!.expirationTime = 90;
      }
      if (isSelectedDays[4]) {
        bonoSelected.condition?.expirationTime = endDate.difference(startDate).inDays + 1;
      }
      setState(() {});
    }
  }
}
