// Flutter Libs
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DatabaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Calendars/CalendarWidgetClient.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Calendars/CalendarWidgetTrainer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Events/ViewEventClient.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CalendarView/Events/ViewEventTrainer.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Images/CircularImage.dart';
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
  // Acceso a Base de Datos
  bool isLoading = true;
  // Notification List
  List<NotificationEvent> notificationsList = [];
  List<Usuario> usersList = [];
  List<Brand> brandsList = [];
  List<Event> eventList = [];
  // Has unread notifications
  bool hasUnread = false;
  // String Deleted Photo
  String deletedObject = "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/not-found-image.jpg?alt=media&token=70687295-6a17-4735-9c0a-e5749c777319";

  @override
  initState() {
    super.initState();
    isLoading = true;
    getAllNotifications();
  }

  Future<void> getAllNotifications () async {
    List<Usuario> users = [];
    List<Brand> brands = [];
    List<Event> events = [];
    notificationsList = await _accessDatabase.getAllNotificationsUser(currentUser.id!);
    // Order Notification List Descending Time
    notificationsList.sort((a,b) {
      var aDate =  DateTime(
        int.parse(a.year!),
        int.parse(a.month!),
        int.parse(a.day!),
        int.parse(a.hour!),
        int.parse(a.minutes!),
        int.parse(a.seconds!),
      );
      var bDate =  DateTime(
        int.parse(b.year!),
        int.parse(b.month!),
        int.parse(b.day!),
        int.parse(b.hour!),
        int.parse(b.minutes!),
        int.parse(b.seconds!),
      );
      return aDate.compareTo(bDate);
    });
    notificationsList = List.from(notificationsList.reversed);
    // Get User, Brand and Events when needed
    for(int i = 0; i < notificationsList.length; i++) {
      NotificationEvent notification = notificationsList[i];
      if (notification.parameters.length > 0) {
        if (notification.parameters[0] != "null") {
          Usuario user = users.firstWhere((element) => element.id == notification.parameters[0], orElse: () => Usuario());
          if (user.id == null) {
            List<String> coverInformation = await _accessDatabase.getUserCoverDetails(notification.parameters[0]);
            if (coverInformation[0] != "Error") {
              user = Usuario(id: notification.parameters[0], name: coverInformation[0], imageUrl: coverInformation[1]);
            } else {
              user = Usuario(name: AppLocalizations.of(context)!.deletedUser.toLowerCase(), imageUrl: deletedObject);
            }
          }
          users.add(user);
        } else {
          users.add(Usuario());
        }
        if (notification.parameters[1] != "null") {
          Brand brand = brands.firstWhere((element) => element.id == notification.parameters[1], orElse: () => Brand());
          if (brand.id == null) {
            List<String> coverInformation = await _accessDatabase.getBrandCover(notification.parameters[1]);
            if (coverInformation[0] != "Error") {
              brand = Brand(id: notification.parameters[1], name: coverInformation[0], logoUrl: coverInformation[1]);
            } else {
              brand = Brand(name: AppLocalizations.of(context)!.deletedBrand.toLowerCase(), logoUrl: deletedObject);
            }
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
          if (event.id == null) {
            events.add(Event(title: AppLocalizations.of(context)!.deletedEvent.toLowerCase()));
          } else {
            events.add(event);
          }
        } else {
          events.add(Event());
        }
      } else {
        users.add(Usuario());
        brands.add(Brand());
        events.add(Event());
      }
    }
    usersList = users;
    brandsList = brands;
    eventList = events;
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String undoCapitalized(String s) => s.length > 0 ?'${s[0].toLowerCase()}${s.substring(1)}':'';

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
            onPressed: () async {
              for (NotificationEvent notif in notificationsList) {
                setState(() {
                  notif.isRead = true;
                });
              }
              await _accessDatabase.markALLNotificationAsRead(currentUser.id!);
            },
          ),
          SizedBox(width: MediaQuery.of(context).size.width*0.03,),
        ],
      ),
      body: !isLoading ? RefreshIndicator(
        displacement: MediaQuery.of(context).size.height*0.05,
        color: Theme.of(context).accentColor,
        onRefresh: () {
          return Future.delayed(
            Duration(seconds: 1), () async {
              this.getAllNotifications();
            },
          );
        },
        child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
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
          ),
      ) : LoadingViewPurple(),
    );
  }

  Widget returnNotification(int index, NotificationEvent notification) {
    var dateSent = DateTime(
      int.parse(notification.year!),
      int.parse(notification.month!),
      int.parse(notification.day!),
      int.parse(notification.hour!),
      int.parse(notification.minutes!),
    );
    String time = DateFormat("E dd MMMM yyyy, HH:mm", Localizations.localeOf(context).languageCode).format(dateSent);
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
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                time.toUpperCase(),
                style: Styles.purpleTextStyle.copyWith(fontSize: 10, color: Theme.of(context).primaryColor),
              ),
            ],
          ),
          onTap: () async {
            await _accessDatabase.markNotificationAsRead(currentUser.id!, notification.id!);
            setState(() {
              notificationsList[index].isRead = true;
            });
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
            borderWidth: 1,
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
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                time.toUpperCase(),
                style: Styles.purpleTextStyle.copyWith(fontSize: 10, color: Theme.of(context).primaryColor),
              ),
            ],
          ),
          onTap: () async {
            await _accessDatabase.markNotificationAsRead(currentUser.id!, notification.id!);

            setState(() {
              notificationsList[index].isRead = true;
            });
          },
        );
      }
      case "UserJoinsBrand_User": {
        return ListTile(
          leading: CircularImage(
            size: MediaQuery.of(context).size.width*0.15,
            image: brand.logoUrl!,
            color: Theme.of(context).primaryColor,
            borderWidth: 1.0,
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
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                time.toUpperCase(),
                style: Styles.purpleTextStyle.copyWith(fontSize: 10, color: Theme.of(context).primaryColor),
              ),
            ],
          ),
          onTap: () async {
            await _accessDatabase.markNotificationAsRead(currentUser.id!, notification.id!);
            setState(() {
              notificationsList[index].isRead = true;
            });
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
            borderWidth: 1.0,
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
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                time.toUpperCase(),
                style: Styles.purpleTextStyle.copyWith(fontSize: 10, color: Theme.of(context).primaryColor),
              ),
            ],
          ),
          onTap: () async {
            await _accessDatabase.markNotificationAsRead(currentUser.id!, notification.id!);
            setState(() {
              notificationsList[index].isRead = true;
            });
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
            borderWidth: 1.0,
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
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                time.toUpperCase(),
                style: Styles.purpleTextStyle.copyWith(fontSize: 10, color: Theme.of(context).primaryColor),
              ),
            ],
          ),
          onTap: () async {
            await _accessDatabase.markNotificationAsRead(currentUser.id!, notification.id!);
            setState(() {
              notificationsList[index].isRead = true;
            });
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
            borderWidth: 1.0,
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
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                time.toUpperCase(),
                style: Styles.purpleTextStyle.copyWith(fontSize: 10, color: Theme.of(context).primaryColor),
              ),
            ],
          ),
          onTap: () async {
            await _accessDatabase.markNotificationAsRead(currentUser.id!, notification.id!);
            setState(() {
              notificationsList[index].isRead = true;
            });
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
            borderWidth: 1.0,
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
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                time.toUpperCase(),
                style: Styles.purpleTextStyle.copyWith(fontSize: 10, color: Theme.of(context).primaryColor),
              ),
            ],
          ),
          onTap: () async {
            await _accessDatabase.markNotificationAsRead(currentUser.id!, notification.id!);
            setState(() {
              notificationsList[index].isRead = true;
            });
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
            borderWidth: 1.0,
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
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                time.toUpperCase(),
                style: Styles.purpleTextStyle.copyWith(fontSize: 10, color: Theme.of(context).primaryColor),
              ),
            ],
          ),
          onTap: () async {
            await _accessDatabase.markNotificationAsRead(currentUser.id!, notification.id!);
            setState(() {
              notificationsList[index].isRead = true;
            });
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
            borderWidth: 1.0,
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
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                time.toUpperCase(),
                style: Styles.purpleTextStyle.copyWith(fontSize: 10, color: Theme.of(context).primaryColor),
              ),
            ],
          ),
          onTap: () async {
            await _accessDatabase.markNotificationAsRead(currentUser.id!, notification.id!);
            setState(() {
              notificationsList[index].isRead = true;
            });
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
            borderWidth: 1.0,
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
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                time.toUpperCase(),
                style: Styles.purpleTextStyle.copyWith(fontSize: 10, color: Theme.of(context).primaryColor),
              ),
            ],
          ),
          onTap: () async {
            await _accessDatabase.markNotificationAsRead(currentUser.id!, notification.id!);
            setState(() {
              notificationsList[index].isRead = true;
            });
            returnActionOnTap(index,notification);
          },
        );
      }
      case "UserJoinEvent_User": {
        if (event.id != null) {
          var startDate = DateTime(
            int.parse(event.year!),
            int.parse(event.month!),
            int.parse(event.day!),
            int.parse(event.hour!),
            int.parse(event.minute!),
          );
          String eventTimeDay = DateFormat('EE dd-MM-yy', Localizations.localeOf(context).languageCode).format(startDate);
          String eventTimeTime = "${event.hour.toString()}:${event.minute=="0" ? "00" : event.minute.toString()}h";
          return ListTile(
            leading: CircularImage(
              size: MediaQuery.of(context).size.width*0.15,
              image: brand.logoUrl!,
              color: Theme.of(context).primaryColor,
              borderWidth: 1.0,
            ),
            title: Text(
              AppLocalizations.of(context)!.userJoinEventUser(event.title!),
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
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                Text(
                  time.toUpperCase(),
                  style: Styles.purpleTextStyle.copyWith(fontSize: 10, color: Theme.of(context).primaryColor),
                ),
              ],
            ),
            onTap: () async {
              await _accessDatabase.markNotificationAsRead(currentUser.id!, notification.id!);
              setState(() {
                notificationsList[index].isRead = true;
              });
              returnActionOnTap(index,notification);
            },
          );
        } else {
          return ListTile(
            leading: SizedBox(
              width: MediaQuery.of(context).size.width*0.15,
              child: Center(
                child: Image(
                    width: MediaQuery.of(context).size.width*0.10,
                    image: AssetImage(Constants.emptyCalendar)
                ),
              ),
            ),
            title: Text(
                AppLocalizations.of(context)!.userJoinEventUser(event.title!),
              style: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                Text(
                  time.toUpperCase(),
                  style: Styles.purpleTextStyle.copyWith(fontSize: 10, color: Theme.of(context).primaryColor),
                ),
              ],
            ),
            onTap: () {

            },
          );
        }
      }
      case "UserJoinEvent_Trainer": {
        if (event.id != null) {
          return ListTile(
            leading: CircularImage(
              size: MediaQuery.of(context).size.width*0.15,
              image: user.imageUrl,
              color: Theme.of(context).primaryColor,
              borderWidth: 1.0,
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
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                Text(
                  time.toUpperCase(),
                  style: Styles.purpleTextStyle.copyWith(fontSize: 10, color: Theme.of(context).primaryColor),
                ),
              ],
            ),
            onTap: () async {
              await _accessDatabase.markNotificationAsRead(currentUser.id!, notification.id!);
              setState(() {
                notificationsList[index].isRead = true;
              });
              returnActionOnTap(index,notification);
            },
          );
        } else {
          return ListTile(
            leading: SizedBox(
              width: MediaQuery.of(context).size.width*0.15,
              child: Center(
                child: Image(
                    width: MediaQuery.of(context).size.width*0.10,
                    image: AssetImage(Constants.emptyCalendar)
                ),
              ),
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
                  time.toUpperCase(),
                  style: Styles.purpleTextStyle.copyWith(fontSize: 10, color: Theme.of(context).primaryColor),
                ),
              ],
            ),
            onTap: ()  {

            },
          );
        }
      }
      case "UserLeaveEvent_User": {
        if (event.id != null) {
          return ListTile(
            leading: CircularImage(
              size: MediaQuery.of(context).size.width*0.15,
              image: brand.logoUrl!,
              color: Theme.of(context).primaryColor,
              borderWidth: 1.0,
            ),
            title: Text(
              AppLocalizations.of(context)!.userLeavesEventUser(event.title!),
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
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                Text(
                  time.toUpperCase(),
                  style: Styles.purpleTextStyle.copyWith(fontSize: 10, color: Theme.of(context).primaryColor),
                ),
              ],
            ),
            onTap: () async {
              await _accessDatabase.markNotificationAsRead(currentUser.id!, notification.id!);
              setState(() {
                notificationsList[index].isRead = true;
              });
              returnActionOnTap(index,notification);
            },
          );
        } else {
          return ListTile(
            leading: SizedBox(
              width: MediaQuery.of(context).size.width*0.15,
              child: Center(
                child: Image(
                    width: MediaQuery.of(context).size.width*0.10,
                    image: AssetImage(Constants.emptyCalendar)
                ),
              ),
            ),
            title: Text(
              AppLocalizations.of(context)!.userLeavesEventUser(event.title!),
              style: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Theme.of(context).primaryColor, fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                Text(
                  time.toUpperCase(),
                  style: Styles.purpleTextStyle.copyWith(fontSize: 10, color: Theme.of(context).primaryColor),
                ),
              ],
            ),
            onTap: ()  {

            },
          );
        }
      }
      case "UserLeaveEvent_Trainer": {
        if (event.id != null) {
          return ListTile(
            leading: CircularImage(
              size: MediaQuery.of(context).size.width*0.15,
              image: user.imageUrl,
              color: Theme.of(context).primaryColor,
              borderWidth: 1.0,
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
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                Text(
                  time.toUpperCase(),
                  style: Styles.purpleTextStyle.copyWith(fontSize: 10, color: Theme.of(context).primaryColor),
                ),
              ],
            ),
            onTap: () async {
              await _accessDatabase.markNotificationAsRead(currentUser.id!, notification.id!);
              setState(() {
                notificationsList[index].isRead = true;
              });
              returnActionOnTap(index,notification);
            },
          );
        } else {
          return ListTile(
            leading: SizedBox(
              width: MediaQuery.of(context).size.width*0.15,
              child: Center(
                child: Image(
                    width: MediaQuery.of(context).size.width*0.10,
                    image: AssetImage(Constants.emptyCalendar)
                ),
              ),
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
                  time.toUpperCase(),
                  style: Styles.purpleTextStyle.copyWith(fontSize: 10, color: Theme.of(context).primaryColor),
                ),
              ],
            ),
            onTap: ()  {

            },
          );
        }
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
        if (brand.id != null) {
          if (currentUser.isTrainer!) {
            Navigator.push(
                context,
              CupertinoPageRoute<Null>(
                builder: (context) => CalendarWidgetTrainer(
                      brandID: brand.id!,
                      canEdit: true,
                    )
                )
            );
          } else {
            Navigator.push(
                context,
              CupertinoPageRoute<Null>(
                builder: (context) => CalendarWidgetClient(
                      brandID: brand.id!,
                      onlyView: false,
                    )
                )
            );
          }
        }
        break;
      }
      case "UserJoinsBrand_Trainer": {
        if (user.id != null) {
          Navigator.push(
              context,
              CupertinoPageRoute<Null>(
                                  builder: (context) => ProfileViewUser(
                    userID: user.id!,
                    viewOnly: false,
                  )
              )
          );
        }
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
        if (brand.id != null) {
          Navigator.push(
              context,
              CupertinoPageRoute<Null>(
                                  builder: (context) => MembershipRequests(
                    brandId: brand.id!,
                  )
              )
          );
        }
        break;
      }
      case "UserCancelRequestToBrand_User": {
        break;
      }
      case "UserCancelRequestToBrand_Trainer": {
        break;
      }
      case "UserJoinEvent_User": {
        if (event.id != null) {
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
              CupertinoPageRoute<Null>(
                  builder: (context) => ViewEventClient(
                  eventId: event.id!,
                  canJoin: canAction,
                  locale: Localizations.localeOf(context),
                ),
              )
          );
        }
        break;
      }
      case "UserJoinEvent_Trainer": {
        if (event.id != null) {
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
              CupertinoPageRoute<Null>(
                                  builder: (context) => ViewEventTrainer(
                  eventId: event.id!,
                  canEdit: canAction,
                  locale: Localizations.localeOf(context),
                ),
              )
          );
        }
        break;
      }
      case "UserLeaveEvent_User": {
        if (brand.id != null) {
          Navigator.push(
              context,
              CupertinoPageRoute<Null>(
                                  builder: (context) => CalendarWidgetClient(
                    brandID: brand.id!,
                    onlyView: true,
                  )
              )
          );
        }
        break;
      }
      case "UserLeaveEvent_Trainer": {
        if (event.id != null) {
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
              CupertinoPageRoute<Null>(
                                  builder: (context) => ViewEventTrainer(
                  eventId: event.id!,
                  canEdit: canAction,
                  locale: Localizations.localeOf(context),
                ),
              )
          );
        }
        break;
      }
      default: {
        break;
      }
    }
  }

}
