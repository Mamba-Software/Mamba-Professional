import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Promotions/PromotionsDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Room/RoomDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Subscription.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Badges/CounterBadgeIcon.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectDaysDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectMembersDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectTimeDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/ConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/DeleteBrandDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/PayWall/ActiveSubscription.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/PayWall/PayWall.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/012-Logo/Logo.dart';

import '../../../../../Globals/Widgets/GroupOfComponents/PayWall/cubitSuscription/BrandSuscriptionCubit.dart';

// Tus Datos Widget.
class BrandSubscription extends StatefulWidget {
  Locale? locale;
  String brandId;
  bool pinned;
  ValueChanged<bool?> pinnedChanged;
  BrandSubscription({Key? key, this.locale, required this.brandId, required this.pinned, required this.pinnedChanged}) : super(key: key);

  @override
  _BrandInfoState createState() => _BrandInfoState();
}

class _BrandInfoState extends State<BrandSubscription> with SingleTickerProviderStateMixin {

  // Variables
  ScrollController? _scrollController;
  DateFormat formatter = DateFormat('dd/MM/yy');
  bool canSubscribe = false;
  int difference = 0;
  bool ShowTextExpired = true;
  // App Bar and Scroll View
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    if (!_scrollController!.hasClients) {
      return false;
    }
    if (_scrollController!.position.userScrollDirection == ScrollDirection.forward) {
      // User is down up, so AppBar should expand.
      return false;
    }
    // Use the same condition as before to check if AppBar is expanded.
    return _scrollController!.offset > (MediaQuery.of(context).size.height * 0.13 - kToolbarHeight);
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
    ..addListener(() => _isAppBarExpanded ?
      setState(() {
        appBarExpanded = true;
      }) :
      setState(() {
        appBarExpanded = false;
      }),
    );
    canSubscribe = currentUser.id == currentBrand.adminID;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.darkGrey,
            expandedHeight: MediaQuery.of(context).size.height*0.15,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            elevation: 4,
            floating: true,
            snap: true,
            pinned: true,
            title: AnimatedOpacity(
                opacity: appBarExpanded ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                    StringUtils().toCapitalized(AppLocalizations.of(context)!.yourPlan.split(" ")[1]),
                    style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(color: AppColors.white,)
                )
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.darkGrey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.025),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            StringUtils().toCapitalized(AppLocalizations.of(context)!.yourPlan.split(" ")[1]),
                            style: Theme.of(context).textTheme.headline1?.copyWith(color: AppColors.white,),
                          ),
                          FittedBox(
                            fit: BoxFit.fitHeight,
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height*0.08,
                              width: MediaQuery.of(context).size.width*0.11,
                              child: TextButton(
                                onPressed: null,
                                child: Icon(
                                  Icons.filter_list,
                                  color: AppColors.darkGrey,
                                  size: MediaQuery.of(context).size.width*0.07,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                    Container(
                      color: AppColors.grey,
                      height: 1.0,
                    ),
                  ],
                ),
              ),
              titlePadding: EdgeInsets.zero,
              //centerTitle: true,
            ),
            centerTitle: false,
            leading: Builder(
              builder: (BuildContext innerContext) => Padding(
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.02),
                child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: AppColors.white,
                      size: MediaQuery.of(context).size.height*0.04,
                    ),
                    onPressed: () => mambaProScaffoldKey.currentState?.openDrawer()
                ),
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CounterBadgeIcon(
                    counter: unreadNotifications,
                    top: 5,
                    right: 7,
                    child: IconButton(
                      icon: Icon(Icons.notifications, color: AppColors.white, size: MediaQuery.of(context).size.width*0.06),
                      alignment: Alignment.center,
                      padding: EdgeInsets.zero,
                      onPressed: () => navigateToNotificationsScreen(context),
                    ),
                  ),
                  CounterBadgeIcon(
                    counter: unreadChats,
                    top: 5,
                    right: 7,
                    child: IconButton(
                      icon: Icon(Icons.chat, color: AppColors.white, size: MediaQuery.of(context).size.width*0.06),
                      alignment: Alignment.center,
                      padding: EdgeInsets.zero,
                      onPressed: () => navigateToChatScreen(context),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width*0.03),
                  GestureDetector(
                    onTap: () => navigateToProfileScreen(context),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.width * 0.08,
                      child: Center(
                        child: CircularImage(
                          size: MediaQuery.of(context).size.width * 0.08,
                          image: currentUser.imageUrl,
                          color: AppColors.grey,
                          borderWidth: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: MediaQuery.of(context).size.width*0.03),
            ],
          ),
          BlocBuilder<BrandSuscriptionCubit, BrandSuscriptionState>(
              builder: (context, state) {
                switch (state.runtimeType) {
                  case BrandSuscriptionInitial:
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        children: [
                          Expanded(
                            child: SizedBox(
                                height: MediaQuery.of(context).size.height*0.65,
                                child: Center(
                                    child: LoadingView()
                                )
                            ),
                          ),
                        ],
                      ),
                    );
                  case BrandSuscriptionLoading:
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        children: [
                          Expanded(
                            child: SizedBox(
                                height: MediaQuery.of(context).size.height*0.65,
                                child: Center(
                                    child: LoadingView()
                                )
                            ),
                          ),
                        ],
                      ),
                    );
                  case BrandSuscriptionLoadedTrue:
                    final suscriptionState = state as BrandSuscriptionLoadedTrue;
                    difference = suscriptionState.subscription.endDate!.toDate().difference(DateTime.now()).inDays;
                    return SliverToBoxAdapter(
                      child: Column(
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height*0.03),
                          suscriptionState.subscription.subscriptionId == '7DAYSTRIAL' ? GestureDetector(
                            onTap: navigateToPaywallScreen,
                            child: Material(
                              elevation: 4,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(15.0)),// BorderRadius
                              ),
                              child: Container(
                                //margin: const EdgeInsetsDirectional.only(start: 1, end: 1, bottom: 1, top: 1),
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height* 0.65,
                                  maxWidth: MediaQuery.of(context).size.width*0.9,
                                  minWidth: MediaQuery.of(context).size.width*0.9,
                                ),
                                padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                                  border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 2),
                                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),// BorderRadius
                                ),// BoxDecoration
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                                    ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Icon(
                                          Icons.new_releases,
                                          color: Theme.of(context).colorScheme.secondary,
                                          size: MediaQuery.of(context).size.width*0.10,
                                        ),
                                      ),
                                      title: Text(
                                          AppLocalizations.of(context)!.chooseYourPlan,
                                          style: Theme.of(context).textTheme.headline3?.copyWith(color: Theme.of(context).colorScheme.secondary),
                                          textAlign: TextAlign.left
                                      ),
                                      dense: true,
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                                      child: Divider(color: Theme.of(context).colorScheme.secondary, thickness: 1),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.height*0.015),
                                      child: Text(
                                        AppLocalizations.of(context)!.freeTrialDaysLeft(difference.toString()),
                                        style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.secondary),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ) :
                          Material(
                            elevation: 4,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15.0)),// BorderRadius
                            ),
                            child: Container(
                              //margin: const EdgeInsetsDirectional.only(start: 1, end: 1, bottom: 1, top: 1),
                              constraints: BoxConstraints(
                                maxHeight: MediaQuery.of(context).size.height* 0.65,
                                maxWidth: MediaQuery.of(context).size.width*0.9,
                                minWidth: MediaQuery.of(context).size.width*0.9,
                              ),
                              padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                                border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 2),
                                borderRadius: const BorderRadius.all(Radius.circular(15.0)),// BorderRadius
                              ),// BoxDecoration
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                                  ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.asset(
                                        Constants.subscriptionImage,),
                                    ),
                                    title: Text(
                                        suscriptionState.subscription.title!,
                                        style: Theme.of(context).textTheme.headline3?.copyWith(color: Theme.of(context).colorScheme.secondary),
                                        textAlign: TextAlign.left
                                    ),
                                    /*
                                    subtitle: Text(
                                        suscriptionState.subscription.title!,
                                        style: Theme.of(context).textTheme.caption
                                    ),
                                     */
                                    dense: true,
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                                    child: Divider(color: Theme.of(context).colorScheme.secondary, thickness: 1),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.height*0.015),
                                    child: Text(
                                      suscriptionState.subscription.unsuscribed!? AppLocalizations.of(context)!.moreSubInfo(formatter.format(suscriptionState.subscription.endDate!.toDate()).toString()) :
                                      AppLocalizations.of(context)!.moreSubInfoRenAut(formatter.format(suscriptionState.subscription.endDate!.toDate())),
                                      style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.secondary),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.03),
                          Material(
                            elevation: 4,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15.0)),
                            ),
                            child: Container(
                              constraints: BoxConstraints(
                                maxHeight: MediaQuery.of(context).size.height* 0.65,
                                maxWidth: MediaQuery.of(context).size.width*0.9,
                                minWidth: MediaQuery.of(context).size.width*0.9,
                              ),
                              padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColorDark.withOpacity(0.6),
                                borderRadius: const BorderRadius.all(Radius.circular(15.0)),// BorderRadius
                              ),// BoxDecoration
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03, vertical: MediaQuery.of(context).size.width*0.02),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(MediaQuery.of(context).size.height*0.01),
                                      child: Text(
                                        AppLocalizations.of(context)!.subscriptionIncludes,
                                        style: Theme.of(context).textTheme.headline1,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.width*0.03, left: MediaQuery.of(context).size.width*0.03, right: MediaQuery.of(context).size.width*0.03),
                                      child: Divider(color: Theme.of(context).dividerColor, thickness: 1.5),
                                    ),
                                    Column(
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
                                        canSubscribe ? SizedBox(height: MediaQuery.of(context).size.height*0.03) : Container(),
                                      ],
                                    ),
                                    canSubscribe ? Column(
                                      children: [
                                        GestureDetector(
                                          onTap: navigateToPaywallScreen,
                                          child: Material(
                                            elevation: 4,
                                            shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).primaryColor,
                                                borderRadius: BorderRadius.circular(30),
                                              ),
                                              width: MediaQuery.of(context).size.width * 0.90,
                                              height: MediaQuery.of(context).size.height * 0.05,
                                              child: Center(
                                                child: Text(
                                                  AppLocalizations.of(context)!.seeAllMasc.split(" ")[0]+" "+AppLocalizations.of(context)!.subscriptionsAppBar.toLowerCase(),
                                                  style: Theme.of(context).textTheme.headline3?.copyWith(color: Theme.of(context).primaryColorDark),
                                                )
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: MediaQuery.of(context).size.height*0.015),
                                      ],
                                    ) : Container(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.015),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!.adminSubscriptionDesc,
                                    style: Theme.of(context).textTheme.caption,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.1),
                        ],
                      ),
                    );
                  case BrandSuscriptionLoadedFalse:
                    return SliverToBoxAdapter(
                      child: Column(
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height*0.03),
                          Material(
                            elevation: 4,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15.0)),// BorderRadius
                            ),
                            child: Container(
                              //margin: const EdgeInsetsDirectional.only(start: 1, end: 1, bottom: 1, top: 1),
                              constraints: BoxConstraints(
                                maxHeight: MediaQuery.of(context).size.height* 0.65,
                                maxWidth: MediaQuery.of(context).size.width*0.9,
                                minWidth: MediaQuery.of(context).size.width*0.9,
                              ),
                              padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                                border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 2),
                                borderRadius: const BorderRadius.all(Radius.circular(15.0)),// BorderRadius
                              ),// BoxDecoration
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                                  ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Icon(
                                        Icons.new_releases,
                                        color: Theme.of(context).colorScheme.secondary,
                                        size: MediaQuery.of(context).size.width*0.10,
                                      ),
                                    ),
                                    title: Text(
                                        AppLocalizations.of(context)!.chooseYourPlan,
                                        style: Theme.of(context).textTheme.headline3?.copyWith(color: Theme.of(context).colorScheme.secondary),
                                        textAlign: TextAlign.left
                                    ),
                                    dense: true,
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                                    child: Divider(color: Theme.of(context).colorScheme.secondary, thickness: 1),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.height*0.015),
                                    child: Text(
                                      ShowTextExpired ? AppLocalizations.of(context)!.subscriptionExpired : AppLocalizations.of(context)!.noSubscription,
                                      style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.secondary),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.03),
                          Material(
                            elevation: 4,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15.0)),
                            ),
                            child: Container(
                              constraints: BoxConstraints(
                                maxHeight: MediaQuery.of(context).size.height* 0.65,
                                maxWidth: MediaQuery.of(context).size.width*0.9,
                                minWidth: MediaQuery.of(context).size.width*0.9,
                              ),
                              padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColorDark.withOpacity(0.6),
                                borderRadius: const BorderRadius.all(Radius.circular(15.0)),// BorderRadius
                              ),// BoxDecoration
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03, vertical: MediaQuery.of(context).size.width*0.02),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(MediaQuery.of(context).size.height*0.01),
                                      child: Text(
                                        AppLocalizations.of(context)!.subscriptionIncludes,
                                        style: Theme.of(context).textTheme.headline1,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.width*0.03, left: MediaQuery.of(context).size.width*0.03, right: MediaQuery.of(context).size.width*0.03),
                                      child: Divider(color: Theme.of(context).dividerColor, thickness: 1.5),
                                    ),
                                    Column(
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
                                        canSubscribe ? SizedBox(height: MediaQuery.of(context).size.height*0.03) : Container(),
                                      ],
                                    ),
                                    canSubscribe ? GestureDetector(
                                      onTap: navigateToPaywallScreen,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Theme.of(context).dividerColor,
                                            width: 3,
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        width: MediaQuery.of(context).size.width * 0.90,
                                        height: MediaQuery.of(context).size.height * 0.05,
                                        child: Center(
                                            child: Text(
                                              AppLocalizations.of(context)!.seeAllSubs,
                                              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.normal,
                                                  color: Theme.of(context).primaryColor
                                              ),
                                            )
                                        ),
                                      ),
                                    ) : Container(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.015),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!.adminSubscriptionDesc,
                                    style: Theme.of(context).textTheme.caption,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.1),
                        ],
                      ),
                    );
                  default:
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        children: [
                          Expanded(
                            child: SizedBox(
                                height: MediaQuery.of(context).size.height*0.65,
                                child: Center(
                                    child: LoadingView()
                                )
                            ),
                          ),
                        ],
                      ),
                    );
                }
              }
          ),

        ],
      ),
    );
  }


  Future<void> navigateToPaywallScreen() async {
    if (canSubscribe) {
      mixpanel!.track('brand_see_paywall');
      await navigateToPayWall(context);
    }
  }

  Widget listTileGetAll(String subtitle) {
    return  ListTile(
      leading: const Icon(
        Icons.done,
        color: Colors.green,
      ),
      title: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyText1,
        textAlign: TextAlign.left
      ),
    );
  }



}

