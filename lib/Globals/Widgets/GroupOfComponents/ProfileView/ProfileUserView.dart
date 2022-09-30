import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Event/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Room/RoomDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Utils/Strings/StringUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/ImageFullScreen.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/TopSnackBar/TopSnackBar.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/OtorgarBono.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/UserBonos/UserBonosWidget.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Data/Models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/EventListTile.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/ChatCore/Chat.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ProfileViewUser extends StatefulWidget {
  @override
  String userID;
  bool viewOnly;
  ProfileViewUser({Key? key, required this.userID, required this.viewOnly}) : super(key: key);
  _ProfileViewUserState createState() => _ProfileViewUserState();
}

class _ProfileViewUserState extends State<ProfileViewUser> with SingleTickerProviderStateMixin {

  // Acceso a Base de Datos
  final _userDataService = UserDataService();
  final _eventDataService = EventDataService();
  final _roomDataService = RoomDataService();
  final _brandDataService = BrandDataService();

  // Boolean Loading
  bool isLoading = false;
  // Usuario
  Usuario? user;
  // Birthday
  int birthday = 0;
  // Event List
  String month = "";
  int totalEvents  = 0;
  int thisMonthEvents  = 0;
  List<Event> listEvents = [];
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
  // Gets the user info from firebase.
  void getUser() async {
    totalEvents  = 0;
    thisMonthEvents  = 0;
    listEvents = [];
    user = await _userDataService.getUserDetails(widget.userID);
    checkIfHasAllBrandBonos();
    getEventsDone();
  }


  // Gets the events passed by the trainer.
  void getEventsDone() async {
    DateTime today = DateTime.now();
    var tempMonth = 0;
    List<Event> list = await _eventDataService.getUserEvents(widget.userID);
    for (var i=0; i<list.length; i++) {
      Event event = list[i];
      var startDate =  DateTime(
        int.parse(event.year!),
        int.parse(event.month!),
        int.parse(event.day!),
        int.parse(event.hour!),
        int.parse(event.minute!),
      );
      if (startDate.isBefore(today)) {
        listEvents.add(event);
        if (startDate.year == today.year && startDate.month == today.month) {
          tempMonth += 1;
        }
      }
    }
    listEvents.sort((a,b) {
      var aDate =  DateTime(
        int.parse(a.year!),
        int.parse(a.month!),
        int.parse(a.day!),
        int.parse(a.hour!),
        int.parse(a.minute!),
      );
      var bDate =  DateTime(
        int.parse(b.year!),
        int.parse(b.month!),
        int.parse(b.day!),
        int.parse(b.hour!),
        int.parse(b.minute!),
      );
      return aDate.compareTo(bDate);
    });
    listEvents = List.from(listEvents.reversed);
    setState(() {
      thisMonthEvents = tempMonth;
      totalEvents = listEvents.length;
      isLoading = false;
    });
  }

