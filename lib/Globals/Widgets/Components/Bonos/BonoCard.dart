import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/BonoRequest.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/Models/Condition.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/SelectEventUsers/BonosDEL%C3%87.dart';

import '../../../../Data/LibraryModels/lColor.dart';
import '../../../../Data/LibraryModels/lDegradate.dart';
import '../../../../Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/AddEditBono.dart';

class BonoCard extends StatefulWidget {
  double height = 0;
  double width = 0;
  Bono bono;
  Brand brand;
  bool canExpand;
  bool clientView;

  BonoCard({Key? key, required this.height, required this.width, required this.bono, required this.brand, required this.canExpand, required this.clientView }) : super(key: key);

  @override
  BonoCardState createState() => BonoCardState();
}

class BonoCardState extends State<BonoCard> {

  final _lDegradate = lDegradate();
  final _lColor = lColor();
  Bono bono = Bono();
  Brand brand = Brand();
  final _brandDataService = BrandDataService();
  String bonoSee = 'nadie';
  Condition condition = Condition();

  @override
  void initState() {
    bono = widget.bono;
    brand = widget.brand;
    getCondition();
    super.initState();
  }

  void getCondition() async {
    condition =  await _brandDataService.getConditionInfo(widget.brand.id!, bono.id!);
  }

  @override
  void didUpdateWidget(BonoCard oldWidget) {
    if (bono != widget.bono) {
      setState((){
        bono = widget.bono;
      });
    }
    super.didUpdateWidget(oldWidget);

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (bono.isActive! && widget.canExpand == true) {
          if (bonoSee == bono.id!) {
            bonoSee = 'nadie';
          } else {
            bonoSee = bono.id!;
          }
          setState(() {});
        }
      },
      child: AnimatedContainer(
        constraints: BoxConstraints(
          minHeight: widget.height,
          minWidth: widget.width,
          maxWidth: widget.width,
        ),
        height: bonoSee == bono.id!? widget.height * 1.5 : widget.height,
        decoration: bono.isDegradate! ? BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(int.parse(_lDegradate.getlDegradate(bono.color!).hexa1!)).withOpacity(bono.opacity!),
                Color(int.parse(_lDegradate.getlDegradate(bono.color!).hexa2!)).withOpacity(bono.opacity!),
              ],
            ),
            image: bono.imageUrl != null && bono.imageUrl != ''? DecorationImage(
              opacity: 225,
              image:  NetworkImage(bono.imageUrl!),
              fit: BoxFit.cover,
            ) : null,
            borderRadius: const BorderRadius.all(Radius.circular(10))
        ) : BoxDecoration(
            image: bono.imageUrl != null && bono.imageUrl != ''? DecorationImage(
              opacity: 225,
              image:  NetworkImage(bono.imageUrl!),
              fit: BoxFit.cover,
            ) : null,
            color: Color(int.parse(_lColor.getlColor(bono.color!).hexa!)).withOpacity(bono.opacity!),
            borderRadius:
            const BorderRadius.all(Radius.circular(10))
        ),
        // Animation
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
        child: Column(
          children: [
            Container(
              height: widget.height,
              width: widget.width,
              padding: EdgeInsets.all(widget.width*0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: widget.height * 0.2,
                        width: widget.width*0.15,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: CircularImage(
                              size: widget.width * 0.15,
                              image: brand.logoUrl,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: widget.height * 0.2,
                        width: widget.width*0.4,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              brand.name!.toUpperCase(),
                              style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.normal, color: Colors.white),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: widget.height * 0.15,
                            width: widget.width*0.6,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  bono.title!.toUpperCase(),
                                  style: Theme.of(context).textTheme.headline1?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: widget.height * 0.1,
                            width: widget.width*0.5,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Row(
                                  children: [
                                    Text(
                                      bono.price!.toString().toUpperCase() + '€',
                                      style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),
                                      textAlign: TextAlign.left,
                                    ),
                                    SizedBox(width: widget.width*0.05,),
                                    condition.infiniteSessions!= null && condition.infiniteSessions!? Text(
                                      '∞ ' +
                                          AppLocalizations.of(context)!
                                              .sessions
                                              .toUpperCase(),
                                      style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),
                                      textAlign: TextAlign.left,
                                    ) : Text(
                                      bono.classes!.toString().toUpperCase() +
                                          ' ' +
                                          AppLocalizations.of(context)!
                                              .sessions
                                              .toUpperCase(),
                                      style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: widget.height * 0.2,
                            width: widget.width*0.1,
                            child: Align(
                              alignment: Alignment.center,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: bonoSee != bono.id!? Icon(
                                  Icons.expand_more,
                                  size: widget.width * 0.1,
                                ) : Icon(
                                  Icons.expand_less,
                                  size: widget.width * 0.1,
                                )
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  /*
                  !bono.isActive! && widget.view == false? Container(
                    height: widget.width * 0.50,
                    width: widget.width * 0.85,
                    decoration:  BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius:
                        BorderRadius.all(Radius.circular(15))),
                    child:  GestureDetector(
                      onTap: () {
                        bono.isActive = !bono.isActive!;
                        _brandDataService.updateBonoActive(brand.id!, bono.id!, bono.isActive!);
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: widget.width * 0.1,
                          width: widget.width * 0.32,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                              ),
                              borderRadius:
                              const BorderRadius.all(Radius.circular(20))),
                          child: Align(
                            alignment: Alignment.center,
                            //padding: EdgeInsets.symmetric(horizontal: widget.width * 0.06, vertical: widget.width * 0.02),
                            child: Text(
                              bono.isActive!? 'Desactivar'.toUpperCase() : 'Activar'.toUpperCase(),
                              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),// 0: Light, 1: Dark

                  ) : Container(),
                  bonoSee == bono.id!? Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: widget.height * 0.30,
                          left: widget.height * 0.035,
                          right: widget.height * 0.04),
                      child: Text(
                        bono.description!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2?.copyWith(color: Colors.white),
                        textAlign: TextAlign.left,
                        maxLines: 4,
                        overflow: TextOverflow.visible,

                      ),
                    ),
                  ) : Container(),
                  bonoSee == bono.id!? Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: widget.height * 0.60,
                          right: widget.height * 0.01),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if(widget.view == false) {
                                navigateToAddBonosScreen(bono, brand, true);
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: widget.height * 0.03,
                                  horizontal: widget.height * 0.01),
                              child: Container(
                                height: widget.width * 0.1,
                                width: widget.width * 0.32,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                    ),
                                    borderRadius:
                                    const BorderRadius.all(Radius.circular(20))),
                                child: Align(
                                  alignment: Alignment.center,
                                  //padding: EdgeInsets.symmetric(horizontal: widget.width * 0.06, vertical: widget.width * 0.02),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .edit.toUpperCase(),
                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if(widget.view == false) {
                                bono.isActive = !bono.isActive!;
                                _brandDataService.updateBonoActive(
                                    brand.id!, bono.id!, bono.isActive!);
                                setState(() {
                                  bonoSee = 'nadie';
                                });
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                  bottom: widget.height * 0.03,
                                  right: widget.height * 0.02),

                              child: Container(
                                height: widget.width * 0.1,
                                width: widget.width * 0.32,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                    ),
                                    borderRadius:
                                    const BorderRadius.all(Radius.circular(20))),
                                child: Align(
                                  alignment: Alignment.center,
                                  //padding: EdgeInsets.symmetric(horizontal: widget.width * 0.06, vertical: widget.width * 0.02),
                                  child: Text(
                                    bono.isActive!? 'Desactivar'.toUpperCase() : 'Activar'.toUpperCase(),
                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ) : Container(),
                   */
                ],
              ),
            ),
            bonoSee == bono.id! ? Text(
              bono.title!.toUpperCase(),
              style: Theme.of(context)
                  .textTheme
                  .headline1
                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.left,
            ) : Container(),
          ],
        ),
      ),
    );

  }

  // Navigate to Add Bonos
  void navigateToAddBonosScreen(Bono bono, Brand brand, bool edit) {
    Bono bonoNew = Bono();
    bonoNew = bono;
    Navigator.push(
        context,
        CupertinoPageRoute<Null>(
          builder: (context) =>  AddEditBono(
            brand: brand,
            bono: bono,
            edit: edit,
          ),
        )).whenComplete(() => () {
          bono = Bono();
      setState(() {
      });
    });
  }
}