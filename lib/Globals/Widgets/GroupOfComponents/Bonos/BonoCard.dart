import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/Models/Condition.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
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
  bool? hideActive;

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
  double isExpandedHeight = 2.8;

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
    if (cnt == 1) isExpandedHeight = isExpandedHeight + 0.55;
    if (cnt == 2) isExpandedHeight = isExpandedHeight + 0.8;
    if (cnt == 3) isExpandedHeight = isExpandedHeight + 1;
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
    isExpandedHeight = 2.8;
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
                            opacity: 225,
                            image: NetworkImage(bono.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    borderRadius:
                        BorderRadius.all(Radius.circular(widget.width * 0.05)))
                : BoxDecoration(
                    image: bono.imageUrl != null && bono.imageUrl != ''
                        ? DecorationImage(
                            opacity: 225,
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
                                                '${bono.price!.toStringAsFixed(2).toUpperCase()} €',
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
                                                      "${AppLocalizations.of(context)!.sessions.toUpperCase()} ${AppLocalizations.of(context)!.ilimitadas.toUpperCase()}",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.copyWith(
                                                              color:
                                                                  Colors.white),
                                                      textAlign: TextAlign.left,
                                                    )
                                                  : Text(
                                                      '${bono.sessions!.toString().toUpperCase()} ${AppLocalizations.of(context)!.sessions.toUpperCase()}',
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
                                                                  0.15,
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
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .desactive
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
                                                                  0.15,
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
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .active
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
                                                              "${StringUtils().toCapitalized(AppLocalizations.of(context)!.recurrentPayment.split(" ")[0])} ${StringUtils().toCapitalized(AppLocalizations.of(context)!.recurrentPayment.split(" ")[1])}",
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
                                                              "${StringUtils().toCapitalized(AppLocalizations.of(context)!.uniquePayment.split(" ")[0])} ${StringUtils().toCapitalized(AppLocalizations.of(context)!.uniquePayment.split(" ")[1])}",
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
                                                  AppLocalizations.of(context)!
                                                      .typeRate,
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
                                                      ? AppLocalizations.of(
                                                              context)!
                                                          .membership
                                                      : AppLocalizations.of(
                                                              context)!
                                                          .bono,
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
                                                  AppLocalizations.of(context)!
                                                      .disponibilidad,
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
                                                      ? AppLocalizations.of(
                                                              context)!
                                                          .active
                                                      : AppLocalizations.of(
                                                              context)!
                                                          .desactive,
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
                                                  AppLocalizations.of(context)!
                                                      .sessions,
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
                                                        StringUtils().toCapitalized(
                                                            AppLocalizations.of(
                                                                    context)!
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
                                                  AppLocalizations.of(context)!
                                                      .price,
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
                                                      "${bono.price!.toStringAsFixed(2)} €",
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
                                                                AppLocalizations.of(
                                                                        context)!
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
                                                  AppLocalizations.of(context)!
                                                      .conditions,
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
                                                        leading: Icon(
                                                            Icons
                                                                .query_builder_outlined,
                                                            size: widget.width *
                                                                0.07,
                                                            color:
                                                                Colors.white70),
                                                        title: Text(
                                                          "${AppLocalizations.of(context)!.expiresAt} ${condition.expirationTime} ${AppLocalizations.of(context)!.days.toLowerCase()}",
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyLarge
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
                                                                  context)!
                                                              .noExpireDate,
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyLarge
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
                                                          "${AppLocalizations.of(context)!.cancelTimeAt} ${condition.cancelTime} ${AppLocalizations.of(context)!.hours.toLowerCase()}",
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyLarge
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
                                                          "${AppLocalizations.of(context)!.max} ${condition.weeklySessions} ${AppLocalizations.of(context)!.trainsPerWeek.toLowerCase()}",
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyLarge
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
                                  ? AppLocalizations.of(context)!.buy
                                  : AppLocalizations.of(context)!.edit,
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
                                        ? AppLocalizations.of(context)!.buy
                                        : AppLocalizations.of(context)!.edit,
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
                  title: Text(AppLocalizations.of(context)!.choseOption,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.left),
                  trailing: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      widget.bono.title!.toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                      softWrap: false,
                      overflow: TextOverflow.fade,
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
                      "${bono.isActive! ? AppLocalizations.of(context)!.mambaProActivated.split(" ")[0] : AppLocalizations.of(context)!.mambaProDesactivated.split(" ")[0]} ${AppLocalizations.of(context)!.bono.toLowerCase()}",
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
                  title: Text(AppLocalizations.of(context)!.editBono,
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
                      "${AppLocalizations.of(context)!.duplicate} ${AppLocalizations.of(context)!.bono.toLowerCase()}",
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
                      "${AppLocalizations.of(context)!.delete} ${AppLocalizations.of(context)!.bono.toLowerCase()}",
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
}
