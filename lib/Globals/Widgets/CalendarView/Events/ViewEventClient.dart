import 'dart:math';
import 'package:flutter/services.dart';
import 'package:mamba_castelldefels/Data/BrandDataService.dart';

import 'package:mamba_castelldefels/Data/EventDataService.dart';
import 'package:mamba_castelldefels/Data/UserDataService.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Dialogs/CancelRequestConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Dialogs/JoinConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Dialogs/LeaveConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Dialogs/SendRequestConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/MyLocationsSelect.dart';
import 'package:mamba_castelldefels/Globals/Widgets/ProfileView/ProfileUserView.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:mamba_castelldefels/Models/Location.dart';
import 'package:mamba_castelldefels/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:page_transition/page_transition.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../../Constants.dart';
import '../../../GlobalVars.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../Styles.dart';
import '../../Images/CircularImage.dart';


class ViewEventClient extends StatefulWidget {
  String eventId;
  bool canJoin;
  bool? onlyView;
  Locale locale;
  ViewEventClient({Key? key,required this.eventId, required this.canJoin, required this.locale, this.onlyView}) : super(key: key);

  @override
  _ViewEventClientState createState() => _ViewEventClientState();
}

class _ViewEventClientState extends State<ViewEventClient> with SingleTickerProviderStateMixin {
  // Acceso a Base de Datos
  var _userDataService = new UserDataService();
  var _brandDataService = new BrandDataService();
  var _eventDataService = new EventDataService();
  // Acceso a Base de Datos
  NotificationService _notificationService = NotificationService();
  // Boolean Loading
  bool isLoading = false;
  bool isLoadingBody = false;
  // Boolean isUpdated
  bool isEditing = false;
  // Title Controller
  var titleController = TextEditingController();
  String? titleString;
  // Description Controller
  var descriptionController = TextEditingController();
  String? descriptionString;
  // Starting Date and Time
  String datetitle = "";
  TextEditingController startDateController = TextEditingController();
  bool errorDate = false;
  // Duration
  TextEditingController durationController = TextEditingController();
  String duration = "1.00";
  List<String> durations = ["0.30","1.00","1.30","2.00","2.30","3.00","3.30","4.00"];
  // Location
  Location location = Location();
  // Participants
  TextEditingController membersController = TextEditingController();
  int members = 1;
  int membersMax = 100;
  // Members Page
  bool isFull = false;
  bool isJoined = false;
  List<Usuario> allUsers = [];
  List<Usuario> eventTrainers = [];
  List<Usuario> eventClients = [];
  // Form To Validate User
  final formKeyInfo = GlobalKey<FormState>();
  final formKeyTime = GlobalKey<FormState>();
  final formKeyMembers = GlobalKey<FormState>();
  // Event Retrieved From BD
  Brand? brand;
  Event? event;
  var placeDetails;
  // BackGround image
  Image? theImage;
  // String Deleted Photo
  String deletedObject = "https://firebasestorage.googleapis.com/v0/b/mamba-style.appspot.com/o/not-found-image.jpg?alt=media&token=70687295-6a17-4735-9c0a-e5749c777319";
  // Request To Brand
  String brandIdRequest = "";
  RequestToBrand? request;


  String toCapitalized(String s) => s.length > 0 ?'${s[0].toUpperCase()}${s.substring(1)}':'';
  String undoCapitalized(String s) => s.length > 0 ?'${s[0].toLowerCase()}${s.substring(1)}':'';


  @override
  initState() {
    isLoading = true;
    theImage = buildRandomImage();
    getEventInfo();
  }

