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
import 'package:mamba_castelldefels/Globals/Utils/MultipleBrands/MultipleBrandsUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/BonoCard.dart';
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


  final NotificationService _notificationService = NotificationService();

  var titleController = TextEditingController();
  var freeCancellController = TextEditingController();
  var weeklyController = TextEditingController();
  var clasesController = TextEditingController();
  var priceController = TextEditingController();

  // Booleans
  bool isLoading = false;
  bool isFirstBuild = true;

  // Payment Method
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

  List<bool> isSelectedDays = [false, false, false, false];

  bool noSessions = false;
  bool isBonoRequest = false;

  // Page View Controller
  int _numPages = 0;
  int? _currentPage;
  PageController? _pageController;

  @override
  void initState() {
    user = widget.user;
    if (widget.edit != null && widget.edit == true) {
      mixpanel!.track('edit_bono_view');
      editBono = true;
    }
    if (widget.bonoRequest != null) {
      mixpanel!.track('bono_confirmation_view');
      isBonoRequest = true;
      paymentMethod = widget.bonoRequest?.paymentMethod;
      startDate = DateTime.now();
    } else {
      mixpanel!.track('give_bono_view');
      paymentMethod = 2;
    }
    getBonos();
    super.initState();
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
      height: 4.0,
      width: isActive ? 12.0 : 6.0,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.5),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  Future<void> getPurchase() async {
    Purchase? purchase = await _purchaseDataService.getPurchaseInfo(bonoSelected.purchaseId!);
    startDate = purchase.purchasedAt!.toDate();
    setConditionsBono(bonoSelected);
  }

  Future<void> getBonos() async {
    if (!editBono && !isBonoRequest) {
      bonos = await _brandDataService.getAllBonosFromBrandList(currentBrand.id!);
      bonos.removeWhere((element) => element.isActive == false);
      userBonos = await _userDataService.getUserBonos(user.id!);
      Bono bonoDelete;
      for (int i = 0; i < userBonos.length; ++i) {
        bonoDelete = bonos.firstWhere((element) => element.id == userBonos[i].id);
        if (bonoDelete.id != '') {
          bonos.remove(bonoDelete);
        }
      }
      _numPages = bonos.length;
      if (bonos.isNotEmpty) {
        bonoSelected.setBasicData = bonos[0];
        bonoSelected.setConditionsData = bonos[0].condition!;
        _currentPage = 0;
        isBonoSelected = true;
        setConditionsBono(bonoSelected);
      }
    } else {
      bonos.add(widget.bono!);
      bonoSelected.setBasicData = bonos[0];
      bonoSelected.setConditionsData = bonos[0].condition!;
      isBonoSelected = true;
      if (isBonoRequest) {
        seeConditions = false;
        setConditionsBono(bonoSelected);
      } else {
        seeConditions = true;
        await getPurchase();
      }

    }

    setState(() {});
  }

  void setConditionsBono(Bono _bono) {
    int? days = _bono.condition?.expirationTime!;
    print(days);
    priceController.text = _bono.price.toString();
    if(_bono.sessions! > 5000) {
      clasesController.text = '';
      noSessions = true;
    }
    else {
      clasesController.text = _bono.sessions.toString();
      noSessions = false;
    }
    freeCancellController.text = (_bono.condition?.cancelTime!).toString();
    weeklyController.text = (_bono.condition?.weeklySessions!).toString();
    clasesController.text = (_bono.sessions!).toString();
    priceController.text = (_bono.price!).toString();
    isSelectedDays[0] = false;
    isSelectedDays[1] = false;
    isSelectedDays[2] = false;
    isSelectedDays[3] = false;
    if (_bono.condition?.expirationTime == 0) {
      isSelectedDays[0] = true;
    }  else {
      isSelectedDays[1] = true;
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
      if(paymentMethod == 0)
        {
          originalPaymentString = AppLocalizations.of(context)!.cashPaymentMethod;
        }
      else if(paymentMethod == 1)
        {
          originalPaymentString = AppLocalizations.of(context)!.transferPaymentMethod;
        }
      isFirstBuild = false;
    }
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
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
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
              width: MediaQuery.of(context).size.width * 0.84,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: Text(
                        editBono? AppLocalizations.of(context)!.editBono : AppLocalizations.of(context)!.acceptBono,
                        style: Theme.of(context).textTheme.headline1,
                        textAlign: TextAlign.left),
                  ),
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
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width * 0.84,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            child: Text(AppLocalizations.of(context)!.user,
                                style: Theme.of(context).textTheme.headline3,
                                textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.08),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        child: ListTile(
                          minLeadingWidth:
                              MediaQuery.of(context).size.width * 0.15,
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
                                "@${widget.user.nick!}",
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              color: isBonoRequest? Theme.of(context).primaryColor : Theme.of(context).backgroundColor,
                              size: MediaQuery.of(context).size.height * 0.03,
                            ),
                            alignment: Alignment.centerRight,
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
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.035),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width * 0.84,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            child: Text(
                                AppLocalizations.of(context)!.bono,
                                style: Theme.of(context).textTheme.headline3,
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
                    ) : SizedBox(
                        height: MediaQuery.of(context).size.height*0.01
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height*0.22,
                        minHeight: MediaQuery.of(context).size.height*0.22,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: PageView.builder(
                                physics: const BouncingScrollPhysics(),
                                controller: _pageController,
                                onPageChanged: (int page) {
                                  setState(()  {
                                    //bonoSelected = bonos[page];
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
                                        onlyView: true
                                    ),
                                  );
                                }
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Padding(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.06, right: MediaQuery.of(context).size.width * 0.06),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            child: Text(
                              AppLocalizations.of(context)!.personalizeBonoUser(widget.user.firstName!),
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  ?.copyWith(
                                  decoration: TextDecoration.underline),
                            ),
                            style: const ButtonStyle(),
                            onPressed: editBono? null : () async {
                              setState(() {
                                seeConditions = !seeConditions;
                              });
                            },
                          ),
                          IconButton(
                            alignment: Alignment.centerRight,
                            icon: Icon(Icons.more_horiz, size: MediaQuery.of(context).size.width*0.06, color: AppColors.grey),
                            onPressed: editBono? null : () async {
                              setState(() {
                                seeConditions = !seeConditions;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    seeConditions ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.08),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                            decoration: BoxDecoration(
                                color: Theme.of(context).backgroundColor,
                                borderRadius: const BorderRadius.all(Radius.circular(10))
                            ),
                            child: optionTextWrite(
                                TextInputType.number,
                                AppLocalizations.of(context)!.sesionsBono,
                                AppLocalizations.of(context)!.sesionsBonoDesc,
                                0.toString(),
                                AppLocalizations.of(context)!.sessionPlease,
                                true,
                                clasesController,
                                false,
                                'ses',
                            false),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                          !editBono? Container(
                            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                            decoration: BoxDecoration(
                                color: Theme.of(context).backgroundColor,
                                borderRadius: const BorderRadius.all(Radius.circular(10))
                            ),
                            child: optionTextWrite(
                                const TextInputType.numberWithOptions(decimal: true),
                                AppLocalizations.of(context)!.priceBono,
                                "",
                                0.toString(),
                                AppLocalizations.of(context)!.pricePlease,
                                true,
                                priceController,
                                false,
                                'price',
                            false),
                          ) : Container(),
                          !editBono? SizedBox(height: MediaQuery.of(context).size.height * 0.01) : Container(),
                          Container(
                            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                            decoration: BoxDecoration(
                              color: Theme.of(context).backgroundColor,
                              borderRadius: const BorderRadius.all(Radius.circular(10))
                            ),
                            child: optionConditionsWrite(
                              TextInputType.text,
                              AppLocalizations.of(context)!.expiresAt + "...",
                              AppLocalizations.of(context)!.expiresAtDesc,
                              AppLocalizations.of(context)!.titleHint,
                              AppLocalizations.of(context)!.titleError,
                              true,
                              titleController,
                              'exp',
                              false
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                          !noSessions? Container(
                            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                            decoration: BoxDecoration(
                              color: Theme.of(context).backgroundColor,
                              borderRadius: const BorderRadius.all(Radius.circular(10))
                            ),
                            child: optionConditionsWrite(
                                TextInputType.number,
                                AppLocalizations.of(context)!.freeCancel,
                                AppLocalizations.of(context)!.freeCancelDesc,
                                AppLocalizations.of(context)!.titleHint,
                                AppLocalizations.of(context)!.titleError,
                                true,
                                freeCancellController,
                                'ses',
                                false
                            ),
                          ) : Container(),
                          !noSessions? SizedBox(height: MediaQuery.of(context).size.height * 0.01) : Container(),
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
                                AppLocalizations.of(context)!.titleHint,
                                AppLocalizations.of(context)!.titleError,
                                true,
                                weeklyController,
                                'maxw',
                                false
                            ),
                          ),
                        ],
                      )
                    ) : Container(),
                    !editBono? SizedBox(height: MediaQuery.of(context).size.height * 0.02) : SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    !editBono? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width * 0.84,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            child: Text(
                                AppLocalizations.of(context)!.paymentMethod,
                                style: Theme.of(context).textTheme.headline3,
                                textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                    ) : Container(),
                    !editBono?  Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.08),
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyText2,
                          children: [
                            TextSpan(
                                text: widget.user.firstName! +
                                    AppLocalizations.of(context)!
                                        .paymentIndication,
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    ?.copyWith(height: 1.5)),
                            TextSpan(
                              text: originalPaymentString,
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  ?.copyWith(
                                      fontWeight: FontWeight.bold, height: 1.5),
                            ),
                            TextSpan(
                                text: ". " +
                                    AppLocalizations.of(context)!
                                        .paymentMethodConfirm,
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    ?.copyWith(height: 1.5)),
                          ],
                        ),
                      ),
                    ) : Container(),
                    !editBono?  SizedBox(height: MediaQuery.of(context).size.height * 0.02) : Container(),
                    !editBono?  Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
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
                    ) : Container(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    isBonoRequest? TextButton(
                        child: Text(AppLocalizations.of(context)!.delete+" "+AppLocalizations.of(context)!.request.toLowerCase(), style: Theme.of(context).textTheme.bodyText2?.copyWith(decoration: TextDecoration.underline), ),
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          await _brandDataService.deleteBrandBonoRequest(widget.brand.id!, widget.user.id!, widget.bonoRequest?.id!);
                          mixpanel!.track('bono_confirmation_deleted');
                          Navigator.of(context).pop();
                        }
                    ) : SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    isBonoSelected
                        ? GestureDetector(
                            onTap: isLoading
                                ? null
                                : () async {
                                    if(freeCancellController.text != '' &&
                                     weeklyController.text != '' &&
                                        (clasesController.text != '' || noSessions) &&
                                     priceController.text != '') {
                                      setState(() {
                                        isLoading = true;
                                      });

                                      if (noSessions) {
                                        bonoSelected.sessions = 10000;
                                      }
                                      if (editBono) {
                                        mixpanel!.track('edit_bono_confirmed');
                                        _userDataService.updateUserBono(
                                            user.id!, currentBrand.id!, bonoSelected);
                                        await Future.delayed(
                                            const Duration(seconds: 1));
                                      }
                                      else if (isBonoRequest) {
                                        // Build Purchase Object
                                        Purchase purchase = Purchase();
                                        purchase.purchasedAt = Timestamp.now();
                                        purchase.brandId = widget.brand.id!;
                                        purchase.bonoId =
                                            widget.bonoRequest?.bonoId;
                                        purchase.price = bonoSelected.price;
                                        purchase.userId =
                                        widget.bonoRequest?.userId!;
                                        purchase.paymentMethod = paymentMethod;
                                        //Add user to brand
                                        Brand? userBrand = await _userDataService.getUserBrands( widget.user.id!);
                                        if(userBrand == null) {
                                          NotificationService().userJoinsBrand(
                                              widget.user.id!, widget.brand.id!);
                                              _brandDataService.addUserToBrand(
                                              widget.user.id!, widget.brand.id!, 0);
                                        }
                                        // Notifications Service
                                        _notificationService.userBuysBono(
                                            widget.user.id!, widget.brand.id!,
                                            bonoSelected);
                                        // Build Purchase Object
                                        await _paymentDataService
                                            .addPurchaseToPayments(
                                            purchase, bonoSelected);
                                        await _brandDataService
                                            .deleteBrandBonoRequest(
                                            widget.brand.id!, widget.user.id!,
                                            widget.bonoRequest?.id!);
                                        await _brandDataService
                                            .updateBonoCompras(
                                            widget.brand.id!, purchase.bonoId!);
                                        mixpanel!.track('bono_confirmation_accepted', properties: {'Payment Method': purchase.paymentMethod.toString()});
                                      }
                                      else {
                                        // Build Purchase Object
                                        Purchase purchase = Purchase();
                                        purchase.purchasedAt = Timestamp.now();
                                        purchase.brandId = widget.brand.id!;
                                        purchase.bonoId = bonoSelected.id!;
                                        purchase.price = bonoSelected.price!;
                                        purchase.userId = user.id!;
                                        purchase.paymentMethod = paymentMethod;
                                        // Build Purchase Object

                                        _notificationService.userBuysBono(
                                            widget.user.id!, widget.brand.id!,
                                            bonoSelected);

                                        await _paymentDataService
                                            .addPurchaseToPayments(
                                            purchase, bonoSelected);

                                        await _brandDataService
                                            .updateBonoCompras(
                                            widget.brand.id!, bonoSelected.id!);
                                        await Future.delayed(
                                            const Duration(seconds: 3));
                                        mixpanel!.track('give_bono_view', properties: {'Payment Method': purchase.paymentMethod.toString()});
                                      }
                                      Navigator.of(context).pop();
                                    }
                                    else {
                                      _topSnackBar.topsnackbar(context, AppLocalizations.of(context)!.personalizedFieldsFirst, AppColors.red);
                                    }
                                  },
                            child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.1,
                                width: double.infinity,
                                color: Theme.of(context).primaryColor,
                                child: isLoading
                                    ? Center(
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.06,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.03,
                                          child: CircularProgressIndicator(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                            strokeWidth: 2.5,
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.00),
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .confirm,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline1
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                ),
                                          ),
                                        ),
                                      )),
                          )
                        : Container(
                            height: MediaQuery.of(context).size.height * 0.1,
                            width: double.infinity,
                            color: Theme.of(context).primaryColor,
                            child: isLoading
                                ? Center(
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
                                  )
                                : Center(
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
                                  )),
                  ],
                ),
              ),
            ),
          ],
        ),
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
      bool checkBox,
      var variable,
      bool wantPadding) {
    return Column(
      children: [
        Padding(
            padding:
            EdgeInsets.only(top: wantPadding ? MediaQuery.of(context).size.height * 0.03 : 0),
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
                      Text(
                        titleText,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            ?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      subtitleText != ""
                          ?  Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          subtitleText,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      )
                          :  Container(),
                    ],
                  ),
                )
                    : variable != 'ses'
                    ? Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        titleText,
                        style: Theme.of(context)
                            .textTheme
                            .headline1
                            ?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      subtitleText != ""
                          ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          subtitleText,
                          style:
                          Theme.of(context).textTheme.caption,
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
                      Text(
                        titleText,
                        style: Theme.of(context)
                            .textTheme
                            .headline1
                            ?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      subtitleText != "" ? variable != 'ses'? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          subtitleText,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ) : isSelectedDays[0] == false? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          subtitleText,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ) : Container() : Container(),
                    ],
                  ),
                )
                    : Container(),

                variable == 'ses' && isSelectedDays[0] == false
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Transform.scale(
                      scale: 1.3,
                      child: Checkbox(
                        value: noSessions,
                        onChanged: setSeeSessions,
                        checkColor: AppColors.white,
                        activeColor: Styles.mainColor,
                      ),
                    )
                  ],
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
                              double price = double.parse(val.replaceAll(',', '.'));
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
                          hintStyle: Theme.of(context).textTheme.caption,
                          hintText: hintText,
                          //border: InputBorder.none,
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
      bool editable,
      var controller,
      var variable,
      bool wantPadding) {
    return Column(
      children: [
        Padding(
            padding:
            EdgeInsets.only(top: wantPadding ? MediaQuery.of(context).size.height * 0.03 : 0),
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
                        style: Theme.of(context).textTheme.headline1?.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitleText != ""
                          ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          subtitleText,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      )
                          : Container(),
                    ],
                  ),
                ),
              ],
            )),
        variable == 'exp' ? Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.03),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                daysSelectoWidget(1, '30', false),
                SizedBox(height: MediaQuery.of(context).size.width * 0.02),
                NoExpireWidget(0, 'No expira', true),
                //SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                //daysSelectoWidget(2, '60', false),

              ],
            ))
            : variable == 'maxw' || variable == 'ses'
            ? Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.00),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Flexible(
                  child: TextFormField(
                    keyboardType: keyboard,
                    controller: controller,
                    //initialValue: widget.edit ? variable == 'maxw'? condition.weeklySessions.toString() : null : null,
                    maxLines: null,
                    minLines: 1,
                    maxLength: variable == 'title'
                        ? 20
                        : variable == 'desc'
                        ? 100
                        : null,
                    //controller:  widget.edit == true ? null : controller,
                    validator: (val) => val!.isEmpty ? errorText : null,
                    onChanged: (val) {
                      setState(() {
                        if (variable == 'maxw') {
                          bonoSelected.condition?.weeklySessions = int.parse(val);
                        } else if (variable == 'ses') {
                          bonoSelected.condition?.cancelTime = int.parse(val);
                        } else if (variable == 'price') {
                          //bono.price = double.parse(val);
                        }
                      });
                    },
                    style: editable? Theme.of(context).textTheme.bodyText1 : Theme.of(context).textTheme.bodyText1?.copyWith(
                        color: Theme.of(context).disabledColor),
                    decoration: InputDecoration(
                      hintStyle: Theme.of(context).textTheme.caption,
                      hintText: hintText,
                      suffixText: variable == 'maxw'
                          ? "sesiones por semana"
                          : variable == 'ses'
                          ? "horas de antelacion"
                          : "",
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
            ))
            : Container(),
      ],
    );
  }

  void setSeeSessions(bool? seeSes) {
    noSessions = seeSes!;
    clasesController.text = '';
    //bonoSelected.sessions = 0;
    if(noSessions) {
      freeCancellController.text = '0';
      bonoSelected.condition?.cancelTime = 0;
    }

    setState(() {});
  }

  Widget NoExpireWidget(int index, String numberDays, bool customized) {
    return !noSessions ? TextButton(
      child: Text(
          AppLocalizations.of(context)!.noExpireDate,
          style: Theme.of(context).textTheme.bodyText1?.copyWith(color: isSelectedDays[index] == true
              ? Theme.of(context).colorScheme.secondary : Theme.of(context).primaryColor, decoration: TextDecoration.underline)
      ),
      onPressed: () {
        isSelectedDays[0] = false;
        isSelectedDays[1] = false;
        isSelectedDays[2] = false;
        isSelectedDays[3] = false;
        isSelectedDays[index] = true;

        if (isSelectedDays[0]) {
          bonoSelected.condition?.expirationTime = 0;
        }
        if (isSelectedDays[1]) {
          bonoSelected.condition?.expirationTime = 30;
        }
        if (isSelectedDays[2]) {
          bonoSelected.condition?.expirationTime = 60;
        }
        if (isSelectedDays[3]) {
          bonoSelected.condition?.expirationTime = 90;
        }
        setState(() {});
      },
    ) : Container();

      GestureDetector(
      onTap: () {
        isSelectedDays[0] = false;
        isSelectedDays[1] = false;
        isSelectedDays[2] = false;
        isSelectedDays[3] = false;
        isSelectedDays[index] = true;

        if (isSelectedDays[0]) {
          bonoSelected.condition?.expirationTime = 0;
        }
        if (isSelectedDays[1]) {
          bonoSelected.condition?.expirationTime = 30;
        }
        if (isSelectedDays[2]) {
          bonoSelected.condition?.expirationTime = 60;
        }
        if (isSelectedDays[3]) {
          bonoSelected.condition?.expirationTime = 90;
        }
        setState(() {});

      },
      child: customized == false ? Container(
        height: MediaQuery.of(context).size.width * 0.15,
        width: MediaQuery.of(context).size.width * 0.15,
        decoration: BoxDecoration(
            border: Border.all(
              width: isSelectedDays[index] == true
                  ? 3 : 1,
              color: isSelectedDays[index] == true
                  ? Styles.mainColor
                  : Theme.of(context).primaryColor,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        child: Align(
          alignment: Alignment.center,
          //padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06, vertical: MediaQuery.of(context).size.width * 0.02),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  customized == false ? numberDays : "No expira",
                  style: Theme.of(context).textTheme.button),
              customized == false
                  ? Text(
                  AppLocalizations.of(context)!.days,
                  style: Theme.of(context).textTheme.button) : Container(),
            ],
          ),
        ),
      ) : !noSessions?
      Container(
        height: MediaQuery.of(context).size.width * 0.15,
        width: MediaQuery.of(context).size.width * 0.20,
        decoration: BoxDecoration(
            border: Border.all(
              width: isSelectedDays[index] == true ? 3 : 1,
              color: isSelectedDays[index] == true
                  ? Styles.mainColor
                  :  Theme.of(context).primaryColor,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        child: Align(
          alignment: Alignment.center,
          //padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06, vertical: MediaQuery.of(context).size.width * 0.02),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  customized == false ? numberDays : "No expira",
                  style: Theme.of(context).textTheme.button),

              customized == false
                  ? Text(
                  AppLocalizations.of(context)!.days,
                  style: Theme.of(context).textTheme.button)
                  : Container(),
            ],
          ),
        ),
      ) : Container(),
    );
  }

  Widget daysSelectoWidget(int index, String numberDays, bool customized) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.of(context).size.width * 0.21,
          width: MediaQuery.of(context).size.width * 0.6,
          decoration: BoxDecoration(
            border: Border.all(
              width: isSelectedDays[index] == true ? 1 : 1,
              color: isSelectedDays[index] == true
                  ? Styles.mainColor
                  :  Theme.of(context).primaryColor,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20))
          ),
          child: Align(
            alignment: Alignment.center,
            //padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06, vertical: MediaQuery.of(context).size.width * 0.02),
            child: InkWell(
              onTap: _show,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context)!.from,
                              textAlign: TextAlign.left,
                              style: Theme.of(context).textTheme.caption,
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width*0.08,
                              width: MediaQuery.of(context).size.width*0.2,
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  startDate != null ?  currentUser.idioma == 'es'? DateFormat.yMd('es').format(startDate) :  DateFormat.yMd('cat').format(startDate) : '--/-- ',
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.width * 0.20,
                        width: 2,
                        color: Theme.of(context).dividerColor,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context)!.to,
                              style: Theme.of(context).textTheme.caption,
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width*0.08,
                              width: MediaQuery.of(context).size.width*0.2,
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  endDate != null ? currentUser.idioma == 'es'? DateFormat.yMd('es').format(endDate) : DateFormat.yMd('cat').format(endDate) :  '--/-- ',
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

  }

  void _show() async {
    await showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) => CalendarPopupView(
        barrierDismissible: true,
        minimumDate: DateTime.now(),
        initialEndDate: endDate,
        initialStartDate: startDate,
        onApplyClick: (DateTime startData, DateTime endData) {
          setState(() {
            isSelectedDays[0] = false;
            isSelectedDays[1] = true;
            startDate = startData;
            endDate = endData;
            bonoSelected.condition?.expirationTime = endDate.difference(startDate).inDays + 1;
          });
        },
      ),
    );
  }
}
