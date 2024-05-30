import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/Purchase/PurchaseDataService.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/data/Models/Bono.dart';
import 'package:mamba/data/Models/BonoRequest.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/events/crud_events/models/Event.dart';
import 'package:mamba/data/Models/Purchase.dart';
import 'package:mamba/data/Models/Usuario.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/notifications/NotificationService/LocalNotificationService.dart';
import 'package:mamba/notifications/NotificationService/NotificationService.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/utils/Bonos/BonosUtils.dart';
import 'package:mamba/commons/utils/Date/DateTimeUtils.dart';
import 'package:mamba/commons/utils/Strings/StringUtils.dart';
import 'package:mamba/commons/widgets/Components/Badges/BetaBadge.dart';
import 'package:mamba/commons/widgets/Components/Badges/SoonBadge.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/commons/widgets/Components/TopSnackBar/TopSnackBarDef.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Bonos/BonoCard.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Bonos/ClientBonoCard.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Bonos/Purchase/PurchaseEvents/views/PurchaseEvents.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Bonos/UserBonos/UserPurchaseHistory/views/UserPurchaseHistory.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Calendars/SelectCalendar/SelectCalendarDate.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Dialogs/ActionDialogs/DeleteConfirmationDialog.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/ProfileView/ProfileUserView.dart';

class PurchasePage extends StatefulWidget {
  Usuario user;
  Brand brand;
  Bono? bono;
  BonoRequest? bonoRequest;
  Purchase? purchase;

  PurchasePage({
    super.key,
    required this.user,
    required this.brand,
    this.bono,
    this.bonoRequest,
    this.purchase,
  });

  @override
  _PurchasePageState createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  // Brand Service
  final _brandDataService = BrandDataService();
  final _userDataService = UserDataService();
  final _purchaseDataService = PurchaseDataService();

  int originalExpirationTime = 0;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  DateTime dateJoined = DateTime.now();

  final NotificationService _notificationService = NotificationService();
  final LocalNotificationService _localNotificationService =
      LocalNotificationService();

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
  final _topSnackBar = TopSnackBarDef();

  // Payment Method
  Purchase purchase = Purchase();
  int? paymentMethod;
  String originalPaymentString = "";
  bool directPaymentMethod = false;

  // Bottom Sheet
  bool canConfirm = false;

  Usuario user = Usuario();

  List<Bono> bonos = [];
  List<Bono> userBonos = [];

  Bono bonoSelected = Bono();
  bool isBonoSelected = false;

  int indexBono = 0;

  bool editBono = false;
  bool seeConditions = false;
  bool isRecurrent = false;
  bool isMainRecurrent = false;

  List<bool> isSelectedDays = [false, false, false, false, false];

  bool noSessions = false;
  bool weekSessions = false;
  bool cancelTimeSessions = false;
  bool isBonoRequest = false;
  bool isPaid = true;
  bool isOriginalPurchaseRecurrent = false;
  bool canDeleteOriginalPurchase = false;

  // Page View Controller
  int _numPages = 0;
  int? _currentPage;
  PageController? _pageController;

  bool eventsUpdated = false;
  Purchase newPurchase = Purchase();

