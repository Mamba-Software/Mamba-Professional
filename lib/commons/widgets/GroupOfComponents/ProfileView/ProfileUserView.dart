import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mamba/commons/constants/constants.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/Event/EventDataService.dart';
import 'package:mamba/data/DataService/Room/RoomDataService.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/data/Models/Bono.dart';
import 'package:mamba/commons/constants/assets.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/app/style/AppColors.dart';
import 'package:mamba/commons/utils/Date/DateTimeUtils.dart';
import 'package:mamba/commons/utils/Strings/StringUtils.dart';
import 'package:mamba/commons/widgets/Components/Images/ImageFullScreen.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Bonos/Purchase/PurchasePage.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Bonos/UserBonos/UserBonosWidget.dart';
import 'package:mamba/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba/events/crud_events/models/Event.dart';
import 'package:mamba/data/Models/Usuario.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:mamba/commons/widgets/GroupOfComponents/Dialogs/ActionDialogs/DeleteFromBrandConfirmationDialog.dart';
import 'package:mamba/user/chat/Chat.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:mamba/commons/widgets/GroupOfComponents/Stats/SessionsMade.dart';
import 'package:mamba/screens/MambaPro/Sesions/SesionsScreens/UserEventHistoryWidget.dart';
import 'package:mamba/screens/MambaPro/Sesions/SesionsScreens/UserRecentEventsWidget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileViewUser extends StatefulWidget {
  @override
  String userID;
  bool viewOnly;
  bool? comesFromChat;
  ValueChanged<bool?>? blockedChanged;

  ProfileViewUser(
      {super.key,
      required this.userID,
      required this.viewOnly,
      this.comesFromChat,
      this.blockedChanged});
  @override
  _ProfileViewUserState createState() => _ProfileViewUserState();
}

