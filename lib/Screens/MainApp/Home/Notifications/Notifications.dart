// Flutter Libs
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Calendars/CalendarWidgetClient.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Calendars/CalendarWidgetTrainer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Events/ViewEventClient.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Events/ViewEventTrainer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Globals/Widgets/ProfileView/ProfileUserView.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:mamba_castelldefels/Models/NotificationEvent.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Marca/Trainer/TieneMarca/TieneMarcaModals/MembershipRequests.dart';
import 'package:page_transition/page_transition.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {

  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  // Notification List
  List<NotificationEvent> notificationsList = [];
  List<Usuario> usersList = [];
  List<Brand> brandsList = [];
  List<Event> eventList = [];
  // Unread Notifications
  int numberUnreadNotifications = 0;
  // Has unread notifications
  bool hasUnread = false;

  @override
  initState() {
    super.initState();
  }

  String undoCapitalized(String s) => s.length > 0 ?'${s[0].toLowerCase()}${s.substring(1)}':'';

  Future<List<NotificationEvent>> documentsToNotifications(List<DocumentSnapshot> documents) async {
    List<NotificationEvent> notifications = [];
    List<Usuario> users = [];
    List<Brand> brands = [];
    List<Event> events = [];

    for(int i = 0; i < documents.length; i++) {
      NotificationEvent notification = NotificationEvent.fromObject(documents[i], documents[i].id);
      if (notification.isRead == false && hasUnread == false) {
        Future.delayed(Duration.zero, () async {
          setState(() {
            hasUnread = true;
          });
        });
      }
      if (notification.parameters.length > 0) {
        if (notification.parameters[0] != "null") {
          Usuario user = users.firstWhere((element) => element.id == notification.parameters[0], orElse: () => Usuario());
          if (user.id == null) {
            List<String> coverInformation = await _accessDatabase.getUserCover(notification.parameters[0]);
            user = Usuario(id: notification.parameters[0], name: coverInformation[0], imageUrl: coverInformation[1]);
          }
          users.add(user);
        } else {
          users.add(Usuario());
        }
        if (notification.parameters[1] != "null") {
          Brand brand = brands.firstWhere((element) => element.id == notification.parameters[1], orElse: () => Brand());
          if (brand.id == null) {
            List<String> coverInformation = await _accessDatabase.getBrandCover(notification.parameters[1]);
            brand = Brand(id: notification.parameters[1], name: coverInformation[0], logoUrl: coverInformation[1]);
          }
          brands.add(brand);
        } else {
          brands.add(Brand());
        }
        if (notification.parameters[2] != "null") {
          Event event = events.firstWhere((element) => element.id == notification.parameters[2], orElse: () => Event());
          if (event.id == null) {
            event = await _accessDatabase.getSingleEvent(notification.parameters[2]);
          }
          events.add(event);
        } else {
          events.add(Event());
        }
      } else {
        users.add(Usuario());
        brands.add(Brand());
        events.add(Event());
      }
      notifications.add(notification);
    }
    notificationsList = notifications;
    usersList = users;
    brandsList = brands;
    eventList = events;
    return notifications;
  }

  Future<void> countUnreadNotifications () async {
    int count = 0;
    count = await _accessDatabase.numberUnreadNotifications(currentUser.id!);
    if (count != numberUnreadNotifications) {
      numberUnreadNotifications = count;
      setState(() {
        unreadNotifications = numberUnreadNotifications;
      });
    }
  }

  void unreadNotificationsFunction (List<NotificationEvent> list) {
    int count = 0;
    for (int i = 0; i < list.length; i++) {
      NotificationEvent notification = list[i];
      if (notification.isRead == false) {
        count += 1;
      }
    }
    WidgetsBinding.instance!.addPostFrameCallback((_){
      if (mounted) {
        setState(() {
          unreadNotifications = count;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            SizedBox(width: MediaQuery.of(context).size.width*0.01,),
            Text(AppLocalizations.of(context)!.notificationsBottomNav, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22), textAlign: TextAlign.center,),
          ],
        ),
        centerTitle: false,
        actions: [
          hasUnread ? TextButton.icon(
            icon: Icon(Icons.mark_email_read_outlined, color: Theme.of(context).primaryColor,),
            label: Text(
              AppLocalizations.of(context)!.markAsRead,
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () async {
              await _accessDatabase.markALLNotificationAsRead(currentUser.id!);
              setState(() {
                hasUnread = false;
              });
            },
          ) : Container(),
          SizedBox(width: MediaQuery.of(context).size.width*0.03,),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
                stream: _accessDatabase.getAllNotificationsUser(currentUser.id!),
                builder: (context, snapshot) {
                  if (snapshot == null || snapshot.data == null || snapshot.data!.docs == null ) {
                    return Container(
                        height: MediaQuery.of(context).size.height*0.65,
                        child: Center(
                            child: LoadingViewPurple()
                        )
                    );
                  } else {
                    return FutureBuilder<List<NotificationEvent>>(
                        future: documentsToNotifications(snapshot.data!.docs),
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            notificationsList = snapshot.data!;
                            return ListView.builder(
                                physics: BouncingScrollPhysics(),
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: notificationsList.length,
                                itemBuilder: (context, index) {
                                  NotificationEvent notification = notificationsList[index];
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.01),
                                    child: returnNotification(index, notification),
                                  );
                                }
                            );
                          } else {
                            return Container(
                                height: MediaQuery.of(context).size.height*0.80,
                                child: Center(
                                    child: LoadingViewPurple()
                                )
                            );
                          }
                        }
                    );
                  }
                }
            ),
          ],
        ),
      ),
    );
  }

  Widget returnNotification(int index, NotificationEvent notification) {
    Usuario user = usersList[index];
    Brand brand = brandsList[index];
    Event event = eventList[index];

    switch(notification.type!) {
      case "Wellcome_User": {
        return ListTile(
          leading: SizedBox(
            width: MediaQuery.of(context).size.width*0.15,
            child: Center(
              child: Image(
                  width: MediaQuery.of(context).size.width*0.10,
                  image: AssetImage(Constants.logoSimpleYellow)
              ),
            ),
          ),
          title: Text(
            AppLocalizations.of(context)!.wellcomeToMAMBA,
            style: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                AppLocalizations.of(context)!.onlyImportantNotifications,
                style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          onTap: () async {
            await _accessDatabase.markNotificationAsRead(notification.id!);
            returnActionOnTap(index,notification);
          },
        );
      }
      case "UserCreatesBrand_User": {
        // Name and Image
        return ListTile(
          leading: CircularImage(
            size: MediaQuery.of(context).size.width*0.15,
            image: brand.logoUrl!,
            color: Theme.of(context).primaryColor,
            borderWidth: 1.5,
          ),
          title: Text(
            AppLocalizations.of(context)!.userCreatesBrandUser(brand.name!),
            style: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                AppLocalizations.of(context)!.userCreatesBrandUserSubtitle,
                style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          onTap: () async {
            await _accessDatabase.markNotificationAsRead(notification.id!);
            returnActionOnTap(index,notification);
          },
        );
      }
      case "UserJoinsBrand_User": {
        return ListTile(
          leading: CircularImage(
            size: MediaQuery.of(context).size.width*0.15,
            image: brand.logoUrl!,
            color: Theme.of(context).primaryColor,
            borderWidth: 1.5,
          ),
          title: Text(
            AppLocalizations.of(context)!.userJoinsBrandUser(brand.name!),
            style: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                AppLocalizations.of(context)!.userJoinsBrandSubtitleUser,
                style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          onTap: () async {
            await _accessDatabase.markNotificationAsRead(notification.id!);
            returnActionOnTap(index,notification);
          },
        );
      }
      case "UserJoinsBrand_Trainer": {
        return ListTile(
          leading: CircularImage(
            size: MediaQuery.of(context).size.width*0.15,
            image: user.imageUrl!,
            color: Theme.of(context).primaryColor,
            borderWidth: 1.5,
          ),
          title: Text(
            AppLocalizations.of(context)!.userJoinsBrandBrand(user.name!, brand.name!),
            style: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                AppLocalizations.of(context)!.userJoinsBrandBrandSubtitle(notification.parameters[3]),
                style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          onTap: () async {
            await _accessDatabase.markNotificationAsRead(notification.id!);
            returnActionOnTap(index,notification);
          },
        );
      }
      case "UserLeavesBrand_User": {
        return ListTile(
          leading: CircularImage(
            size: MediaQuery.of(context).size.width*0.15,
            image: brand.logoUrl!,
            color: Theme.of(context).primaryColor,
            borderWidth: 1.5,
          ),
          title: Text(
            AppLocalizations.of(context)!.userLeavesBrandUser(brand.name!),
            style: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                AppLocalizations.of(context)!.userLeavesBrandUserSubtitle,
                style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          onTap: () async {
            await _accessDatabase.markNotificationAsRead(notification.id!);
            returnActionOnTap(index,notification);
          },
        );
      }
      case "UserLeavesBrand_Trainer": {
        return ListTile(
          leading: CircularImage(
            size: MediaQuery.of(context).size.width*0.15,
            image: user.imageUrl!,
            color: Theme.of(context).primaryColor,
            borderWidth: 1.5,
          ),
          title: Text(
            AppLocalizations.of(context)!.userLeavesBrandBrand(user.name!, brand.name!),
            style: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                AppLocalizations.of(context)!.userLeavesBrandBrandSubtitle(notification.parameters[3]),
                style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          onTap: () async {
            await _accessDatabase.markNotificationAsRead(notification.id!);
            returnActionOnTap(index,notification);
          },
        );
      }
      case "UserSendRequestToBrand_User": {
        return ListTile(
          leading: CircularImage(
            size: MediaQuery.of(context).size.width*0.15,
            image: brand.logoUrl!,
            color: Theme.of(context).primaryColor,
            borderWidth: 1.5,
          ),
          title: Text(
            AppLocalizations.of(context)!.userSendRequestToBrandUser(brand.name!),
            style: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                AppLocalizations.of(context)!.userSendRequestToBrandUserSubtitle,
                style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          onTap: () async {
            await _accessDatabase.markNotificationAsRead(notification.id!);
            returnActionOnTap(index,notification);
          },
        );
      }
      case "UserSendRequestToBrand_Trainer": {
        return ListTile(
          leading: CircularImage(
            size: MediaQuery.of(context).size.width*0.15,
            image: user.imageUrl!,
            color: Theme.of(context).primaryColor,
            borderWidth: 1.5,
          ),
          title: Text(
            AppLocalizations.of(context)!.userSendRequestToBrandBrand(user.name!),
            style: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                AppLocalizations.of(context)!.userSendRequestToBrandBrandSubtitle(notification.parameters[3]),
                style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          onTap: () async {
            await _accessDatabase.markNotificationAsRead(notification.id!);
            returnActionOnTap(index,notification);
          },
        );
      }
      case "UserCancelRequestToBrand_User": {
        return ListTile(
          leading: CircularImage(
            size: MediaQuery.of(context).size.width*0.15,
            image: brand.logoUrl!,
            color: Theme.of(context).primaryColor,
            borderWidth: 1.5,
          ),
          title: Text(
            AppLocalizations.of(context)!.userCancelRequestToBrandUser(brand.name!),
            style: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                AppLocalizations.of(context)!.userCancelRequestToBrandUserSubtitle,
                style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          onTap: () async {
            await _accessDatabase.markNotificationAsRead(notification.id!);
            returnActionOnTap(index,notification);
          },
        );
      }
      case "UserCancelRequestToBrand_Trainer": {
        return ListTile(
          leading: CircularImage(
            size: MediaQuery.of(context).size.width*0.15,
            image: user.imageUrl!,
            color: Theme.of(context).primaryColor,
            borderWidth: 1.5,
          ),
          title: Text(
            AppLocalizations.of(context)!.userCancelRequestToBrandBrand(user.name!),
            style: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                AppLocalizations.of(context)!.userCancelRequestToBrandBrandSubtitle,
                style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          onTap: () async {
            await _accessDatabase.markNotificationAsRead(notification.id!);
            returnActionOnTap(index,notification);
          },
        );
      }
      case "UserJoinEvent_User": {
        var startDate = DateTime(
          int.parse(event.year!),
          int.parse(event.month!),
          int.parse(event.day!),
          int.parse(event.hour!),
          int.parse(event.minute!),
        );
        String eventTimeDay = DateFormat('EE dd/MM/yy', Localizations.localeOf(context).languageCode).format(startDate);
        String eventTimeTime = "${event.hour.toString()}:${event.minute=="0" ? "00" : event.minute.toString()}h";
        return ListTile(
          leading: CircularImage(
            size: MediaQuery.of(context).size.width*0.15,
            image: brand.logoUrl!,
            color: Theme.of(context).primaryColor,
            borderWidth: 1.5,
          ),
          title: Text(
            AppLocalizations.of(context)!.userJoinEventUser(event.title!, brand.name!),
            style: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                AppLocalizations.of(context)!.userJoinEventUserSubtitle(eventTimeDay, eventTimeTime),
                style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          onTap: () async {
            await _accessDatabase.markNotificationAsRead(notification.id!);
            returnActionOnTap(index,notification);
          },
        );
      }
      case "UserJoinEvent_Trainer": {
        return ListTile(
          leading: CircularImage(
            size: MediaQuery.of(context).size.width*0.15,
            image: user.imageUrl,
            color: Theme.of(context).primaryColor,
            borderWidth: 1.5,
          ),
          title: Text(
            AppLocalizations.of(context)!.userJoinEventBrand(user.name!, event.title!),
            style: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                AppLocalizations.of(context)!.userJoinEventBrandSubtitle(event.joinedMembers.length.toString(), event.maxMembers.toString() ),
                style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          onTap: () async {
            await _accessDatabase.markNotificationAsRead(notification.id!);
            returnActionOnTap(index,notification);
          },
        );
      }
      case "UserLeaveEvent_User": {
        var startDate = DateTime(
          int.parse(event.year!),
          int.parse(event.month!),
          int.parse(event.day!),
          int.parse(event.hour!),
          int.parse(event.minute!),
        );
        String eventTimeDay = DateFormat('EE dd/MM/yy', Localizations.localeOf(context).languageCode).format(startDate);
        String eventTimeTime = "${event.hour.toString()}:${event.minute=="0" ? "00" : event.minute.toString()}h";
        return ListTile(
          leading: CircularImage(
            size: MediaQuery.of(context).size.width*0.15,
            image: brand.logoUrl!,
            color: Theme.of(context).primaryColor,
            borderWidth: 1.5,
          ),
          title: Text(
            AppLocalizations.of(context)!.userLeavesEventUser(event.title!, brand.name!),
            style: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                AppLocalizations.of(context)!.userLeavesEventUserSubtitle,
                style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          onTap: () async {
            await _accessDatabase.markNotificationAsRead(notification.id!);
            returnActionOnTap(index,notification);
          },
        );
      }
      case "UserLeaveEvent_Trainer": {
        return ListTile(
          leading: CircularImage(
            size: MediaQuery.of(context).size.width*0.15,
            image: user.imageUrl,
            color: Theme.of(context).primaryColor,
            borderWidth: 1.5,
          ),
          title: Text(
            AppLocalizations.of(context)!.userLeavesEventBrand(user.name!, event.title!),
            style: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                AppLocalizations.of(context)!.userLeavesEventBrandSubtitle(event.joinedMembers.length.toString(), event.maxMembers.toString() ),
                style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          onTap: () async {
            await _accessDatabase.markNotificationAsRead(notification.id!);
            returnActionOnTap(index,notification);
          },
        );
      }
      default: {
        return Container();
      }
    }
  }

  void returnActionOnTap (int index, NotificationEvent notification) {

    Usuario user = usersList[index];
    Brand brand = brandsList[index];
    Event event = eventList[index];

    switch(notification.type!) {
      case "Wellcome_User": {
        break;
      }
      case "UserCreatesBrand_User": {
        break;
      }
      case "UserJoinsBrand_User": {
        if (currentUser.isTrainer!) {
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.bottomToTop,
                  child: CalendarWidgetTrainer(
                    brandID: notification.parameters[1],
                    canEdit: true,
                  )
              )
          );
        } else {

          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.bottomToTop,
                  child: CalendarWidgetClient(
                    brandID: notification.parameters[1],
                    onlyView: false,
                  )
              )
          );
        }
        break;
      }
      case "UserJoinsBrand_Trainer": {
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.bottomToTop,
                child: ProfileViewUser(
                  userID: notification.parameters[0],
                  viewOnly: false,
                )
            )
        );
        break;
      }
      case "UserLeavesBrand_User": {
        break;
      }
      case "UserLeavesBrand_Trainer": {
        break;
      }
      case "UserSendRequestToBrand_User": {
        break;
      }
      case "UserSendRequestToBrand_Trainer": {
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.bottomToTop,
                child: MembershipRequests(
                  brandId: notification.parameters[1],
                )
            )
        );
        break;
      }
      case "UserCancelRequestToBrand_User": {
        break;
      }
      case "UserCancelRequestToBrand_Trainer": {
        break;
      }
      case "UserJoinEvent_User": {
        bool canAction = true;
        var startDate = DateTime(
          int.parse(event.year!),
          int.parse(event.month!),
          int.parse(event.day!),
          int.parse(event.hour!),
          int.parse(event.minute!),
        );
        if (startDate.isBefore(DateTime.now())) {
          canAction = false;
        }
        Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.bottomToTop,
              child: ViewEventClient(
                eventId: notification.parameters[2],
                canJoin: canAction,
                locale: Localizations.localeOf(context),
              ),
            )
        );
        break;
      }
      case "UserJoinEvent_Trainer": {
        bool canAction = true;
        var startDate = DateTime(
          int.parse(event.year!),
          int.parse(event.month!),
          int.parse(event.day!),
          int.parse(event.hour!),
          int.parse(event.minute!),
        );
        if (startDate.isBefore(DateTime.now())) {
          canAction = false;
        }
        Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.bottomToTop,
              child: ViewEventTrainer(
                eventId: notification.parameters[2],
                canEdit: canAction,
                locale: Localizations.localeOf(context),
              ),
            )
        );
        break;
      }
      case "UserLeaveEvent_User": {
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.bottomToTop,
                child: CalendarWidgetClient(
                  brandID: notification.parameters[1],
                  onlyView: true,
                )
            )
        );
        break;
      }
      case "UserLeaveEvent_Trainer": {
        bool canAction = true;
        var startDate = DateTime(
          int.parse(event.year!),
          int.parse(event.month!),
          int.parse(event.day!),
          int.parse(event.hour!),
          int.parse(event.minute!),
        );
        if (startDate.isBefore(DateTime.now())) {
          canAction = false;
        }
        Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.bottomToTop,
              child: ViewEventTrainer(
                eventId: notification.parameters[2],
                canEdit: canAction,
                locale: Localizations.localeOf(context),
              ),
            )
        );
        break;
      }
      default: {
        break;
      }
    }
  }

}
