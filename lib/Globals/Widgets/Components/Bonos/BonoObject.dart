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

class BonoObject extends StatefulWidget {
  Bono bono;
  Brand brand;
  bool view;
  bool clientView;

  BonoObject({Key? key, required this.bono,required this.brand, required this.view, required this.clientView }) : super(key: key);

  @override
  bonoObjectState createState() => new bonoObjectState();
}

class bonoObjectState extends State<BonoObject> {

  var _lDegradate = new lDegradate();
  var _lColor = new lColor();
  Bono bono = new Bono(
  );
  Brand brand = new Brand();
  final _brandDataService = BrandDataService();
  String bonoSee = 'nadie';
  Condition condition = new Condition();

  @override
  void initState() {
    bono = widget.bono;
    brand = widget.brand;
    getCondition();
    super.initState();
  }

  void getCondition() async
  {
    condition =  await _brandDataService.getConditionInfo(widget.brand.id!, bono.id!);
  }

  @override
  void didUpdateWidget(BonoObject oldWidget) {
    if(bono != widget.bono) {
      setState((){
        bono = widget.bono;
      });
    }
    super.didUpdateWidget(oldWidget);

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return
    GestureDetector(
      onTap: () {
        if(bono.isActive! || widget.view == true) {
          if (bonoSee == bono.id!) {
            bonoSee = 'nadie';
          }
          else {
            bonoSee = bono.id!;
          }
          setState(() {});
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.width * 0.0,
            horizontal: MediaQuery.of(context).size.width * 0.065),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              height:  bonoSee == bono.id!? MediaQuery.of(context).size.width * 1.5 : MediaQuery.of(context).size.width * 0.50,
              width: MediaQuery.of(context).size.width * 0.85,
              decoration:  bono.isDegradate! ?  BoxDecoration(
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


                  //color: Color(int.parse(_lColor.getlColor(bono.color!).hexa!)),
                  borderRadius:
                  const BorderRadius.all(const Radius.circular(15))) : BoxDecoration(
                  image: bono.imageUrl != null && bono.imageUrl != ''? DecorationImage(
                    opacity: 225,

                    image:  NetworkImage(bono.imageUrl!),
                    fit: BoxFit.cover,
                  ) : null,
                  color: Color(int.parse(_lColor.getlColor(bono.color!).hexa!)).withOpacity(bono.opacity!),
                  borderRadius:
                  const BorderRadius.all(const Radius.circular(15))),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.015,
                  left: MediaQuery.of(context).size.height * 0.03),
              child: Align(
                alignment: Alignment.topLeft,
                child: CircularImage(
                  size: MediaQuery.of(context).size.width * 0.10,
                  image: brand.logoUrl,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02,
                  right: MediaQuery.of(context).size.height * 0.03),
              child: Align(
                alignment: Alignment.topRight,
                child: Text(
                  brand.name!.toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .headline3
                      ?.copyWith(fontWeight: FontWeight.normal, color: Colors.white),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.13,
                  left: MediaQuery.of(context).size.height * 0.005),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.width * 0.01,
                      horizontal: MediaQuery.of(context).size.width * 0.005),
                  child: ListTile(
                      title: Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.01,
                            left: MediaQuery.of(context).size.height * 0.01),
                        child: Text(
                          bono.title!.toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .headline1
                              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.01,
                            left: MediaQuery.of(context).size.height * 0.01),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  right: MediaQuery.of(context).size.height * 0.02),
                              child: Text(
                                bono.price!.toString().toUpperCase() + '€',
                                style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),
                                textAlign: TextAlign.left,
                              ),
                            ),
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
                            SizedBox(width: MediaQuery.of(context).size.width * 0.27),
                            bonoSee != bono.id!? Icon(
                              Icons.more_horiz_outlined,
                              size: MediaQuery.of(context).size.width * 0.07,
                            ) : Icon(
                              Icons.more_horiz_outlined,
                              size: MediaQuery.of(context).size.width * 0.07,
                              color: Colors.transparent,
                            )
                          ],
                        ),
                      )),

                ),
              ),
            ),
            !bono.isActive! && widget.view == false? Container(
              height: MediaQuery.of(context).size.width * 0.50,
              width: MediaQuery.of(context).size.width * 0.85,
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
                    height: MediaQuery.of(context).size.width * 0.1,
                    width: MediaQuery.of(context).size.width * 0.32,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                        ),
                        borderRadius:
                        const BorderRadius.all(const Radius.circular(20))),
                    child: Align(
                      alignment: Alignment.center,
                      //padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06, vertical: MediaQuery.of(context).size.width * 0.02),
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
                    top: MediaQuery.of(context).size.height * 0.30,
                    left: MediaQuery.of(context).size.height * 0.035,
                    right: MediaQuery.of(context).size.height * 0.04),
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
                    top: MediaQuery.of(context).size.height * 0.60,
                    right: MediaQuery.of(context).size.height * 0.01),
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
                            vertical: MediaQuery.of(context).size.height * 0.03,
                            horizontal: MediaQuery.of(context).size.height * 0.01),
                        child: Container(
                          height: MediaQuery.of(context).size.width * 0.1,
                          width: MediaQuery.of(context).size.width * 0.32,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                              ),
                              borderRadius:
                              const BorderRadius.all(const Radius.circular(20))),
                          child: Align(
                            alignment: Alignment.center,
                            //padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06, vertical: MediaQuery.of(context).size.width * 0.02),
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
                            bottom: MediaQuery.of(context).size.height * 0.03,
                            right: MediaQuery.of(context).size.height * 0.02),

                        child: Container(
                          height: MediaQuery.of(context).size.width * 0.1,
                          width: MediaQuery.of(context).size.width * 0.32,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                              ),
                              borderRadius:
                              const BorderRadius.all(const Radius.circular(20))),
                          child: Align(
                            alignment: Alignment.center,
                            //padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06, vertical: MediaQuery.of(context).size.width * 0.02),
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
          ],
        ),
      ),
    );

  }

  // Navigate to Add Bonos
  void navigateToAddBonosScreen(Bono bono, Brand brand, bool edit) {
    Bono bonoNew = new Bono();
    bonoNew = bono;
    Navigator.push(
        context,
        new CupertinoPageRoute<Null>(
          builder: (context) =>  new AddEditBono(
            brand: brand,
            bono: bono,
            edit: edit,
          ),
        )).whenComplete(() => () {
          bono = new Bono();
      setState(() {
      });
    });
  }
}