  // Gets the events passed by the trainer.
  void checkIfHasAllBrandBonos() async {
    listBonos = await _brandDataService.getAllBonosFromBrandList(currentBrand.id!);
    userBonos = await _userDataService.getUserBonos(user?.id!);
    for (int i = 0; i < userBonos.length; ++i) {
      bonoFound = listBonos.firstWhere((element) => element.id == userBonos[i].id);
      if (bonoFound.id != '') {
        listBonos.remove(bonoFound);
      }
    }
    if (listBonos.isEmpty) {
      setState(() {
        hasAllBrandBonos = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(isLoading ? AppLocalizations.of(context)!.profileBottomNav : user!.name!, style: Theme.of(context).appBarTheme.titleTextStyle,),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            isLoading == true || widget.viewOnly || user!.id! == currentUser.id ? Container() : Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.04),
              child: IconButton(
                onPressed: () {
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
                        heightFactor: 0.28,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height*0.4,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.02, vertical: MediaQuery.of(context).size.width*0.03),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: Text(
                                      AppLocalizations.of(context)!.choseOption,
                                      style: Theme.of(context).textTheme.caption,
                                      textAlign: TextAlign.left
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.chat_outlined,
                                    size: MediaQuery.of(context).size.width*0.06,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  title: Text(
                                      AppLocalizations.of(context)!.chatBottomNav,
                                      style: Theme.of(context).textTheme.bodyText1,
                                      textAlign: TextAlign.left
                                  ),
                                  onTap: () async {
                                    types.User otherUser = types.User(
                                      firstName: user!.firstName,
                                      lastName: user!.lastName,
                                      id: user!.id!, // UID from Firebase Authentication
                                      imageUrl: user!.imageUrl,
                                    );
                                    final room = await FirebaseChatCore.instance.createRoom(otherUser,metadata: {
                                      "trainer" + user!.id!: user!.isTrainer,
                                      "trainer" + currentUser.id!: currentUser.isTrainer,
                                      "active" + user!.id!: false,
                                      "active" + currentUser.id!: true,
                                    });

                                    bool? deleteRoom = await Navigator.push(
                                      context,
                                      CupertinoPageRoute<bool>(
                                          builder: (context) => ChatPage(room: room)),).whenComplete(() async {
                                      room.metadata!["active" + currentUser.id!] = false;
                                      _roomDataService.updateRoom(room.id, room.metadata!);
                                    });
                                    if (!deleteRoom!) {
                                      _roomDataService.deleteRoom(room.id);
                                    }
                                  },
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.confirmation_number_outlined,
                                    size: MediaQuery.of(context).size.width*0.06,
                                    color: hasAllBrandBonos ? Theme.of(context).primaryColor.withOpacity(0.5) : Theme.of(context).primaryColor,
                                  ),
                                  title: Text(
                                      AppLocalizations.of(context)!.acceptBono,
                                      style: Theme.of(context).textTheme.bodyText1?.copyWith(color: hasAllBrandBonos ? Theme.of(context).primaryColor.withOpacity(0.5) : Theme.of(context).primaryColor),
                                      textAlign: TextAlign.left
                                  ),
                                  subtitle: hasAllBrandBonos ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8,),
                                      Text(
                                          AppLocalizations.of(context)!.allBonosInClient,
                                          style: Theme.of(context).textTheme.caption,
                                          textAlign: TextAlign.left
                                      ),
                                    ],
                                  ) : Container(),
                                  onTap: hasAllBrandBonos == false ? () async {
                                    Navigator.pop(context);
                                    showModalBottomSheet<bool?>(
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
                                          heightFactor: 0.95,
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () {
                                              FocusScopeNode currentFocus = FocusScope.of(context);
                                              if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                                                FocusManager.instance.primaryFocus?.unfocus();
                                              }
                                            },
                                            child: OtorgarBono(
                                              user: user!,
                                              edit: false,
                                              brand: currentBrand,
                                            ),
                                          ),
                                        );
                                      }
                                    ).whenComplete(() => checkIfHasAllBrandBonos());
                                  } : null,
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
                  size: MediaQuery.of(context).size.width*0.07,
                ),
              ),
            ),
          ],
        ),
        body: isLoading ?
        LoadingView()
            :
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.03),
              GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute<void>(
                            builder: (context) => FullScreenPage(
                              child:  Image.network(
                                user!.imageUrl!,
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
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
                              dark: false,
                            )
                        )
                    );
                  },
                  child: CircularImage(
                    size: MediaQuery.of(context).size.width*0.45,
                    image: user!.imageUrl,
                    borderWidth: 1.5,)),
              SizedBox(height: MediaQuery.of(context).size.height*0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    user!.isTrainer! ?  Icons.record_voice_over : Icons.directions_run,
                    color: Theme.of(context).colorScheme.secondary,
                    size: MediaQuery.of(context).size.width*0.04,
                  ),
                  user!.isTrainer! ? const SizedBox(width: 4) : const SizedBox(width: 2),
                  Text(
                    user!.isTrainer! ?  AppLocalizations.of(context)!.trainer : AppLocalizations.of(context)!.client,
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).colorScheme.secondary),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                    //elevation: 4,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.81,
                      height: MediaQuery.of(context).size.height * 0.10,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        //border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.10,
                            width: MediaQuery.of(context).size.width * 0.38,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Text(
                                  totalEvents.toString(),
                                  style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColor),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  AppLocalizations.of(context)!.allEvents,
                                  style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColor),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.05,
                            height: MediaQuery.of(context).size.height * 0.03,
                            child: VerticalDivider(color: Theme.of(context).primaryColor,),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.10,
                            width: MediaQuery.of(context).size.width * 0.38,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Text(
                                  thisMonthEvents.toString(),
                                  style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColor),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  AppLocalizations.of(context)!.monthEvents,
                                  style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColor),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              user!.isTrainer! == false ? UserBonosWidget(
                userId: widget.userID,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ) : SizedBox(height: MediaQuery.of(context).size.height*0.03),
              SizedBox(height: MediaQuery.of(context).size.height*0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.08),
                    child: Text(
                        AppLocalizations.of(context)!.mySessions,
                        style: Theme.of(context).textTheme.headline3!.copyWith(color: AppColors.grey, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.02),
              listEvents.isNotEmpty ? Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: listEvents.length,
                    itemBuilder: (context,int index) {
                      Event event = listEvents[index];
                      bool addLabel = false;
                      var startDate =  DateTime(
                        int.parse(event.year!),
                        int.parse(event.month!),
                        int.parse(event.day!),
                        int.parse(event.hour!),
                        int.parse(event.minute!),
                      );
                      String _month = DateFormat('MMMM yyyy', Localizations.localeOf(context).languageCode).format(startDate);
                      if (_month != month) {
                        month = _month;
                        addLabel = true;
                      }
                      return Column(
                        children: [
                          addLabel ? Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.08, vertical: MediaQuery.of(context).size.width*0.03),
                            child: Column(
                              children: [
                                //if(index != 0) SizedBox(height: MediaQuery.of(context).size.height*0.02),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      Localizations.localeOf(context).languageCode == 'ca' ? month.substring(3).toUpperCase() : StringUtils().toCapitalized(month),
                                      style: Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.secondary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ) : Container(),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.02),
                            child: EventListTile(
                              eventId: event.id!,
                              userId: widget.userID,
                              showFeedback: true,
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width*0.84,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.02, horizontal: MediaQuery.of(context).size.width*0.08),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: 1,
                                  width: MediaQuery.of(context).size.width*0.6,
                                  color: AppColors.grey,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                ],
              )
                :
              SizedBox(
                height: MediaQuery.of(context).size.height*0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: MediaQuery.of(context).size.height*0.15,
                        child: Image.asset(Constants.emptyCalendar)
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.20),
                      child: Text(AppLocalizations.of(context)!.noTrainingsDone, style: Theme.of(context).textTheme.caption, textAlign: TextAlign.center,),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.04),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }

  bool canDeleteFromBrand() {
    if (widget.viewOnly || currentUser.id! == user!.id! ) {
      return false;
    } else {
      // Si es entrenador i mira a un client
      if (currentUser.isTrainer! && !(user!.isTrainer!)) {
        return true;
      }
      // Si es entrenador i mira a un entrenador, ha de ser admin ID.
      if (currentUser.isTrainer! && user!.isTrainer! && currentUser.id! == currentBrand.adminID) {
        return true;
      }
      return false;
    }
  }

  bool canDeleteFromEvent(int numTrainers) {
    if (widget.viewOnly) {
      return false;
    } else {
      // Si es entrenador i mira a un client
      if (currentUser.isTrainer! && !(user!.isTrainer!)) {
        return true;
      }
      // Si es entrenador i mira a un entrenador, ha de ser admin ID.
      if (currentUser.isTrainer! && user!.isTrainer! && currentUser.id! == currentBrand.adminID && numTrainers > 1) {
        return true;
      }
      return false;
    }
  }
}
