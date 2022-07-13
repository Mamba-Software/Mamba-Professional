// Flutter Libs
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Calendars/BrandCalendarWidget.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventPage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/ProfileView/ProfileUserView.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Notifications/NotificationEvent.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Mamba/Brand/BrandScreens/BrandSettings/MembershipRequests.dart';
import 'package:shimmer/shimmer.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {

  // Acceso a Base de Datos
  var _userDataService = new UserDataService();
  var _brandDataService = new BrandDataService();
  var _eventDataService = new EventDataService();
  // Acceso a Base de Datos
  bool isLoading = true;
  // Lazy Loading
  var scrollController = ScrollController();
  int lastIndex = 9;
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
    getFirstNotificationsLimit10();
    scrollController.addListener(() async {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels == 0)
          print('ListView scroll at top');
        else {
          print('last index: '+lastIndex.toString());
          print('last notif: '+notificationsList[lastIndex].id!.toString());
          await getMoreNotificationsLimit10(notificationsList[lastIndex]);
        }
      }
    });
  }

  Future<void> getFirstNotificationsLimit10() async {
    List<Usuario> users = [];
    List<Brand> brands = [];
    List<Event> events = [];
    notificationsList = await _userDataService.getUserFirstNotificationsLimit10(currentUser.id!);
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
            user = await _userDataService.getUserCoverDetails(notification.parameters[0]);
            if (user.id == null) {
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
            brand = await _brandDataService.getBrandCoverDetails(notification.parameters[1]);
            if (brand.id == null) {
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
            event = await _eventDataService.getSingleEvent(notification.parameters[2]);
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
        lastIndex = 9;
        isLoading = false;
      });
    }
  }

  Future<void> getMoreNotificationsLimit10(NotificationEvent notif) async {
    List<Usuario> users = [];
    List<Brand> brands = [];
    List<Event> events = [];
    var extraNotifications = await _userDataService.getUserMoreNotificationsLimit10(currentUser.id!, notif.id!);
    // Order Notification List Descending Time
    extraNotifications.sort((a,b) {
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
    extraNotifications = List.from(extraNotifications.reversed);
    // Get User, Brand and Events when needed
    for(int i = 0; i < extraNotifications.length; i++) {
      NotificationEvent notification = extraNotifications[i];
      if (notification.parameters.length > 0) {
        if (notification.parameters[0] != "null") {
          Usuario user = users.firstWhere((element) => element.id == notification.parameters[0], orElse: () => Usuario());
          if (user.id == null) {
            user = await _userDataService.getUserCoverDetails(notification.parameters[0]);
            if (user.id == null) {
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
            brand = await _brandDataService.getBrandCoverDetails(notification.parameters[1]);
            if (brand.id == null) {
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
            event = await _eventDataService.getSingleEvent(notification.parameters[2]);
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
    usersList.addAll(users);
    brandsList.addAll(brands);
    eventList.addAll(events);
    if (mounted) {
      setState(() {
        notificationsList.addAll(extraNotifications);
        lastIndex += 10;
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
            Text(AppLocalizations.of(context)!.notificationsBottomNav, style: Theme.of(context).textTheme.headline3, textAlign: TextAlign.center,),
          ],
        ),
        centerTitle: false,
        actions: [
          TextButton.icon(
            icon: Icon(Icons.mark_email_read_outlined, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.05,),
            label: Text(
              AppLocalizations.of(context)!.markAsRead,
              style: Theme.of(context).textTheme.bodyText2,
            ),
            onPressed: () async {
              for (NotificationEvent notif in notificationsList) {
                setState(() {
                  notif.isRead = true;
                });
              }
              await _userDataService.markALLNotificationAsRead(currentUser.id!);
            },
          ),
          SizedBox(width: MediaQuery.of(context).size.width*0.03,),
        ],
      ),
      body: isLoading ? Container(
        child: ListView.builder(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: 12,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.01),
                child: ListTile(
                  dense: true,
                  leading: Shimmer.fromColors(
                    baseColor: AppColors.grey,
                    highlightColor: AppColors.grey.withOpacity(0.5),
                    child: Container(
                      height: MediaQuery.of(context).size.height*0.08,
                      width: MediaQuery.of(context).size.height*0.08,
                      decoration: BoxDecoration(
                        color: AppColors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  title: Shimmer.fromColors(
                    baseColor: AppColors.grey,
                    highlightColor: AppColors.grey.withOpacity(0.5),
                    child: Container(
                      height: MediaQuery.of(context).size.height*0.025,
                      width: MediaQuery.of(context).size.width*0.02,
                      decoration: BoxDecoration(
                        borderRadius: new BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height*0.005),
                      Shimmer.fromColors(
                        baseColor: AppColors.grey,
                        highlightColor: AppColors.grey.withOpacity(0.5),
                        child: Container(
                          height: MediaQuery.of(context).size.height*0.02,
                          width: MediaQuery.of(context).size.width*0.3,
                          decoration: BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: new BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.005),
                      Shimmer.fromColors(
                        baseColor: AppColors.grey,
                        highlightColor: AppColors.grey.withOpacity(0.5),
                        child: Container(
                          height: MediaQuery.of(context).size.height*0.02,
                          width: MediaQuery.of(context).size.width*0.2,
                          decoration: BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: new BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: Shimmer.fromColors(
                    baseColor: AppColors.grey,
                    highlightColor: AppColors.grey.withOpacity(0.5),
                    child: Container(
                      height: MediaQuery.of(context).size.height*0.04,
                      width: MediaQuery.of(context).size.height*0.04,
                      decoration: BoxDecoration(
                        color: AppColors.grey,
                        borderRadius: new BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  onTap: null,
                ),
              );
            }
        ),
      ) : RefreshIndicator(
          displacement: MediaQuery.of(context).size.height*0.05,
          color: Theme.of(context).accentColor,
          onRefresh: () {
            return Future.delayed(
              Duration(seconds: 1), () async {
                this.getFirstNotificationsLimit10();
              },
            );
          },
          child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              controller: scrollController,
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
        ),
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
            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                AppLocalizations.of(context)!.onlyImportantNotifications,
                style: Theme.of(context).textTheme.caption,                
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                time.toUpperCase(),
                style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
              ),
            ],
          ),
          onTap: () async {
            await _userDataService.markNotificationAsRead(currentUser.id!, notification.id!);
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
            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                AppLocalizations.of(context)!.userCreatesBrandUserSubtitle,
                style: Theme.of(context).textTheme.caption,
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                time.toUpperCase(),
                style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
              ),
            ],
          ),
          onTap: () async {
            await _userDataService.markNotificationAsRead(currentUser.id!, notification.id!);

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
            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                AppLocalizations.of(context)!.userJoinsBrandSubtitleUser,
                style: Theme.of(context).textTheme.caption,
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                time.toUpperCase(),
                style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
              ),
            ],
          ),
          onTap: () async {
            await _userDataService.markNotificationAsRead(currentUser.id!, notification.id!);
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
            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                AppLocalizations.of(context)!.userJoinsBrandBrandSubtitle(notification.parameters[3]),
                style: Theme.of(context).textTheme.caption,
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                time.toUpperCase(),
                style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
              ),
            ],
          ),
          onTap: () async {
            await _userDataService.markNotificationAsRead(currentUser.id!, notification.id!);
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
            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                AppLocalizations.of(context)!.userLeavesBrandUserSubtitle,
                style: Theme.of(context).textTheme.caption,
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                time.toUpperCase(),
                style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
              ),
            ],
          ),
          onTap: () async {
            await _userDataService.markNotificationAsRead(currentUser.id!, notification.id!);
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
            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                AppLocalizations.of(context)!.userLeavesBrandBrandSubtitle(notification.parameters[3]),
                style: Theme.of(context).textTheme.caption,
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                time.toUpperCase(),
                style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
              ),
            ],
          ),
          onTap: () async {
            await _userDataService.markNotificationAsRead(currentUser.id!, notification.id!);
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
            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                AppLocalizations.of(context)!.userSendRequestToBrandUserSubtitle,
                style: Theme.of(context).textTheme.caption,
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                time.toUpperCase(),
                style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
              ),
            ],
          ),
          onTap: () async {
            await _userDataService.markNotificationAsRead(currentUser.id!, notification.id!);
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
            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                AppLocalizations.of(context)!.userSendRequestToBrandBrandSubtitle(notification.parameters[3]),
                style: Theme.of(context).textTheme.caption,
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                time.toUpperCase(),
                style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
              ),
            ],
          ),
          onTap: () async {
            await _userDataService.markNotificationAsRead(currentUser.id!, notification.id!);
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
            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                AppLocalizations.of(context)!.userCancelRequestToBrandUserSubtitle,
                style: Theme.of(context).textTheme.caption,
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                time.toUpperCase(),
                style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
              ),
            ],
          ),
          onTap: () async {
            await _userDataService.markNotificationAsRead(currentUser.id!, notification.id!);
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
            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                AppLocalizations.of(context)!.userCancelRequestToBrandBrandSubtitle,
                style: Theme.of(context).textTheme.caption,
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.01),
              Text(
                time.toUpperCase(),
                style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
              ),
            ],
          ),
          onTap: () async {
            await _userDataService.markNotificationAsRead(currentUser.id!, notification.id!);
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
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                Text(
                  AppLocalizations.of(context)!.userJoinEventUserSubtitle(eventTimeDay, eventTimeTime),
                  style: Theme.of(context).textTheme.caption,
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                Text(
                  time.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
                ),
              ],
            ),
            onTap: () async {
              await _userDataService.markNotificationAsRead(currentUser.id!, notification.id!);
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
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                Text(
                  time.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
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
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                Text(
                  AppLocalizations.of(context)!.userJoinEventBrandSubtitle(event.numClients.toString(), event.maxMembers.toString() ),
                  style: Theme.of(context).textTheme.caption,
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                Text(
                  time.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
                ),
              ],
            ),
            onTap: () async {
              await _userDataService.markNotificationAsRead(currentUser.id!, notification.id!);
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
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                Text(
                  time.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
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
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                Text(
                  AppLocalizations.of(context)!.userLeavesEventUserSubtitle,
                  style: Theme.of(context).textTheme.caption,
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                Text(
                  time.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
                ),
              ],
            ),
            onTap: () async {
              await _userDataService.markNotificationAsRead(currentUser.id!, notification.id!);
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
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                Text(
                  time.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
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
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                Text(
                  AppLocalizations.of(context)!.userLeavesEventBrandSubtitle(event.joinedMembers.length.toString(), event.maxMembers.toString() ),
                  style: Theme.of(context).textTheme.caption,
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                Text(
                  time.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
                ),
              ],
            ),
            onTap: () async {
              await _userDataService.markNotificationAsRead(currentUser.id!, notification.id!);
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
              style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: notification.isRead! ? FontWeight.normal : FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                Text(
                  time.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
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
          Navigator.push(
              context,
            CupertinoPageRoute<Null>(
              builder: (context) => BrandCalendarWidget(
                  brandId: brand.id!,
                )
              )
          );
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
                  builder: (context) => EventPage(
                  eventId: event.id!,
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
                  builder: (context) => EventPage(
                  eventId: event.id!,
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
                  builder: (context) => BrandCalendarWidget(
                    brandId: brand.id!,
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
                  builder: (context) => EventPage(
                  eventId: event.id!,
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
