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
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/SelectEventUsers/BonosDEL%C3%87.dart';

import '../../../../Data/LibraryModels/lColor.dart';
import '../../../../Data/LibraryModels/lDegradate.dart';
import '../../../../Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/AddEditBono.dart';

class BonoCard extends StatefulWidget {
  // Variables per omplir Bono i Size
  double height = 0;
  double width = 0;
  Bono bono;
  Brand brand;
  Condition condition;
  // Booleans de que fer amb el Bono
  bool canExpand;
  bool? isExpanded;
  bool? onlyView;

  BonoCard(
      {Key? key,
      required this.height,
      required this.width,
      required this.bono,
      required this.brand,
      required this.canExpand,
      this.isExpanded,
      required this.onlyView,
      required this.condition})
      : super(key: key);

  @override
  BonoCardState createState() => BonoCardState();
}

class BonoCardState extends State<BonoCard> {

  // Models i base de Dades
  Bono bono = Bono();
  Brand brand = Brand();
  final _brandDataService = BrandDataService();
  Condition condition = Condition();
  // Variables Colors
  final _lDegradate = lDegradate();
  final _lColor = lColor();
  // Booleans
  bool isExpanded = false;
  double isExpandedHeight = 2.5;

  @override
  void initState() {
    bono = widget.bono;
    brand = widget.brand;
    if (widget.isExpanded != null && widget.isExpanded!) {
      isExpanded = true;
    }
    if (widget.onlyView == true) {
      condition = widget.condition;
    } else {
      getCondition();
      print(bono.title.toString());
      if (condition.expirationTime != 0) {
        isExpandedHeight = isExpandedHeight + 0.33;
      }
      if (condition.weeklySessions != 0) {
        isExpandedHeight = isExpandedHeight + 0.33;
      }
      if (condition.cancelTime != 0) {
        isExpandedHeight = isExpandedHeight + 0.33;
      }
    }
    super.initState();

  }

  void getCondition() async {
    condition = await _brandDataService.getConditionInfo(widget.brand.id!, bono.id!);
  }

