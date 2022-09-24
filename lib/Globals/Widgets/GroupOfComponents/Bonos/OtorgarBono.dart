import 'package:animated_widgets/widgets/opacity_animated.dart';
import 'package:animated_widgets/widgets/translation_animated.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/BonoCard.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/ProfileView/ProfileUserView.dart';
import 'package:mamba_castelldefels/Globals/Widgets/TopSnackBar/TopSnackBar.dart';

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
    }
    setState(() {});
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
                    Row(
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
                            onPressed: () async {},
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    SizedBox(
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
                    ),
                    Padding(
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
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Padding(
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
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    isBonoSelected
                        ? GestureDetector(
                            onTap: isLoading
                                ? null
                                : () async {
                                    setState(() {
                                      isLoading = true;
                                    });
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

                                    await _brandDataService.updateBonoCompras(widget.brand.id!, bonoSelected.id!);
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
}
