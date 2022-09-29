import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/BonoRequest.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/Models/Condition.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Date/DateTimeUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/OtorgarBono.dart';
import '../../../../Data/LibraryModels/lColor.dart';
import '../../../../Data/LibraryModels/lDegradate.dart';

class ClientBonoCard extends StatefulWidget {
  // Variables per omplir Bono i Size
  double height = 0;
  double width = 0;
  Bono bono;
  Brand brand;
  Purchase purchase;
  // Booleans de que fer amb el Bono
  bool canExpand;
  bool? isExpanded;
  bool? onlyView;
  bool? clientView;
  // Bono Request
  BonoRequest? bonoRequest;

  ClientBonoCard({
    Key? key,
    required this.height,
    required this.width,
    required this.bono,
    required this.brand,
    required this.purchase,
    required this.canExpand,
    required this.onlyView,
    this.isExpanded,
    this.bonoRequest,
  }) : super(key: key);

  @override
  ClientBonoCardState createState() => ClientBonoCardState();
}

class ClientBonoCardState extends State<ClientBonoCard> {
  // Models
  Bono bono = Bono();
  Purchase purchase = Purchase();
  Brand brand = Brand();
  Condition condition = Condition();

  final _userDataService = UserDataService();
  Usuario user = Usuario();

  // Variables Colors
  final _lDegradate = lDegradate();
  final _lColor = lColor();
  // Booleans
  bool isExpanded = false;
  double isExpandedHeight = 2.5;
  // Client Current Bono Stats
  bool isFinished = false;
  int sessionsDone = 0;
  List<Event> eventsThisWeek = [];
  DateTime purchasedDate = DateTime.now();
  int daysToExpire = 0;
  int weeklySessions = 0;

  @override
  void initState() {
    bono = widget.bono;
    bono.purchaseId = widget.purchase.id;
    brand = widget.brand;
    purchase = widget.purchase;
    condition = Condition(
      expirationTime: widget.bono.condition!.expirationTime,
      cancelTime: widget.bono.condition!.cancelTime,
      weeklySessions: widget.bono.condition!.weeklySessions,
    );
    if (widget.isExpanded != null && widget.isExpanded!) {
      isExpanded = true;
    }
    calculateExpandedHeight();
    calculateCurrentBonoStats();
    getUser();
    super.initState();
  }

  Future<void> getUser() async {
    user = await _userDataService.getUserDetails(purchase.userId!);
  }


  Future<void> calculateExpandedHeight() async {
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
    if (cnt == 1) isExpandedHeight = isExpandedHeight + 0.4;
    if (cnt == 2) isExpandedHeight = isExpandedHeight + 1;
    if (cnt == 3) isExpandedHeight = isExpandedHeight + 1.2;
  }

  Future<void> calculateCurrentBonoStats() async {
    // Sessions Done
    sessionsDone = purchase.events.length;
    // Sessions Done This Week
    DateTime now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime monday = now.subtract(Duration(days: 7-now.weekday));
    eventsThisWeek = purchase.events;
    eventsThisWeek.retainWhere((element) => element.doneAt!.toDate().isAfter(monday));
    // First Get Days to expire
    purchasedDate = purchase.purchasedAt!.toDate();
    purchasedDate = DateTime(
      purchasedDate.year,
      purchasedDate.month,
      purchasedDate.day+1,
    );
    // Expiration Date
    DateTime expirationDate = purchasedDate.add(Duration(days:condition.expirationTime!));
    Duration diff = expirationDate.difference(DateTime.now());
    // Days to Expire
    daysToExpire = diff.inDays;
    if (daysToExpire == 0 && condition.expirationTime != 0) {
      isFinished = true;
    }
  }