  @override
  void didUpdateWidget(BonoCard oldWidget) {
    if (bono != widget.bono) {
      setState(() {
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
        if (bono.isActive! && widget.canExpand == true || widget.onlyView! && widget.canExpand) {
          isExpanded = !isExpanded;
          setState(() {});
        }
      },
      child: AnimatedContainer(
        constraints: BoxConstraints(
          minHeight: widget.height,
          minWidth: widget.width,
          maxWidth: widget.width,
        ),
        height: isExpanded ? widget.height * isExpandedHeight : widget.height,
        decoration: bono.isDegradate!
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(int.parse(
                            _lDegradate.getlDegradate(bono.color!).hexa1!))
                        .withOpacity(bono.opacity!),
                    Color(int.parse(
                            _lDegradate.getlDegradate(bono.color!).hexa2!))
                        .withOpacity(bono.opacity!),
                  ],
                ),
                image: bono.imageUrl != null && bono.imageUrl != ''
                    ? DecorationImage(
                        opacity: 225,
                        image: NetworkImage(bono.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
                borderRadius: const BorderRadius.all(Radius.circular(10)))
            : BoxDecoration(
                image: bono.imageUrl != null && bono.imageUrl != ''
                    ? DecorationImage(
                        opacity: 225,
                        image: NetworkImage(bono.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: Color(int.parse(_lColor.getlColor(bono.color!).hexa!))
                    .withOpacity(bono.opacity!),
                borderRadius: const BorderRadius.all(Radius.circular(10))),
        // Animation
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
        child: Column(
          children: [
            Container(
              width: widget.width,
              padding: EdgeInsets.only(right: widget.width * 0.05, left: widget.width * 0.05, top: widget.width * 0.05, bottom: !isExpanded ? widget.width * 0.05 : 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // 20%
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: widget.height * 0.2,
                        width: widget.width * 0.15,
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
                        width: widget.width * 0.6,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              brand.name!.toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headline3
                                  ?.copyWith(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: widget.height * 0.3),

                  //30%
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: widget.height * 0.15,
                            width: widget.width * 0.7,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  bono.title!.toUpperCase(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline1
                                      ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ),
                          isExpanded == false ? SizedBox(
                              height: widget.height * 0.15,
                              width: widget.width * 0.1
                          ) : SizedBox(
                            height: widget.height * 0.15,
                            width: widget.width * 0.1,
                            child: Align(
                              alignment: Alignment.center,
                              child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: isExpanded
                                      ? Icon(
                                    Icons.expand_less,
                                    size: widget.width * 0.1,
                                  )
                                      : Icon(
                                    Icons.expand_more,
                                    size: widget.width * 0.1,
                                  )),
                            ),
                          ),
                        ],
                      ),
                      isExpanded == false ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: widget.height * 0.15,
                            width: widget.width * 0.8,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Row(
                                  children: [
                                    Text(
                                      bono.price!
                                          .toStringAsFixed(2)
                                          .toUpperCase() +
                                          '€',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          ?.copyWith(color: Colors.white),
                                      textAlign: TextAlign.left,
                                    ),
                                    SizedBox(
                                      width: widget.width * 0.05,
                                    ),
                                    bono.classes == 100000 ? Text(
                                      AppLocalizations.of(context)!
                                              .sessions
                                              .toUpperCase()+" ILIMITADAS",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          ?.copyWith(color: Colors.white),
                                      textAlign: TextAlign.left,
                                    ) : Text(
                                      bono.classes!
                                          .toString()
                                          .toUpperCase() +
                                          ' ' +
                                          AppLocalizations.of(context)!
                                              .sessions
                                              .toUpperCase(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          ?.copyWith(color: Colors.white),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: widget.height * 0.15,
                            width: widget.width * 0.1,
                            child: Align(
                              alignment: Alignment.center,
                              child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: isExpanded
                                      ? Icon(
                                    Icons.expand_less,
                                    size: widget.width * 0.1,
                                  )
                                      : Icon(
                                    Icons.expand_more,
                                    size: widget.width * 0.1,
                                  )),
                            ),
                          ),
                        ],
                      ) : Container(),
                    ],
                  ),
                ],
              ),
            ),
            isExpanded ? Expanded(
              child: SizedBox(
                height: widget.height * isExpandedHeight*2 - widget.height,
                width: widget.width,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: widget.height*0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: widget.width*0.9,
                        child: Text(
                          bono.description!,
                          style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white70),
                          textAlign: TextAlign.left,
                          maxLines: 4,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      SizedBox(height: widget.height*0.15,),
                      SizedBox(
                        width: widget.width*0.9,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: widget.width*0.4,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Nº SESIONES",
                                        style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold, color: Colors.white70),
                                        textAlign: TextAlign.left,
                                      ),
                                      SizedBox(height: widget.width*0.02,),
                                      Text(
                                        bono.classes!.toString(),
                                        style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white70),
                                        textAlign: TextAlign.left,
                                        maxLines: 4,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: widget.width*0.4,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "DISPONIBILIDAD",
                                        style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold, color: Colors.white70),
                                        textAlign: TextAlign.left,
                                      ),
                                      SizedBox(height: widget.width*0.02,),
                                      Text(
                                        "Activo",
                                        style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white70),
                                        textAlign: TextAlign.left,
                                        maxLines: 4,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: widget.width*0.05,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: widget.width*0.7,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "PRECIO",
                                        style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold, color: Colors.white70),
                                        textAlign: TextAlign.left,
                                      ),
                                      SizedBox(height: widget.width*0.02,),
                                      Row(
                                        children: [
                                          Text(
                                            bono.price!.toStringAsFixed(2)+" €",
                                            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white70),
                                            textAlign: TextAlign.left,
                                            maxLines: 4,
                                            overflow: TextOverflow.visible,
                                          ),
                                          SizedBox(width: widget.width*0.05,),
                                          Text(
                                            "("+(bono.price!/bono.classes!).toStringAsFixed(2)+" €/sesión)",
                                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.white70),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: widget.height*0.15,),
                      SizedBox(
                        width: widget.width*0.9,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: widget.width*0.9,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "CONDICIONES",
                                        style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold, color: Colors.white70),
                                        textAlign: TextAlign.left,
                                      ),
                                      SizedBox(height: widget.width*0.02,),
                                      condition.expirationTime != 0 ? ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        minLeadingWidth: widget.width*0.07,
                                        leading: Icon(
                                            Icons.query_builder_outlined,
                                            size: widget.width*0.07,
                                            color: Colors.white70),
                                        title: Text(
                                          "Expira en 30 días",
                                          style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white70),
                                        )
                                      ) : Container(),
                                      condition.cancelTime != 0 ? ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        minLeadingWidth: widget.width*0.07,
                                        leading: Icon(
                                            Icons.free_cancellation,
                                            size: widget.width*0.07,
                                            color: Colors.white70),
                                        title: Text(
                                          "Cancelacion gratuita hasta 8 horas",
                                          style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white70),
                                        )
                                      ) : Container(),
                                      condition.weeklySessions != 0 ? ListTile(
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                          minLeadingWidth: widget.width*0.07,
                                          leading: Icon(
                                              Icons.rule_outlined,
                                              size: widget.width*0.07,
                                              color: Colors.white70),
                                          title: Text(
                                            "Máximo 3 entrenos por semana",
                                            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white70),
                                          )
                                      ) : Container(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: widget.height*0.05,),
                      GestureDetector(
                        onTap: () => navigateToAddBonosScreen(bono, brand, true),
                        child: Container(
                          height: widget.height*0.3,
                          width: widget.width*0.9,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.edit,
                              style: Theme.of(context).textTheme.headline3?.copyWith(color: AppColors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ) : Container(),
          ],
        ),

        /*
                      Padding(
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
                      */
        /*
                      !bono.isActive! && !widget.onlyView! ? GestureDetector(
                        onTap: () {
                          if(widget.onlyView == false) {
                            bono.isActive = !bono.isActive!;
                            _brandDataService.updateBonoActive(
                                brand.id!, bono.id!, bono.isActive!);
                            setState(() {
                              bonoSee = 'nadie';
                            });
                          }
                        },
                        child:  Container(
                          constraints: BoxConstraints(
                            minHeight: widget.height,
                            minWidth: widget.width,
                            maxWidth: widget.width,
                          ),
                          height: bonoSee == bono.id! ? widget.height * widthOpen : widget.height,
                          width: widget.width,
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

                      ) : Container(),
        */

        /*
        Stack(
          children: [
            Column(
            children: [
              Container(
                height: widget.height,
                width: widget.width,
                padding: EdgeInsets.all(widget.width * 0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: widget.height * 0.2,
                          width: widget.width * 0.15,
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
                          width: widget.width * 0.6,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Text(
                                brand.name!.toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3
                                    ?.copyWith(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white),
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
                              width: widget.width * 0.7,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    bono.title!.toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline1
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
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
                              width: widget.width * 0.8,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Row(
                                    children: [
                                      Text(
                                        bono.price!
                                                .toStringAsFixed(2)
                                                .toUpperCase() +
                                            '€',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            ?.copyWith(color: Colors.white),
                                        textAlign: TextAlign.left,
                                      ),
                                      Text(
                                        (bono.price!/bono.classes!)
                                            .toStringAsFixed(2)
                                            .toUpperCase() +
                                            '€/S',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            ?.copyWith(color: Colors.white70),
                                        textAlign: TextAlign.left,
                                      ),
                                      SizedBox(
                                        width: widget.width * 0.05,
                                      ),
                                      bono.classes == 100000
                                          ? Text(
                                              '∞ ' +
                                                  AppLocalizations.of(context)!
                                                      .sessions
                                                      .toUpperCase(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  ?.copyWith(color: Colors.white),
                                              textAlign: TextAlign.left,
                                            )
                                          : Text(
                                              bono.classes!
                                                      .toString()
                                                      .toUpperCase() +
                                                  ' ' +
                                                  AppLocalizations.of(context)!
                                                      .sessions
                                                      .toUpperCase(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  ?.copyWith(color: Colors.white),
                                              textAlign: TextAlign.left,
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: widget.height * 0.2,
                              width: widget.width * 0.1,
                              child: Align(
                                alignment: Alignment.center,
                                child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: bonoSee != bono.id!
                                        ? Icon(
                                            Icons.expand_more,
                                            size: widget.width * 0.1,
                                          )
                                        : Icon(
                                            Icons.expand_less,
                                            size: widget.width * 0.1,
                                          )),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    /*
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
                                if(widget.onlyView == false) {
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
                                if(widget.onlyView == false) {
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
              bonoSee == bono.id!
                  ? Container(
                      height: widget.height * widthOpen - widget.height,
                      width: widget.width,
                      padding: EdgeInsets.symmetric(
                          vertical: widget.width * 0.005,
                          horizontal: widget.width * 0.05),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: widget.height * 0.30,//(0.15 + bono.description!.length/100),
                                width: widget.width * 0.9,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            bono.description!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                ?.copyWith(color: Colors.white70),
                                            textAlign: TextAlign.left,
                                            maxLines: 4,
                                            overflow: TextOverflow.visible,
                                          ),
                                        ),
                                      ],
                                    ),

                                ),
                              )
                            ],
                          ),
                          Column(
                              children: [
                            widthOpen != 2.5
                                ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: widget.height * 0.20,
                                        width: widget.width * 0.7,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Text(
                                              'CONDICIONES',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                            condition.expirationTime != 0
                                ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: widget.height * 0.30,
                                        width: widget.width * 0.7,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                            child: Text(
                                              '- Este bono expira pasados los ' +
                                                  condition.expirationTime
                                                      .toString() +
                                                  ' dias',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.white70),
                                              textAlign: TextAlign.left,
                                            ),

                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                            condition.weeklySessions != 0
                                ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: widget.height * 0.30,
                                        width: widget.width * 0.7,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                            child: Flexible(
                                              child: Text(
                                                '- El usuario no puede usar el bono más de ' +
                                                    condition.weeklySessions
                                                        .toString() +
                                                    ' veces por semana',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.white70),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),

                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                            condition.cancelTime != 0
                                ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: widget.height * 0.30,
                                        width: widget.width * 0.7,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                            child: Text(
                                              '- Tiene cancelación gratuita ' +
                                                  condition.cancelTime
                                                      .toString() +
                                                  ' hora/s antes del evento',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.white70),
                                              textAlign: TextAlign.left,
                                            ),

                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                          ]),
                          widget.clientView
                              ? GestureDetector(
                                onTap: () {
                                  if(widget.onlyView == false) {
                                    _brandDataService.addBonoRequestToBrand(brand.id!, currentUser.id!, bono.id!, bono.title!, bono.price, bono.classes, Timestamp.now());
                                  }
                                },
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: widget.height * 0.60,
                                        width: widget.width * 0.85,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Container(
                                              height: widget.width * 0.2,
                                              width: widget.width * 0.9,
                                              decoration: BoxDecoration(
                                                color: AppColors.darkGrey,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(30))),
                                              child: Align(
                                                alignment: Alignment.center,
                                                //padding: EdgeInsets.symmetric(horizontal: widget.width * 0.06, vertical: widget.width * 0.02),
                                                child: Text(
                                                  'comprar'.toUpperCase(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1
                                                      ?.copyWith(
                                                          color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if(widget.onlyView == false) {
                                          navigateToAddBonosScreen(bono, brand, true);
                                        }
                                      },
                                      child: SizedBox(
                                        height: widget.height * 0.60,
                                        width: widget.width * 0.40,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Container(
                                              height: widget.width * 0.2,
                                              width: widget.width * 0.35,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.white,
                                                  ),
                                                  borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(30))),
                                              child: Align(
                                                alignment: Alignment.center,
                                                //padding: EdgeInsets.symmetric(horizontal: widget.width * 0.06, vertical: widget.width * 0.02),
                                                child: Text(
                                                  AppLocalizations.of(context)!
                                                      .edit.toUpperCase().toUpperCase(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1
                                                      ?.copyWith(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if(widget.onlyView == false) {
                                          bono.isActive = !bono.isActive!;
                                          _brandDataService.updateBonoActive(
                                              brand.id!, bono.id!, bono.isActive!);
                                          setState(() {
                                            bonoSee = 'nadie';
                                          });
                                        }
                                      },
                                      child: SizedBox(
                                        height: widget.height * 0.60,
                                        width: widget.width * 0.50,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Container(
                                              height: widget.width * 0.2,
                                              width: widget.width * 0.35,
                                              decoration: BoxDecoration(
                                                  color: AppColors.darkGrey,
                                                  borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(30))),
                                              child: Align(
                                                alignment: Alignment.center,
                                                //padding: EdgeInsets.symmetric(horizontal: widget.width * 0.06, vertical: widget.width * 0.02),
                                                child: Text(
                                                  'desactivar'.toUpperCase(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1
                                                      ?.copyWith(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                        ],
                      ),
                    )
                  : Container(),
/*
              Padding(
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
              */
