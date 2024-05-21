// Flutter Libs
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:intl/intl.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/Event/EventDataService.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/data/Models/Bono.dart';
import 'package:mamba/events/crud_events/read_event/views/mobile/ReadEventPage.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/commons/styles/AppColors.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/ProfileView/ProfileUserView.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/events/crud_events/models/Event.dart';
import 'package:mamba/data/Models/Notifications/NotificationEvent.dart';
import 'package:mamba/data/Models/Usuario.dart';
import 'package:mamba/commons/extensions/context.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/01-Qui/015-AddMembers/MembershipRequestsPro.dart';
import 'package:mamba/screens/MambaPro/HasBrandScreens/02-Que/007%20-%20Purchases/views/BrandPurchaseHistory.dart';
import 'package:shimmer/shimmer.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  // Acceso a Base de Datos
  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();
  final _eventDataService = EventDataService();
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
  List<Bono> bonoList = [];
  // Has unread notifications
  bool hasUnread = false;
  // String Deleted Photo
  String deletedObject =
      "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/not-found-image.jpg?alt=media&token=70687295-6a17-4735-9c0a-e5749c777319";

  @override
  initState() {
    super.initState();
    mixpanel!.track('user_notifications_view');
    isLoading = true;
    getFirstNotificationsLimit10();
    scrollController.addListener(() async {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels != 0) {
          if (notificationsList.length >= 10) {
            await getMoreNotificationsLimit10(notificationsList[lastIndex]);
            mixpanel!.track('user_notifications_get_more');
          }
        }
      }
    });
  }

  Future<void> getFirstNotificationsLimit10() async {
    List<Usuario> users = [];
    List<Brand> brands = [];
    List<Event> events = [];
    List<Bono> bonos = [];
    notificationsList = await _userDataService
        .getUserFirstNotificationsLimit10(currentUser.id!);
    // Order Notification List Descending Time
    notificationsList.sort((a, b) {
      var aDate = DateTime(
        int.parse(a.year!),
        int.parse(a.month!),
        int.parse(a.day!),
        int.parse(a.hour!),
        int.parse(a.minutes!),
        int.parse(a.seconds!),
      );
      var bDate = DateTime(
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
    for (int i = 0; i < notificationsList.length; i++) {
      NotificationEvent notification = notificationsList[i];
      if (notification.parameters.length > 0) {
        if (notification.parameters[0] != "null") {
          Usuario user = users.firstWhere(
              (element) => element.id == notification.parameters[0],
              orElse: () => Usuario());
          if (user.id == null) {
            user = await _userDataService
                .getUserCoverDetails(notification.parameters[0]);
            if (user.id == null) {
              user = Usuario(
                  name: context.l10n.deletedUser.toLowerCase(),
                  imageUrl: deletedObject);
            }
          }
          users.add(user);
        } else {
          users.add(Usuario());
        }
        if (notification.parameters[1] != "null") {
          Brand brand = brands.firstWhere(
              (element) => element.id == notification.parameters[1],
              orElse: () => Brand());
          if (brand.id == null) {
            brand = await _brandDataService
                .getBrandCoverDetails(notification.parameters[1]);
            if (brand.id == null) {
              brand = Brand(
                  name: context.l10n.deletedBrand.toLowerCase(),
                  logoUrl: deletedObject);
            }
          }
          brands.add(brand);
        } else {
          brands.add(Brand());
        }
        if (notification.parameters[2] != "null") {
          Event event = events.firstWhere(
              (element) => element.id == notification.parameters[2],
              orElse: () => Event());
          if (event.id == null) {
            event = await _eventDataService
                .getSingleEvent(notification.parameters[2]);
          }
          if (event.id == null) {
            events.add(Event(title: context.l10n.deletedEvent.toLowerCase()));
          } else {
            events.add(event);
          }
        } else {
          events.add(Event());
        }
        if (notification.parameters.length > 4 &&
            notification.parameters[4] != "null") {
          Bono bono = bonos.firstWhere(
              (element) => element.id == notification.parameters[4],
              orElse: () => Bono());
          if (bono.id == null) {
            print(notification.parameters[1]);
            print(notification.parameters[4]);
            //bono = await _brandDataService.getBonoInfo(currentBrand.id!, notification.parameters[4]);
            //TODO SCRIPT TO SOLVE THIS
            bono = await _brandDataService.getBonoInfo(
                notification.parameters[1], notification.parameters[4]);
            //bono = await _brandDataService.getBonoInfo('5d089751-9f05-41e2-9f5d-b4ff3bed921c', notification.parameters[4]);
          }
          if (bono.id == null) {
            bonos.add(Bono(title: context.l10n.deletedEvent.toLowerCase()));
          } else {
            bonos.add(bono);
          }
        } else {
          bonos.add(Bono());
        }
      } else {
        users.add(Usuario());
        brands.add(Brand());
        events.add(Event());
        bonos.add(Bono());
      }
    }
    usersList = users;
    brandsList = brands;
    eventList = events;
    bonoList = bonos;
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
    List<Bono> bonos = [];
    var extraNotifications = await _userDataService
        .getUserMoreNotificationsLimit10(currentUser.id!, notif.id!);
    // Order Notification List Descending Time
    extraNotifications.sort((a, b) {
      var aDate = DateTime(
        int.parse(a.year!),
        int.parse(a.month!),
        int.parse(a.day!),
        int.parse(a.hour!),
        int.parse(a.minutes!),
        int.parse(a.seconds!),
      );
      var bDate = DateTime(
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
    for (int i = 0; i < extraNotifications.length; i++) {
      NotificationEvent notification = extraNotifications[i];
      if (notification.parameters.length > 0) {
        if (notification.parameters[0] != "null") {
          Usuario user = users.firstWhere(
              (element) => element.id == notification.parameters[0],
              orElse: () => Usuario());
          if (user.id == null) {
            user = await _userDataService
                .getUserCoverDetails(notification.parameters[0]);
            if (user.id == null) {
              user = Usuario(
                  name: context.l10n.deletedUser.toLowerCase(),
                  imageUrl: deletedObject);
            }
          }
          users.add(user);
        } else {
          users.add(Usuario());
        }
        if (notification.parameters[1] != "null") {
          Brand brand = brands.firstWhere(
              (element) => element.id == notification.parameters[1],
              orElse: () => Brand());
          if (brand.id == null) {
            brand = await _brandDataService
                .getBrandCoverDetails(notification.parameters[1]);
            if (brand.id == null) {
              brand = Brand(
                  name: context.l10n.deletedBrand.toLowerCase(),
                  logoUrl: deletedObject);
            }
          }
          brands.add(brand);
        } else {
          brands.add(Brand());
        }
        if (notification.parameters[2] != "null") {
          Event event = events.firstWhere(
              (element) => element.id == notification.parameters[2],
              orElse: () => Event());
          if (event.id == null) {
            event = await _eventDataService
                .getSingleEvent(notification.parameters[2]);
          }
          if (event.id == null) {
            events.add(Event(title: context.l10n.deletedEvent.toLowerCase()));
          } else {
            events.add(event);
          }
        } else {
          events.add(Event());
        }
        if (notification.parameters.length > 4 &&
            notification.parameters[4] != "null") {
          Bono bono = bonos.firstWhere(
              (element) => element.id == notification.parameters[4],
              orElse: () => Bono());
          if (bono.id == null) {
            bono = await _brandDataService.getBonoInfo(
                currentBrand.id!, notification.parameters[4]);
          }
          if (bono.id == null) {
            bonos.add(Bono(title: context.l10n.deletedEvent.toLowerCase()));
          } else {
            bonos.add(bono);
          }
        } else {
          bonos.add(Bono());
        }
      } else {
        users.add(Usuario());
        brands.add(Brand());
        events.add(Event());
        bonos.add(Bono());
      }
    }
    usersList.addAll(users);
    brandsList.addAll(brands);
    eventList.addAll(events);
    bonoList.addAll(bonos);
    if (mounted) {
      setState(() {
        notificationsList.addAll(extraNotifications);
        lastIndex += 10;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.01,
            ),
            Text(
              context.l10n.notificationsBottomNav,
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: MediaQuery.of(context).size.width * 0.06,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: false,
        actions: [
          TextButton.icon(
            icon: Icon(
              Icons.mark_email_read_outlined,
              color: Theme.of(context).primaryColor,
              size: MediaQuery.of(context).size.width * 0.05,
            ),
            label: Text(
              context.l10n.markAsRead,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onPressed: () async {
              mixpanel!.track('user_notifications_all_read');
              for (NotificationEvent notif in notificationsList) {
                setState(() {
                  notif.isRead = true;
                });
              }
              await _userDataService.markALLNotificationAsRead(currentUser.id!);
            },
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.03,
          ),
        ],
      ),
      body: isLoading
          ? ListView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: 12,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.01),
                  child: ListTile(
                    dense: true,
                    leading: Shimmer.fromColors(
                      baseColor: AppColors.grey,
                      highlightColor: AppColors.grey.withOpacity(0.5),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.08,
                        width: MediaQuery.of(context).size.height * 0.08,
                        decoration: const BoxDecoration(
                          color: AppColors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    title: Shimmer.fromColors(
                      baseColor: AppColors.grey,
                      highlightColor: AppColors.grey.withOpacity(0.5),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.025,
                        width: MediaQuery.of(context).size.width * 0.02,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.005),
                        Shimmer.fromColors(
                          baseColor: AppColors.grey,
                          highlightColor: AppColors.grey.withOpacity(0.5),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.02,
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: const BoxDecoration(
                              color: AppColors.grey,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.005),
                        Shimmer.fromColors(
                          baseColor: AppColors.grey,
                          highlightColor: AppColors.grey.withOpacity(0.5),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.02,
                            width: MediaQuery.of(context).size.width * 0.2,
                            decoration: const BoxDecoration(
                              color: AppColors.grey,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
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
                        height: MediaQuery.of(context).size.height * 0.04,
                        width: MediaQuery.of(context).size.height * 0.04,
                        decoration: const BoxDecoration(
                          color: AppColors.grey,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                    onTap: null,
                  ),
                );
              })
          : RefreshIndicator(
              displacement: MediaQuery.of(context).size.height * 0.05,
              color: Theme.of(context).colorScheme.secondary,
              onRefresh: () {
                return Future.delayed(
                  const Duration(seconds: 1),
                  () async {
                    getFirstNotificationsLimit10();
                  },
                );
              },
              child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  controller: scrollController,
                  scrollDirection: Axis.vertical,
                  itemCount: notificationsList.length,
                  itemBuilder: (context, index) {
                    NotificationEvent notification = notificationsList[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.01),
                      child: returnNotification(index, notification),
                    );
                  }),
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
    String time = DateFormat("E dd MMMM yyyy, HH:mm",
            Localizations.localeOf(context).languageCode)
        .format(dateSent);
    Usuario user = usersList[index];
    Brand brand = brandsList[index];
    Event event = eventList[index];
    Bono bono = bonoList[index];

    switch (notification.type!) {
      case "Wellcome_User":
        {
          return ListTile(
            leading: SizedBox(
              width: MediaQuery.of(context).size.width * 0.15,
              child: Center(
                child: Image(
                    width: MediaQuery.of(context).size.width * 0.10,
                    image: AssetImage(Assets.logoSimpleYellow)),
              ),
            ),
            title: Text(
              context.l10n.wellcomeToMAMBA,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: notification.isRead!
                      ? FontWeight.normal
                      : FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  context.l10n.onlyImportantNotifications,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  time.toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 10),
                ),
              ],
            ),
            onTap: () async {
              await _userDataService.markNotificationAsRead(
                  currentUser.id!, notification.id!);
              setState(() {
                notificationsList[index].isRead = true;
              });
              returnActionOnTap(index, notification);
            },
          );
        }
      case "UserCreatesBrand_User":
        {
          // Name and Image
          return ListTile(
            leading: CircularImage(
              size: MediaQuery.of(context).size.width * 0.15,
              image: brand.logoUrl!,
              color: AppColors.grey,
              borderWidth: 0.5,
            ),
            title: Text(
              context.l10n.userCreatesBrandUser(brand.name!),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: notification.isRead!
                      ? FontWeight.normal
                      : FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  context.l10n.userCreatesBrandUserSubtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  time.toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 10),
                ),
              ],
            ),
            onTap: () async {
              await _userDataService.markNotificationAsRead(
                  currentUser.id!, notification.id!);

              setState(() {
                notificationsList[index].isRead = true;
              });
            },
          );
        }
      case "UserJoinsBrand_Trainer":
        {
          return ListTile(
            leading: CircularImage(
              size: MediaQuery.of(context).size.width * 0.15,
              image: user.imageUrl!,
              color: AppColors.grey,
              borderWidth: 0.5,
            ),
            title: Text(
              context.l10n.userJoinsBrandBrand(user.name!, brand.name!),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: notification.isRead!
                      ? FontWeight.normal
                      : FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  context.l10n
                      .userJoinsBrandBrandSubtitle(notification.parameters[3]),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  time.toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 10),
                ),
              ],
            ),
            onTap: () async {
              await _userDataService.markNotificationAsRead(
                  currentUser.id!, notification.id!);
              setState(() {
                notificationsList[index].isRead = true;
              });
              returnActionOnTap(index, notification);
            },
          );
        }
      case "UserLeavesBrand_Trainer":
        {
          return ListTile(
            leading: CircularImage(
              size: MediaQuery.of(context).size.width * 0.15,
              image: user.imageUrl!,
              color: AppColors.grey,
              borderWidth: 0.5,
            ),
            title: Text(
              context.l10n.userLeavesBrandBrand(user.name!, brand.name!),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: notification.isRead!
                      ? FontWeight.normal
                      : FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  context.l10n
                      .userLeavesBrandBrandSubtitle(notification.parameters[3]),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  time.toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 10),
                ),
              ],
            ),
            onTap: () async {
              await _userDataService.markNotificationAsRead(
                  currentUser.id!, notification.id!);
              setState(() {
                notificationsList[index].isRead = true;
              });
              returnActionOnTap(index, notification);
            },
          );
        }
      case "UserSendRequestToBrand_Trainer":
        {
          return ListTile(
            leading: CircularImage(
              size: MediaQuery.of(context).size.width * 0.15,
              image: user.imageUrl!,
              color: AppColors.grey,
              borderWidth: 0.5,
            ),
            title: Text(
              context.l10n.userSendRequestToBrandBrand(user.name!),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: notification.isRead!
                      ? FontWeight.normal
                      : FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  context.l10n.userSendRequestToBrandBrandSubtitle(
                      notification.parameters[3]),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  time.toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 10),
                ),
              ],
            ),
            onTap: () async {
              await _userDataService.markNotificationAsRead(
                  currentUser.id!, notification.id!);
              setState(() {
                notificationsList[index].isRead = true;
              });
              returnActionOnTap(index, notification);
            },
          );
        }
      case "UserCancelRequestToBrand_Trainer":
        {
          return ListTile(
            leading: CircularImage(
              size: MediaQuery.of(context).size.width * 0.15,
              image: user.imageUrl!,
              color: AppColors.grey,
              borderWidth: 0.5,
            ),
            title: Text(
              context.l10n.userCancelRequestToBrandBrand(user.name!),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: notification.isRead!
                      ? FontWeight.normal
                      : FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  context.l10n.userCancelRequestToBrandBrandSubtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  time.toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 10),
                ),
              ],
            ),
            onTap: () async {
              await _userDataService.markNotificationAsRead(
                  currentUser.id!, notification.id!);
              setState(() {
                notificationsList[index].isRead = true;
              });
              returnActionOnTap(index, notification);
            },
          );
        }
      case "UserJoinEvent_Trainer":
        {
          if (event.id != null) {
            return ListTile(
              leading: CircularImage(
                size: MediaQuery.of(context).size.width * 0.15,
                image: event.imageUrl!,
                color: AppColors.grey,
                borderWidth: 0.5,
              ),
              title: Text(
                context.l10n.userJoinEventBrand(user.name!, event.title!),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: notification.isRead!
                        ? FontWeight.normal
                        : FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    context.l10n.userJoinEventBrandSubtitle(
                        event.numClients.toString(),
                        event.maxMembers.toString()),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    time.toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 10),
                  ),
                ],
              ),
              onTap: () async {
                await _userDataService.markNotificationAsRead(
                    currentUser.id!, notification.id!);
                setState(() {
                  notificationsList[index].isRead = true;
                });
                returnActionOnTap(index, notification);
              },
            );
          } else {
            return ListTile(
              leading: SizedBox(
                width: MediaQuery.of(context).size.width * 0.15,
                child: Center(
                  child: Image(
                      width: MediaQuery.of(context).size.width * 0.10,
                      image: AssetImage(Assets.emptyCalendar)),
                ),
              ),
              title: Text(
                context.l10n.userJoinEventBrand(user.name!, event.title!),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: notification.isRead!
                        ? FontWeight.normal
                        : FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    time.toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 10),
                  ),
                ],
              ),
              onTap: () {},
            );
          }
        }
      case "UserLeaveEvent_Trainer":
        {
          if (event.id != null) {
            return ListTile(
              leading: CircularImage(
                size: MediaQuery.of(context).size.width * 0.15,
                image: event.imageUrl!,
                color: AppColors.grey,
                borderWidth: 0.5,
              ),
              title: Text(
                context.l10n.userLeavesEventBrand(user.name!, event.title!),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: notification.isRead!
                        ? FontWeight.normal
                        : FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    context.l10n.userLeavesEventBrandSubtitle(
                        event.numClients.toString(),
                        event.maxMembers.toString()),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    time.toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 10),
                  ),
                ],
              ),
              onTap: () async {
                await _userDataService.markNotificationAsRead(
                    currentUser.id!, notification.id!);
                setState(() {
                  notificationsList[index].isRead = true;
                });
                returnActionOnTap(index, notification);
              },
            );
          } else {
            return ListTile(
              leading: SizedBox(
                width: MediaQuery.of(context).size.width * 0.15,
                child: Center(
                  child: Image(
                      width: MediaQuery.of(context).size.width * 0.10,
                      image: AssetImage(Assets.emptyCalendar)),
                ),
              ),
              title: Text(
                context.l10n.userLeavesEventBrand(user.name!, event.title!),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: notification.isRead!
                        ? FontWeight.normal
                        : FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    time.toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 10),
                  ),
                ],
              ),
              onTap: () {},
            );
          }
        }
      case "UserSendBonoRequest_Trainer":
        {
          return ListTile(
            leading: CircularImage(
              size: MediaQuery.of(context).size.width * 0.15,
              image: user.imageUrl!,
              color: AppColors.grey,
              borderWidth: 0.5,
            ),
            title: Text(
              context.l10n.userSendsBonoRequestBrand(user.name!),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: notification.isRead!
                      ? FontWeight.normal
                      : FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  context.l10n.userSendsBonoRequestSubtitleBrand(
                      bono.title!.toUpperCase()),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  time.toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 10),
                ),
              ],
            ),
            onTap: () async {
              await _userDataService.markNotificationAsRead(
                  currentUser.id!, notification.id!);
              setState(() {
                notificationsList[index].isRead = true;
              });
              returnActionOnTap(index, notification);
            },
          );
        }
      case "UserCancelBonoRequest_Trainer":
        {
          return ListTile(
            leading: CircularImage(
              size: MediaQuery.of(context).size.width * 0.15,
              image: user.imageUrl!,
              color: AppColors.grey,
              borderWidth: 0.5,
            ),
            title: Text(
              context.l10n.userCancelsBonoRequestBrand(user.name!),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: notification.isRead!
                      ? FontWeight.normal
                      : FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  context.l10n.userCancelsBonoRequestSubtitleBrand(
                      bono.title!.toUpperCase()),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  time.toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 10),
                ),
              ],
            ),
            onTap: () async {
              await _userDataService.markNotificationAsRead(
                  currentUser.id!, notification.id!);
              setState(() {
                notificationsList[index].isRead = true;
              });
              returnActionOnTap(index, notification);
            },
          );
        }
      case "UserBuysBono_Trainer":
        {
          return ListTile(
            leading: CircularImage(
              size: MediaQuery.of(context).size.width * 0.15,
              image: user.imageUrl!,
              color: AppColors.grey,
              borderWidth: 0.5,
            ),
            title: Text(
              context.l10n
                  .userBuysBonoTrainer(user.name!, bono.title!.toUpperCase()),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: notification.isRead!
                      ? FontWeight.normal
                      : FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  context.l10n.userBuysBonoTrainerSubtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  time.toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 10),
                ),
              ],
            ),
            onTap: () async {
              await _userDataService.markNotificationAsRead(
                  currentUser.id!, notification.id!);
              setState(() {
                notificationsList[index].isRead = true;
              });
              returnActionOnTap(index, notification);
            },
          );
        }
      default:
        {
          return Container();
        }
    }
  }

  void returnActionOnTap(int index, NotificationEvent notification) {
    Usuario user = usersList[index];
    Brand brand = brandsList[index];
    Event event = eventList[index];

    mixpanel!.track('user_notifications_tap',
        properties: {'type': notification.type});

    switch (notification.type!) {
      case "Wellcome_User":
        {
          break;
        }
      case "UserCreatesBrand_User":
        {
          break;
        }
      case "UserJoinsBrand_User":
        {
          if (brand.id != null) {
            /*
          Navigator.push(
              context,
            CupertinoPageRoute<Null>(
              builder: (context) => BrandCalendarWidget(
                  brandId: brand.id!,
                )
              )
          );
           */
          }
          break;
        }
      case "UserJoinsBrand_Trainer":
        {
          if (user.id != null) {
            Navigator.push(
                context,
                CupertinoPageRoute<void>(
                    builder: (context) => ProfileViewUser(
                          userID: user.id!,
                          viewOnly: false,
                        )));
          }
          break;
        }
      case "UserLeavesBrand_User":
        {
          break;
        }
      case "UserLeavesBrand_Trainer":
        {
          break;
        }
      case "UserSendRequestToBrand_User":
        {
          break;
        }
      case "UserSendRequestToBrand_Trainer":
        {
          if (brand.id != null) {
            navigateToRequestsScreen(brand.id!);
          }
          break;
        }
      case "UserCancelRequestToBrand_User":
        {
          break;
        }
      case "UserCancelRequestToBrand_Trainer":
        {
          break;
        }
      case "UserJoinEvent_User":
        {
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
                CupertinoPageRoute<void>(
                  builder: (context) => EventPage(
                    eventId: event.id!,
                  ),
                ));
          }
          break;
        }
      case "UserJoinEvent_Trainer":
        {
          if (event.id != null) {
            Navigator.push(
                context,
                CupertinoPageRoute<void>(
                  builder: (context) => EventPage(
                    eventId: event.id!,
                  ),
                ));
          }
          break;
        }
      case "UserLeaveEvent_User":
        {
          if (brand.id != null) {
            /*
          Navigator.push(
              context,
              CupertinoPageRoute<Null>(
                  builder: (context) => BrandCalendarWidget(
                    brandId: brand.id!,
                  )
              )
          );
           */
          }
          break;
        }
      case "UserLeaveEvent_Trainer":
        {
          if (event.id != null) {
            Navigator.push(
                context,
                CupertinoPageRoute<void>(
                  builder: (context) => EventPage(
                    eventId: event.id!,
                  ),
                ));
          }
          break;
        }
      case "UserSendBonoRequest_Trainer":
        {
          /*
          Navigator.push(
              context,
              CupertinoPageRoute<void>(
                builder: (context) => BrandPurchaseHistory(
                  brandId: currentBrand.id!,
                ),
              ));
              */
          break;
        }
      case "UserBuysBono_Trainer":
        {
          if (user.id != null) {
            Navigator.push(
                context,
                CupertinoPageRoute<void>(
                    builder: (context) => ProfileViewUser(
                          userID: user.id!,
                          viewOnly: false,
                        )));
          }
          break;
        }
      default:
        {
          break;
        }
    }
  }

  Future<void> navigateToRequestsScreen(String brandId) async {
    mixpanel!.track('brand_membership_requests_view');
    await Navigator.push(
        context,
        CupertinoPageRoute<bool?>(
          builder: (context) => MembershipRequestsPro(
            brandId: brandId,
          ),
        ));
  }
}
