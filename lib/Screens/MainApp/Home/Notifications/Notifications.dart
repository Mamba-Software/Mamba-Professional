// Flutter Libs
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Models/NotificationEvent.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {

  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  // Request List
  List<NotificationEvent> notificationsList = [];

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
    return notifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(AppLocalizations.of(context)!.notificationsBottomNav, style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22), textAlign: TextAlign.center,),
        actions: [
          IconButton(
            icon: Icon(Icons.mark_email_read_outlined),
            onPressed: () {

            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height*0.01),
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
                  return ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: notificationsList.length,
                      itemBuilder: (context, index) {
                        NotificationEvent notification = notificationsList[index];
                        return ListTile(
                          leading: Icon(Icons.calendar_today_outlined, color: Theme.of(context).primaryColor, size: 25,),
                          title: Text(
                            notification.title!,
                            style: Styles.purpleTextStyle.copyWith(fontSize: 14, color: Colors.grey),
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
                          trailing: Icon(Icons.help_outline, color: Theme.of(context).primaryColor, size: 30,),
                          onTap: () {

                          },
                        );
                      }
                  );
                }
              }
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.01),
        ],
      ),
    );
  }
}
