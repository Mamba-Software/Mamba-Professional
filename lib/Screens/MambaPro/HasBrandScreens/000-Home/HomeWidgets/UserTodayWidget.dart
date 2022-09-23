import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Globals/ChatCore/ChatCore.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/Notifications.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Badges/CounterBadgeIcon.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventPage/EventPage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/Profile/Profile.dart';

class UserTodayWidget extends StatefulWidget {

  UserTodayWidget({Key? key}) : super(key: key);

  @override
  _UserTodayWidgetState createState() => _UserTodayWidgetState();
}

class _UserTodayWidgetState extends State<UserTodayWidget> {

  // Acceso a Base de Datos
  final _userDataService = UserDataService();
  final _eventDataService = EventDataService();
  // AlL Events From User
  List<Event> userEventsToday = [];
  var todayEventsLabels = [];
  List<Widget> eventSliders = [];
  int _current = 0;

  @override
  void initState() {
    super.initState();
  }

  List<Event> documentsToEvents(List<DocumentSnapshot> documents) {
    List<Event> events = [];
    for(int i = 0; i < documents.length; i++) {
      events.add(Event.fromObjectOnlyCoverData(documents[i].id, documents[i]));
    }
    return events;
  }

  // Navigate to Notifications Screen
  void navigateToProfileScreen() {
    Navigator.push(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => const Profile(),
          settings: const RouteSettings(name: 'Profile'),
        )
    );
  }
  
  // Navigate to Notifications Screen
  void navigateToNotificationsScreen() {
    Navigator.push(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => const Notifications(),
        )
    ).whenComplete(() async {
      var temp = await _userDataService.getUnreadNotifications(currentUser.id!);
      setState(() {
        unreadNotifications = temp;
      });
    });
  }

  // Navigate to Notifications Screen
  void navigateToChatScreen() {
    Navigator.push(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => const ChatCore(),
        )
    ).whenComplete(() async {
      var temp = await _userDataService.getUnreadConversations(currentUser.id!);
      setState(() {
        unreadChats = temp;
      });
    });
  }

  // Navigate to Event Screen on Tap
  void navigateToEventScreen(String eventId) {
    // Navigate to Event Screen
    Navigator.push(
      context,
      CupertinoPageRoute<void>(
        builder: (context) => EventPage(
          eventId: eventId,
        ),
      )
    );
  }

  // Return bade on events Today
  Widget buildBadge(int index) {
    int label = todayEventsLabels[index];
    var badgeHeight = MediaQuery.of(context).size.height*0.03;
    switch (label) {
    // To Do
      case 0:
        return Material(
          elevation: 4,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          child: Container(
            height: badgeHeight,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width*0.25,
            ),
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(10)
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.update_outlined,
                    color: Colors.white,
                    size: 15,
                  ),
                ],
              ),
            ),
          ),
        );
    // Doing
      case 1:
        return Material(
          elevation: 4,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          child: Container(
            height: badgeHeight,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width*0.25,
            ),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(10)
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.02),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  /*
                  Flexible(
                    child: Text(AppLocalizations.of(context)!.doing,
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 10), textAlign: TextAlign.left),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width*0.01,),
                   */
                  Icon(
                    Icons.hourglass_top_outlined,
                    color: Colors.white,
                    size: 15,
                  ),
                ],
              ),
            ),
          ),
        );
    // Done
      case 2:
        return Material(
          elevation: 4,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          child: Container(
            height: badgeHeight,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width*0.25,
            ),
            decoration: BoxDecoration(
                color: Colors.green, borderRadius: BorderRadius.circular(10)
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  /*
                  Text(AppLocalizations.of(context)!.finished,
                      style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 10), textAlign: TextAlign.left),
                  SizedBox(width: MediaQuery.of(context).size.width*0.01,),
                   */
                  Icon(
                    Icons.done_outline_outlined,
                    color: Colors.white,
                    size: 15,
                  ),
                ],
              ),
            ),
          ),
        );
      default:
        return Container();
    }
  }

  // Build Event Container
  Widget buildEventContainer(Event event, var height, var width, var badge) {
    return GestureDetector(
      onTap: () => navigateToEventScreen(event.id!),
      child: Material(
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(event.imageUrl!),
                  )
              ),
              child: const Center(),
            ),
            Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                color: Colors.white,
                gradient: LinearGradient(
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                    colors: [
                      Colors.grey.withOpacity(0.0),
                      Colors.black,
                    ],
                    stops: const [
                      0.0,
                      0.75
                    ]
                ),
                border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              child: const Center(),
            ),
            Padding(
              padding: EdgeInsets.all(width * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: width*0.8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: width*0.4,
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(event.title!,
                                    style: Theme.of(context).textTheme.headline3!.copyWith(color: Colors.white, fontWeight: FontWeight.w600), textAlign: TextAlign.left),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            badge,
                            SizedBox(width: width*0.02),
                            Container(
                              child: event.isPrivate! ? Row(
                                children: [
                                  Text(
                                      AppLocalizations.of(context)!.private,
                                      style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                                      textAlign: TextAlign.right
                                  ),
                                  SizedBox(width: width*0.01),
                                  Icon(
                                    Icons.lock_outlined,
                                    color: AppColors.white,
                                    size: width*0.05,
                                  ),
                                ],
                              ) : Row(
                                children: [
                                  Text(
                                      AppLocalizations.of(context)!.group,
                                      style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                                      textAlign: TextAlign.right
                                  ),
                                  SizedBox(width: width*0.01),
                                  Icon(
                                    Icons.groups,
                                    color: AppColors.white,
                                    size: width*0.05,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height*0.05),
                  SizedBox(
                    width: width*0.8,
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.schedule,
                            color: Colors.white,
                            size: width*0.04,
                          ),
                          SizedBox(width: width*0.02),
                          Text(
                            event.hour.toString(),
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                          ),
                          Text(
                            ":",
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                          ),
                          Text(
                            event.minute=="0" ? "00" : event.minute.toString(),
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                          ),
                          const SizedBox(
                              height: 16,
                              width: 32,
                              child: VerticalDivider(color: Colors.white, width: 10, thickness: 2,)
                          ),
                          Icon(
                            Icons.timer,
                            color: Colors.white,
                            size: width*0.04,
                          ),
                          SizedBox(width: width*0.02),
                          Text(
                            StringUtils().durationToString(event.duration!),
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                          ),
                          const SizedBox(
                              height: 16,
                              width: 32,
                              child: VerticalDivider(color: Colors.white, width: 10, thickness: 2,)
                          ),
                          const Icon(
                            Icons.record_voice_over,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: width*0.02),
                          Text(
                            event.numTrainers.toString(),
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                          ),
                          const SizedBox(
                              height: 16,
                              width: 32,
                              child: VerticalDivider(color: Colors.white, width: 10, thickness: 2,)
                          ),
                          const Icon(
                            Icons.directions_run,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: width*0.02),
                          Text(
                            event.numClients.toString(),
                            style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height,
        maxWidth: MediaQuery.of(context).size.width*0.84,
        minWidth: MediaQuery.of(context).size.width*0.84,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(15.0),
          bottomRight: Radius.circular(15.0),
        ),// BorderRadius

      ),// BoxDecoration
      child: Container(
        margin: const EdgeInsetsDirectional.only(start: 1, end: 1, bottom: 1),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height,
          maxWidth: MediaQuery.of(context).size.width*0.84,
          minWidth: MediaQuery.of(context).size.width*0.84,
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width*0.05, left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.05),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(15.0),
            bottomRight: Radius.circular(15.0),
          ),// BorderRadius
        ),// BoxDecoration
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: navigateToProfileScreen,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.width * 0.15,
                    child: Center(
                      child: CircularImage(
                        size: MediaQuery.of(context).size.width * 0.15,
                        image: currentUser.imageUrl,
                        color: Theme.of(context).backgroundColor,
                        borderWidth: 1,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width*0.02,),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          StringUtils().greetingMessage(context),
                          style: Theme.of(context).textTheme.bodyText1?.copyWith(color: AppColors.grey),
                          textAlign: TextAlign.center
                      ),
                      Text(
                          currentUser.firstName!,
                          style: Theme.of(context).textTheme.headline1,
                          textAlign: TextAlign.center
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CounterBadgeIcon(
                      counter: unreadNotifications,
                      child: IconButton(
                        icon: Icon(Icons.notifications, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.06),
                        alignment: Alignment.centerRight,
                        onPressed: navigateToNotificationsScreen,
                      ),
                    ),
                    CounterBadgeIcon(
                      counter: unreadChats,
                      child: IconButton(
                        icon: Icon(Icons.chat, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.06),
                        alignment: Alignment.centerRight,
                        onPressed: navigateToChatScreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.04,),
            StreamBuilder<QuerySnapshot>(
                stream: _eventDataService.getUserEventsTodayStream(currentUser.id!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return LoadingView(
                      hasLogo: false,
                    );
                  } else {
                    userEventsToday = documentsToEvents(snapshot.data!.docs);
                    if (userEventsToday.isNotEmpty) {
                      eventSliders = userEventsToday
                          .map((item) => Container(
                          child: buildEventContainer(item, MediaQuery.of(context).size.height*0.20, MediaQuery.of(context).size.width, buildBadge(userEventsToday.indexOf(item)))
                      ))
                          .toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height*0.05,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.08),
                              child: Text(AppLocalizations.of(context)!.todaysBrandEvents, style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.w400), textAlign: TextAlign.start),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height*0.20,
                            width: MediaQuery.of(context).size.width,
                            child: CarouselSlider(
                              options: CarouselOptions(
                                  autoPlay: false,
                                  aspectRatio: 2.0,
                                  viewportFraction: 0.84,
                                  enlargeCenterPage: true,
                                  enableInfiniteScroll: false,
                                  initialPage: _current,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _current = index;
                                    });
                                  }
                              ),
                              items: eventSliders,
                            ),
                          ),
                          userEventsToday.length > 1 ? SizedBox(
                            height: MediaQuery.of(context).size.height*0.05,
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: eventSliders.asMap().entries.map((entry) {
                                return Container(
                                  width: MediaQuery.of(context).size.height*0.01,
                                  height: MediaQuery.of(context).size.height*0.01,
                                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: (Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black)
                                          .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                                );
                              }).toList(),
                            ),
                          ) : Container(),
                        ],
                      );
                    } else {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height*0.10,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(child: Text(AppLocalizations.of(context)!.noEventsToday, style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.w400), textAlign: TextAlign.start)),
                              TextButton(
                                onPressed: null,
                                child: Text(
                                  AppLocalizations.of(context)!.calendar,
                                  style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.secondary),
                                ),
                              ),
                            ],
                          ),
                        )
                      );
                    }
                    return Container();
                    /*
                  if (userBonos.isNotEmpty) {
                    return Column(
                      children: [
                        SizedBox(
                          height: widget.height*0.05,
                          width: widget.width*0.84,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  AppLocalizations.of(context)!.bonos,
                                  style: Theme.of(context).textTheme.headline3!.copyWith(color: AppColors.grey, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: widget.height*0.02,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: widget.width*0.08),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: userBonos.length,
                            itemBuilder: (context,int index) {
                              Bono bono = userBonos[index];
                              int sessions = bono.sessions!;
                              String purchaseId = bono.purchaseId!;
                              return StreamBuilder<DocumentSnapshot>(
                                  stream: _brandDataService.getBonoInfoStream(bono.brandId!, bono.id!),
                                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                    if (!snapshot.hasData) {
                                      return Container();
                                    } else {
                                      bono = Bono.fromObjectAllData(snapshot.data!.id, snapshot.data!);
                                      bono.setBonoSessions = sessions;
                                      return StreamBuilder<DocumentSnapshot>(
                                          stream: _purchaseDataService.getPurchaseInfoStream(purchaseId),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return Container();
                                            } else {
                                              Purchase bonoPurchase = Purchase.fromObjectAllData(snapshot.data!.id, snapshot.data!);
                                              return ClientBonoCard(
                                                height: widget.height*0.22,
                                                width: widget.width*0.84,
                                                bono: bono,
                                                brand: currentBrand,
                                                purchase: bonoPurchase,
                                                canExpand: true,
                                                onlyView: false,
                                              );
                                            }
                                          }
                                      );
                                    }
                                  }
                              );
                            },
                          ),
                        ),
                        SizedBox(height: widget.height*0.04,),
                      ],
                    );
                  } else {
                    return Container();
                  }
                   */
                  }
                }
            ),
          ],
        ),
      ),
    );// Container

  }
}
