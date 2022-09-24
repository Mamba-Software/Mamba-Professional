import 'package:animated_widgets/widgets/opacity_animated.dart';
import 'package:animated_widgets/widgets/translation_animated.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Payments/PaymentDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/BonoRequest.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/BonoCard.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/ProfileView/ProfileUserView.dart';

import '../../Components/TopSnackBar/TopSnackBar.dart';


class OtorgarBono extends StatefulWidget {
  Usuario user;
  Brand brand;
  bool? edit;
  Bono? bono;


  OtorgarBono({Key? key, required this.user, required this.brand, this.edit, this.bono})
      : super(key: key);

  @override
  _OtorgarBonoState createState() => _OtorgarBonoState();
}

class _OtorgarBonoState extends State<OtorgarBono> {
  // Brand Service
  final _brandDataService = BrandDataService();
  final _paymentDataService = PaymentDataService();
  final _userDataService = UserDataService();

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


  @override
  void initState() {
    if(widget.edit != null && widget.edit == true) {
      editBono = true;
    }
    user = widget.user;
    paymentMethod = 2;
    getBonos();
    super.initState();
  }

  Future<void> getBonos() async {
    if(!editBono) {
      bonos =
      await _brandDataService.getAllBonosFromBrandList(currentBrand.id!);
      userBonos = await _userDataService.getUserBonos(user.id!);
      Bono bonoDelete;
      for (int i = 0; i < userBonos.length; ++i) {
        bonoDelete =
            bonos.firstWhere((element) => element.id == userBonos[i].id);
        if (bonoDelete.id != '') {
          bonos.remove(bonoDelete);
        }
      }
      if (bonos.length > 0) {
        bonoSelected = bonos[0];
        isBonoSelected = true;
      }
      if (isBonoSelected == false) {
        _topSnackBar.topsnackbar(
            context, 'Este usuario ya tiene todos los bonos de tu marca',
            AppColors.red);
        Navigator.of(context).pop();
      }
    }
    else {
      bonos.add(widget.bono!);
      bonoSelected = bonos[0];
      isBonoSelected = true;
      seeConditions = true;
      setConditionsBono(bonoSelected);
    }
    setState(() {});
  }