  @override
  void didUpdateWidget(ClientBonoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    bono = widget.bono;
    brand = widget.brand;
    purchase = widget.purchase;
    condition = Condition(
      expirationTime: widget.bono.condition!.expirationTime,
      cancelTime: widget.bono.condition!.cancelTime,
      weeklySessions: widget.bono.condition!.weeklySessions,
    );
    isExpandedHeight = 2.5;
    calculateExpandedHeight();
    calculateCurrentBonoStats();
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
                  color: Color(int.parse(_lColor.getlColor(bono.color!).hexa!)).withOpacity(bono.opacity!),
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
                        isExpanded == false ? Row(
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
                                      bono.sessions! > 5000 ? Text(
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
                                      ) : Text(
                                        sessionsDone.toString()+"/"+bono.sessions!.toString().toUpperCase() + ' ' + AppLocalizations.of(context)!.sessions.toUpperCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            ?.copyWith(
                                            color:
                                            Colors.white),
                                        textAlign: TextAlign.left,
                                      ),
                                      SizedBox(
                                        width: widget.width * 0.05,
                                      ),
                                      condition.weeklySessions != 0 ? Text(
                                        eventsThisWeek.length.toString()+"/${condition.weeklySessions}"+" "+AppLocalizations.of(context)!.thisWeek.toUpperCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            ?.copyWith(
                                            color:
                                            Colors.white),
                                        textAlign: TextAlign.left,
                                      ) : condition.expirationTime != 0 ? Text(
                                        AppLocalizations.of(context)!.expiresAt + " " + daysToExpire.toString() + " " + AppLocalizations.of(context)!.days.toLowerCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            ?.copyWith(
                                            color:
                                            Colors.white),
                                        textAlign: TextAlign.left,
                                      ) : const Text(""),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            widget.canExpand == false
                                ? SizedBox(
                                height: widget.height * 0.15,
                                width: widget.width * 0.1) : SizedBox(
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
                        ) : Container(),
                      ],
                    ),
                  ],
                ),
              ),
              isExpanded ? Expanded(
                      child: SizedBox(
                        height: widget.height * isExpandedHeight * 2 - widget.height,
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
                                              bono.sessions! > 5000 ?
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
                                                sessionsDone.toString() + "/"+bono.sessions!.toString(),
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
                                                isFinished == false ? AppLocalizations.of(context)!.active : AppLocalizations.of(
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
                                                  bono.sessions! > 5000 ?
                                                  Container()
                                                      :
                                                  Text(
                                                    "(" +
                                                        (bono.price! /
                                                            bono.sessions!)
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
                                              condition.expirationTime != 0 ? ListTile(
                                                dense: true,
                                                contentPadding: EdgeInsets.zero,
                                                minLeadingWidth: widget.width * 0.07,
                                                leading: Icon(Icons.query_builder_outlined,
                                                  size: widget.width * 0.07,
                                                  color: Colors.white70
                                                ),
                                                title: Text(
                                                  AppLocalizations.of(context)!.expiresAt + " " + daysToExpire.toString() + " " + AppLocalizations.of(context)!.days.toLowerCase(),
                                                  style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white70),
                                                ),
                                                subtitle: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(
                                                      height: 8,
                                                    ),
                                                    Text(
                                                      AppLocalizations.of(context)!.buyDate + ": " + DateTimeUtils().formatDateTimeToStringDDMMYYYY(purchasedDate, Localizations.localeOf(context).languageCode),
                                                      style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white70),
                                                    ),
                                                  ],
                                                ),
                                              ) : ListTile(
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
                                                  ),
                                                  subtitle: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const SizedBox(
                                                        height: 8,
                                                      ),
                                                      Text(
                                                        AppLocalizations.of(context)!.buyDate + ": " + DateTimeUtils().formatDateTimeToStringDDMMYYYY(purchasedDate, Localizations.localeOf(context).languageCode),
                                                        style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white70),
                                                      ),
                                                    ],
                                                  ),
                                              ),
                                              condition.weeklySessions != 0 ? ListTile(
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
                                                        " " + AppLocalizations.of(context)!.trainsPerWeek.toLowerCase(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        ?.copyWith(
                                                        color: Colors
                                                            .white70),
                                                  ),
                                                  subtitle: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const SizedBox(
                                                        height: 8,
                                                      ),
                                                      Text(
                                                        AppLocalizations.of(context)!.thisWeek+": " + eventsThisWeek.length.toString()+"/${condition.weeklySessions}"+" "+AppLocalizations.of(context)!.sessions.toLowerCase(),
                                                        style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white70),
                                                      ),
                                                    ],
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
                                                            " " + AppLocalizations.of(context)!.hours.toLowerCase(),
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
                    ) : Container(),
              isExpanded && widget.onlyView == false ? GestureDetector(
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
                      bono.setPurchaseId = widget.purchase.id!;
                      return FractionallySizedBox(
                        heightFactor: 0.95,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            FocusScopeNode currentFocus = FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            }
                          },
                          child: OtorgarBono(
                            user: user,
                            brand: brand,
                            edit: true,
                            bono: bono,
                          ),
                        ),
                      );
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
                      AppLocalizations.of(context)!.edit,
                      style: Theme.of(context).textTheme.headline3?.copyWith(color: Theme.of(context).primaryColorDark),
                    ),
                  ),
                ),
              ) : Container(),
            ],
          ),
        ),
      ]
      ),
    );
  }
}
