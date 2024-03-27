import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/LibraryModels/lColor.dart';
import 'package:mamba/data/LibraryModels/lDegradate.dart';
import 'package:mamba/data/Models/Bono.dart';
import 'package:mamba/data/Models/BonoRequest.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/l10n/language_manager.dart';
import 'package:mamba/data/Models/Condition.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/commons/utils/Bonos/BonosUtils.dart';
import 'package:mamba/commons/utils/Strings/StringUtils.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/AddEditBono.dart';

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
  bool? hideActive;
  bool? isDynamic;

  BonoCard({
    super.key,
    required this.height,
    required this.width,
    required this.bono,
    required this.brand,
    this.condition,
    required this.canExpand,
    this.isExpanded,
    this.clientView,
    this.hideActive,
    required this.onlyView,
    this.isDynamic,
  });

  @override
  BonoCardState createState() => BonoCardState();
}

class BonoCardState extends State<BonoCard> {
  // Modal Clicked
  bool isModalClicked = false;

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
  double isExpandedHeight = 3;

  @override
  void initState() {
    bono = widget.bono;
    brand = widget.brand;
    if (widget.isExpanded != null && widget.isExpanded!) {
      isExpanded = true;
    }
    calculateExpandedHeight();
    super.initState();
  }

  Future<void> calculateExpandedHeight() async {
    if (widget.condition == null) {
      condition = Condition(
        expirationTime: widget.bono.condition!.expirationTime,
        cancelTime: widget.bono.condition!.cancelTime,
        weeklySessions: widget.bono.condition!.weeklySessions,
      );
    } else {
      condition = widget.condition!;
    }
    // Height of Expanded Container
    // Primer Condicions
    int cnt = 0;
    if (condition.cancelTime != 0) {
      cnt += 1;
    }
    if (condition.weeklySessions != 0) {
      cnt += 1;
    }
    if (widget.onlyView == false) {
      cnt += 1;
    }
    // Apliquem el Expanded Height
    if (cnt == 1) isExpandedHeight = isExpandedHeight + 0.6;
    if (cnt == 2) isExpandedHeight = isExpandedHeight + 0.85;
    if (cnt == 3) isExpandedHeight = isExpandedHeight + 1.15;
  }