class _ProfileViewUserState extends State<ProfileViewUser>
    with SingleTickerProviderStateMixin {
  // Acceso a Base de Datos
  final _userDataService = UserDataService();
  final _eventDataService = EventDataService();
  final _roomDataService = RoomDataService();
  final _brandDataService = BrandDataService();

  // Boolean Loading
  bool isLoading = false;
  bool isDeleted = false;
  // Usuario
  Usuario user = Usuario();
  bool blockedUser = false;
  bool blockedByUser = false;
  // DateJoined
  DateTime dateJoined = DateTime.now();
  // User Event Stats
  List<Event> totalEvents = [];
  List<Event> lastEvents = [];
  double averageTime = 0;
  double totalTime = 0;
  // Streak
  bool hasStreak = true;
  int streakWeeks = 0;
  // Progress
  bool isYearly = false;
  // Bonos
  bool hasAllBrandBonos = false;
  Bono bonoFound = Bono();
  List<Bono> listBonos = [];
  List<Bono> userBonos = [];

  // init Widget state. Loading user info.
  @override
  void initState() {
    isLoading = true;
    getUser();
    super.initState();
  }

  // Check if this user is blocked by the user
  Future<void> checkUserBlocked() async {
    blockedUser =
        await _userDataService.checkUserBlocked(currentUser.id!, widget.userID);
    blockedByUser =
        await _userDataService.checkUserBlocked(widget.userID, currentUser.id!);
  }

  // Gets the user info from firebase.
  void getUser() async {
    user = await _userDataService.getUserDetails(widget.userID);
    dateJoined = DateFormat('dd-MM-yyyy').parse(user.dateJoined!);
    checkIfHasAllBrandBonos();
    checkUserBlocked();
    getUserEventsFinished();
  }

  // Gets the events passed by the trainer.
  Future<void> getUserEventsFinished() async {
    List res = await _eventDataService.getUserEventsStats(widget.userID);
    totalEvents = res[0];
    // Remove Events that are not from this Brand
    totalEvents.removeWhere((element) => element.brandID != currentBrand.id!);
    if (totalEvents.length > 4) {
      lastEvents = List.from(totalEvents.sublist(0, 4));
    } else {
      lastEvents = List.from(totalEvents);
    }
    totalTime = res[1];
    averageTime = res[2] * 60;
    streakWeeks = res[3].toInt();
    if (streakWeeks == 0) {
      hasStreak = false;
    }
    setState(() {
      isLoading = false;
    });
  }

  // Gets the events passed by the trainer.
  Future<void> checkIfHasAllBrandBonos() async {
    listBonos =
        await _brandDataService.getAllBonosFromBrandList(currentBrand.id!);
    listBonos.removeWhere((element) => element.isActive == false);
    userBonos = await _userDataService.getUserActiveBonosFromBrand(
        user.id!, currentBrand.id!);
    for (int i = 0; i < userBonos.length; ++i) {
      int index =
          listBonos.indexWhere((element) => element.id == userBonos[i].id);
      if (index != -1) {
        bonoFound = listBonos[index];
        listBonos.remove(bonoFound);
      }
    }
    if (listBonos.isEmpty) {
      setState(() {
        hasAllBrandBonos = true;
      });
    }
  }

  // Navigate to FullScreenImage Screen
  void navigateToFullScreenImage() {
    mixpanel!.timeEvent('profile_picture_click');
    Navigator.push(
        context,
        CupertinoPageRoute<Null>(
            builder: (context) => FullScreenPage(
                  dark: false,
                  child: Image.network(
                    user.imageUrl!,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.secondary,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                )));
    mixpanel!.track('user_profile_picture_click');
  }

  // Build the Widget of the Image
  Widget buildUserPicture() {
    return !isLoading
        ? Center(
            child: GestureDetector(
              onTap: navigateToFullScreenImage,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.17,
                child: Center(
                  child: CircularImage(
                    size: MediaQuery.of(context).size.height * 0.17,
                    image: user.imageUrl,
                    color: AppColors.lightGrey,
                    borderWidth: 1,
                  ),
                ),
              ),
            ),
          )
        : Center(
            child: Shimmer.fromColors(
              baseColor: AppColors.grey.withOpacity(0.8),
              highlightColor: AppColors.grey.withOpacity(0.5),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.17,
                decoration: const BoxDecoration(
                  color: AppColors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
  }

  // Build the Widget of the User Name
  Widget buildUserTitle() {
    return !isLoading
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                  user.isTrainer!
                      ? AppLocalizations.of(context)!.trainer
                      : AppLocalizations.of(context)!.client,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(
                  AppLocalizations.of(context)!.joinedIn(DateTimeUtils()
                      .formatDateTimeToStringMMYYYY(dateJoined,
                          Localizations.localeOf(context).languageCode)),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center)
            ],
          )
        : Shimmer.fromColors(
            baseColor: AppColors.grey.withOpacity(0.8),
            highlightColor: AppColors.grey.withOpacity(0.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.02,
                  width: MediaQuery.of(context).size.width * 0.3,
                  decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(height: 6),
                Container(
                  height: MediaQuery.of(context).size.width * 0.04,
                  width: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(5)),
                ),
              ],
            ));
  }

  // Build the Widget of the Image
  Widget buildUserStatsEvent() {
    return !isLoading
        ? Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.stats,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.065,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(FontAwesomeIcons.hourglassHalf,
                          size: MediaQuery.of(context).size.width * 0.09,
                          color: Colors.blue),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.15,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            averageTime < 90
                                ? Text(
                                    "${averageTime.toStringAsFixed(0)} ${AppLocalizations.of(context)!.minutesString.toLowerCase()}/${AppLocalizations.of(context)!.week.toLowerCase()}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall,
                                  )
                                : Text(
                                    "${(averageTime / 60).toStringAsFixed(1)} ${AppLocalizations.of(context)!.hoursString.toLowerCase()}/${AppLocalizations.of(context)!.week.toLowerCase()}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall,
                                  ),
                            const SizedBox(height: 4),
                            Text(
                              user.isTrainer!
                                  ? AppLocalizations.of(context)!
                                      .averageTimeWorked
                                  : AppLocalizations.of(context)!
                                      .averageTimeTrained,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.065,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.timer_outlined,
                          size: MediaQuery.of(context).size.width * 0.09,
                          color: AppColors.red),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.15,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${totalTime.toStringAsFixed(0)} ${AppLocalizations.of(context)!.hoursString.toLowerCase()}",
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.isTrainer!
                                  ? AppLocalizations.of(context)!
                                      .totalTimeWorked
                                  : AppLocalizations.of(context)!
                                      .totalTimeTrained,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.065,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(FontAwesomeIcons.squareCheck,
                          size: MediaQuery.of(context).size.width * 0.09,
                          color: Colors.green),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.15,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${totalEvents.length} ${AppLocalizations.of(context)!.sessions.toLowerCase()}",
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context)!.sesionsCompleted,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Shimmer.fromColors(
            baseColor: AppColors.grey.withOpacity(0.8),
            highlightColor: AppColors.grey.withOpacity(0.5),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.stats,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.065,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.hourglassHalf,
                            size: MediaQuery.of(context).size.width * 0.09,
                            color: Colors.blue),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02),
                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.15,
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.width * 0.04,
                                width: MediaQuery.of(context).size.width * 0.25,
                                decoration: BoxDecoration(
                                    color: AppColors.lightGrey,
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppLocalizations.of(context)!
                                    .averageTimeTrained,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.065,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.timer_outlined,
                            size: MediaQuery.of(context).size.width * 0.09,
                            color: AppColors.red),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02),
                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.15,
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.width * 0.04,
                                width: MediaQuery.of(context).size.width * 0.2,
                                decoration: BoxDecoration(
                                    color: AppColors.lightGrey,
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppLocalizations.of(context)!.totalTimeTrained,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.065,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.squareCheck,
                            size: MediaQuery.of(context).size.width * 0.09,
                            color: Colors.green),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02),
                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.15,
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.width * 0.04,
                                width: MediaQuery.of(context).size.width * 0.22,
                                decoration: BoxDecoration(
                                    color: AppColors.lightGrey,
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppLocalizations.of(context)!.sesionsCompleted,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ));
  }

  // Build the Widget of the Image
  Widget buildUserTrainingStreak() {
    return !isLoading
        ? Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.trainingStreak,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                hasStreak
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.065,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.1,
                              child: Image.asset(Assets.fireEmojiImage),
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.02),
                            SizedBox(
                              height: MediaQuery.of(context).size.width * 0.15,
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  streakWeeks != 1
                                      ? Text(
                                          "$streakWeeks ${AppLocalizations.of(context)!.week.toLowerCase()} ${AppLocalizations.of(context)!.inrow.toLowerCase()}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge,
                                        )
                                      : Text(
                                          "$streakWeeks ${AppLocalizations.of(context)!.week.toLowerCase()}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge,
                                        ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .trainingStreakCongrats,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        height: MediaQuery.of(context).size.height * 0.065,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.1,
                              child: Image.asset(Assets.fireEmojiImage),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width * 0.15,
                              width: MediaQuery.of(context).size.width * 0.78,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      AppLocalizations.of(context)!
                                          .trainingStreakDescription,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              ],
            ),
          )
        : Shimmer.fromColors(
            baseColor: AppColors.grey.withOpacity(0.8),
            highlightColor: AppColors.grey.withOpacity(0.5),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.trainingStreak,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.065,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.1,
                          child: Image.asset(Assets.fireEmojiImage),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02),
                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.15,
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.width * 0.04,
                                width: MediaQuery.of(context).size.width * 0.35,
                                decoration: BoxDecoration(
                                    color: AppColors.lightGrey,
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height:
                                    MediaQuery.of(context).size.width * 0.04,
                                width: MediaQuery.of(context).size.width * 0.55,
                                decoration: BoxDecoration(
                                    color: AppColors.lightGrey,
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ));
  }

  // Build the Widget of the Image
  Widget buildUserProgressWidget() {
    if (!isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.isTrainer!
                  ? AppLocalizations.of(context)!.sesionsCompleted
                  : StringUtils().toCapitalized(
                      AppLocalizations.of(context)!.myProgress.split(" ")[1]),
              style: Theme.of(context).textTheme.displaySmall,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isYearly = false;
                        });
                      },
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(4),
                          surfaceTintColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.background),
                          backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.background),
                          animationDuration: const Duration(milliseconds: 100),
                          overlayColor: MaterialStateProperty.all(
                              Theme.of(context).primaryColor.withOpacity(0.1)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ))),
                      child: Row(
                        children: [
                          Container(
                            height: 10.0,
                            width: 10.0,
                            decoration: BoxDecoration(
                                color: isYearly
                                    ? Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.2)
                                    : Theme.of(context).primaryColor,
                                shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!
                                .lastNMonths(6.toString()),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: Theme.of(context).primaryColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isYearly = true;
                        });
                      },
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(4),
                          surfaceTintColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.background),
                          backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.background),
                          animationDuration: const Duration(milliseconds: 100),
                          overlayColor: MaterialStateProperty.all(
                              Theme.of(context).primaryColor.withOpacity(0.1)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ))),
                      child: Row(
                        children: [
                          Container(
                            height: 10.0,
                            width: 10.0,
                            decoration: BoxDecoration(
                                color: isYearly == false
                                    ? Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.2)
                                    : Theme.of(context).primaryColor,
                                shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.lastYear,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: Theme.of(context).primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            SessionsMade(
              events: totalEvents.length > 5 ? totalEvents : [],
              backEvents: totalEvents,
              isYearly: isYearly,
            ),
          ],
        ),
      );
    } else {
      return Shimmer.fromColors(
        baseColor: AppColors.grey.withOpacity(0.8),
        highlightColor: AppColors.grey.withOpacity(0.5),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Text(
                AppLocalizations.of(context)!.myProgress,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isYearly = false;
                          });
                        },
                        style: ButtonStyle(
                            elevation: MaterialStateProperty.all(4),
                            surfaceTintColor: MaterialStateProperty.all(
                                Theme.of(context).primaryColor),
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context).primaryColor),
                            animationDuration:
                                const Duration(milliseconds: 100),
                            overlayColor: MaterialStateProperty.all(
                                Theme.of(context)
                                    .colorScheme
                                    .background
                                    .withOpacity(0.2)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ))),
                        child: Row(
                          children: [
                            Container(
                              height: 10.0,
                              width: 10.0,
                              decoration: BoxDecoration(
                                  color: isYearly
                                      ? Theme.of(context)
                                          .primaryColorDark
                                          .withOpacity(0.2)
                                      : Theme.of(context).primaryColorDark,
                                  shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!
                                  .lastNMonths(6.toString()),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      color:
                                          Theme.of(context).primaryColorDark),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isYearly = true;
                          });
                        },
                        style: ButtonStyle(
                            elevation: MaterialStateProperty.all(4),
                            surfaceTintColor: MaterialStateProperty.all(
                                Theme.of(context).primaryColor),
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context).primaryColor),
                            animationDuration:
                                const Duration(milliseconds: 100),
                            overlayColor: MaterialStateProperty.all(
                                Theme.of(context)
                                    .colorScheme
                                    .background
                                    .withOpacity(0.2)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ))),
                        child: Row(
                          children: [
                            Container(
                              height: 10.0,
                              width: 10.0,
                              decoration: BoxDecoration(
                                  color: isYearly == false
                                      ? Theme.of(context)
                                          .primaryColorDark
                                          .withOpacity(0.2)
                                      : Theme.of(context).primaryColorDark,
                                  shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.lastYear,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      color:
                                          Theme.of(context).primaryColorDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: MediaQuery.of(context).size.width * 0.85,
                    decoration: BoxDecoration(
                        color: AppColors.grey,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  // Build the Widget of the Image
  Widget buildRecentEventsWidget() {
    if (!isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.recentEvents,
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center),
                totalEvents.isNotEmpty
                    ? TextButton(
                        onPressed: navigateToEventHistoryScreen,
                        child: Text(
                            "${AppLocalizations.of(context)!.seeMap.split(" ")[0]} ${AppLocalizations.of(context)!.historial.toLowerCase()}",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    decoration: TextDecoration.underline)))
                    : Container(),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.0),
            UserRecentEventsWidget(
              userId: user.id!,
              events: totalEvents,
            ),
          ],
        ),
      );
    } else {
      return Shimmer.fromColors(
        baseColor: AppColors.grey.withOpacity(0.8),
        highlightColor: AppColors.grey.withOpacity(0.5),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.recentEvents,
                      style: Theme.of(context).textTheme.displaySmall,
                      textAlign: TextAlign.center),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.15,
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                        color: AppColors.grey,
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.15,
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                        color: AppColors.grey,
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            ],
          ),
        ),
      );
    }
  }

  // Navigate to Event History Screen
  void navigateToEventHistoryScreen() {
    mixpanel!.track('user_sesions_event_history');
    Navigator.push(
        context,
        CupertinoPageRoute<void>(
            builder: (context) => UserEventHistoryWidget(
                  userId: user.id!,
                  isTrainer: user.isTrainer!,
                  events: totalEvents,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isLoading
              ? AppLocalizations.of(context)!.profileBottomNav
              : user.name!,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 4,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: MediaQuery.of(context).size.width * 0.06,
          ),
          onPressed: () {
            Navigator.pop(context, isDeleted);
          },
        ),
        actions: [
          isLoading == true || widget.viewOnly || user.id! == currentUser.id
              ? Container()
              : Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.04),
                  child: IconButton(
                    onPressed: () {
                      mixpanel!.track('profile_view_more_options_button');
                      showModalBottomSheet<int?>(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        builder: (BuildContext context) {
                          return FractionallySizedBox(
                            heightFactor: user.isTrainer! == false ? 0.46 : 0.4,
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                    vertical:
                                        MediaQuery.of(context).size.width *
                                            0.03),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      title: Text(
                                          AppLocalizations.of(context)!
                                              .choseOption,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                          textAlign: TextAlign.left),
                                    ),
                                    !blockedByUser
                                        ? ListTile(
                                            leading: Icon(
                                              Icons.chat_outlined,
                                              size: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.06,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            title: Text(
                                                AppLocalizations.of(context)!
                                                    .chatBottomNav,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge,
                                                textAlign: TextAlign.left),
                                            onTap: () async {
                                              mixpanel!.track(
                                                  'profile_view_chat_button');
                                              types.User otherUser = types.User(
                                                firstName: user.firstName,
                                                lastName: user.lastName,
                                                id: user
                                                    .id!, // UID from Firebase Authentication
                                                imageUrl: user.imageUrl,
                                              );
                                              final room =
                                                  await FirebaseChatCore
                                                      .instance
                                                      .createRoom(otherUser,
                                                          metadata: {
                                                    "trainer${user.id!}":
                                                        user.isTrainer,
                                                    "trainer${currentUser.id!}":
                                                        currentUser.isTrainer,
                                                    "active${user.id!}": false,
                                                    "active${currentUser.id!}":
                                                        true,
                                                  });

                                              bool? deleteRoom =
                                                  await Navigator.push(
                                                context,
                                                CupertinoPageRoute<bool>(
                                                    builder: (context) =>
                                                        ChatPage(room: room)),
                                              ).whenComplete(() async {
                                                room.metadata![
                                                        "active${currentUser.id!}"] =
                                                    false;
                                                _roomDataService.updateRoom(
                                                    room.id, room.metadata!);
                                              });
                                              if (!deleteRoom!) {
                                                mixpanel!.track(
                                                    'profile_view_chat_empty');
                                                _roomDataService
                                                    .deleteRoom(room.id);
                                              }
                                            },
                                          )
                                        : ListTile(
                                            leading: Icon(
                                              Icons.chat_outlined,
                                              size: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.06,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            title: Text(
                                                AppLocalizations.of(context)!
                                                    .chatBottomNav,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                        color: Theme.of(context)
                                                            .disabledColor),
                                                textAlign: TextAlign.left),
                                          ),
                                    user.isTrainer! == false
                                        ? ListTile(
                                            leading: Icon(
                                              Icons
                                                  .confirmation_number_outlined,
                                              size: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.06,
                                              color: hasAllBrandBonos
                                                  ? Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(0.5)
                                                  : Theme.of(context)
                                                      .primaryColor,
                                            ),
                                            title: Text(
                                                AppLocalizations.of(context)!
                                                    .acceptBono,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                        color: hasAllBrandBonos
                                                            ? Theme.of(context)
                                                                .primaryColor
                                                                .withOpacity(
                                                                    0.5)
                                                            : Theme.of(context)
                                                                .primaryColor),
                                                textAlign: TextAlign.left),
                                            subtitle: hasAllBrandBonos
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const SizedBox(
                                                        height: 8,
                                                      ),
                                                      Text(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .allBonosInClient,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall,
                                                          textAlign:
                                                              TextAlign.left),
                                                    ],
                                                  )
                                                : null,
                                            onTap: hasAllBrandBonos == false
                                                ? () async {
                                                    mixpanel!.track(
                                                        'profile_view_give_bono');
                                                    Navigator.pop(context);
                                                    // Cupertino Modal
                                                    await Navigator.push(
                                                            context,
                                                            CupertinoPageRoute<
                                                                void>(
                                                              builder: (context) =>
                                                                  PurchasePage(
                                                                user: user,
                                                                brand:
                                                                    currentBrand,
                                                              ),
                                                            ))
                                                        .whenComplete(() async {
                                                      await checkIfHasAllBrandBonos();
                                                    });
                                                  }
                                                : null,
                                          )
                                        : Container(),
                                    canDeleteFromBrand()
                                        ? ListTile(
                                            leading: Icon(
                                              Icons.person_remove,
                                              size: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.06,
                                              color: AppColors.red,
                                            ),
                                            title: Text(
                                                "${AppLocalizations.of(context)!.delete} ${AppLocalizations.of(context)!.member.toLowerCase()}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                      color: AppColors.red,
                                                    ),
                                                textAlign: TextAlign.left),
                                            onTap: () async {
                                              Navigator.pop(context);
                                              var result = await showDialog(
                                                  context: context,
                                                  builder: (_) {
                                                    return DeleteFromBrandConfirmationDialog(
                                                      userId: widget.userID,
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .deleteFromBrandConfirmation,
                                                    );
                                                  });
                                              if (result) {
                                                setState(() {
                                                  isDeleted = true;
                                                });
                                              }
                                            },
                                          )
                                        : Container(),
                                    ListTile(
                                      leading: Icon(
                                        Icons.flag_outlined,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.06,
                                        color: AppColors.red,
                                      ),
                                      title: Text(
                                          AppLocalizations.of(context)!.report,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: AppColors.red,
                                              ),
                                          textAlign: TextAlign.left),
                                      onTap: () async {
                                        mixpanel!.track(
                                            'profile_view_report_button');
                                        launchEmail();
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        blockedUser
                                            ? Icons.disabled_visible
                                            : Icons.block,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.06,
                                        color: AppColors.red,
                                      ),
                                      title: Text(
                                          blockedUser
                                              ? AppLocalizations.of(context)!
                                                  .unblock
                                              : AppLocalizations.of(context)!
                                                  .block,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: AppColors.red,
                                              ),
                                          textAlign: TextAlign.left),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        if (!blockedUser) {
                                          mixpanel!.track(
                                              'profile_view_unblock_button');
                                          _userDataService.addUserBlocked(
                                              currentUser.id!, user.id!);
                                        } else {
                                          mixpanel!.track(
                                              'profile_view_block_button');
                                          _userDataService.deleteUserBlocked(
                                              currentUser.id!, user.id!);
                                        }
                                        setState(() {
                                          blockedUser = !blockedUser;
                                        });
                                        if (widget.comesFromChat != null &&
                                            widget.comesFromChat == true) {
                                          widget.blockedChanged!(blockedUser);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.more_horiz,
                      color: Theme.of(context).primaryColor,
                      size: MediaQuery.of(context).size.width * 0.07,
                    ),
                  ),
                ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.0),
            Material(
                elevation: 4,
                shape: const CircleBorder(),
                child: buildUserPicture()),
            const SizedBox(height: 12),
            buildUserTitle(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            buildUserStatsEvent(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            user.isTrainer == true || hasStreak == false
                ? Container()
                : buildUserTrainingStreak(),
            user.isTrainer == false
                ? UserBonosWidget(
                    userId: widget.userID,
                    brandId: currentBrand.id!,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                  )
                : Container(),
            buildUserProgressWidget(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            buildRecentEventsWidget(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          ],
        ),
      ),
    );
  }

  Future<void> launchEmail() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: contactEmail,
      query:
          'subject=Report ${widget.userID}&body=${AppLocalizations.of(context)!.reportUserFor}',
    );
    var url = params.toString();
    await launchUrl(Uri.parse(url));
  }

  bool canDeleteFromBrand() {
    if (widget.viewOnly || currentUser.id! == user.id!) {
      return false;
    } else {
      return currentUser.brandRole < 2 ? true : false;
    }
  }
}
