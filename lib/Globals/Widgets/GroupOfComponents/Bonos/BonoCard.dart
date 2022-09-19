import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/Models/Condition.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import '../../../../Data/LibraryModels/lColor.dart';
import '../../../../Data/LibraryModels/lDegradate.dart';
import '../../../../Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/AddEditBono.dart';

class BonoCard extends StatefulWidget {
  // Variables per omplir Bono i Size
  double height = 0;
  double width = 0;
  Bono bono;
  Brand brand;
  Condition? condition;

  // Booleans de que fer amb el Bono
  bool canExpand;
  bool? isExpanded;
  bool? onlyView;
  bool? clientView;

  BonoCard({
    Key? key,
    required this.height,
    required this.width,
    required this.bono,
    required this.brand,
    this.condition,
    required this.canExpand,
    this.isExpanded,
    this.clientView,
    required this.onlyView,
  }) : super(key: key);

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
  double isExpandedHeight = 2;

  @override
  void initState() {
    bono = widget.bono;
    brand = widget.brand;
    if (widget.isExpanded != null && widget.isExpanded!) {
      isExpanded = true;
    }
    if (widget.onlyView == false) {
      isExpandedHeight = isExpandedHeight + 0.4;
    }
    if (widget.condition == null) {
      getCondition();
    } else {
      condition = widget.condition!;
    }
    //if (condition.expirationTime != 0) {
      isExpandedHeight = isExpandedHeight + 0.35;
    //}
    if (condition.cancelTime != 0) {
      isExpandedHeight = isExpandedHeight + 0.35;
    }
    if (condition.weeklySessions != 0) {
      isExpandedHeight = isExpandedHeight + 0.35;
    }
    super.initState();
  }