  @override
  void didUpdateWidget(BonoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    bono = widget.bono;
    brand = widget.brand;
    /*
    condition = Condition(
      expirationTime: widget.bono.condition!.expirationTime,
      cancelTime: widget.bono.condition!.cancelTime,
      weeklySessions: widget.bono.condition!.weeklySessions,
    );

     */
    isExpandedHeight = 3;
    calculateExpandedHeight();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.canExpand == true || widget.onlyView! && widget.canExpand) {
          isExpanded = !isExpanded;
          setState(() {});
        }
      },
      child: Material(
        elevation: widget.width * 0.025,
        borderRadius: BorderRadius.circular(widget.width * 0.05),
        child: Stack(children: [
          AnimatedContainer(
            constraints: BoxConstraints(
              minHeight: widget.height,
              minWidth: widget.width,
              maxWidth: widget.width,
            ),
            height:
                isExpanded ? widget.height * isExpandedHeight : widget.height,
            decoration: BoxDecoration(
                color: AppColors.black.withOpacity(0.3),
                borderRadius:
                    BorderRadius.all(Radius.circular(widget.width * 0.05))),
            // Animation
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
          ),
          AnimatedContainer(
            constraints: BoxConstraints(
              minHeight: widget.height,
              minWidth: widget.width,
              maxWidth: widget.width,
            ),
            height:
                isExpanded ? widget.height * isExpandedHeight : widget.height,
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
                            opacity: 0.1,
                            image: NetworkImage(bono.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    borderRadius:
                        BorderRadius.all(Radius.circular(widget.width * 0.05)))
                : BoxDecoration(
                    image: bono.imageUrl != null && bono.imageUrl != ''
                        ? DecorationImage(
                            opacity: 0.1,
                            image: NetworkImage(bono.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color:
                        Color(int.parse(_lColor.getlColor(bono.color!).hexa!))
                            .withOpacity(bono.opacity!),
                    borderRadius:
                        BorderRadius.all(Radius.circular(widget.width * 0.05))),
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
                                      .displaySmall
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
                                    child: Row(
                                      children: [
                                        Text(
                                          bono.title!.toUpperCase(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                          textAlign: TextAlign.left,
                                        ),
                                        isExpanded == false
                                            ? Padding(
                                                padding: EdgeInsets.only(
                                                    left: widget.width * 0.015),
                                                child: SizedBox(
                                                    height: widget.width * 0.06,
                                                    width: widget.width * 0.06,
                                                    child: ClipOval(
                                                        child: Material(
                                                            color: AppColors
                                                                .white
                                                                .withOpacity(
                                                                    0.33),
                                                            child: InkWell(
                                                              splashColor: Theme
                                                                      .of(context)
                                                                  .colorScheme
                                                                  .background, // Splash color

                                                              child: Icon(
                                                                bono.isRecurrent!
                                                                    ? Icons
                                                                        .repeat
                                                                    : FontAwesomeIcons
                                                                        .one,
                                                                color: AppColors
                                                                    .white,
                                                                size: bono
                                                                        .isRecurrent!
                                                                    ? widget.width *
                                                                        0.04
                                                                    : widget.width *
                                                                        0.033,
                                                              ),
                                                            )))))
                                            : Container(),
                                      ],
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
                                                ? Icon(Icons.expand_less,
                                                    size: widget.width * 0.1,
                                                    color: AppColors.white)
                                                : Icon(Icons.expand_more,
                                                    size: widget.width * 0.1,
                                                    color: AppColors.white)),
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
                                                priceBono(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                        color: Colors.white),
                                                textAlign: TextAlign.left,
                                              ),
                                              SizedBox(
                                                width: widget.width * 0.05,
                                              ),
                                              bono.sessions! > 5000
                                                  ? Text(
                                                      "${context.l10n.sessions.toUpperCase().substring(0, 3)}. ${context.l10n.ilimitadas.toUpperCase()}",
                                                      //"${context.l10n.ilimitadas.toUpperCase()}",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.copyWith(
                                                              color:
                                                                  Colors.white),
                                                      textAlign: TextAlign.left,
                                                    )
                                                  : Text(
                                                      '${bono.sessions!.toString().toUpperCase()} ${context.l10n.sessions.toUpperCase()}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.copyWith(
                                                              color:
                                                                  Colors.white),
                                                      textAlign: TextAlign.left,
                                                    ),
                                              SizedBox(
                                                width: widget.width * 0.05,
                                              ),
                                              widget.hideActive == true
                                                  ? Container()
                                                  : bono.isActive! == false
                                                      ? SizedBox(
                                                          height:
                                                              widget.height *
                                                                  0.14,
                                                          width: widget.width *
                                                              0.2,
                                                          child: FittedBox(
                                                            fit: BoxFit.contain,
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(5),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: AppColors
                                                                    .red,
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                  context.l10n
                                                                      .desactiveFem
                                                                      .toUpperCase(),
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyLarge
                                                                      ?.copyWith(
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .visible,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : SizedBox(
                                                          height:
                                                              widget.height *
                                                                  0.14,
                                                          width: widget.width *
                                                              0.2,
                                                          child: FittedBox(
                                                            fit: BoxFit.contain,
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(6),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                  context.l10n
                                                                      .activeFem
                                                                      .toUpperCase(),
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyLarge
                                                                      ?.copyWith(
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .visible,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
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
                                                      ? Icon(Icons.expand_less,
                                                          size: widget.width *
                                                              0.1,
                                                          color:
                                                              AppColors.white)
                                                      : Icon(Icons.expand_more,
                                                          size: widget.width *
                                                              0.1,
                                                          color:
                                                              AppColors.white)),
                                            ),
                                          ),
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      height: widget.height * 0.2,
                                      width: widget.width * 0.8,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Row(
                                            children: [
                                              Container(
                                                  height: widget.width * 0.07,
                                                  padding: EdgeInsets.symmetric(
                                                      vertical:
                                                          widget.width * 0.01,
                                                      horizontal:
                                                          widget.width * 0.02),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.white
                                                        .withOpacity(
                                                      0.33,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                widget.width *
                                                                    0.05)),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        bono.isRecurrent!
                                                            ? Icons.repeat
                                                            : FontAwesomeIcons
                                                                .one,
                                                        color: AppColors.white,
                                                        size: bono.isRecurrent!
                                                            ? widget.width *
                                                                0.04
                                                            : widget.width *
                                                                0.033,
                                                      ),
                                                      SizedBox(
                                                          width: widget.width *
                                                              0.01),
                                                      bono.isRecurrent!
                                                          ? Text(
                                                              "${StringUtils().toCapitalized(context.l10n.recurrentPayment.split(" ")[0])} ${StringUtils().toCapitalized(context.l10n.recurrentPayment.split(" ")[1])}",
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodySmall
                                                                  ?.copyWith(
                                                                      color: Colors
                                                                          .white),
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                            )
                                                          : Text(
                                                              "${StringUtils().toCapitalized(context.l10n.uniquePayment.split(" ")[0])} ${StringUtils().toCapitalized(context.l10n.uniquePayment.split(" ")[1])}",
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodySmall
                                                                  ?.copyWith(
                                                                      color: Colors
                                                                          .white),
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                            ),
                                                    ],
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
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
                                        .bodyLarge
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
                                                  context.l10n.typeRate,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              AppColors.white),
                                                  textAlign: TextAlign.left,
                                                ),
                                                SizedBox(
                                                  height: widget.width * 0.02,
                                                ),
                                                Text(
                                                  bono.isRecurrent!
                                                      ? context.l10n.membership
                                                      : context.l10n.bono,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                          color:
                                                              Colors.white70),
                                                  textAlign: TextAlign.left,
                                                  maxLines: 4,
                                                  overflow:
                                                      TextOverflow.visible,
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
                                                  context.l10n.disponible,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              AppColors.white),
                                                  textAlign: TextAlign.left,
                                                ),
                                                SizedBox(
                                                  height: widget.width * 0.02,
                                                ),
                                                Text(
                                                  bono.isActive!
                                                      ? context.l10n.yes
                                                      : context.l10n.no,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                          color:
                                                              Colors.white70),
                                                  textAlign: TextAlign.left,
                                                  maxLines: 4,
                                                  overflow:
                                                      TextOverflow.visible,
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
                                            width: widget.width * 0.4,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  context.l10n.sessions,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              AppColors.white),
                                                  textAlign: TextAlign.left,
                                                ),
                                                SizedBox(
                                                  height: widget.width * 0.02,
                                                ),
                                                bono.sessions! > 5000
                                                    ? Text(
                                                        StringUtils()
                                                            .toCapitalized(
                                                                context.l10n
                                                                    .ilimitadas),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.copyWith(
                                                                color: Colors
                                                                    .white70),
                                                        textAlign:
                                                            TextAlign.left,
                                                        maxLines: 4,
                                                        overflow: TextOverflow
                                                            .visible,
                                                      )
                                                    : Text(
                                                        bono.sessions!
                                                            .toString(),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.copyWith(
                                                                color: Colors
                                                                    .white70),
                                                        textAlign:
                                                            TextAlign.left,
                                                        maxLines: 4,
                                                        overflow: TextOverflow
                                                            .visible,
                                                      ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: widget.width * 0.3,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  context.l10n.price,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              AppColors.white),
                                                  textAlign: TextAlign.left,
                                                ),
                                                SizedBox(
                                                  height: widget.width * 0.02,
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      priceBono(),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.copyWith(
                                                              color: Colors
                                                                  .white70),
                                                      textAlign: TextAlign.left,
                                                      maxLines: 4,
                                                      overflow:
                                                          TextOverflow.visible,
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          widget.width * 0.05,
                                                    ),
                                                    /* Commeting Precio por Sesión
                                                    bono.sessions! > 5000
                                                        ? Container()
                                                        : Text(
                                                            "(" +
                                                                (bono.price! /
                                                                        bono
                                                                            .sessions!)
                                                                    .toStringAsFixed(
                                                                        2) +
                                                                " €/" +
                                                                context.l10n
                                                                    .session +
                                                                ')',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium
                                                                ?.copyWith(
                                                                    color: Colors
                                                                        .white70),
                                                            textAlign:
                                                                TextAlign.left,
                                                          ),
                                                    */
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
                                                  context.l10n.conditions,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              AppColors.white),
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
                                                        leading: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                                bono.isRecurrent!
                                                                    ? Icons
                                                                        .repeat
                                                                    : Icons
                                                                        .query_builder_outlined,
                                                                size: widget
                                                                        .width *
                                                                    0.07,
                                                                color: Colors
                                                                    .white70),
                                                          ],
                                                        ),
                                                        title: Text(
                                                          "${bono.isRecurrent! ? context.l10n.autoRenovation.split(" ")[0] : StringUtils().toCapitalized(context.l10n.expireDate.split(" ")[2])} ${condition.expirationTime == 30 ? context.l10n.monthly : condition.expirationTime == 60 ? context.l10n.bimonthly : context.l10n.quarterly}",
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyLarge
                                                              ?.copyWith(
                                                                  color: Colors
                                                                      .white70),
                                                        ),
                                                        subtitle: Text(
                                                          bono.isRecurrent!
                                                              ? context.l10n
                                                                  .eachNDaysAprox(
                                                                      condition
                                                                          .expirationTime
                                                                          .toString())
                                                              : context.l10n
                                                                  .afterNDaysAprox(
                                                                      condition
                                                                          .expirationTime
                                                                          .toString()),
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.copyWith(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      )
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
                                                          context.l10n
                                                              .noExpireDate,
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyLarge
                                                              ?.copyWith(
                                                                  color: Colors
                                                                      .white70),
                                                        ),
                                                        subtitle: Text(
                                                          context.l10n
                                                              .allSessionsDone,
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.copyWith(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ),
                                                condition.weeklySessions != 0
                                                    ? ListTile(
                                                        dense: true,
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        minLeadingWidth:
                                                            widget.width * 0.07,
                                                        leading: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .date_range_outlined,
                                                                size: widget
                                                                        .width *
                                                                    0.07,
                                                                color: Colors
                                                                    .white70),
                                                          ],
                                                        ),
                                                        title: Text(
                                                          "${context.l10n.trainsPerWeek.split(" ")[0]} ${context.l10n.trainsPerWeek.split(" ")[1]} ${StringUtils().toCapitalized(context.l10n.trainsPerWeek.split(" ")[2])}",
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyLarge
                                                              ?.copyWith(
                                                                  color: Colors
                                                                      .white70),
                                                        ),
                                                        subtitle: Text(
                                                          "${context.l10n.max} ${condition.weeklySessions} ${context.l10n.trainsPerWeek.toLowerCase()}",
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.copyWith(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      )
                                                    : Container(),
                                                condition.cancelTime != 0
                                                    ? ListTile(
                                                        dense: true,
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        minLeadingWidth:
                                                            widget.width * 0.07,
                                                        leading: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .free_cancellation,
                                                                size: widget
                                                                        .width *
                                                                    0.07,
                                                                color: Colors
                                                                    .white70),
                                                          ],
                                                        ),
                                                        title: Text(
                                                          "${context.l10n.freeCancel.split(" ")[0]} ${StringUtils().toCapitalized(context.l10n.freeCancel.split(" ")[1])}",
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyLarge
                                                              ?.copyWith(
                                                                  color: Colors
                                                                      .white70),
                                                        ),
                                                        subtitle: Text(
                                                          "${StringUtils().toCapitalized(context.l10n.cancelTimeAt.split(" ")[2])} ${condition.cancelTime} ${context.l10n.hours.toLowerCase()}",
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.copyWith(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      )
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
                        onTap: () async {
                          if (!brandIsActive) {
                            await navigateToPayWall(context);
                          } else {
                            await showModalBottomSheet<bool?>(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              builder: (BuildContext context) {
                                return modalBottomSheet();
                              },
                            );
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
                                  ? context.l10n.buy
                                  : context.l10n.edit,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
                                      color:
                                          Theme.of(context).primaryColorDark),
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          !bono.isActive! && !widget.onlyView!
              ? AnimatedContainer(
                  constraints: BoxConstraints(
                    minHeight: widget.height,
                    minWidth: widget.width,
                    maxWidth: widget.width,
                  ),
                  height: isExpanded
                      ? widget.height * isExpandedHeight
                      : widget.height,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius:
                        BorderRadius.all(Radius.circular(widget.width * 0.05)),
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
                                  padding:
                                      EdgeInsets.only(top: widget.height * 0.1),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
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
                              onTap: () async {
                                await showModalBottomSheet<bool?>(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  builder: (BuildContext context) {
                                    return modalBottomSheet();
                                  },
                                );
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
                                        ? context.l10n.buy
                                        : context.l10n.edit,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall
                                        ?.copyWith(
                                            color: Theme.of(context)
                                                .primaryColorDark),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                )
              : Container(),
        ]),
      ),
    );
  }

  // Modal Bottom Sheet Add/Edit/DeleteBono
  Widget modalBottomSheet() {
    return FractionallySizedBox(
      heightFactor: 0.37,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    context.l10n.choseOption,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                  ),
                  trailing: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Text(
                      widget.bono.title!.toUpperCase() +
                          widget.bono.title!.toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  dense: true,
                  onTap: null,
                ),
                ListTile(
                  onTap: () async {
                    if (widget.onlyView != null && widget.onlyView == false) {
                      await _brandDataService.updateBonoActive(
                          widget.brand.id!, bono.id!, !bono.isActive!);
                      Navigator.pop(context);
                    }
                  },
                  minLeadingWidth: MediaQuery.of(context).size.width * 0.06,
                  leading: Icon(
                      bono.isActive!
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
                      color: Theme.of(context).primaryColor,
                      size: MediaQuery.of(context).size.width * 0.06),
                  title: Text(
                      "${bono.isActive! ? context.l10n.mambaProActivated.split(" ")[0] : context.l10n.mambaProDesactivated.split(" ")[0]} ${context.l10n.rate.toLowerCase()}",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.left),
                ),
                ListTile(
                  onTap: () async {
                    if (widget.onlyView != null && widget.onlyView == false) {
                      navigateToAddBonosScreen(bono, brand, true, false, false);
                      setState(() {
                        isModalClicked = true;
                      });
                    }
                  },
                  minLeadingWidth: MediaQuery.of(context).size.width * 0.06,
                  leading: Icon(Icons.edit,
                      color: Theme.of(context).primaryColor,
                      size: MediaQuery.of(context).size.width * 0.06),
                  title: Text(
                      "${context.l10n.edit} ${context.l10n.rate.toLowerCase()}",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.left),
                ),
                ListTile(
                  onTap: () {
                    if (widget.onlyView != null && widget.onlyView == false) {
                      navigateToAddBonosScreen(bono, brand, false, true, false);
                      setState(() {
                        isModalClicked = true;
                      });
                    }
                  },
                  minLeadingWidth: MediaQuery.of(context).size.width * 0.06,
                  leading: Icon(Icons.file_copy_outlined,
                      color: Theme.of(context).primaryColor,
                      size: MediaQuery.of(context).size.width * 0.06),
                  title: Text(
                      "${context.l10n.duplicate} ${context.l10n.rate.toLowerCase()}",
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.left),
                ),
                ListTile(
                  onTap: () {
                    if (widget.onlyView != null && widget.onlyView == false) {
                      navigateToAddBonosScreen(bono, brand, true, false, true);
                      setState(() {
                        isModalClicked = true;
                      });
                    }
                  },
                  minLeadingWidth: MediaQuery.of(context).size.width * 0.06,
                  leading: Icon(Icons.delete_outline,
                      color: Colors.red,
                      size: MediaQuery.of(context).size.width * 0.06),
                  title: Text(
                      "${context.l10n.delete} ${context.l10n.rate.toLowerCase()}",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.red),
                      textAlign: TextAlign.left),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Navigate to Add Bonos
  Future<void> navigateToAddBonosScreen(
      Bono bono, Brand brand, bool edit, bool duplicate, bool delete) async {
    isExpanded = false;

    await Navigator.push(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            child: AddEditBono(
              brand: brand,
              bono: bono,
              edit: edit,
              duplicate: duplicate,
              delete: delete,
            ),
          ),
        )).whenComplete(() => {
          if (isModalClicked) {Navigator.pop(context)}
        });
  }

  String priceBono() {
    if (widget.isDynamic != null && widget.isDynamic == true) {
      return "${BonosUtils().getPurchasePrice(brand, bono, condition).toStringAsFixed(2)} €";
    } else {
      return "${bono.price!.toStringAsFixed(2)} €";
    }
  }
}
