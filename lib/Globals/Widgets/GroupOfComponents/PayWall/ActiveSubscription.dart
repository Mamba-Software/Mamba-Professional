import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/Models/Subscription.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/PayWall/PayWall.dart';
import 'package:purchases_flutter/models/offerings_wrapper.dart';


class ActiveSubscription extends StatefulWidget {
  Subscription subscription;
  String brandId;
  Offerings? offerings;

  ActiveSubscription({Key? key, required this.subscription, required this.brandId, this.offerings}) : super(key: key);

  @override
  _ActiveSubscriptionState createState() => _ActiveSubscriptionState();
}

class _ActiveSubscriptionState extends State<ActiveSubscription> {

  DateFormat formatter = DateFormat('dd/MM/yy');
  Subscription subscription = Subscription();
  bool hasChanged = false;

  @override
  initState() {
    super.initState();
    subscription = widget.subscription;
  }

  Future<void> navigateToSubscriptionsScreen() async {
    mixpanel!.track('brand_see_paywall');
    await Navigator.push(
        context,
        CupertinoPageRoute<bool?>(
          builder: (context) => PayWall(
            brandId: widget.brandId,
            offerigns: widget.offerings,
          ),
        )
    );
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            AppLocalizations.of(context)!.subscriptionsAppBar,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: MediaQuery.of(context).size.width * 0.06,
          ),
          onPressed: () {
            Navigator.pop(context, hasChanged);
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05, vertical: MediaQuery.of(context).size.width * 0.05),
          child: Column(
            children: [
              // Owners
              Column(
                children: [
                  Material(
                    elevation: 4,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.65,
                        maxWidth: MediaQuery.of(context).size.width*0.9,
                        minWidth: MediaQuery.of(context).size.width*0.9,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),// BorderRadius
                      ),// BoxDecoration
                      child: Container(
                        margin: const EdgeInsetsDirectional.only(start: 1, end: 1, bottom: 1, top: 1),
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height* 0.65,
                          maxWidth: MediaQuery.of(context).size.width*0.9,
                          minWidth: MediaQuery.of(context).size.width*0.9,
                        ),
                        padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColorDark.withOpacity(0.4),
                          borderRadius: const BorderRadius.all(Radius.circular(10.0)),// BorderRadius
                        ),// BoxDecoration
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  Constants.subscriptionImage,),
                              ),
                              title: Text(
                                  subscription.title!,
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .headline3,
                                  textAlign: TextAlign.left
                              ),
                              subtitle: Text(
                                  'Fitness is Business',
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .caption
                              ),
                              dense: true,
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height*0.02,),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                              child: Divider(color: Theme.of(context).dividerColor, thickness: 1.5),
                            ),
                            Padding(
                              padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.05),
                              child: Text(
                                  AppLocalizations.of(context)!.moreSubInfo(formatter.format(subscription.startDate!.toDate()), formatter.format(subscription.endDate!.toDate()).toString()),
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .caption
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  GestureDetector(
                    onTap: navigateToSubscriptionsScreen,
                    child: Material(
                      elevation: 4,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.65,
                          maxWidth: MediaQuery.of(context).size.width*0.9,
                          minWidth: MediaQuery.of(context).size.width*0.9,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.all(Radius.circular(5.0)),// BorderRadius
                        ),// BoxDecoration
                        child: Container(
                          margin: const EdgeInsetsDirectional.only(start: 1, end: 1, bottom: 1, top: 1),
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height* 0.65,
                            maxWidth: MediaQuery.of(context).size.width*0.9,
                            minWidth: MediaQuery.of(context).size.width*0.9,
                          ),
                          padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorDark.withOpacity(0.4),
                            borderRadius: const BorderRadius.all(Radius.circular(10.0)),// BorderRadius
                          ),// BoxDecoration
                          child: Padding(
                            padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(MediaQuery.of(context).size.height*0.01),
                                  child: Text(
                                    AppLocalizations.of(context)!.subscriptionIncludes,
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .headline1,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.width*0.03, left: MediaQuery.of(context).size.width*0.03, right: MediaQuery.of(context).size.width*0.03),
                                  child: Divider(color: Theme.of(context).dividerColor, thickness: 1.5),
                                ),
                                Padding(
                                  padding:  EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.00),
                                  child: Column(
                                    children: [
                                      listTileGetAll(AppLocalizations.of(context)!.personalizeBrandActiveText),
                                      SizedBox(height: MediaQuery.of(context).size.height*0.005),
                                      listTileGetAll( AppLocalizations.of(context)!.searcherActiveText),
                                      SizedBox(height: MediaQuery.of(context).size.height*0.005),
                                      listTileGetAll(AppLocalizations.of(context)!.sessionControActiveText),
                                      SizedBox(height: MediaQuery.of(context).size.height*0.005),
                                      listTileGetAll( AppLocalizations.of(context)!.pricePolicyActiveText),
                                      SizedBox(height: MediaQuery.of(context).size.height*0.005),
                                      listTileGetAll( AppLocalizations.of(context)!.statsActiveText),
                                      SizedBox(height: MediaQuery.of(context).size.height*0.03),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    mixpanel!.track('brand_see_paywall');
                                    await Navigator.push(
                                        context,
                                        CupertinoPageRoute<bool?>(
                                          builder: (context) =>
                                              PayWall(
                                                brandId: widget.brandId,
                                                offerigns: widget.offerings,
                                              ),
                                        )
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Theme.of(context).dividerColor,
                                        width: 3,
                                      ),
                                      borderRadius: BorderRadius
                                          .circular(20),
                                    ),
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.90,
                                    height: MediaQuery
                                        .of(context)
                                        .size
                                        .height * 0.05,
                                    child: Center(
                                        child: Text(
                                          AppLocalizations.of(context)!.seeAllSubs,
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .bodyText1
                                              ?.copyWith(
                                              fontWeight: FontWeight
                                                  .normal,
                                              color: Theme.of(context).primaryColor
                                          ),
                                        )

                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.width * 0.05),
            ],
          ),
        ),
      ),
    );
  }


  Widget listTileGetAll(String subtitle)
  {
    return  ListTile(
      leading: Icon(
        Icons.done,
        color: Colors.green,
      ),
      title: Text(
          subtitle,
          style: Theme
              .of(context)
              .textTheme
              .bodyText1,
          textAlign: TextAlign.left
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