  void getCondition() async {
    condition =
        await _brandDataService.getConditionInfo(widget.brand.id!, bono.id!);
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
        if (widget.canExpand == true ||
            widget.onlyView! && widget.canExpand) {
          isExpanded = !isExpanded;
          setState(() {});
        }
      },
      child: Stack(children: [
        AnimatedContainer(
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
                  borderRadius: BorderRadius.all(Radius.circular(widget.width*0.03)))
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
                  borderRadius: BorderRadius.all(Radius.circular(widget.width*0.03))),
          // Animation
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          child: Column(
            children: [
              Container(
                width: widget.width,
                padding: EdgeInsets.only(
                    right: widget.width * 0.05,
                    left: widget.width * 0.05,
                    top: widget.width * 0.05,
                    bottom: !isExpanded ? widget.width * 0.05 : 0),
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
                    SizedBox(height: widget.height * 0.29),

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
                            isExpanded == false
                                ? SizedBox(
                                    height: widget.height * 0.15,
                                    width: widget.width * 0.1)
                                : SizedBox(
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
                                                    color: AppColors.white
                                                )
                                              : Icon(
                                                  Icons.expand_more,
                                                  size: widget.width * 0.1,
                                                  color: AppColors.white
                                                )),
                                    ),
                                  ),
                          ],
                        ),
                        isExpanded == false
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                                  ?.copyWith(
                                                      color: Colors.white),
                                              textAlign: TextAlign.left,
                                            ),
                                            SizedBox(
                                              width: widget.width * 0.05,
                                            ),
                                            bono.classes == 0
                                                ? Text(
                                                    AppLocalizations.of(
                                                                context)!
                                                            .sessions
                                                            .toUpperCase() +
                                                        " " +  AppLocalizations.of(
                                                        context)!.ilimitadas.toUpperCase(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        ?.copyWith(
                                                            color:
                                                                Colors.white),
                                                    textAlign: TextAlign.left,
                                                  )
                                                : Text(
                                                    bono.classes!
                                                            .toString()
                                                            .toUpperCase() +
                                                        ' ' +
                                                        AppLocalizations.of(
                                                                context)!
                                                            .sessions
                                                            .toUpperCase(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        ?.copyWith(
                                                            color:
                                                                Colors.white),
                                                    textAlign: TextAlign.left,
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  widget.canExpand == false
                                      ? SizedBox(
                                          height: widget.height * 0.15,
                                          width: widget.width * 0.1)
                                      : SizedBox(
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
                                                        color: AppColors.white
                                                      )
                                                    : Icon(
                                                        Icons.expand_more,
                                                        size: widget.width * 0.1,
                                                        color: AppColors.white
                                                      )),
                                          ),
                                        ),
                                ],
                              )
                            : Container(),
                      ],
                    ),
                  ],
                ),
              ),
              isExpanded
                  ? Expanded(
                      child: SizedBox(
                        height: widget.height * isExpandedHeight * 2 -
                            widget.height,
                        width: widget.width,
                        child: Padding(
                          padding: EdgeInsets.only(top: widget.height * 0.1),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: widget.width * 0.9,
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
                              SizedBox(
                                height: widget.height * 0.15,
                              ),
                              SizedBox(
                                width: widget.width * 0.9,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: widget.width * 0.4,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                              AppLocalizations.of(
                                              context)!.numberSessions.toUpperCase(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                    color: AppColors.white
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                              SizedBox(
                                                height: widget.width * 0.02,
                                              ),
                                              bono.classes == 0?
                                              Text(
                                                AppLocalizations.of(
                                                    context)!.ilimitadas.toUpperCase(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    ?.copyWith(
                                                    color: Colors.white70),
                                                textAlign: TextAlign.left,
                                                maxLines: 4,
                                                overflow: TextOverflow.visible,
                                              ) :
                                              Text(
                                                bono.classes!.toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    ?.copyWith(
                                                        color: Colors.white70),
                                                textAlign: TextAlign.left,
                                                maxLines: 4,
                                                overflow: TextOverflow.visible,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: widget.width * 0.4,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppLocalizations.of(
                                                    context)!.disponibilidad.toUpperCase(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                    color: AppColors.white),
                                                textAlign: TextAlign.left,
                                              ),
                                              SizedBox(
                                                height: widget.width * 0.02,
                                              ),
                                              Text(
                                                bono.isActive!? AppLocalizations.of(
                                                    context)!.active : AppLocalizations.of(
                                                    context)!.desactive,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    ?.copyWith(
                                                        color: Colors.white70),
                                                textAlign: TextAlign.left,
                                                maxLines: 4,
                                                overflow: TextOverflow.visible,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: widget.width * 0.05,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: widget.width * 0.7,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppLocalizations.of(
                                                    context)!.price.toUpperCase(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                    color: AppColors.white),
                                                textAlign: TextAlign.left,
                                              ),
                                              SizedBox(
                                                height: widget.width * 0.02,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    bono.price!.toStringAsFixed(
                                                            2) +
                                                        " €",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        ?.copyWith(
                                                            color:
                                                                Colors.white70),
                                                    textAlign: TextAlign.left,
                                                    maxLines: 4,
                                                    overflow:
                                                        TextOverflow.visible,
                                                  ),
                                                  SizedBox(
                                                    width: widget.width * 0.05,
                                                  ),
                                                  bono.classes == 0?
                                                  Container()
                                                  :
                                                    Text(
                                                    "(" +
                                                        (bono.price! /
                                                                bono.classes!)
                                                            .toStringAsFixed(
                                                                2) +
                                                        " €/" + AppLocalizations.of(
                                                        context)!.session + ')',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2
                                                        ?.copyWith(
                                                            color:
                                                                Colors.white70),
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
                              SizedBox(
                                height: widget.height * 0.15,
                              ),
                               SizedBox(
                                width: widget.width * 0.9,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: widget.width * 0.9,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppLocalizations.of(
                                                    context)!.conditions.toUpperCase(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                    color: AppColors.white),
                                                textAlign: TextAlign.left,
                                              ),
                                              SizedBox(
                                                height: widget.width * 0.02,
                                              ),
                                              condition.expirationTime != 0
                                                  ? ListTile(
                                                      dense: true,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      minLeadingWidth:
                                                          widget.width * 0.07,
                                                      leading: Icon(
                                                          Icons
                                                              .query_builder_outlined,
                                                          size: widget.width *
                                                              0.07,
                                                          color:
                                                              Colors.white70),
                                                      title: Text(
                                                        AppLocalizations.of(
                                                            context)!.expiresAt + " " +
                                                            condition
                                                                .expirationTime
                                                                .toString() +
                                                            " " + AppLocalizations.of(
                                                            context)!.days.toLowerCase(),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1
                                                            ?.copyWith(
                                                                color: Colors
                                                                    .white70),
                                                      ))
                                                  : ListTile(
                                                  dense: true,
                                                  contentPadding:
                                                  EdgeInsets.zero,
                                                  minLeadingWidth:
                                                  widget.width * 0.07,
                                                  leading: Icon(
                                                      Icons
                                                          .query_builder_outlined,
                                                      size: widget.width *
                                                          0.07,
                                                      color:
                                                      Colors.white70),
                                                  title: Text(
                                                    AppLocalizations.of(
                                                        context)!.noExpireDate,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        ?.copyWith(
                                                        color: Colors
                                                            .white70),
                                                  )),
                                              condition.cancelTime != 0
                                                  ? ListTile(
                                                      dense: true,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      minLeadingWidth:
                                                          widget.width * 0.07,
                                                      leading: Icon(
                                                          Icons
                                                              .free_cancellation,
                                                          size: widget.width *
                                                              0.07,
                                                          color:
                                                              Colors.white70),
                                                      title: Text(
                                                        AppLocalizations.of(
                                                            context)!.cancelTimeAt + " " +
                                                            condition.cancelTime
                                                                .toString() +
                                                            " " + AppLocalizations.of(
                                                            context)!.hours.toLowerCase(),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1
                                                            ?.copyWith(
                                                                color: Colors
                                                                    .white70),
                                                      ))
                                                  : Container(),
                                              condition.weeklySessions != 0
                                                  ? ListTile(
                                                      dense: true,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      minLeadingWidth:
                                                          widget.width * 0.07,
                                                      leading: Icon(
                                                          Icons.rule_outlined,
                                                          size: widget.width *
                                                              0.07,
                                                          color:
                                                              Colors.white70),
                                                      title: Text(
                                                        AppLocalizations.of(
                                                            context)!.max + " " +
                                                            condition
                                                                .weeklySessions
                                                                .toString() +
                                                            " " + AppLocalizations.of(
                                                            context)!.trainsPerWeek.toLowerCase(),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1
                                                            ?.copyWith(
                                                                color: Colors
                                                                    .white70),
                                                      ))
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                               SizedBox(
                                height: widget.height * 0.05,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(),
              isExpanded && widget.onlyView == false
                  ? GestureDetector(
                      onTap: () {
                        if (widget.onlyView != null &&
                            widget.onlyView == false) {
                          navigateToAddBonosScreen(bono, brand, true);
                        }
                      },
                      child: Container(
                        height: widget.height * 0.4,
                        width: widget.width,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.clientView != null &&
                                    widget.clientView == true
                                ? AppLocalizations.of(
                                context)!.buy
                                : AppLocalizations.of(context)!.edit,
                            style: Theme.of(context)
                                .textTheme
                                .headline3
                                ?.copyWith(color: Theme.of(context).primaryColorDark),
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
        !bono.isActive! && !widget.onlyView!? AnimatedContainer(
          constraints: BoxConstraints(
            minHeight: widget.height,
            minWidth: widget.width,
            maxWidth: widget.width,
          ),
          height: isExpanded ? widget.height * isExpandedHeight : widget.height,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          // Animation
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          child: Column(
            children: [
              Container(
                width: widget.width,
                padding: EdgeInsets.only(
                    right: widget.width * 0.05,
                    left: widget.width * 0.05,
                    top: widget.width * 0.05,
                    bottom: !isExpanded ? widget.width * 0.05 : 0),

              ),
              isExpanded
                  ? Expanded(
                child: SizedBox(
                  height: widget.height * isExpandedHeight * 2 -
                      widget.height,
                  width: widget.width,
                  child: Padding(
                    padding: EdgeInsets.only(top: widget.height * 0.1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: widget.width * 0.9,
                        ),
                        SizedBox(
                          height: widget.height * 0.15,
                        ),
                        SizedBox(
                          width: widget.width * 0.9,
                        ),
                        SizedBox(
                          height: widget.height * 0.15,
                        ),
                        SizedBox(
                          width: widget.width * 0.9,
                        ),
                        SizedBox(
                          height: widget.height * 0.05,
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  : Container(),
              isExpanded && widget.onlyView == false
                  ? GestureDetector(
                onTap: () {
                  if (widget.onlyView != null &&
                      widget.onlyView == false) {
                    navigateToAddBonosScreen(bono, brand, true);
                  }
                },
                child: Container(
                  height: widget.height * 0.4,
                  width: widget.width,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      widget.clientView != null &&
                          widget.clientView == true
                          ? AppLocalizations.of(
                          context)!.buy
                          : AppLocalizations.of(context)!.edit,
                      style: Theme.of(context)
                          .textTheme
                          .headline3
                          ?.copyWith(color: Theme.of(context).primaryColorDark),
                    ),
                  ),
                ),
              )
                  : Container(),
            ],
          ),
        ) : Container(),
      ]
      ),
    );
  }

  // Navigate to Add Bonos
  void navigateToAddBonosScreen(Bono bono, Brand brand, bool edit) {
    Bono bonoNew = Bono();
    bonoNew = bono;
    isExpanded = false;
    Navigator.push(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => AddEditBono(
            brand: brand,
            bono: bono,
            edit: edit,
          ),
        ));
  }
}