/*
              !bono.isActive! && !widget.onlyView! ? GestureDetector(
                onTap: () {
                  if(widget.onlyView == false) {
                    bono.isActive = !bono.isActive!;
                    _brandDataService.updateBonoActive(
                        brand.id!, bono.id!, bono.isActive!);
                    setState(() {
                      bonoSee = 'nadie';
                    });
                  }
                },
                child:  Container(
                  constraints: BoxConstraints(
                    minHeight: widget.height,
                    minWidth: widget.width,
                    maxWidth: widget.width,
                  ),
                  height: bonoSee == bono.id! ? widget.height * widthOpen : widget.height,
                  width: widget.width,
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

              ) : Container(),
*/

            ],
          ),
            /*
            !bono.isActive! && !widget.onlyView! ?
            Container(
              height: widget.height,
              width: widget.width * 1.4,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius:
                BorderRadius.all(Radius.circular(10)),),

              child: GestureDetector(
                onTap: () {
                  if(widget.onlyView == false) {
                    bono.isActive = !bono.isActive!;
                    _brandDataService.updateBonoActive(brand.id!, bono.id!, bono.isActive!);
                    setState(() {
                      bonoSee = 'nadie';
                    });
                  }
                },
                child:  Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: widget.height * 0.3,
                    width: widget.width * 0.4,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        borderRadius:
                        const BorderRadius.all(Radius.circular(30))),
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
            ) : Container(),
             */


      ],
        ),
         */
      ),
    );
  }

  // Navigate to Add Bonos
  void navigateToAddBonosScreen(Bono bono, Brand brand, bool edit) {
    Bono bonoNew = Bono();
    bonoNew = bono;
    Navigator.push(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => AddEditBono(
            brand: brand,
            bono: bono,
            edit: edit,
          ),
        )).whenComplete(() => () {
          bono = Bono();
          setState(() {});
        });
  }
}
