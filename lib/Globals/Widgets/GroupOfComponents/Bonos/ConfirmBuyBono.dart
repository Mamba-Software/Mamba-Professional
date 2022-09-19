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

  //Brand Service
  final _brandDataService = BrandDataService();
  // Payment Method
  int? paymentMethod;
  // Payment Method
  bool isLoading = false;
  bool isClosing = false;
  bool isSending = false;
  bool isSendingTwo = false;
  // Page View Controller
  final int _numPages = 3;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
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
            Expanded(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: <Widget>[
                  SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height*0.02
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height*0.1,
                          width: MediaQuery.of(context).size.width*0.84,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                    "Verifica que la información de compra para otorgar el bono",
                                    style: Theme.of(context).textTheme.caption,
                                    textAlign: TextAlign.center
                                ),
                              ),
                            ],
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
                                    AppLocalizations.of(context)!.user,
                                    style: Theme.of(context).textTheme.caption,
                                    textAlign: TextAlign.center
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                          child: ListTile(
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
                                    style: Theme.of(context).textTheme.caption,
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
                                    style: Theme.of(context).textTheme.caption,
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
                        SizedBox(height: MediaQuery.of(context).size.height*0.02),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height*0.02
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height*0.1,
                        width: MediaQuery.of(context).size.width*0.84,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                              child: Text(
                                  "AppLocalizations.of(context)!.whichPaymentMethod",
                                  style: Theme.of(context).textTheme.headline1,
                                  textAlign: TextAlign.left
                              ),
                            ),
                            Flexible(
                              child: Text(
                                  "AppLocalizations.of(context)!.whichPaymentMethodText",
                                  style: Theme.of(context).textTheme.caption,
                                  textAlign: TextAlign.center
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.04),
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
                      SizedBox(height: MediaQuery.of(context).size.height*0.03),
                      Row(
                          children: <Widget>[
                            Expanded(
                              child: Divider(color: Theme.of(context).primaryColor, height: 1, indent: MediaQuery.of(context).size.width*0.2, endIndent: MediaQuery.of(context).size.width*0.05),
                            ),
                            Text(
                                "o",
                                style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.grey),
                                textAlign: TextAlign.center
                            ),
                            Expanded(
                              child: Divider(color: Theme.of(context).primaryColor, height: 1, indent: MediaQuery.of(context).size.width*0.05, endIndent: MediaQuery.of(context).size.width*0.2),
                            ),
                          ]
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.03),
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height*0.02
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height*0.1,
                        width: MediaQuery.of(context).size.width*0.84,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                              child: Text(
                                  "AppLocalizations.of(context)!.askBono",
                                  style: Theme.of(context).textTheme.headline1,
                                  textAlign: TextAlign.left
                              ),
                            ),
                            Flexible(
                              child: Text(
                                  "AppLocalizations.of(context)!.askBonoText",
                                  style: Theme.of(context).textTheme.caption,
                                  textAlign: TextAlign.center
                              ),
                            ),
                          ],
                        ),
                      ),
                      TranslationAnimatedWidget.tween(
                        enabled: true,
                        translationDisabled: const Offset(0, 150),
                        translationEnabled: const Offset(0, 0),
                        child: OpacityAnimatedWidget.tween(
                          enabled: true,
                          opacityDisabled: 0,
                          opacityEnabled: 1,
                          child: Column(
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height*0.06),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                                child: ListTile(
                                  leading: CircularImage(
                                    size: MediaQuery.of(context).size.width*0.15,
                                    image: currentBrand.logoUrl!,
                                    color: Theme.of(context).primaryColor,
                                    borderWidth: 1.0,
                                  ),
                                  title: Text(
                                    currentBrand.name!,
                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.left,
                                  ),
                                  subtitle: Column(
                                    children: [
                                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                      Text(
                                       " AppLocalizations.of(context)!.askBonoBrandFirstText",
                                        style: Theme.of(context).textTheme.caption,
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TranslationAnimatedWidget.tween(
                        enabled: isSending,
                        translationDisabled: const Offset(0, 150),
                        translationEnabled: const Offset(0, 0),
                        child: OpacityAnimatedWidget.tween(
                            enabled: isSending,
                            opacityDisabled: 0,
                            opacityEnabled: 1,
                            child: Column(
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height*0.06),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                                  child: ListTile(

                                    trailing: CircularImage(
                                      size: MediaQuery.of(context).size.width*0.15,
                                      image: currentUser.imageUrl!,
                                      color: Theme.of(context).primaryColor,
                                      borderWidth: 1.0,
                                    ),
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          currentUser.name!,
                                          style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                        Text(
                                          "AppLocalizations.of(context)!.askBonoUserText",
                                          style: Theme.of(context).textTheme.caption,
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ),
                      ),
                      TranslationAnimatedWidget.tween(
                        enabled: isSendingTwo,
                        translationDisabled: const Offset(0, 150),
                        translationEnabled: const Offset(0, 0),
                        child: OpacityAnimatedWidget.tween(
                          enabled: isSendingTwo,
                          opacityDisabled: 0,
                          opacityEnabled: 1,
                          child: Column(
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height*0.06),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                                child: ListTile(

                                  leading: CircularImage(
                                    size: MediaQuery.of(context).size.width*0.15,
                                    image: currentBrand.logoUrl!,
                                    color: Theme.of(context).primaryColor,
                                    borderWidth: 1.0,
                                  ),
                                  title: Text(
                                    currentBrand.name!,
                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.left,
                                  ),
                                  subtitle: Column(
                                    children: [
                                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                      Text(
                                        "AppLocalizations.of(context)!.askBonoBrandSecondText",
                                        style: Theme.of(context).textTheme.caption,
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.04),
                      TranslationAnimatedWidget.tween(
                        enabled: isSendingTwo,
                        translationDisabled: const Offset(0, 150),
                        translationEnabled: const Offset(0, 0),
                        child: OpacityAnimatedWidget.tween(
                          enabled: isSendingTwo,
                          opacityDisabled: 0,
                          opacityEnabled: 1,
                          child: TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                AppLocalizations.of(context)!.entendido,
                                style: Theme.of(context).textTheme.headline3?.copyWith(decoration: TextDecoration.underline),
                                textAlign: TextAlign.left,
                              )
                          )
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.04),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomSheet: (_currentPage == _numPages - 1) ? TranslationAnimatedWidget.tween(
        enabled: !isSendingTwo,
        translationDisabled: const Offset(0, 150),
        translationEnabled: const Offset(0, 0),
        child: OpacityAnimatedWidget.tween(
          enabled: !isSendingTwo,
          opacityDisabled: 0,
          opacityEnabled: 1,
          child: GestureDetector(
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
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.02),
                    child: Text(
                      AppLocalizations.of(context)!.send,
                      style: Theme.of(context).textTheme.headline1?.copyWith(color: Theme.of(context).primaryColorDark,),
                    ),
                  ),
                )
            ),
          )
        ),
      ): const Text(''),
    );
  }
}
