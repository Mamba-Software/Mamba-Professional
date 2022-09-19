import 'package:animated_widgets/widgets/opacity_animated.dart';
import 'package:animated_widgets/widgets/translation_animated.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/BonoRequest.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/BonoCard.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/ProfileView/ProfileUserView.dart';

class ConfirmBuyBono extends StatefulWidget {
  Bono bono;
  Usuario user;
  BonoRequest bonoRequest;
  Brand brand;

  ConfirmBuyBono({Key? key, required this.bono,required this.user,required this.bonoRequest, required this.brand }) : super(key: key);
  @override
  _ConfirmBuyBonoState createState() => _ConfirmBuyBonoState();
}

class _ConfirmBuyBonoState extends State<ConfirmBuyBono> {

  // Brand Service
  final _brandDataService = BrandDataService();
  // Booleans
  bool isLoading = false;
  bool isFirstBuild = true;
  // Payment Method
  int? paymentMethod;
  String originalPaymentString = "";
  // Bottom Sheet
  bool canConfirm = false;

  @override
  void initState() {
    super.initState();
    paymentMethod = widget.bonoRequest.paymentMethod;
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstBuild) {
      if (widget.bonoRequest.paymentMethod == 0) {
        originalPaymentString = AppLocalizations.of(context)!.cashPaymentMethod;
      } else {
        originalPaymentString = AppLocalizations.of(context)!.transferPaymentMethod;
      }
      isFirstBuild = false;
    }
    return Scaffold(
      body: Container(

        width: double.infinity,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*0.02),
            Container(
              height: MediaQuery.of(context).size.height*0.007,
              width: MediaQuery.of(context).size.width*0.15,
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
            ),
            SizedBox(
                height: MediaQuery.of(context).size.height*0.02
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height*0.1,
              width: MediaQuery.of(context).size.width*0.84,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                        "Confirmación de compra",
                        style: Theme.of(context).textTheme.headline1,
                        textAlign: TextAlign.left
                    ),
                  ),
                  Flexible(
                    child: Text(
                        "Verifica la información de compra antes de otorgar el bono",
                        style: Theme.of(context).textTheme.caption?.copyWith(height: 1.5),
                        textAlign: TextAlign.center
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height*0.05,
                      width: MediaQuery.of(context).size.width*0.84,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            child: Text(
                                AppLocalizations.of(context)!.user,
                                style: Theme.of(context).textTheme.headline3,
                                textAlign: TextAlign.center
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.01),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.08),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          borderRadius: const BorderRadius.all(Radius.circular(10))
                        ),
                        child: ListTile(
                          minLeadingWidth: MediaQuery.of(context).size.width*0.15,
                          leading: CircularImage(
                            size: MediaQuery.of(context).size.width*0.15,
                            image: widget.user.imageUrl,
                            color: Theme.of(context).primaryColor,
                            borderWidth: 1.0,
                          ),
                          title: Text(
                            widget.user.name!,
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
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
                            icon: Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.height*0.03,),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.all(0),
                            onPressed: false ? () {
                            } : null,
                          ),
                          onTap: () async {
                            await Navigator.push(
                                context,
                                CupertinoPageRoute<bool?>(
                                    builder: (context) => ProfileViewUser(
                                      userID: widget.user.id!,
                                      viewOnly: false,
                                    )
                                )
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.02),

                    SizedBox(
                      height: MediaQuery.of(context).size.height*0.05,
                      width: MediaQuery.of(context).size.width*0.84,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            child: Text(
                                "Bono",
                                style: Theme.of(context).textTheme.headline3,
                                textAlign: TextAlign.center
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.01),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BonoCard(
                            height: MediaQuery.of(context).size.height*0.22,
                            width: MediaQuery.of(context).size.width*0.84,
                            bono: widget.bono,
                            brand: widget.brand,
                            canExpand: true,
                            onlyView: true
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.035),

                    SizedBox(
                      height: MediaQuery.of(context).size.height*0.05,
                      width: MediaQuery.of(context).size.width*0.84,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            child: Text(
                                "Método de Pago",
                                style: Theme.of(context).textTheme.headline3,
                                textAlign: TextAlign.center
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.08),
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyText2,
                          children: [
                            TextSpan(text: widget.user.firstName! +" ha indicado que ha pagado usando: ", style: Theme.of(context).textTheme.caption?.copyWith(height: 1.5)),
                            TextSpan(text: originalPaymentString, style: Theme.of(context).textTheme.caption?.copyWith(fontWeight: FontWeight.bold, height: 1.5),),
                            TextSpan(text: ". Confirma el método de pago por favor.", style: Theme.of(context).textTheme.caption?.copyWith(height: 1.5)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.02),
                    Row(
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
                                padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.05),
                                height: MediaQuery.of(context).size.height*0.18,
                                width: MediaQuery.of(context).size.height*0.18,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).backgroundColor,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                  border: Border.all(color: Theme.of(context).primaryColor, width: paymentMethod == 0 ? 5 : 1),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: Image(
                                    image: AssetImage(Constants.imageCash),
                                    opacity: AlwaysStoppedAnimation(paymentMethod == 1 ? 100 : 1),
                                  ),
                                ),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*0.01),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.cashPaymentMethod,
                                    style: Theme.of(context).textTheme.headline3?.copyWith(color: paymentMethod == 1 ? Theme.of(context).primaryColor.withOpacity(0.5) : Theme.of(context).primaryColor),
                                    textAlign: TextAlign.center,
                                  ),
                                  paymentMethod == 0 ? Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).primaryColor,
                                  ) : Container(),
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
                                padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.05),
                                height: MediaQuery.of(context).size.height*0.18,
                                width: MediaQuery.of(context).size.height*0.18,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).backgroundColor,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                  border: Border.all(color: Theme.of(context).primaryColor, width: paymentMethod == 1 ? 5 : 1),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: Image(
                                    image: AssetImage(Constants.imageTransfer),
                                    opacity: AlwaysStoppedAnimation(paymentMethod == 0 ? 100 : 1),
                                  ),
                                ),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.height*0.01),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.transferPaymentMethod,
                                    style: Theme.of(context).textTheme.headline3?.copyWith(color: paymentMethod == 0 ? Theme.of(context).primaryColor.withOpacity(0.5) : Theme.of(context).primaryColor),
                                    textAlign: TextAlign.center,
                                  ),
                                  paymentMethod == 1 ? Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).primaryColor,
                                  ) : Container(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.05),
                    GestureDetector(
                      onTap: null,
                      child: Container(
                          height: MediaQuery.of(context).size.height*0.1,
                          width: double.infinity,
                          color: Theme.of(context).primaryColor,
                          child: isLoading ? Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.06,
                              height: MediaQuery.of(context).size.height * 0.03,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).primaryColorDark,
                                strokeWidth: 2.5,
                              ),
                            ),
                          ) : Center(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.00),
                              child: Text(
                                "Otorgar bono",
                                style: Theme.of(context).textTheme.headline1?.copyWith(color: Theme.of(context).primaryColorDark,),
                              ),
                            ),
                          )
                      ),
                    )
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