  // App Bar and Scroll View
  ScrollController? _scrollController;
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    return _scrollController!.hasClients &&
        _scrollController!.offset >
            (MediaQuery.of(context).size.height * 0.1 - kToolbarHeight);
  }

  @override
  void initState() {
    super.initState();
    user = widget.user;

    /// EDIT PURCHASE
    if (widget.purchase != null) {
      mixpanel!.track('edit_bono_view');
      purchase = widget.purchase!;
      editBono = true;
    }

    /// ACCEPT PURCHASE
    if (widget.bonoRequest != null) {
      mixpanel!.track('bono_confirmation_view');
      isBonoRequest = true;
      isPaid = true;
      paymentMethod = widget.bonoRequest?.paymentMethod;
    }

    /// GIFT PURCHASE
    if (widget.bono == null) {
      mixpanel!.track('give_bono_view');
      paymentMethod = 2;
    }
    getBonos();
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
  }

  Future<void> checkRecurrency() async {
    if (purchase.isRecurrent != null && purchase.isRecurrent!) {
      isRecurrent = true;
      if (purchase.purchaseGroupId != null && purchase.purchaseGroupId != '') {
        var result = await _purchaseDataService
            .getRecurrentPurchaseGroup(purchase.purchaseGroupId!);
        purchase.groupPurchases = result.cast<String>();

        if (purchase.groupPurchases != null &&
            purchase.groupPurchases!.isNotEmpty) {
          var lastPurchase = purchase.groupPurchases!.last;
          if (lastPurchase == purchase.id) {
            isMainRecurrent = true;
          }
        }
        if (purchase.purchaseGroupId == purchase.id) {
          isOriginalPurchaseRecurrent = true;
          if (purchase.groupPurchases!.length <= 1) {
            canDeleteOriginalPurchase = true;
          }
        }
      }
    }
  }

  Future<void> getBonos() async {
    // Otorgar Bono
    if (editBono == false && isBonoRequest == false) {
      bonos =
          await _brandDataService.getAllBonosFromBrandList(currentBrand.id!);
      userBonos = await _userDataService.getUserActiveBonosFromBrand(
          user.id!, currentBrand.id!);
      // Remove the ones that the user already has
      Bono bonoDelete;
      for (int i = 0; i < userBonos.length; ++i) {
        bonoDelete =
            bonos.firstWhere((element) => element.id == userBonos[i].id);
        if (bonoDelete.id != '') {
          bonos.remove(bonoDelete);
        }
      }
      // Remove the unactive bonos.
      bonos.removeWhere((element) => element.isActive == false);
      _numPages = bonos.length;
      if (bonos.isNotEmpty) {
        bonoSelected.setBasicData = bonos[0];
        bonoSelected.setConditionsData = bonos[0].condition!;
        _currentPage = 0;
        isBonoSelected = true;
        setBonoConditions(bonoSelected);
      }
    } else {
      // Edit Bono && Bono Request
      bonos.add(widget.bono!);
      bonoSelected.setBasicData = bonos[0];
      isBonoSelected = true;
      // Accept Bono Request
      if (isBonoRequest) {
        bonoSelected.setBonoPrice = bonos[0].price!;
        bonoSelected.setBonoSessions = bonos[0].sessions!;
        bonoSelected.setConditionsData = bonos[0].condition!;
        seeConditions = false;
        setBonoConditions(bonoSelected);
      } else {
        // Edit Bono
        bonoSelected.setBonoPrice = purchase.price!;
        bonoSelected.setBonoSessions = purchase.sessions!;
        bonoSelected.setConditionsData = purchase.condition!;
        seeConditions = true;
        await getPurchase();
      }
    }
    Future.delayed(Duration.zero, () async {
      dateJoined = DateTimeUtils().formatStringToDateTimeDDMMYY(
          user.dateJoined!, Localizations.localeOf(context).languageCode);
      originalPaymentString = context.l10n.giftPaymentMethod;
      if (paymentMethod == 0) {
        originalPaymentString = context.l10n.cashPaymentMethod;
      } else if (paymentMethod == 1) {
        originalPaymentString = context.l10n.transferPaymentMethod;
      } else if (paymentMethod == 2) {
        originalPaymentString = context.l10n.giftPaymentMethod;
      } else if (paymentMethod == 3) {
        originalPaymentString = context.l10n.cardPaymentMethod;
      } else if (paymentMethod == 4) {
        originalPaymentString = context.l10n.applePayPaymentMethod;
      } else if (paymentMethod == 5) {
        originalPaymentString = context.l10n.googlePayPaymentMethod;
      }
      if (paymentMethod! > 2) directPaymentMethod = true;
    });
    setState(() {});
  }

  Future<void> getPurchase() async {
    Purchase tempPurchase =
        await _purchaseDataService.getPurchaseInfo(purchase.id!);
    purchase.events = tempPurchase.events;
    purchase.setInitialEventsData = tempPurchase.events;
    startDate = purchase.purchasedAt!.toDate();
    paymentMethod = purchase.paymentMethod;
    originalExpirationTime = bonoSelected.condition!.expirationTime!;
    isFirstBuild = true;
    purchase.isRecurrent = tempPurchase.isRecurrent ?? false;
    purchase.isRecurrencyActive = tempPurchase.isRecurrencyActive ?? false;
    purchase.purchaseGroupId = tempPurchase.purchaseGroupId ?? '';
    purchase.subscriptionStripe = '';
    if (tempPurchase.subscriptionStripe != null &&
        tempPurchase.subscriptionStripe != '') {
      purchase.subscriptionStripe = tempPurchase.subscriptionStripe;
    }
    await checkRecurrency();
    setBonoConditions(bonoSelected);
  }

  void setBonoConditions(Bono bono) {
    int? days = bono.condition?.expirationTime!;
    //Es una request o un regal
    if (!editBono) {
      bonoSelected.setBonoPrice =
          BonosUtils().getPurchasePrice(widget.brand, bono, bono.condition!);
      bono.setBonoPrice = bonoSelected.price!;
      days = BonosUtils().getExpirationTime(widget.brand, bono.condition!);
    }
    priceController.text = bono.price.toString();
    if (bono.sessions! > 5000) {
      sessionsController.text = '';
      noSessions = true;
    } else {
      sessionsController.text = bono.sessions.toString();
      noSessions = false;
    }
    freeCancellController.text = (bono.condition?.cancelTime!).toString();
    weeklyController.text = (bono.condition?.weeklySessions!).toString();
    sessionsController.text = (bono.sessions!).toString();
    priceController.text = (bono.price!).toStringAsFixed(2);
    isSelectedDays[0] = false;
    isSelectedDays[1] = false;
    isSelectedDays[2] = false;
    isSelectedDays[3] = false;
    isSelectedDays[4] = false;
    if (bono.condition?.expirationTime == 0) {
      isSelectedDays[0] = true;
    } else {
      isSelectedDays[4] = true;
      endDate = startDate.add(Duration(days: days!));
    }
  }

  bool checkIfAllBonoConditionsAreCorrect() {
    if (seeConditions && formKeyInfo.currentState!.validate()) {
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
      if (weekSessions && cancelTimeSessions) {
        if (freeCancellController.text.isNotEmpty &&
            weeklyController.text.isNotEmpty) {
          return true;
        }
      }
      if (!weekSessions && !cancelTimeSessions) {
        return true;
      }
      return false;
    }
  }

  // Check If User Bonos Have Expired
  Future<void> checkIfUserBonosHaveExpiredOrBeenReactivated(
      Purchase purchase) async {
    // Check if we have active or not active status now.
    bool purchaseIsActive = purchase.isActive!;
    if (purchaseIsActive) {
      // Sessions Done
      int sessionsDone = purchase.events.length;
      if (purchase.sessions == sessionsDone) {
        int index = purchase.events.indexWhere(
            (element) => element.doneAt!.toDate().isAfter(DateTime.now()));
        if (index == -1) {
          await _userDataService.deleteUserBono(purchase.userId!,
              purchase.brandId!, purchase.bonoId!, purchase.id!);
        }
      }
      // After Expiration Date
      if (purchase.condition!.expirationTime! != 0) {
        DateTime purchasedDate = purchase.purchasedAt!.toDate();
        purchasedDate = DateTime(
          purchasedDate.year,
          purchasedDate.month,
          purchasedDate.day,
        );
        DateTime expirationDate = purchasedDate
            .add(Duration(days: purchase.condition!.expirationTime!));
        DateTime now = DateTime.now();
        if (now.isAfter(expirationDate)) {
          await _userDataService.deleteUserBono(purchase.userId!,
              purchase.brandId!, purchase.bonoId!, purchase.id!);
        }
      }
    } else {
      // Sessions Done
      int sessionsDone = purchase.events.length;
      if (purchase.sessions! != sessionsDone) {
        await _userDataService.activateUserBono(purchase.userId!,
            purchase.brandId!, purchase.bonoId!, purchase.id!);
      }
      // After Expiration Date
      if (purchase.condition!.expirationTime! != 0) {
        DateTime purchasedDate = purchase.purchasedAt!.toDate();
        purchasedDate = DateTime(
          purchasedDate.year,
          purchasedDate.month,
          purchasedDate.day,
        );
        DateTime expirationDate = purchasedDate
            .add(Duration(days: purchase.condition!.expirationTime!));
        DateTime now = DateTime.now();
        if (now.isBefore(expirationDate)) {
          await _userDataService.activateUserBono(purchase.userId!,
              purchase.brandId!, purchase.bonoId!, purchase.id!);
        }
      }
    }
  }

  void executeFunctionWithPurchase(Purchase purchase) {
    eventsUpdated = true;
    List<Event> deleteEvents = purchase.initalEvents
        .where((b) => !purchase.events.any((a) => a.id == b.id))
        .toList();
    List<Event> newEvents = purchase.events
        .where((b) => !purchase.initalEvents.any((a) => a.id == b.id))
        .toList();
    newPurchase.setInitialEventsData = deleteEvents;
    newPurchase.setPurchasedEventsData = newEvents;
  }

  Widget buildStatusLabel() {
    if (isBonoRequest) {
      return Column(
        children: [
          /*
          Container(
            height: MediaQuery.of(context).size.height * 0.06,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.help_outline_outlined,
                      color: AppColors.red,
                      size: MediaQuery.of(context).size.width * 0.05,
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                    Text(
                      context.l10n.toConfirm,
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(
                          color: AppColors.red, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ],
            ),
          ),
          */
          // Mark as not payed already from the start
          isPaid == false
              ? Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.new_releases_outlined,
                                color: AppColors.red,
                                size: MediaQuery.of(context).size.width * 0.05,
                              ),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.01),
                              Text(
                                context.l10n.unverfied,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                        color: AppColors.red,
                                        fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.06,
                            width: MediaQuery.of(context).size.width * 0.15,
                            child: CupertinoSwitch(
                              value: false,
                              onChanged: (bool newVal) {
                                setState(() {
                                  isPaid = !isPaid;
                                });
                              },
                              trackColor: AppColors.red.withOpacity(0.4),
                              thumbColor: AppColors.white,
                              activeColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.verified_outlined,
                                color: Theme.of(context).primaryColor,
                                size: MediaQuery.of(context).size.width * 0.05,
                              ),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.01),
                              Text(
                                context.l10n.verfied,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.06,
                            width: MediaQuery.of(context).size.width * 0.15,
                            child: CupertinoSwitch(
                              value: true,
                              onChanged: (bool newVal) {
                                setState(() {
                                  isPaid = !isPaid;
                                });
                              },
                              trackColor: AppColors.red.withOpacity(0.4),
                              thumbColor: AppColors.white,
                              activeColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.005),
          Row(
            children: [
              Flexible(
                child: Text(
                  context.l10n.toConfirmDesc,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontSize: 12),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        ],
      );
    } else {
      if (purchase.directPurchase != null && purchase.directPurchase!) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.new_releases_outlined,
                        color: AppColors.red,
                        size: MediaQuery.of(context).size.width * 0.05,
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                      Text(
                        context.l10n.unverfied,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.red, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.06,
                    width: MediaQuery.of(context).size.width * 0.15,
                    child: CupertinoSwitch(
                      value: false,
                      onChanged: (bool newVal) {
                        setState(() {
                          purchase.directPurchase = false;
                        });
                      },
                      trackColor: AppColors.red.withOpacity(0.4),
                      thumbColor: AppColors.white,
                      activeColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.005),
            Row(
              children: [
                Flexible(
                  child: Text(
                    context.l10n.unverfiedDesc,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontSize: 12),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ],
        );
      } else {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        color: Theme.of(context).primaryColor,
                        size: MediaQuery.of(context).size.width * 0.05,
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                      Text(
                        context.l10n.verfied,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.06,
                    width: MediaQuery.of(context).size.width * 0.15,
                    child: CupertinoSwitch(
                      value: true,
                      onChanged: (bool newVal) {
                        setState(() {
                          purchase.directPurchase = true;
                        });
                      },
                      trackColor: AppColors.red.withOpacity(0.4),
                      thumbColor: AppColors.white,
                      activeColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.005),
            Row(
              children: [
                Flexible(
                  child: Text(
                    context.l10n.verfiedDesc,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontSize: 12),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ],
        );
      }
    }
  }

  Widget buildDateDetails() {
    if (widget.bonoRequest != null) {
      return Row(
        children: [
          Text(
            DateFormat("E dd MMMM yy, HH:mm",
                    Localizations.localeOf(context).languageCode)
                .format(widget.bonoRequest!.timeRequested!.toDate())
                .toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Text(
            purchase.id != null
                ? DateFormat("E dd MMMM yy, HH:mm",
                        Localizations.localeOf(context).languageCode)
                    .format(purchase.purchasedAt!.toDate())
                    .toUpperCase()
                : '',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              scrolledUnderElevation: 2,
              pinned: true,
              floating: false,
              centerTitle: false,
              expandedHeight: MediaQuery.of(context).size.height * 0.08,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: MediaQuery.of(context).size.width * 0.06,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: AnimatedOpacity(
                  opacity: appBarExpanded ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                      editBono
                          ? "${context.l10n.edit} ${context.l10n.purchase.toLowerCase()}"
                          : isBonoRequest
                              ? StringUtils().toCapitalized(context.l10n
                                  .userSendsBonoRequestBrand("")
                                  .split("una")[1]
                                  .trim())
                              : context.l10n.acceptBono,
                      style: Theme.of(context).appBarTheme.titleTextStyle)),
              actions: [
                /// DELETE BONO REQUEST
                isBonoRequest
                    ? IconButton(
                        onPressed: () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                          var result = await showDialog(
                              context: context,
                              builder: (_) {
                                return DeleteConfirmationDialog(
                                    text: context.l10n.deletePurchaseRequest);
                              });
                          if (result) {
                            setState(() {
                              isLoading = true;
                            });
                            await _brandDataService.deleteBrandBonoRequest(
                                widget.brand.id!,
                                widget.user.id!,
                                widget.bonoRequest?.id!);
                            await Future.delayed(
                                const Duration(milliseconds: 1500));
                            mixpanel!.track('bono_confirmation_deleted');
                            Navigator.of(context).pop();
                          }
                        },
                        icon: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete_outlined,
                                color: AppColors.red,
                                size: MediaQuery.of(context).size.width * 0.07,
                              )
                            ],
                          ),
                        ))
                    : editBono
                        ? IconButton(
                            onPressed: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              var result = await showDialog(
                                  context: context,
                                  builder: (_) {
                                    return DeleteConfirmationDialog(
                                      permitDelete: isOriginalPurchaseRecurrent
                                          ? canDeleteOriginalPurchase
                                              ? null
                                              : false
                                          : null,
                                      text: isOriginalPurchaseRecurrent
                                          ? canDeleteOriginalPurchase
                                              ? context.l10n.deletePurchase
                                              : context.l10n.cantDeletePurchase
                                          : context.l10n.deletePurchase,
                                    );
                                  });
                              if (result) {
                                setState(() {
                                  isLoading = true;
                                });
                                await _purchaseDataService.deletePurchase(
                                    purchase.id!,
                                    widget.user.id!,
                                    widget.brand.id!,
                                    purchase.purchaseGroupId!);
                                mixpanel!.track('purchase_deleted');
                                Navigator.of(context).pop();
                              }
                            },
                            icon: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete_outlined,
                                    color: AppColors.red,
                                    size: MediaQuery.of(context).size.width *
                                        0.07,
                                  )
                                ],
                              ),
                            ))
                        : Container(),
                SizedBox(width: MediaQuery.of(context).size.width * 0.03)
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  /// TITLE
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              editBono
                                  ? "${context.l10n.edit} ${context.l10n.purchase.toLowerCase()}"
                                  : isBonoRequest
                                      ? StringUtils().toCapitalized(context.l10n
                                          .userSendsBonoRequestBrand("")
                                          .split("una")[1]
                                          .trim())
                                      : context.l10n.acceptBono,
                              style: Theme.of(context).textTheme.displayLarge,
                              textAlign: TextAlign.left),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.015),
                          isBonoRequest || editBono
                              ? Column(
                                  children: [
                                    buildDateDetails(),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.015),
                                    buildStatusLabel(),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Text(
                                      context.l10n.acceptBonoDesc,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      textAlign: TextAlign.left,
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.02),
                                    isPaid == false
                                        ? Column(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .background,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .new_releases_outlined,
                                                          color: AppColors.red,
                                                          size: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.05,
                                                        ),
                                                        SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.01),
                                                        Text(
                                                          context
                                                              .l10n.unverfied,
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyLarge
                                                              ?.copyWith(
                                                                  color:
                                                                      AppColors
                                                                          .red,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                          textAlign:
                                                              TextAlign.right,
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.06,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.15,
                                                      child: CupertinoSwitch(
                                                        value: false,
                                                        onChanged:
                                                            (bool newVal) {
                                                          setState(() {
                                                            isPaid = !isPaid;
                                                          });
                                                        },
                                                        trackColor: AppColors
                                                            .red
                                                            .withOpacity(0.4),
                                                        thumbColor:
                                                            AppColors.white,
                                                        activeColor:
                                                            Colors.green,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        : Column(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .background,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .verified_outlined,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          size: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.05,
                                                        ),
                                                        SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.01),
                                                        Text(
                                                          context.l10n.verfied,
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyLarge
                                                              ?.copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                          textAlign:
                                                              TextAlign.right,
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.06,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.15,
                                                      child: CupertinoSwitch(
                                                        value: true,
                                                        onChanged:
                                                            (bool newVal) {
                                                          setState(() {
                                                            isPaid = !isPaid;
                                                          });
                                                        },
                                                        trackColor: AppColors
                                                            .red
                                                            .withOpacity(0.4),
                                                        thumbColor:
                                                            AppColors.white,
                                                        activeColor:
                                                            Colors.green,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),

                  /*
                  /// ACTIVATE PURCHASE
                  editBono ? Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                              child: Text(purchase.isActive! ? context.l10n.desactivarCompra : context.l10n.activarCompra,
                                  style: Theme.of(context).textTheme.headline1?.copyWith(fontSize: 22),
                                  textAlign: TextAlign.center),
                            ),
      
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                context.l10n.activePurchaseQuesDesc,
                                style: Theme.of(context)
                                    .textTheme
                                    .caption,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 4.0),
                              child: CupertinoSwitch(
                                value: purchase.isActive!,
                                onChanged: setPurchaseActivation,
                                trackColor: Colors.green.withOpacity(0.4),
                                thumbColor: AppColors.white,
                                activeColor: Colors.green,
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    ],
                  ) : Container(),
                   */
                  /// USER
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          child: Text(context.l10n.user,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(fontSize: 22),
                              textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.background,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        minLeadingWidth:
                            MediaQuery.of(context).size.width * 0.1,
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
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.lastEventAt == null
                                  ? context.l10n.lastActiveIn(DateTimeUtils()
                                      .formatDateTimeToStringMMMYYYY(
                                          dateJoined,
                                          Localizations.localeOf(context)
                                              .languageCode))
                                  : context.l10n.lastActiveIn(DateTimeUtils()
                                      .formatDateTimeToStringMMMYYYY(
                                          user.lastEventAt!.toDate(),
                                          Localizations.localeOf(context)
                                              .languageCode)),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: isBonoRequest || editBono
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            size: MediaQuery.of(context).size.height * 0.02,
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(0),
                          onPressed: false ? () {} : null,
                        ),
                        onTap: isBonoRequest || editBono
                            ? () async {
                                await Navigator.push(
                                    context,
                                    CupertinoPageRoute<bool?>(
                                        builder: (context) => ProfileViewUser(
                                              userID: widget.user.id!,
                                              viewOnly: false,
                                            )));
                              }
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),

                  /// TARIFAS
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          child: Text(
                              !editBono || purchase.id == null
                                  ? context.l10n.rate
                                  : bonoSelected.isRecurrent!
                                      ? context.l10n.membership
                                      : context.l10n.bono,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(fontSize: 22),
                              textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ),
                  bonos.length > 1
                      ? Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _buildPageIndicator(),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01),
                          ],
                        )
                      : SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                  !editBono || purchase.id == null
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.24,
                            minHeight:
                                MediaQuery.of(context).size.height * 0.24,
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
                                      setState(() {
                                        bonoSelected.setBasicData = bonos[page];
                                        bonoSelected.setConditionsData =
                                            bonos[page].condition!;
                                        isBonoSelected = true;
                                        setBonoConditions(bonoSelected);
                                        _currentPage = page;
                                      });
                                    },
                                    itemCount: bonos.length,
                                    itemBuilder: (context, index) {
                                      Bono bono = bonos[index];
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.08,
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.08,
                                            bottom: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.02),
                                        child: BonoCard(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.22,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.84,
                                          bono: bono,
                                          brand: widget.brand,
                                          canExpand: false,
                                          onlyView: true,
                                          hideActive: true,
                                          isDynamic: !editBono,
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          width: MediaQuery.of(context).size.width,
                          constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.24,
                            minHeight:
                                MediaQuery.of(context).size.height * 0.24,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    right: MediaQuery.of(context).size.width *
                                        0.08,
                                    left: MediaQuery.of(context).size.width *
                                        0.08,
                                    bottom: MediaQuery.of(context).size.height *
                                        0.02),
                                child: ClientBonoCard(
                                  height:
                                      MediaQuery.of(context).size.height * 0.22,
                                  width:
                                      MediaQuery.of(context).size.width * 0.84,
                                  bono: bonoSelected,
                                  brand: widget.brand,
                                  purchase: Purchase.copy(purchase),
                                  isExpanded: false,
                                  canExpand: false,
                                  onlyView: true,
                                ),
                              )
                            ],
                          ),
                        ),
                  //Active or Not Active
                  editBono && isRecurrent ? membresiaWidget() : Container(),

                  /// EVENTS
                  editBono
                      ? PurchaseEvents(
                          purchase: purchase,
                          context: context,
                          executeFunction: executeFunctionWithPurchase)
                      : Container(),

                  /// CONDITIONS
                  !editBono
                      ? Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.04,
                              right: MediaQuery.of(context).size.width * 0.04),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        Theme.of(context).primaryColor,
                                  ),
                                  onPressed: editBono
                                      ? null
                                      : () async {
                                          setState(() {
                                            seeConditions = !seeConditions;
                                          });
                                        },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          context.l10n.personalizeBonoUser(
                                              widget.user.firstName!),
                                          //style: Theme.of(context).textTheme.bodyText1?.copyWith(decoration: TextDecoration.underline, height: 1.5),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  fontWeight:
                                                      FontWeight.normal),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(
                                          seeConditions
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.08,
                                          color:
                                              Theme.of(context).primaryColor),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.03,
                              left: MediaQuery.of(context).size.width * 0.05,
                              right: MediaQuery.of(context).size.width * 0.05,
                              bottom:
                                  MediaQuery.of(context).size.height * 0.02),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.conditions,
                                //style: Theme.of(context).textTheme.bodyText1?.copyWith(decoration: TextDecoration.underline, height: 1.5),
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge
                                    ?.copyWith(fontSize: 22),
                              ),
                            ],
                          ),
                        ),
                  seeConditions
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.05),
                          child: Form(
                            key: formKeyInfo,
                            child: Column(
                              children: [
                                /// SESSIONS
                                Container(
                                  padding: EdgeInsets.all(
                                      MediaQuery.of(context).size.width * 0.05),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10))),
                                  child: optionTextWrite(
                                      TextInputType.number,
                                      context.l10n.sessions,
                                      context.l10n.sesionsBonoDesc,
                                      context.l10n.sessionHint,
                                      context.l10n.sessionPlease,
                                      true,
                                      sessionsController,
                                      focusNodeSessionsController,
                                      false,
                                      'ses',
                                      false),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01),

                                /// PRICE
                                Container(
                                  padding: EdgeInsets.all(
                                      MediaQuery.of(context).size.width * 0.05),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10))),
                                  child: optionTextWrite(
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                      context.l10n.price,
                                      "",
                                      context.l10n.priceHint,
                                      context.l10n.pricePlease,
                                      true,
                                      priceController,
                                      focusNodePriceController,
                                      false,
                                      'price',
                                      false),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01),

                                /// EXPIRATION DATE
                                Container(
                                    padding: EdgeInsets.all(
                                        MediaQuery.of(context).size.width *
                                            0.05),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10))),
                                    child: optionConditionsWrite(
                                        TextInputType.text,
                                        bonoSelected.isRecurrent != null &&
                                                bonoSelected.isRecurrent!
                                            ? context.l10n.renovationDate
                                            : context.l10n.expireDate,
                                        bonoSelected.isRecurrent != null &&
                                                bonoSelected.isRecurrent!
                                            ? context.l10n.renovationDateDesc
                                            : context.l10n.expiresAtDesc,
                                        context.l10n.titleError,
                                        context.l10n.titleError,
                                        context.l10n.titleError,
                                        true,
                                        titleController,
                                        null,
                                        'expEdit',
                                        false)),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01),

                                /// WEEKLY SESSIONS
                                Container(
                                  padding: EdgeInsets.all(
                                      MediaQuery.of(context).size.width * 0.05),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10))),
                                  child: optionConditionsWrite(
                                      TextInputType.number,
                                      context.l10n.trainsPerWeek,
                                      context.l10n.trainsPerWeekDesc,
                                      context.l10n.sessionHint,
                                      context.l10n.sessionPlease,
                                      context.l10n.trainsPerWeekError,
                                      true,
                                      weeklyController,
                                      focusNodeWeeklyController,
                                      'maxw',
                                      false),
                                ),

                                /// CANCEL TIME
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01),
                                Container(
                                  padding: EdgeInsets.all(
                                      MediaQuery.of(context).size.width * 0.05),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10))),
                                  child: optionConditionsWrite(
                                      TextInputType.number,
                                      context.l10n.freeCancel,
                                      context.l10n.freeCancelDesc,
                                      context.l10n.freeCancelHint,
                                      context.l10n.freeCancelError,
                                      context.l10n.freeCancelErrorSecond,
                                      true,
                                      freeCancellController,
                                      focusNodeFreeCancelController,
                                      'canFree',
                                      false),
                                ),
                              ],
                            ),
                          ))
                      : Container(),
                  editBono
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04)
                      : SizedBox(
                          height: MediaQuery.of(context).size.height * 0.04),

                  /// PAYMENT METHOD
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          child: Text(context.l10n.paymentMethod,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(fontSize: 22),
                              textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ),
                  !(editBono || isBonoRequest)
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.05),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              RichText(
                                textAlign: TextAlign.left,
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  children: [
                                    TextSpan(
                                      text: context.l10n.paymentMethodConfirm,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(height: 1.5),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.05),
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: [
                                TextSpan(
                                    text: context.l10n.paymentMethodOriginal,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(height: 1.5)),
                                TextSpan(
                                  text: originalPaymentString,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          height: 1.5),
                                ),
                                TextSpan(
                                    text: directPaymentMethod == false
                                        ? ". ${context.l10n.paymentMethodEdit}"
                                        : ". ${context.l10n.paymentMethodNoEdit}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(height: 1.5)),
                              ],
                            ),
                          ),
                        ),

                  // Confirmation Payment Menthods
                  /*
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.width * 0.05),
                    child: Row(children: <Widget>[
                      Expanded(
                        child: Divider(
                            color: Theme.of(context).primaryColor,
                            height: 1,
                            indent: MediaQuery.of(context).size.width * 0.05,
                            endIndent:
                                MediaQuery.of(context).size.width * 0.05),
                      ),
                      Text(
                          context.l10n
                              .intermediatePaymentMethod,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.grey),
                          textAlign: TextAlign.center),
                      Expanded(
                        child: Divider(
                            color: Theme.of(context).primaryColor,
                            height: 1,
                            indent: MediaQuery.of(context).size.width * 0.05,
                            endIndent:
                                MediaQuery.of(context).size.width * 0.05),
                      ),
                    ]),
                  ),
                  */
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  directPaymentMethod == false
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.05),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Cash
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
                                          MediaQuery.of(context).size.width *
                                              0.02),
                                      margin: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.03),
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.20,
                                      width: MediaQuery.of(context).size.width *
                                          0.20,
                                      decoration: BoxDecoration(
                                        color: paymentMethod == 0
                                            ? Colors.green.withOpacity(0.33)
                                            : Theme.of(context)
                                                .colorScheme
                                                .background,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                        border: Border.all(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: paymentMethod == 0 ? 2 : 1),
                                      ),
                                      child: Image(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.12,
                                        image: AssetImage(Assets.imageCash),
                                        opacity: AlwaysStoppedAnimation(
                                            paymentMethod == 0 ? 1 : 0.5),
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.01),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          context.l10n.cashPaymentMethod,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  color: paymentMethod == 0
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : Theme.of(context)
                                                          .primaryColor
                                                          .withOpacity(0.5),
                                                  fontWeight: paymentMethod == 0
                                                      ? FontWeight.bold
                                                      : FontWeight.normal),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Bizum
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
                                      margin: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.03),
                                      padding: EdgeInsets.all(
                                          MediaQuery.of(context).size.width *
                                              0.02),
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.20,
                                      width: MediaQuery.of(context).size.width *
                                          0.20,
                                      decoration: BoxDecoration(
                                        color: paymentMethod == 1
                                            ? Colors.blue.withOpacity(0.33)
                                            : Theme.of(context)
                                                .colorScheme
                                                .background,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                        border: Border.all(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: paymentMethod == 1 ? 2 : 1),
                                      ),
                                      child: Image(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.12,
                                        image: AssetImage(Assets.imageTransfer),
                                        opacity: AlwaysStoppedAnimation(
                                            paymentMethod == 1 ? 1 : 0.5),
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.01),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          context.l10n.transferPaymentMethod,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  color: paymentMethod == 1
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : Theme.of(context)
                                                          .primaryColor
                                                          .withOpacity(0.5),
                                                  fontWeight: paymentMethod == 1
                                                      ? FontWeight.bold
                                                      : FontWeight.normal),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Gift
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
                                      margin: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.03),
                                      padding: EdgeInsets.all(
                                          MediaQuery.of(context).size.width *
                                              0.02),
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.20,
                                      width: MediaQuery.of(context).size.width *
                                          0.20,
                                      decoration: BoxDecoration(
                                        color: paymentMethod == 2
                                            ? AppColors.red.withOpacity(0.33)
                                            : Theme.of(context)
                                                .colorScheme
                                                .background,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                        border: Border.all(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: paymentMethod == 2 ? 2 : 1),
                                      ),
                                      child: Image(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.12,
                                        image: AssetImage(Assets.imageGift),
                                        opacity: AlwaysStoppedAnimation(
                                            paymentMethod == 2 ? 1 : 0.5),
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.01),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          context.l10n.giftPaymentMethod,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  color: paymentMethod == 2
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : Theme.of(context)
                                                          .primaryColor
                                                          .withOpacity(0.5),
                                                  fontWeight: paymentMethod == 2
                                                      ? FontWeight.bold
                                                      : FontWeight.normal),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.05),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Card
                              Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(
                                        MediaQuery.of(context).size.width *
                                            0.02),
                                    margin: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.03),
                                    height: MediaQuery.of(context).size.width *
                                        0.20,
                                    width: MediaQuery.of(context).size.width *
                                        0.20,
                                    decoration: BoxDecoration(
                                      color: paymentMethod == 3
                                          ? AppColors.white
                                          : Theme.of(context)
                                              .colorScheme
                                              .background,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                      border: Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: paymentMethod == 3 ? 2 : 1),
                                    ),
                                    child: Image(
                                      image: AssetImage(Assets.imageCard),
                                      opacity: AlwaysStoppedAnimation(
                                          paymentMethod == 3 ? 1 : 0.5),
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        context.l10n.cardPaymentMethod,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: paymentMethod == 3
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(0.5),
                                                fontWeight: paymentMethod == 3
                                                    ? FontWeight.bold
                                                    : FontWeight.normal),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01),
                                  GestureDetector(
                                      onTap: () {
                                        _topSnackBar.showSnackBarBottom(context,
                                            context.l10n.betaFeature, 5);
                                      },
                                      child: const BetaBadge())
                                ],
                              ),
                              // Apple
                              Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.03),
                                    padding: EdgeInsets.all(
                                        MediaQuery.of(context).size.width *
                                            0.02),
                                    height: MediaQuery.of(context).size.width *
                                        0.20,
                                    width: MediaQuery.of(context).size.width *
                                        0.20,
                                    decoration: BoxDecoration(
                                      color: paymentMethod == 4
                                          ? AppColors.white
                                          : Theme.of(context)
                                              .colorScheme
                                              .background,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                      border: Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: paymentMethod == 4 ? 2 : 1),
                                    ),
                                    child: Container(
                                      margin: EdgeInsets.all(
                                          MediaQuery.of(context).size.width *
                                              0.02),
                                      child: Image(
                                        color: AppColors.black,
                                        image: AssetImage(Assets.apple),
                                        opacity: AlwaysStoppedAnimation(
                                            paymentMethod == 4 ? 1 : 0.5),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        context.l10n.applePayPaymentMethod,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: paymentMethod == 4
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(0.5),
                                                fontWeight: paymentMethod == 4
                                                    ? FontWeight.bold
                                                    : FontWeight.normal),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01),
                                  GestureDetector(
                                      onTap: () {
                                        _topSnackBar.showSnackBarBottom(context,
                                            context.l10n.soonFeature, 5);
                                      },
                                      child: const SoonBadge()),
                                ],
                              ),
                              // Google Pay
                              Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.03),
                                    padding: EdgeInsets.all(
                                        MediaQuery.of(context).size.width *
                                            0.02),
                                    height: MediaQuery.of(context).size.width *
                                        0.20,
                                    width: MediaQuery.of(context).size.width *
                                        0.20,
                                    decoration: BoxDecoration(
                                      color: paymentMethod == 5
                                          ? AppColors.white
                                          : Theme.of(context)
                                              .colorScheme
                                              .background,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                      border: Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: paymentMethod == 5 ? 2 : 1),
                                    ),
                                    child: Container(
                                      margin: EdgeInsets.all(
                                          MediaQuery.of(context).size.width *
                                              0.02),
                                      child: Image(
                                        image: AssetImage(Assets.google),
                                        //color: paymentMethod == 4 ? AppColors.black : AppColors.white,
                                        opacity: AlwaysStoppedAnimation(
                                            paymentMethod != 5 ? 0.5 : 1),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        context.l10n.googlePayPaymentMethod,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: paymentMethod == 5
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(0.5),
                                                fontWeight: paymentMethod == 5
                                                    ? FontWeight.bold
                                                    : FontWeight.normal),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01),
                                  GestureDetector(
                                      onTap: () {
                                        _topSnackBar.showSnackBarBottom(context,
                                            context.l10n.soonFeature, 5);
                                      },
                                      child: const SoonBadge()),
                                ],
                              ),
                            ],
                          ),
                        ),
                  // Direct Payment Menthods
                  /*
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.width * 0.05),
                    child: Row(children: <Widget>[
                      Expanded(
                        child: Divider(
                            color: Theme.of(context).primaryColor,
                            height: 1,
                            indent: MediaQuery.of(context).size.width * 0.05,
                            endIndent:
                                MediaQuery.of(context).size.width * 0.05),
                      ),
                      Text(context.l10n.inmediatePaymentMethod,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.grey),
                          textAlign: TextAlign.center),
                      Expanded(
                        child: Divider(
                            color: Theme.of(context).primaryColor,
                            height: 1,
                            indent: MediaQuery.of(context).size.width * 0.05,
                            endIndent:
                                MediaQuery.of(context).size.width * 0.05),
                      ),
                    ]),
                  ),
                  */

                  SizedBox(height: MediaQuery.of(context).size.height * 0.17),
                ],
              ),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
      floatingActionButton: whichFloatingActionButton(context),
    );
  }

  Widget whichFloatingActionButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width * 0.03,
          horizontal: MediaQuery.of(context).size.width * 0.01),
      child: FloatingActionButton.extended(
        shape: const StadiumBorder(),
        heroTag: "10",
        onPressed: isLoading
            ? null
            : () async {
                if (checkIfAllBonoConditionsAreCorrect()) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  setState(() {
                    isLoading = true;
                  });
                  if (noSessions) {
                    bonoSelected.sessions = 10000;
                  }
                  if (editBono) {
                    /// EDIT BONO REQUEST
                    mixpanel!.track('edit_bono_confirmed');
                    try {
                      purchase.paymentMethod = paymentMethod;
                      await _userDataService.updateUserPurchase(
                          user.id!, currentBrand.id!, bonoSelected, purchase);
                      await _purchaseDataService.updatePurchasePaymentStatus(
                          purchase.id!, purchase.directPurchase!);
                    } catch (e) {
                      print(e);
                    }
                    // Has Updated the Events of this Purchase
                    if (eventsUpdated) {
                      await _purchaseDataService.updatePurchaseEvents(
                          purchase.id!,
                          user.id!,
                          newPurchase.events,
                          newPurchase.initalEvents);
                      purchase.events = newPurchase.events;
                    }
                    // Update Purchase As active or not.
                    await checkIfUserBonosHaveExpiredOrBeenReactivated(
                        purchase);

                    /// UPDATE EXPIRING LOCAL NOTIFICATION IF EXPIRTAION TIME HAS CHANGED
                    if (originalExpirationTime !=
                        bonoSelected.condition!.expirationTime!) {
                      // Delete Local Notifications if Expiration Time has change in Update
                      await _localNotificationService
                          .deleteRemoteBonoExpirationLocalNotification(user.id!,
                              currentBrand.id!, bonoSelected.purchaseId!);
                      // Local Notifications Service
                      await _localNotificationService
                          .addRemoteBonoExpirationLocalNotification(
                              context, bonoSelected.purchaseId!);
                    }
                    mixpanel!.track('give_bono_view', properties: {
                      'Payment Method': purchase.paymentMethod.toString()
                    });
                    await Future.delayed(const Duration(milliseconds: 1500));
                  } else if (isBonoRequest) {
                    /// CONFIRM BONO REQUEST
                    // Build Purchase Object
                    Purchase purchase = Purchase();
                    purchase.purchasedAt = Timestamp.now();
                    purchase.brandId = widget.brand.id!;
                    purchase.bonoId = widget.bonoRequest?.bonoId;
                    purchase.price = bonoSelected.price;
                    purchase.userId = widget.bonoRequest?.userId!;
                    purchase.paymentMethod = paymentMethod;
                    if (currentBrand.gracePeriod != null) {
                      purchase.gracePeriod = currentBrand.gracePeriod;
                    } else {
                      purchase.gracePeriod = 0;
                    }
                    if (currentBrand.maxCanWeek != null) {
                      purchase.maxCanWeek = currentBrand.maxCanWeek!;
                    } else {
                      purchase.maxCanWeek = 7;
                    }
                    if (currentBrand.paymentTerms != null) {
                      purchase.paymentTerms = currentBrand.paymentTerms;
                    } else {
                      purchase.paymentTerms = 2;
                    }
                    if (isPaid == false) {
                      purchase.directPurchase = true;
                    }
                    //Add user to brand
                    Brand? userBrand = await _userDataService
                        .getUserBrandsToAdd(widget.user.id!, widget.brand.id!);
                    if (userBrand == null) {
                      NotificationService()
                          .userJoinsBrand(widget.user.id!, widget.brand.id!);
                      _brandDataService.addUserToBrand(
                          widget.user.id!, widget.brand.id!, 0);
                    }
                    // Notifications Service
                    _notificationService.userBuysBono(
                        widget.user.id!, widget.brand.id!, bonoSelected);
                    // Build Purchase Object
                    String purchaseId = await _purchaseDataService.addPurchase(
                        purchase, bonoSelected, widget.brand);
                    await _brandDataService.deleteBrandBonoRequest(
                        widget.brand.id!,
                        widget.user.id!,
                        widget.bonoRequest?.id!);
                    await _brandDataService.updateBonoCompras(
                        widget.brand.id!, purchase.bonoId!);
                    // Local Notifications Service
                    await _localNotificationService
                        .addRemoteBonoExpirationLocalNotification(
                            context, purchaseId);
                    mixpanel!.track('bono_confirmation_accepted', properties: {
                      'Payment Method': purchase.paymentMethod.toString()
                    });
                  } else {
                    /// OTORGAR BONO
                    // Build Purchase Object
                    Purchase purchase = Purchase();
                    purchase.purchasedAt = Timestamp.now();
                    purchase.brandId = widget.brand.id!;
                    purchase.bonoId = bonoSelected.id!;
                    purchase.price = bonoSelected.price!;
                    purchase.userId = user.id!;
                    purchase.paymentMethod = paymentMethod;
                    if (currentBrand.gracePeriod != null) {
                      purchase.gracePeriod = currentBrand.gracePeriod;
                    } else {
                      purchase.gracePeriod = 0;
                    }
                    if (currentBrand.maxCanWeek != null) {
                      purchase.maxCanWeek = currentBrand.maxCanWeek!;
                    } else {
                      purchase.maxCanWeek = 7;
                    }
                    if (currentBrand.paymentTerms != null) {
                      purchase.paymentTerms = currentBrand.paymentTerms;
                    } else {
                      purchase.paymentTerms = 2;
                    }
                    if (isPaid == false) {
                      purchase.directPurchase = true;
                    }
                    // Build Purchase Object
                    _notificationService.userBuysBono(
                        widget.user.id!, widget.brand.id!, bonoSelected);
                    // Save Purchase Object
                    String purchaseId = await _purchaseDataService.addPurchase(
                        purchase, bonoSelected, widget.brand);
                    await _brandDataService.updateBonoCompras(
                        widget.brand.id!, bonoSelected.id!);
                    await Future.delayed(const Duration(seconds: 2));
                    // Local Notifications Service
                    await _localNotificationService
                        .addRemoteBonoExpirationLocalNotification(
                            context, purchaseId);
                    mixpanel!.track('give_bono_view', properties: {
                      'Payment Method': purchase.paymentMethod.toString()
                    });
                  }
                  Navigator.of(context).pop();
                }
              },
        backgroundColor: Colors.green,
        icon: isLoading
            ? Container(
                height: MediaQuery.of(context).size.width * 0.04,
                width: MediaQuery.of(context).size.width * 0.04,
                margin: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.01),
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: const CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 1.5,
                ),
              )
            : editBono
                ? Icon(Icons.save,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.width * 0.05)
                : Icon(Icons.check_circle_outline,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.width * 0.05),
        label: Text(editBono ? context.l10n.save : context.l10n.confirm,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Colors.white)),
      ),
    );
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
            padding: EdgeInsets.only(
                top: wantPadding
                    ? MediaQuery.of(context).size.height * 0.03
                    : 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                !checkBox && variable != 'ses'
                    ? Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(titleText,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            subtitleText != ""
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      subtitleText,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      )
                    : Container(),
                variable == 'ses'
                    ? Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(titleText,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            subtitleText != ""
                                ? variable != 'ses'
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          subtitleText,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      )
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                subtitleText,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ),
                                            Container(
                                                margin: const EdgeInsets.only(
                                                    left: 4.0),
                                                child: CupertinoSwitch(
                                                  value: noSessions,
                                                  onChanged: setSeeSessions,
                                                  thumbColor: AppColors.white,
                                                  activeColor: editable
                                                      ? Colors.green
                                                      : Colors.green
                                                          .withOpacity(0.4),
                                                  trackColor: editable
                                                      ? Colors.green
                                                          .withOpacity(0.4)
                                                      : Theme.of(context)
                                                          .disabledColor,
                                                ))
                                          ],
                                        ),
                                      )
                                : Container(),
                          ],
                        ),
                      )
                    : Container(),
              ],
            )),
        !checkBox && variable != 'ses'
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.00),
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
                              minLines: 1,
                              controller: controller,
                              validator: (val) =>
                                  val!.isEmpty ? errorText : null,
                              textCapitalization: TextCapitalization.sentences,
                              onChanged: (val) {
                                setState(() {
                                  if (variable == 'ses') {
                                    bonoSelected.sessions = int.parse(val);
                                  } else if (variable == 'price') {
                                    double price =
                                        double.parse(val.replaceAll(',', '.'));
                                    bonoSelected.price = roundDouble(price, 2);
                                  }
                                });
                              },
                              style: editable
                                  ? Theme.of(context).textTheme.bodyLarge
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                          color:
                                              Theme.of(context).disabledColor),
                              decoration: InputDecoration(
                                suffixText: variable == 'ses'
                                    ? context.l10n.sessions.toLowerCase()
                                    : variable == 'price'
                                        ? "euros (€)"
                                        : "",
                                suffixStyle:
                                    Theme.of(context).textTheme.bodySmall,
                                hintStyle:
                                    Theme.of(context).textTheme.bodySmall,
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
                      )),
                  variable == 'price' &&
                          priceController.text.isNotEmpty &&
                          priceController.text != "0" &&
                          sessionsController.text != "" &&
                          sessionsController.text != "0" &&
                          noSessions == false
                      ? Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.01),
                          child: Text(
                            "${(bonoSelected.price! / bonoSelected.sessions!).toStringAsFixed(2)} € / ${context.l10n.session}",
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.left,
                          ),
                        )
                      : Container(),
                ],
              )
            : variable == 'ses' && !noSessions
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: EdgeInsets.only(
                              bottom:
                                  MediaQuery.of(context).size.height * 0.00),
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
                                  controller: controller,
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
                                        bonoSelected.price =
                                            roundDouble(price, 2);
                                      }
                                    });
                                  },
                                  style: editable
                                      ? Theme.of(context).textTheme.bodyLarge
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .disabledColor),
                                  decoration: InputDecoration(
                                    suffixText: variable == 'ses'
                                        ? "sesiones"
                                        : variable == 'price'
                                            ? "euros (€)"
                                            : "",
                                    hintStyle:
                                        Theme.of(context).textTheme.bodySmall,
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
                          )),
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
            padding: EdgeInsets.only(
                top: wantPadding
                    ? MediaQuery.of(context).size.height * 0.03
                    : 0),
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
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      variable == 'exp' || variable == 'expEdit'
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                subtitleText,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            )
                          : variable == 'canFree'
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: noSessions == true
                                                ? Text(
                                                    context.l10n.freeCancelInfo,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall,
                                                  )
                                                : Text(
                                                    subtitleText,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall,
                                                  ),
                                          ),
                                          Container(
                                              margin: const EdgeInsets.only(
                                                  left: 4.0),
                                              child: CupertinoSwitch(
                                                value: cancelTimeSessions,
                                                onChanged: noSessions == true
                                                    ? null
                                                    : setCancelHours,
                                                thumbColor: AppColors.white,
                                                activeColor: editable
                                                    ? Colors.green
                                                    : Colors.green
                                                        .withOpacity(0.4),
                                                trackColor:
                                                    !noSessions && editable
                                                        ? Colors.green
                                                            .withOpacity(0.4)
                                                        : Theme.of(context)
                                                            .disabledColor,
                                              ))
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : variable == 'maxw'
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              subtitleText,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ),
                                          Container(
                                              margin: const EdgeInsets.only(
                                                  left: 4.0),
                                              child: CupertinoSwitch(
                                                value: weekSessions,
                                                onChanged: setWeekSessions,
                                                thumbColor: AppColors.white,
                                                activeColor: editable
                                                    ? Colors.green
                                                    : Colors.green
                                                        .withOpacity(0.4),
                                                trackColor: editable
                                                    ? Colors.green
                                                        .withOpacity(0.4)
                                                    : Theme.of(context)
                                                        .disabledColor,
                                              ))
                                        ],
                                      ),
                                    )
                                  : Container(),
                    ],
                  ),
                ),
              ],
            )),
        variable == 'exp'
            ? Column(
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
            : variable == 'expEdit'
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.015),
                      bonoSelected.isRecurrent != null &&
                              bonoSelected.isRecurrent!
                          ? Container()
                          : daysSelectorWidget(0, '0', editable, noSessions),
                      daysSelectorWidget(4, 'Edit', editable, false),
                    ],
                  )
                : variable == 'canFree' && cancelTimeSessions
                    ? Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Flexible(
                            child: TextFormField(
                              keyboardType: keyboard,
                              focusNode: focusNode,
                              controller: controller,
                              maxLines: null,
                              minLines: 1,
                              validator: (val) => val!.isEmpty
                                  ? errorText
                                  : int.parse(val) > 72
                                      ? errorTextSecond
                                      : null,
                              onChanged: (val) {
                                setState(() {
                                  if (variable == 'maxw') {
                                    bonoSelected.condition?.weeklySessions =
                                        int.parse(val);
                                  } else if (variable == 'canFree') {
                                    bonoSelected.condition?.cancelTime =
                                        int.parse(val);
                                  }
                                });
                              },
                              style: editable
                                  ? Theme.of(context).textTheme.bodyLarge
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                          color:
                                              Theme.of(context).disabledColor),
                              decoration: InputDecoration(
                                suffixText: variable == 'maxw'
                                    ? context.l10n.trainsPerWeek.toLowerCase()
                                    : variable == 'canFree'
                                        ? context.l10n.hoursString.toLowerCase()
                                        : "",
                                suffixStyle:
                                    Theme.of(context).textTheme.bodySmall,
                                hintStyle:
                                    Theme.of(context).textTheme.bodySmall,
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
                    : variable == 'maxw' && weekSessions
                        ? Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Flexible(
                                child: TextFormField(
                                  keyboardType: keyboard,
                                  focusNode: focusNode,
                                  controller: controller,
                                  maxLines: null,
                                  minLines: 1,
                                  validator: (val) =>
                                      val!.isEmpty ? errorText : null,
                                  onChanged: (val) {
                                    setState(() {
                                      if (variable == 'maxw') {
                                        bonoSelected.condition?.weeklySessions =
                                            int.parse(val);
                                      } else if (variable == 'canFree') {
                                        bonoSelected.condition?.cancelTime =
                                            int.parse(val);
                                      }
                                    });
                                  },
                                  style: editable
                                      ? Theme.of(context).textTheme.bodyLarge
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .disabledColor),
                                  decoration: InputDecoration(
                                    suffixText: variable == 'maxw'
                                        ? context.l10n.sessions.toLowerCase()
                                        : variable == 'canFree'
                                            ? context.l10n.hoursString
                                                .toLowerCase()
                                            : "",
                                    suffixStyle:
                                        Theme.of(context).textTheme.bodySmall,
                                    hintStyle:
                                        Theme.of(context).textTheme.bodySmall,
                                    hintText: hintText,
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
                        : Container(),
      ],
    );
  }

  void setSeeSessions(bool? seeSes) {
    noSessions = seeSes!;
    if (noSessions) {
      cancelTimeSessions = false;
      sessionsController.text = '';
      freeCancellController.text = '0';
      bonoSelected.condition?.cancelTime = 0;
      if (isSelectedDays[0]) {
        isSelectedDays[0] = false;
        isSelectedDays[4] = true;
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
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: isActive ? 6.0 : 4.0,
      width: isActive ? 6.0 : 4.0,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).primaryColor
            : Theme.of(context).primaryColor.withOpacity(0.5),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  Widget daysSelectorWidget(
      int index, String numberDays, bool editable, bool notShow) {
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
                numberDays == "Edit"
                    ? InkWell(
                        onTap: _show,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.06,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Text(
                                      "${context.l10n.expiresAt} ${StringUtils().toCapitalized(DateFormat('EEEE - d MMM yyyy', Localizations.localeOf(context).languageCode).format(endDate))}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              color: notShow == false
                                                  ? Theme.of(context)
                                                      .primaryColor
                                                  : Theme.of(context)
                                                      .disabledColor),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Flexible(
                                    child: Text(
                                      "${context.l10n.from} ${StringUtils().toCapitalized(DateFormat('d/M/yy', Localizations.localeOf(context).languageCode).format(startDate))} ${context.l10n.to.toLowerCase()} ${StringUtils().toCapitalized(DateFormat('d/M/yy', Localizations.localeOf(context).languageCode).format(endDate))}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(fontSize: 12),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Text(
                        numberDays != "0"
                            ? "$numberDays ${context.l10n.days.toLowerCase()}"
                            : "No expira",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: notShow == false
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).disabledColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                numberDays != "0" && numberDays != "Edit"
                    ? Text(
                        context.l10n.until(StringUtils().toCapitalized(
                            DateFormat(
                                    'EEEE - d/M/yy',
                                    Localizations.localeOf(context)
                                        .languageCode)
                                .format(startDate.add(
                                    Duration(days: int.parse(numberDays)))))),
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.left,
                      )
                    : Container(),
              ],
            ),
          ),
          notShow == false
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.034,
                  width: MediaQuery.of(context).size.height * 0.06,
                  child: MaterialButton(
                    elevation: 2,
                    color: isSelectedDays[index] == true
                        ? editable
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).disabledColor
                        : Theme.of(context).scaffoldBackgroundColor,
                    padding: EdgeInsets.zero,
                    shape: const CircleBorder(),
                    onPressed: editable == false
                        ? () {}
                        : () {
                            FocusScopeNode currentFocus =
                                FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus &&
                                currentFocus.focusedChild != null) {
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
                              bonoSelected.condition?.expirationTime =
                                  endDate.difference(startDate).inDays;
                            }
                            setState(() {});
                          },
                    child: isSelectedDays[index] == true
                        ? Icon(Icons.check,
                            color: Theme.of(context).primaryColorDark,
                            size: MediaQuery.of(context).size.width * 0.06)
                        : SizedBox(
                            height: MediaQuery.of(context).size.width * 0.03,
                            width: MediaQuery.of(context).size.width * 0.03,
                          ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  double roundDouble(double value, int places) {
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
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
        bonoSelected.condition?.expirationTime =
            endDate.difference(startDate).inDays;
      }
      priceController.text = BonosUtils()
          .getPurchasePrice(
              widget.brand, bonos[_currentPage!], bonoSelected.condition!)
          .toString();
      purchase.price = double.parse(priceController.text);
      bonoSelected.setBonoPrice = double.parse(priceController.text);
      /*int days =
          BonosUtils().getExpirationTime(widget.brand, bonoSelected.condition!);
      priceController.text = BonosUtils()
          .getPurchasePrice(widget.brand, widget.bono!, bonoSelected.condition!)
          .toString();
      purchase.price = double.parse(priceController.text);
      isSelectedDays[0] = false;
      isSelectedDays[1] = false;
      isSelectedDays[2] = false;
      isSelectedDays[3] = false;
      isSelectedDays[4] = false;
      if (bonoSelected.condition?.expirationTime == 0) {
        isSelectedDays[0] = true;
      } else {
        isSelectedDays[4] = true;
        endDate = startDate.add(Duration(days: days!));
      }*/
      setState(() {});
    }
  }

  void setPurchaseActivation(bool? activation) {
    setState(() {
      purchase.isActive = activation;
    });
  }

  Widget membresiaWidget() {
    return Column(
      children: [
        isMainRecurrent
            ? Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  purchase.isRecurrencyActive!
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.05),
                          child: Column(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).colorScheme.background,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.repeat,
                                          color: Theme.of(context).primaryColor,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.05,
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.01),
                                        Text(
                                          context.l10n.autoRenovation,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.06,
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: CupertinoSwitch(
                                        value: true,
                                        onChanged: (bool newVal) async {
                                          /*
                                          var result = await showDialog(
                                              context: context,
                                              builder: (_) {
                                                return CancelMembresiaConfirmationDialog(
                                                  text: context.l10n
                                                      .cancelRequestConfirmation,
                                                  brand: widget.brand,
                                                );
                                              });
                                          if (result) {
                                            //TODO CANCEL SUSCRIPTION
                                            _purchaseDataService
                                                .updatePurchasePaymentRecurrency(
                                                    purchase.id!,
                                                    false,
                                                    purchase.paymentMethod!);
                                            setState(() {
                                              purchase.isRecurrencyActive =
                                                  false;
                                            });
                                          }*/
                                          setState(() {
                                            purchase.isRecurrencyActive = false;
                                          });
                                        },
                                        trackColor:
                                            AppColors.red.withOpacity(0.4),
                                        thumbColor: AppColors.white,
                                        activeColor: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.05),
                          child: Column(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).colorScheme.background,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.repeat,
                                          color: AppColors.red,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.05,
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.01),
                                        Text(
                                          context.l10n.notRenovation,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                  color: AppColors.red,
                                                  fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.06,
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: CupertinoSwitch(
                                        value: false,
                                        onChanged: (bool newVal) {
                                          setState(() {
                                            purchase.isRecurrencyActive = true;
                                          });
                                          print(purchase.isRecurrencyActive);
                                        },
                                        trackColor:
                                            AppColors.red.withOpacity(0.4),
                                        thumbColor: AppColors.white,
                                        activeColor: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.03),
                    child: Row(
                      children: [
                        Flexible(
                          child: TextButton(
                            onPressed: navigateToBonoHistoryPurchaseScreen,
                            child: RichText(
                              text: TextSpan(
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontSize: 12),
                                children: [
                                  TextSpan(
                                    text:
                                        "${context.l10n.automaticRenewalDesc} ",
                                  ),
                                  TextSpan(
                                      text: context
                                          .l10n.seeAutomaticRenewalPurchases,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              fontSize: 12,
                                              decoration:
                                                  TextDecoration.underline)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Container(),
      ],
    );
  }

  // Navigate to Event History Screen
  void navigateToBonoHistoryPurchaseScreen() {
    mixpanel!.track('profile_view_purchase_history');
    Navigator.push(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => UserPurchaseHistory(
            userId: user.id!,
            brandId: widget.brand.id!,
            purchaseGroupId: purchase.purchaseGroupId!,
          ),
        ));
  }
}