  void setConditionsBono(Bono _bono) {
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
    } else if (_bono.condition?.expirationTime == 30) {
      isSelectedDays[1] = true;
    } else if (_bono.condition?.expirationTime == 60) {
      isSelectedDays[2] = true;
    } else {
      isSelectedDays[3] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstBuild) {
      originalPaymentString = AppLocalizations.of(context)!.giftPaymentMethod;
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
                    child: Text(AppLocalizations.of(context)!.acceptBono,
                        style: Theme.of(context).textTheme.headline1,
                        textAlign: TextAlign.left),
                  ),
                  Flexible(
                    child: Text(AppLocalizations.of(context)!.acceptBonoDesc,
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
                              color: Theme.of(context).primaryColor,
                              size: MediaQuery.of(context).size.height * 0.03,
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.all(0),
                            onPressed: false ? () {} : null,
                          ),
                          onTap: () async {
                            await Navigator.push(
                                context,
                                CupertinoPageRoute<bool?>(
                                    builder: (context) => ProfileViewUser(
                                          userID: widget.user.id!,
                                          viewOnly: false,
                                        )));
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
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    isBonoSelected
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              bonos.isNotEmpty && indexBono != 0
                                  ? GestureDetector(
                                      onTap: () {
                                        indexBono = indexBono - 1;
                                        bonoSelected = bonos[indexBono];
                                        setConditionsBono(bonoSelected);
                                        setState(() {

                                        });
                                      },
                                      child: Icon(
                                        Icons.arrow_back_ios,
                                        color: AppColors.white,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.06,
                                      ))
                                  : Icon(
                                      Icons.arrow_back_ios,
                                      color: Theme.of(context).backgroundColor,
                                      size: MediaQuery.of(context).size.width *
                                          0.06,
                                    ),
                              BonoCard(
                                  height:
                                      MediaQuery.of(context).size.height * 0.22,
                                  width:
                                      MediaQuery.of(context).size.width * 0.84,
                                  bono: bonoSelected,
                                  brand: widget.brand,
                                  canExpand: true,
                                  onlyView: true),
                              bonos.isNotEmpty && indexBono != bonos.length - 1
                                  ? GestureDetector(
                                  onTap: () {
                                    indexBono = indexBono + 1;
                                    bonoSelected = bonos[indexBono];
                                    setConditionsBono(bonoSelected);
                                    setState(() {

                                    });
                                  },
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: AppColors.white,
                                    size:
                                    MediaQuery.of(context).size.width *
                                        0.06,
                                  ))
                                  : Icon(
                                Icons.arrow_forward_ios,
                                color: Theme.of(context).backgroundColor,
                                size: MediaQuery.of(context).size.width *
                                    0.06,
                              ),
                            ],
                          )
                        : Container(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    !seeConditions? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.06),
                          child: TextButton(
                            child: Text(
                              "Personalizar este bono solo para ${widget.user.firstName!}",
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  ?.copyWith(
                                      decoration: TextDecoration.underline),
                            ),
                            style: const ButtonStyle(),
                            onPressed: () async {
                              seeConditions = !seeConditions;
                              setState(() {

                              });
                            },
                          ),
                        ),
                      ],
                    ) : conditionsPage(),

                    !editBono? SizedBox(height: MediaQuery.of(context).size.height * 0.02) : SizedBox(height: MediaQuery.of(context).size.height * 0.14),
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
                    isBonoSelected
                        ? GestureDetector(
                            onTap: isLoading
                                ? null
                                : () async {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    if(editBono)
                                      {
                                        _userDataService.updateUserBono(user.id!, bonoSelected);
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


                                      await _paymentDataService
                                          .addPurchaseToPayments(purchase);

                                      await _brandDataService.updateBonoCompras(
                                          widget.brand.id!, bonoSelected.id!);
                                    }
                                    await Future.delayed(const Duration(seconds: 3));
                                    Navigator.of(context).pop();
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

  Widget conditionsPage() {
    return Column(
      children: [
        Form(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  optionConditionsWrite(
                      TextInputType.text,
                      AppLocalizations.of(context)!.expiresAt + "...",
                      AppLocalizations.of(context)!.expiresAtDesc,
                      AppLocalizations.of(context)!.titleHint,
                      AppLocalizations.of(context)!.titleError,
                      true,
                      titleController,
                      'exp'),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  optionConditionsWrite(
                      TextInputType.number,
                      AppLocalizations.of(context)!.freeCancel,
                      AppLocalizations.of(context)!.freeCancelDesc,
                      AppLocalizations.of(context)!.titleHint,
                      AppLocalizations.of(context)!.titleError,
                      true,
                      freeCancellController,
                      'ses'),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  optionConditionsWrite(
                      TextInputType.number,
                      AppLocalizations.of(context)!.trainsPerWeek,
                      AppLocalizations.of(context)!.trainsPerWeekDesc,
                      AppLocalizations.of(context)!.titleHint,
                      AppLocalizations.of(context)!.titleError,
                      true,
                      weeklyController,
                      'maxw'),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                ]),
          ),
        ),
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
      var variable) {
    return Column(
      children: [
        Padding(
            padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03),
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
        variable == 'exp'
            ? Padding(
    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.03),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                daysSelectoWidget(0, 'No expira', true),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                daysSelectoWidget(1, '30', false),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                daysSelectoWidget(2, '60', false),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                daysSelectoWidget(3, '90', false),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02),
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
/*
  Widget optionTextWrite(
      var keyboard,
      var titleText,
      var subtitleText,
      var hintText,
      var errorText,
      bool editable,
      var controller,
      bool checkBox,
      var variable) {
    return Column(
      children: [
        Padding(
            padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03),
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
                            .headline1
                            ?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 25),
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
                            fontSize: 25),
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
                            fontSize: 25),
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
                        onChanged: !widget.edit? setSeeSessions : null,
                        checkColor: AppColors.white,
                        activeColor: Styles.mainColor,
                      ),
                    )
                  ],
                )
                    : Container(),

                checkBox
                    ? Container(),
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
                        initialValue:  variable == 'ses'
                            ? bonoSelected.sessions.toString()
                            : variable == 'price'
                            ? bonoSelected.price.toString()
                            : null,
                        minLines: 1,
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
                              double price =
                              double.parse(val.replaceAll(',', '.'));
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
                        initialValue: widget.edit == true
                            ? variable == 'title'
                            ? bono.title
                            : variable == 'desc'
                            ? bono.description
                            : variable == 'ses'
                            ? bono.sessions.toString()
                            : variable == 'price'
                            ? bono.price.toString()
                            : null
                            : null,
                        maxLines: variable == 'desc' ? 5 : null,
                        minLines: 1,
                        maxLength: variable == 'title'
                            ? 20
                            : variable == 'desc'
                            ? 100
                            : null,
                        controller:
                        widget.edit == true ? null : controller,
                        validator: (val) =>
                        val!.isEmpty ? errorText : null,
                        textCapitalization: variable == 'title'
                            ? TextCapitalization.words
                            : TextCapitalization.sentences,
                        onChanged: (val) {
                          setState(() {
                            if (variable == 'title') {
                              bono.title = val;
                            } else if (variable == 'desc') {
                              bono.description = val;
                            } else if (variable == 'ses') {
                              bono.sessions = int.parse(val);
                            } else if (variable == 'price') {
                              double price = double.parse(
                                  val.replaceAll(',', '.'));
                              print(roundDouble(price, 2));
                              bono.price = roundDouble(price, 2);
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

 */

  Widget daysSelectoWidget(int index, String numberDays, bool customized) {
    return GestureDetector(
      onTap: () {
        if(widget.edit == false) {
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
          //bono.condition!.expirationTime = condition.expirationTime;

          setState(() {});
        }
      },
      child:
      customized == false? Container(
        height: MediaQuery.of(context).size.width * 0.15,
        width: MediaQuery.of(context).size.width * 0.2,
        decoration: BoxDecoration(
            border: Border.all(
              width: isSelectedDays[index] == true
                  ? 3 : 1,
              color: isSelectedDays[index] == true
                  ? Styles.mainColor
                  : widget.edit == false? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
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
                style: widget.edit == false? Theme.of(context).textTheme.button : Theme.of(context).textTheme.button!.copyWith(color: Theme.of(context).disabledColor),
              ),
              customized == false
                  ? Text(
                AppLocalizations.of(context)!.days,
                style: widget.edit == false? Theme.of(context).textTheme.button : Theme.of(context).textTheme.button!.copyWith(color: Theme.of(context).disabledColor),
              )
                  : Container(),
            ],
          ),
        ),
      ) : !noSessions?
      Container(
        height: MediaQuery.of(context).size.width * 0.15,
        width: MediaQuery.of(context).size.width * 0.2,
        decoration: BoxDecoration(
            border: Border.all(
              width: isSelectedDays[index] == true ? 3 : 1,
              color: isSelectedDays[index] == true
                  ? Styles.mainColor
                  : widget.edit == false? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
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
                style: widget.edit == false? Theme.of(context).textTheme.button : Theme.of(context).textTheme.button!.copyWith(color: Theme.of(context).disabledColor),
              ),
              customized == false
                  ? Text(
                AppLocalizations.of(context)!.days,
                style: widget.edit == false? Theme.of(context).textTheme.button : Theme.of(context).textTheme.button!.copyWith(color: Theme.of(context).disabledColor),
              )
                  : Container(),
            ],
          ),
        ),
      ) : Container(),
    );
  }

}