  // Did Change Dependencies
  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(theImage!.image, context);
  }

  Image buildRandomImage() {
    Random random = new Random();
    int randomNumber = random.nextInt(15);
    switch(randomNumber) {
      case 0: {
        return Image.asset(Constants.eventBackground);
      }
      case 1: {
        return Image.asset(Constants.eventBackground1);
      }
      case 2: {
        return Image.asset(Constants.eventBackground2);
      }
      case 3: {
        return Image.asset(Constants.eventBackground3);
      }
      case 4: {
        return Image.asset(Constants.eventBackground4);
      }
      case 5: {
        return Image.asset(Constants.eventBackground5);
      }
      case 6: {
        return Image.asset(Constants.eventBackground6);
      }
      case 7: {
        return Image.asset(Constants.eventBackground7);
      }
      case 8: {
        return Image.asset(Constants.eventBackground8);
      }
      case 9: {
        return Image.asset(Constants.eventBackground9);
      }
      case 10: {
        return Image.asset(Constants.eventBackground10);
      }
      case 11: {
        return Image.asset(Constants.eventBackground11);
      }
      case 12: {
        return Image.asset(Constants.eventBackground12);
      }
      case 13: {
        return Image.asset(Constants.eventBackground13);
      }
      case 14: {
        return Image.asset(Constants.eventBackground14);
      }
      case 15: {
        return Image.asset(Constants.eventBackground15);
      }
      default: {
        return Image.asset(Constants.eventBackground);
      }
    }
  }

  void getEventInfo() async {
    // Get Event
    event = await _eventDataService.getSingleEvent(widget.eventId);
    // Get Brand
    brand = await _brandDataService.getBrandDetails(event!.brandID!);
    titleController.text = "${event!.title}";
    titleString = "${event!.title}";
    descriptionController.text = "${event!.description}";
    descriptionString = "${event!.description}";
    var startDate = DateTime(
      int.parse(event!.year!),
      int.parse(event!.month!),
      int.parse(event!.day!),
      int.parse(event!.hour!),
      int.parse(event!.minute!),
    );
    startDateController.text = DateFormat('EEEE d/M/y - HH:mm', widget.locale.languageCode).format(startDate);
    datetitle = DateFormat('EEEE d MMMM', widget.locale.languageCode).format(startDate);
    startDateController.text = toCapitalized(startDateController.text);
    duration = event!.duration!.toStringAsFixed(2);
    var hour = event!.duration.toString().split(".")[0];
    var min = event!.duration!.toStringAsFixed(2).split(".")[1];
    durationController.text = "${hour}h ${min}min";
    members = event!.maxMembers!;
    membersController.text = "${event!.numClients.toString()} / ${event!.maxMembers.toString()}";
    isFull = (event!.numClients!/event!.maxMembers! == 1);
    await getEventUsers();
    await getLocation(event!.locationId!);
    if (widget.onlyView != null) {
      if (widget.onlyView!) await getUserPendingRequests();
    }
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          isLoading = false;
          isLoadingBody = false;
          isEditing = false;
        });
      });
    }
  }

  Future<void> getEventUsers() async {
    allUsers = await _eventDataService.getEventUsers(event!.id!);
    List<Usuario> trainers = [];
    List<Usuario> clients = [];
    for (var i=0; i < allUsers.length; i++) {
      var user = allUsers[i];
      if (user.isTrainer!) {
        trainers.add(user);
      } else {
        if (currentUser.id! == user.id!) {
          // User has joined the event
          clients.insert(0, user);
          setState(() {
            isJoined = true;
          });
        } else {
          clients.add(user);
        }
      }
    }
    clients = orderClientsPrivateLast(clients);
    if (mounted) {
      setState(() {
        eventTrainers = trainers;
        eventClients = clients;
      });
    }
  }

  List<Usuario> orderClientsPrivateLast(List<Usuario> clients) {
    List<Usuario> orderedUsers = [];
    List<Usuario> privateUsers = [];
    for (var i=0; i< clients.length; i++) {
      Usuario client = clients[i];
      if (client.id == currentUser.id) {
        orderedUsers.insert(0, client);
      } else {
        if (client.isPrivate!) {
          privateUsers.add(client);
        } else {
          orderedUsers.add(client);
        }
      }
    }
    orderedUsers.addAll(privateUsers);
    return orderedUsers;
  }

  Future<void> getLocation(String locationId) async {
    location = await _eventDataService.getEventLocation(event!.id!);
    var temp = location;
    setState(() {
      location = temp;
    });
  }

  // Get user pending requests
  Future<void> getUserPendingRequests() async {
    List<RequestToBrand> req = await _userDataService.getUserRequests(currentUser.id!);
    if (req.isNotEmpty) {
      // At this moment, only 1 requests possible
      setState(() {
        request = req[0];
        brandIdRequest = request!.brandId!;
      });
    } else {
      setState(() {
        request = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return isLoading ?
    Scaffold(
      appBar: null,
      body: LoadingViewPurple(),
    )
        :
    Scaffold(
      appBar: null,
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
          ),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: MediaQuery.of(context).size.height*0.26,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: theImage!.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height*0.26,
                decoration: new BoxDecoration(
                  color: Colors.white,
                  gradient: LinearGradient(
                      begin: FractionalOffset.bottomCenter,
                      end: FractionalOffset.topCenter,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.9),
                      ],
                      stops: [
                        0.8,
                        1
                      ]
                  ),
                ),
                child: Center(),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).size.height*0.23,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height*0.10,
              ),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Material(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))
                    ),
                    elevation: 4,
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back, color: !isEditing ? Theme.of(context).primaryColor : Colors.white),
                              onPressed: !isEditing ? () {
                                Navigator.pop(context);
                              } : null,
                            ),
                          ),
                          isEditing ? Text(AppLocalizations.of(context)!.editEvent, style:  Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24)) : Text(datetitle, style:  Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
                          !widget.canJoin ? Padding(
                            padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.06, left: MediaQuery.of(context).size.width*0.06),
                            child: Container(),
                          ) :
                          Padding(
                            padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.05, left: MediaQuery.of(context).size.width*0.05),
                            child: Column(
                              children: [
                                !isEditing ? Icon(isFull ? Icons.lock_outline : Icons.lock_open, color: isFull ? Colors.red : Color(0xFFA8C76C)) : Icon(Icons.lock_open, color: Colors.white),
                                !isEditing ? Text(isFull ? AppLocalizations.of(context)!.full : AppLocalizations.of(context)!.available, style:  Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 12, color: isFull ? Colors.red : Color(0xFFA8C76C))) : Text(AppLocalizations.of(context)!.full, style:  Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height*0.32,
            bottom: 0,
            left: 0,
            right: 0,
            child: !isLoadingBody ? Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Form(
                              key: formKeyInfo,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: new TextField(
                                          controller: titleController,
                                          readOnly: true,
                                          style: Theme.of(context).textTheme.headline1!.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 22),
                                          decoration: InputDecoration(
                                            labelStyle: Styles.purpleTextStyle.copyWith(fontSize: 16),
                                            hintText:AppLocalizations.of(context)!.noDescription,
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                  Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 0),
                                      child: new Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Flexible(
                                            child: new TextFormField(
                                              controller: descriptionController,
                                              readOnly: true,
                                              minLines: 1,
                                              maxLines: 4,
                                              style: Styles.purpleTextStyle.copyWith(fontSize: 15),
                                              decoration: InputDecoration(
                                                labelStyle: Styles.purpleTextStyle.copyWith(fontSize: 16),
                                                hintText:AppLocalizations.of(context)!.noDescription,
                                                border: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                errorBorder: InputBorder.none,
                                                disabledBorder: InputBorder.none,
                                                contentPadding: EdgeInsets.all(0),
                                              ),
                                              textAlign: TextAlign.justify,
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.035),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.30,
                              width: MediaQuery.of(context).size.width * 0.90,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).backgroundColor,
                                  borderRadius: BorderRadius.all(Radius.circular(15.0))
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.width*0.05),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Icon(Icons.calendar_today_outlined, color: Theme.of(context).accentColor,),
                                        Container(
                                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                                            width: MediaQuery.of(context).size.width*0.72,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: <Widget>[
                                                Flexible(
                                                  child: TextFormField(
                                                    controller: startDateController,
                                                    readOnly: true,
                                                    enabled: false,
                                                    style: Styles.purpleTextStyle,
                                                    decoration: InputDecoration(
                                                      labelStyle: Styles.purpleTextStyle,
                                                      border: InputBorder.none,
                                                      focusedBorder: InputBorder.none,
                                                      enabledBorder: InputBorder.none,
                                                      errorBorder: InputBorder.none,
                                                      disabledBorder: InputBorder.none,
                                                    ),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                              ],
                                            )
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Icon(Icons.timer, color: Theme.of(context).accentColor,),
                                        Container(
                                            padding: EdgeInsets.only(left: 20),
                                            width: MediaQuery.of(context).size.width*0.70,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: <Widget>[
                                                Flexible(
                                                  child: TextFormField(
                                                    controller: durationController,
                                                    readOnly: true,
                                                    enabled: false,
                                                    style: Styles.purpleTextStyle,
                                                    decoration: InputDecoration(
                                                      labelStyle: Styles.purpleTextStyle,
                                                      border: InputBorder.none,
                                                      focusedBorder: InputBorder.none,
                                                      enabledBorder: InputBorder.none,
                                                      errorBorder: InputBorder.none,
                                                      disabledBorder: InputBorder.none,
                                                    ),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                              ],
                                            )
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(Icons.location_on_outlined, color: Theme.of(context).accentColor, size: 30,),
                                            Container(
                                              padding: EdgeInsets.only(left: 15),
                                              width: MediaQuery.of(context).size.width*0.70,
                                              child: ListTile(
                                                contentPadding: EdgeInsets.all(0),
                                                title: Text(
                                                    location.description!,
                                                    style: Styles.purpleTextStyle.copyWith(color: Theme.of(context).primaryColor)
                                                ),
                                                trailing: IconButton(
                                                  onPressed: () async {
                                                    Clipboard.setData(new ClipboardData(text: location.description!)).then((_){
                                                      showTopSnackBar(
                                                        context,
                                                        CustomSnackBar.info(
                                                          icon: Container(),
                                                          iconRotationAngle: 0,
                                                          backgroundColor: Theme.of(context).accentColor,
                                                          message: AppLocalizations.of(context)!.copyCorrectLocation,
                                                          textStyle: Styles.whiteTextStyle,
                                                        ),
                                                      );
                                                    });
                                                  },
                                                  icon: Icon(Icons.copy, color: Theme.of(context).accentColor, size: 25,),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.0),
                        child: Column(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height*0.03),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: 10),
                                child: new Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    new Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        new Text(
                                          AppLocalizations.of(context)!.numberClientJoining,
                                          style: Styles.purpleTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Icon(
                                    Icons.record_voice_over,
                                    color: Theme.of(context).accentColor,
                                    size: 25,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(context)!.trainers,
                                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).accentColor),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height*0.15,
                                    width: MediaQuery.of(context).size.width*0.99,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: BouncingScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: eventTrainers.length,
                                        itemBuilder: (context, int index) {
                                          var trainer = eventTrainers[index];
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(context, CupertinoPageRoute<Null>(
                                                builder: (context) => ProfileViewUser(userID: trainer.id!, viewOnly: false,)));
                                            },
                                            child: Padding(
                                              padding: !(index == 0 || index == eventTrainers.length-1) ? EdgeInsets.symmetric(horizontal: 8.0) : (index == 0) ? EdgeInsets.only(left: MediaQuery.of(context).size.width*0.06, right: 8.0) : EdgeInsets.only(right: eventTrainers.length != 1 ? MediaQuery.of(context).size.width*0.06 : 8.0, left: 8.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  CircularImage(
                                                    size: MediaQuery.of(context).size.width*0.2,
                                                    image: trainer.imageUrl,
                                                    color: Theme.of(context).primaryColor,
                                                    borderWidth: 1,
                                                  ),
                                                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                                  Container(
                                                    width: MediaQuery.of(context).size.width*0.2,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            trainer.name! != AppLocalizations.of(context)!.notFoundUser ? trainer.firstName! : trainer.name!,
                                                            style: Styles.purpleTextStyle.copyWith(fontSize: 15),
                                                            textAlign: TextAlign.center,
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
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height*0.01),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: 10),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Icon(
                                    Icons.directions_run,
                                    color: Theme.of(context).accentColor,
                                    size: 25,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    AppLocalizations.of(context)!.clients,
                                    style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).accentColor),
                                  ),
                                  SizedBox(width: 16),
                                  Row(
                                    children: [
                                      Text(
                                        "( "+event!.numClients.toString(),
                                        style: TextStyle(color: Theme.of(context).accentColor, fontSize: 16),
                                      ),
                                      Text(
                                        " / ",
                                        style: TextStyle(color: Theme.of(context).accentColor, fontSize: 16),
                                      ),
                                      Text(
                                        event!.maxMembers.toString()+" )",
                                        style: TextStyle(color: Theme.of(context).accentColor, fontSize: 16),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 0),
                              child:
                              eventClients.isEmpty ?
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                          height: 100,
                                          child: Image.asset(Constants.emptyPeople)
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!.noClientJoining,
                                        style: Styles.purpleTextStyle.copyWith(color: Color(0xFF808080), fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ],
                              ) :
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height*0.15,
                                    width: MediaQuery.of(context).size.width,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: BouncingScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: eventClients.length,
                                        itemBuilder: (context, int index) {
                                          var client = eventClients[index];
                                          if (client.isPrivate! && client.id != currentUser.id) {
                                            return GestureDetector(
                                              onTap: () {

                                              },
                                              child: Padding(
                                                padding: !(index == 0 || index == eventClients.length-1) ? EdgeInsets.symmetric(horizontal: 8.0) : (index == 0) ? EdgeInsets.only(left: MediaQuery.of(context).size.width*0.06, right: 8.0) : EdgeInsets.only(right: eventClients.length != 1 ? MediaQuery.of(context).size.width*0.06 : 8.0, left: 8.0),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    CircularImage(
                                                      size: MediaQuery.of(context).size.width*0.2,
                                                      image: client.noImageUrl,
                                                      color: Colors.grey,
                                                      borderWidth: 1,
                                                    ),
                                                    SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                                    Container(
                                                      width: MediaQuery.of(context).size.width*0.2,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              client.name! != AppLocalizations.of(context)!.notFoundUser ? client.firstName! : client.name!,
                                                              style: Styles.purpleTextStyle.copyWith(fontSize: 15, color: Theme.of(context).primaryColor.withOpacity(0.3)),
                                                              textAlign: TextAlign.center,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          } else {
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(context, CupertinoPageRoute<Null>(
                                                  builder: (context) => ProfileViewUser(userID: client.id!, viewOnly: false)));
                                              },
                                              child: Padding(
                                                padding: !(index == 0 || index == eventClients.length-1) ? EdgeInsets.symmetric(horizontal: 8.0) : (index == 0) ? EdgeInsets.only(left: MediaQuery.of(context).size.width*0.06, right: 8.0) : EdgeInsets.only(right: eventClients.length != 1 ? MediaQuery.of(context).size.width*0.06 : 8.0, left: 8.0),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    CircularImage(
                                                      size: MediaQuery.of(context).size.width*0.2,
                                                      image: client.imageUrl,
                                                      color: Theme.of(context).primaryColor,
                                                    borderWidth: 1,
                                                    ),
                                                    SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                                    Container(
                                                      width: MediaQuery.of(context).size.width*0.2,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              client.name! != AppLocalizations.of(context)!.notFoundUser ? client.firstName! : client.name!,
                                                              style: Styles.purpleTextStyle.copyWith(fontSize: 15),
                                                              textAlign: TextAlign.center,
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

                                        }
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            widget.canJoin || (widget.onlyView != null) ? SizedBox(height: MediaQuery.of(context).size.height*0.17) : SizedBox(height: MediaQuery.of(context).size.height*0.05),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
            ) : Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.13),
                child: LoadingViewPurple()),
          ),
        ],
      ),
      floatingActionButton: whichFloatingActionButton(),
    );
  }

  Widget whichFloatingActionButton() {
    if (isLoadingBody) {
      return Container();
    } else {
      if (widget.canJoin) {
        if (!isJoined && !isFull) {
          return Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width*0.40,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03),
                      child: FloatingActionButton.extended(
                        heroTag: "6",
                        onPressed: () async {
                          var result = await showDialog(
                              context: context,
                              builder: (_) {
                                return JoinConfirmationDialog(text: AppLocalizations.of(context)!.joinEventConfirmation);
                              }
                          );
                          if (result) {
                            // Join Event
                            setState(() {
                              isLoadingBody = true;
                            });
                            await _eventDataService.addUserToEvent(event!.id!, currentUser.id!);
                            _notificationService.userJoinEvent(currentUser.id!, event!.brandID!, event!.id!);
                            getEventInfo();
                            setState(() {
                              isJoined = true;
                              isLoadingBody = false;
                            });
                          }
                        },
                        backgroundColor: Colors.green,
                        icon: Icon(Icons.event_available_outlined, color: Colors.white,),
                        label: Text(
                          AppLocalizations.of(context)!.book,
                          style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (isJoined) {
          return Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width*0.40,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03),
                      child: FloatingActionButton.extended(
                        heroTag: "50",
                        onPressed: () async {
                          var result = await showDialog(
                              context: context,
                              builder: (_) {
                                return LeaveConfirmationDialog(text: AppLocalizations.of(context)!.leaveEventConfirmation);
                              }
                          );
                          if (result) {
                            // Leave Event
                            setState(() {
                              isLoadingBody = true;
                            });
                            await _eventDataService.deleteUserFromEvent(event!.id!, currentUser.id!);
                            _notificationService.userLeaveEvent(currentUser.id!, event!.brandID!, event!.id!);
                            getEventInfo();
                            setState(() {
                              isJoined = false;
                              isLoadingBody = false;
                            });
                          }
                        },
                        backgroundColor: Colors.red,
                        icon: Icon(Icons.event_busy_outlined, color: Colors.white,),
                        label: Text(
                          AppLocalizations.of(context)!.leave,
                          style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      }
      if (widget.onlyView != null) {
        if (widget.onlyView!) {
          if (request == null || brandIdRequest == brand!.id!) {
            if (brandIdRequest == brand!.id!) {
              return Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width*0.40,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03),
                          child: FloatingActionButton.extended(
                            heroTag: "1",
                            onPressed: () async {
                              var result = await showDialog(
                                  context: context,
                                  builder: (_) {
                                    return CancelRequestConfirmationDialog(
                                      text: AppLocalizations.of(context)!.cancelRequestConfirmation,
                                      brand: brand!,
                                    );
                                  }
                              );
                              if (result) {
                                setState(() {
                                  brandIdRequest = "";
                                });
                                NotificationService().userCancelRequestToBrand(currentUser.id!, request!.brandId!);
                                // New DataBase
                                _userDataService.deleteRequestToBrand(request!);
                                getUserPendingRequests();
                              }
                            },
                            backgroundColor: Colors.red,
                            icon: Icon(Icons.schedule_send, color: Colors.white,),
                            label: Text(
                              AppLocalizations.of(context)!.sent,
                              style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width*0.40,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03),
                          child: FloatingActionButton.extended(
                            heroTag: "2",
                            onPressed: () async {
                              var result = await showDialog(
                                  context: context,
                                  builder: (_) {
                                    return SendRequestConfirmationDialog(
                                      text: AppLocalizations.of(context)!.sendRequestConfirmation,
                                      brand: brand!,
                                    );
                                  }
                              );
                              if (result) {
                                setState(() {
                                  brandIdRequest = brand!.id!;
                                });
                                // New DataBase
                                await _userDataService.sendRequestToBrand(brand!.id!, currentUser.name! ,currentUser.isTrainer!);
                                NotificationService().userSendRequestToBrand(currentUser.id!, brand!.id!);
                                getUserPendingRequests();
                              }
                            },
                            backgroundColor: Colors.green,
                            icon: Icon(Icons.send_outlined, color: Colors.white,),
                            label: Text(
                              AppLocalizations.of(context)!.join,
                              style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }
        }
      }
      return Container();
    }
  }
}

