// Flutter Libs
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Calendars/CalendarWidgetClient.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Calendars/CalendarWidgetTrainer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Events/ViewEventTrainer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Globals/Widgets/ProfileView/ProfileUserView.dart';
import 'package:mamba_castelldefels/Models/NotificationEvent.dart';
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
  List<NotificationEvent> notReadNotificationsList = [];

  @override
  initState() {
    super.initState();
  }

  String undoCapitalized(String s) => s.length > 0 ?'${s[0].toLowerCase()}${s.substring(1)}':'';

  List<NotificationEvent> documentsToNotifications(List<DocumentSnapshot> documents) {
    List<NotificationEvent> notifications = [];
    for(int i = 0; i < documents.length; i++) {
      NotificationEvent notification = NotificationEvent.fromObject(documents[i], documents[i].id);
      notifications.add(notification);
    }
    unreadNotificationsFunction(notifications);
    return notifications;
  }

  void unreadNotificationsFunction (List<NotificationEvent> list) {
    int count = 0;
    for (int i = 0; i < list.length; i++) {
      NotificationEvent notification = list[i];
      if (notification.isRead == false) {
        count += 1;
      }
    }
    Future.delayed(Duration.zero, () async {
      setState(() {
        unreadNotifications = count;
      });
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
          TextButton.icon(
            icon: Icon(Icons.mark_email_read_outlined, color: Theme.of(context).primaryColor,),
            label: Text(
              AppLocalizations.of(context)!.markAsRead,
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              _accessDatabase.markALLNotificationAsRead(currentUser.id!);
              unreadNotificationsFunction(notificationsList);
            },
          ),
          SizedBox(width: MediaQuery.of(context).size.width*0.03,),
        ],
      ),
      body: Column(
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
                  notificationsList = documentsToNotifications(snapshot.data!.docs);
                  unreadNotificationsFunction(notificationsList);
                  return ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: notificationsList.length,
                      itemBuilder: (context, index) {
                        NotificationEvent notification = notificationsList[index];
                        bool isRead = notification.isRead!;
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.01),
                          child: ListTile(
                            leading: returnIconGivenType(notification),
                            title: Text(
                              notification.title!,
                              style: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                Text(
                                  notification.subtitle!,
                                  style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            onTap: () {
                              _accessDatabase.markNotificationAsRead(notification.id!);
                              unreadNotificationsFunction(notificationsList);
                              returnActionOnTap(notification);
                            },
                          ),
                        );
                      }
                  );
                }
              }
          ),
        ],
      ),
    );
  }

  Widget returnIconGivenType (NotificationEvent notification) {
    // Return the leading icon depending on Type
    switch(notification.type!) {
      case "Wellcome_User": {
        return SizedBox(
            width: MediaQuery.of(context).size.width*0.15,
            child: Center(
              child: Image(
                width: MediaQuery.of(context).size.width*0.10,
                image: AssetImage(Constants.logoSimpleYellow)
              ),
            ),
          );
      }
      case "UserJoinsBrand_User": {
        return CircularImage(
          size: MediaQuery.of(context).size.width*0.15,
          image: notification.parameters[1],
          color: Theme.of(context).primaryColor,
          borderWidth: 1.5,
        );
      }
      case "UserJoinsBrand_Trainer": {
        return CircularImage(
          size: MediaQuery.of(context).size.width*0.15,
          image: notification.parameters[1],
          color: Theme.of(context).primaryColor,
          borderWidth: 1.5,
        );
      }
      case "UserLeavesBrand_User": {
        return CircularImage(
          size: MediaQuery.of(context).size.width*0.15,
          image: notification.parameters[1],
          color: Theme.of(context).primaryColor,
          borderWidth: 1.5,
        );
      }
      case "UserLeavesBrand_Trainer": {
        return CircularImage(
          size: MediaQuery.of(context).size.width*0.15,
          image: notification.parameters[1],
          color: Theme.of(context).primaryColor,
          borderWidth: 1.5,
        );
      }
      case "UserSendRequestToBrand_User": {
        return CircularImage(
          size: MediaQuery.of(context).size.width*0.15,
          image: notification.parameters[1],
          color: Theme.of(context).primaryColor,
          borderWidth: 1.5,
        );
      }
      case "UserSendRequestToBrand_Trainer": {
        return CircularImage(
          size: MediaQuery.of(context).size.width*0.15,
          image: notification.parameters[1],
          color: Theme.of(context).primaryColor,
          borderWidth: 1.5,
        );
      }
      case "EventJoined": {
        return CircularImage(
          size: MediaQuery.of(context).size.width*0.15,
          image: notification.parameters[0],
          color: Theme.of(context).primaryColor,
          borderWidth: 1.5,
        );
      }
      case "EventAbandoned": {
        return
          Icon(
            Icons.event_busy,
            color: Colors.red,
            size: 30,
          );
      }
      default: {
        return Container();
      }
    }
  }

  void returnActionOnTap (NotificationEvent notification) {
    switch(notification.type!) {
      case "Wellcome_User": {
        break;
      }
      case "UserJoinsBrand_User": {
        if (currentUser.isTrainer!) {
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.bottomToTop,
                  child: CalendarWidgetTrainer(
                    brandID: notification.parameters[0],
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
                    brandID: notification.parameters[0],
                    onlyView: true,
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
        if (notification.isRead == false) {
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.bottomToTop,
                  child: MembershipRequests(
                    brandId: notification.parameters[2],
                  )
              )
          );
        }
        break;
      }
      case "EventJoined": {
        Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.bottomToTop,
              child: ViewEventTrainer(
                eventId: notification.parameters[1],
                canEdit: false,
                locale: Localizations.localeOf(context),
              ),
            )
        );
        break;
      }
      case "EventAbandoned": {
        break;
      }
      default: {
        break;
      }
    }
  }

}
