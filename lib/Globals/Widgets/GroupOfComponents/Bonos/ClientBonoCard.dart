import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/BonoRequest.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/Models/Condition.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Date/DateTimeUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/Purchase/PurchasePage.dart';
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
  bool isNotActive = false;
  bool isFinished = false;
  bool isExpired = false;
  int sessionsDone = 0;
  List<Event> eventsThisWeek = [];
  DateTime purchasedDate = DateTime.now();
  DateTime expirationDate = DateTime.now();
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
    } else {
      isExpanded = false;
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
    // Llargada de la Descripció del Bono
    if (bono.description!.length <= 33) {
      isExpandedHeight = 2.4;
    } else if (bono.description!.length > 33 && bono.description!.length <= 66) {
      isExpandedHeight = 2.45;
    } else {
      isExpandedHeight = 2.55;
    }
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
    if (cnt == 1) isExpandedHeight = isExpandedHeight + 0.8;
    if (cnt == 2) isExpandedHeight = isExpandedHeight + 1;
    if (cnt == 3) isExpandedHeight = isExpandedHeight + 1.3;
  }

  Future<void> calculateCurrentBonoStats() async {
    // Sessions Done
    sessionsDone = purchase.numberOfEvents;
    // Sessions Done This Week
    DateTime now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));
    DateTime sunday = now.add(Duration(days: 7 - now.weekday)).add(const Duration(hours: 23, minutes: 59, seconds: 59));
    eventsThisWeek = purchase.events;
    eventsThisWeek.retainWhere((element) => element.doneAt!.toDate().isAfter(monday) && element.doneAt!.toDate().isBefore(sunday));
    // First Get Days to expire
    purchasedDate = purchase.purchasedAt!.toDate();
    purchasedDate = DateTime(
      purchasedDate.year,
      purchasedDate.month,
      purchasedDate.day,
    );
    // Expiration Date
    expirationDate = purchasedDate.add(Duration(days:condition.expirationTime!));
    Duration diff = expirationDate.difference(DateTime.now());
    // Days to Expire
    daysToExpire = diff.inDays;
    // Check if Expired
    if (condition.expirationTime != 0 && daysToExpire < 1) {
      isExpired = true;
      isNotActive = true;
    }
    // Check if Finished
    if (bono.sessions == purchase.numberOfEvents) {
      // Check if there is still some sessions to do
      int index = purchase.events.indexWhere((element) => element.doneAt!.toDate().isAfter(DateTime.now()));
      if (index == -1) {
        isFinished = true;
        isNotActive = true;
      }
    }
    // Check If Not Active
    if (purchase.isActive == false) {
      isNotActive = true;
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
    if (widget.isExpanded != null && widget.isExpanded!) {
      isExpanded = true;
    } else {
      isExpanded = false;
    }
    calculateExpandedHeight();
    calculateCurrentBonoStats();
    print("rebuild");
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
      child: Material(
        elevation: widget.width*0.025,
        borderRadius: BorderRadius.circular(widget.width*0.05),
        child: Stack(
          children: [
            AnimatedContainer(
              constraints: BoxConstraints(
                minHeight: widget.height,
                minWidth: widget.width,
                maxWidth: widget.width,
              ),
              height: isExpanded ? widget.height * isExpandedHeight : widget.height,
              decoration: BoxDecoration(
                  color: AppColors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.all(Radius.circular(widget.width*0.05))),
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
                      borderRadius: BorderRadius.all(Radius.circular(widget.width*0.05)))
                  : BoxDecoration(
                      image: bono.imageUrl != null && bono.imageUrl != ''
                          ? DecorationImage(
                              opacity: 225,
                              image: NetworkImage(bono.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: Color(int.parse(_lColor.getlColor(bono.color!).hexa!)).withOpacity(bono.opacity!),
                      borderRadius: BorderRadius.all(Radius.circular(widget.width*0.05))),
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
                              mainAxisAlignment: isExpanded == false || widget.canExpand == false ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: widget.height * 0.15,
                                  constraints: BoxConstraints(
                                    maxWidth: widget.width * 0.65,
                                  ),
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
                                SizedBox(width: widget.width * 0.02),
                                isExpanded == false || widget.canExpand == false
                                    ?
                                isNotActive == false ? SizedBox(
                                  height: widget.height * 0.15,
                                  width: widget.width * 0.2,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.green,
                                      ),
                                      child: Center(
                                        child: Text(
                                          AppLocalizations.of(context)!.active.toUpperCase(),
                                          style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    ),
                                  ),
                                ) : Container()
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
                            SizedBox(height: widget.height * 0.01),
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
                                      child: isNotActive == false ? Row(
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
                                      ) : Row(
                                        children: [
                                          bono.sessions! > 5000 ? Text(
                                            sessionsDone.toString()+ ' ' + AppLocalizations.of(context)!.sessions.toUpperCase(),
                                            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),
                                            textAlign: TextAlign.left,
                                          ) : Text(
                                            sessionsDone.toString()+"/"+bono.sessions!.toString().toUpperCase() + ' ' + AppLocalizations.of(context)!.sessions.toUpperCase(),
                                            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),
                                            textAlign: TextAlign.left,
                                          ),
                                          SizedBox(
                                            width: widget.width * 0.05,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: AppColors.red,
                                            ),
                                            child: Text(
                                              isFinished ? AppLocalizations.of(context)!.esgotat.toUpperCase() : isExpired ? AppLocalizations.of(context)!.expired.toUpperCase() : AppLocalizations.of(context)!.desactive.toUpperCase(),
                                              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                                              textAlign: TextAlign.left,
                                              maxLines: 4,
                                              overflow: TextOverflow.visible,
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
                                                        context)!.state.toUpperCase(),
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
                                                    isFinished == false && isExpired == false  ? AppLocalizations.of(context)!.active : isFinished ? AppLocalizations.of(
                                                        context)!.esgotat : isExpired ? AppLocalizations.of(context)!.expired : AppLocalizations.of(context)!.expired,
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
                                                    title: isNotActive == false ? Text(
                                                      AppLocalizations.of(context)!.expiresAt + " " + daysToExpire.toString() + " " + AppLocalizations.of(context)!.days.toLowerCase(),
                                                      style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white70),
                                                    ) : Text(
                                                      AppLocalizations.of(context)!.expiresAt + " " + condition.expirationTime.toString() + " " + AppLocalizations.of(context)!.days.toLowerCase(),
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
                                                          style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),
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
                                                            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),
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
                                                    subtitle: isNotActive == false ? Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Text(
                                                          AppLocalizations.of(context)!.thisWeek+": " + eventsThisWeek.length.toString()+"/${condition.weeklySessions}"+" "+AppLocalizations.of(context)!.sessions.toLowerCase(),
                                                          style: Theme.of(context).textTheme.caption?.copyWith(color: Colors.white),
                                                        ),
                                                      ],
                                                    ) : null,

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
                      bono.setPurchaseId = widget.purchase.id!;
                      await Navigator.push(
                          context,
                          CupertinoPageRoute<void>(
                            builder: (context) => PurchasePage(
                              bono: bono,
                              user: user,
                              brand: brand,
                              purchase: purchase,
                            ),
                          )
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
      ),
    );
  }
}
