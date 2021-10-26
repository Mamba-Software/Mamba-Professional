import 'package:flutter/services.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/LocationPlacesSearch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Globals/Widgets/ProfileView/ProfileUserView.dart';
import 'package:mamba_castelldefels/Models/Event.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:page_transition/page_transition.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../../../Constants.dart';
import '../../../GlobalVars.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../Styles.dart';
import '../../CircularImage.dart';


class ViewEvent extends StatefulWidget {
  String eventId;
  bool canEdit;
  bool canJoin;
  Locale locale;
  ViewEvent({Key? key, required this.eventId,  required this.canEdit,  required this.canJoin, required this.locale}) : super(key: key);

  @override
  _ViewEventState createState() => _ViewEventState();
}

class _ViewEventState extends State<ViewEvent> with SingleTickerProviderStateMixin{
  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  // Boolean Loading
  bool isLoading = false;
  // Boolean isUpdated
  bool isUpdated = false;
  // Tab Controller
  TabController? _tabController;
  int _selectedIndex = 0;
  List<bool> tabs = [true, true, true];
  // Title Controller
  var titleController = TextEditingController();
  String? titleString;
  // Description Controller
  var descriptionController = TextEditingController();
  String? descriptionString;
  // Starting Date and Time
  String datetitle = "";
  String de = "de";
  TextEditingController startDateController = TextEditingController();
  bool errorDate = false;
  // Duration
  TextEditingController durationController = TextEditingController();
  String duration = "1.00";
  List<String> durations = ["0.30","1.00","1.30","2.00","2.30","3.00","3.30","4.00"];
  // Ubicació
  var ubicacionController =  TextEditingController();
  // Members Page
  List<Usuario> brandTrainersSelected = [];
  List<Usuario> brandClientsJoining = [];
  // Form To Validate User
  final formKeyInfo = GlobalKey<FormState>();
  final formKeyTime = GlobalKey<FormState>();
  final formKeyMembers = GlobalKey<FormState>();
  // Event Retrieved From BD
  Event? event;
  var placeDetails;

  String toCapitalized(String s) => s.length > 0 ?'${s[0].toUpperCase()}${s.substring(1)}':'';
  String undoCapitalized(String s) => s.length > 0 ?'${s[0].toLowerCase()}${s.substring(1)}':'';


  @override
  initState() {
    isLoading = true;
    _tabController = TabController(length: 2, vsync: this);
    getEventInfo();
  }

  void getEventInfo() async {
    event = await _accessDatabase.getSingleEvent(widget.eventId);
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
    var hour = event!.duration.toString().split(".")[0];
    var min = event!.duration!.toStringAsFixed(2).split(".")[1];
    durationController.text = "${hour}h ${min}min";
    getAllTrainersFromBrand();
    getAllClientsFromBrand();
    getPlaceFullAddress();
  }

  Future<void> getAllTrainersFromBrand() async {
    List<Usuario> allTrainers = await _accessDatabase.getAllTrainersFromBrand(currentBrand.id!);
    List<Usuario> temp = [];
    for (var i=0; i < allTrainers.length; i++) {
      var trainer = allTrainers[i];
      if (event!.selectedTrainers.contains(trainer.id)) {
        temp.add(trainer);
      }
    }
    if (mounted) {
      setState(() {
        brandTrainersSelected = temp;
      });
    }
  }

  Future<void> getAllClientsFromBrand() async {
    List<Usuario> allClients = await _accessDatabase.getAllClientsFromBrand(currentBrand.id!);
    List<Usuario> temp = [];
    for (var i=0; i < allClients.length; i++) {
      var client = allClients[i];
      if (event!.joinedMembers.contains(client.id)) {
        temp.add(client);
      }
    }
    if (mounted) {
      setState(() {
        brandClientsJoining = temp;
      });
    }
  }

  void getPlaceFullAddress() async {
    placeDetails = await LocationPlacesSearch().getPlaceDetailFromId(event!.placeId!);
    ubicacionController.text = placeDetails.fullAddress!;
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? Scaffold(
      appBar: null,
      body: LoadingViewPurple(),
    ) :
    Scaffold(
      appBar: null,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          //SizedBox(height: MediaQuery.of(context).size.height*0.03),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height*0.22,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Constants.eventBackground),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height*0.19,
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
                              icon: Icon(Icons.arrow_back, color: Styles.accent),
                              onPressed: () => {
                                Navigator.pop(context)
                              },
                            ),
                          ),
                          Text(datetitle, style:  Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.03),
                            child: IconButton(
                              icon: Icon(Icons.lock_open, color: Styles.accent),
                              onPressed: () => {

                              },
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
            top: MediaQuery.of(context).size.height*0.28,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                        child: Column(
                          children: [
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 0),
                                child: new Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    new Flexible(
                                      child: new TextField(
                                        controller: titleController,
                                        readOnly: true,
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).accentColor),
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
                                )
                            ),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 0),
                                child: new Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    new Flexible(
                                      child: new TextFormField(
                                        controller: descriptionController,
                                        readOnly: true,
                                        minLines: 1,
                                        maxLines: 6,
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
                            Padding(
                              padding: EdgeInsets.only(top: 20.0),
                              child: Container(
                                height: MediaQuery.of(context).size.height * 0.25,
                                width: MediaQuery.of(context).size.width * 0.90,
                                decoration: BoxDecoration(
                                    color: Theme.of(context).backgroundColor,
                                    borderRadius: BorderRadius.all(Radius.circular(15.0))
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left:18, top: 10.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(Icons.calendar_today_outlined, color: Theme.of(context).accentColor,),
                                          Container(
                                              padding: EdgeInsets.symmetric(horizontal: 20),
                                              width: MediaQuery.of(context).size.width*0.78,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  new Flexible(
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
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left:18, top: 10.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(Icons.timer, color: Theme.of(context).accentColor,),
                                          Container(
                                              padding: EdgeInsets.only(left: 20),
                                              width: MediaQuery.of(context).size.width*0.30,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget>[
                                                  new Flexible(
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
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left:18, top: 10.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(Icons.location_on_outlined, color: Theme.of(context).accentColor, size: 30,),
                                          Container(
                                              padding: EdgeInsets.only(left: 15),
                                              width: MediaQuery.of(context).size.width*0.77,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: <Widget>[
                                                  new Flexible(
                                                    child: TextFormField(
                                                      controller: ubicacionController,
                                                      readOnly: true,
                                                      minLines: 2,
                                                      maxLines: 3,
                                                      style: Styles.purpleTextStyle,
                                                      decoration: InputDecoration(
                                                        labelStyle: Styles.purpleTextStyle,
                                                        border: InputBorder.none,
                                                        focusedBorder: InputBorder.none,
                                                        enabledBorder: InputBorder.none,
                                                        errorBorder: InputBorder.none,
                                                        disabledBorder: InputBorder.none,
                                                        suffixIcon: IconButton(
                                                          onPressed: () async {
                                                            Clipboard.setData(new ClipboardData(text: ubicacionController.text)).then((_){
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
                                                          icon: Icon(
                                                            Icons.copy,
                                                            color: Theme.of(context).accentColor,
                                                            size: 28,
                                                          ),
                                                        ),
                                                      ),
                                                      textAlign: TextAlign.start,
                                                    ),
                                                  ),
                                                ],
                                              )
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
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.0),
                        child: Column(
                          children: [
                            SizedBox(height: 10,),
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
                                        physics: AlwaysScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: brandTrainersSelected.length,
                                        itemBuilder: (context, int index) {
                                          var trainer = brandTrainersSelected[index];
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(context, PageTransition(type: PageTransitionType.bottomToTop, child: ProfileViewUser(userID: trainer.id!)));
                                            },
                                            child: Padding(
                                              padding: !(index == 0) ? EdgeInsets.symmetric(horizontal: 8.0) : EdgeInsets.only(left: MediaQuery.of(context).size.width*0.06, right: 8.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  CircularImage(
                                                    size: MediaQuery.of(context).size.width*0.2,
                                                    image: trainer.imageUrl,
                                                    color: Theme.of(context).accentColor,
                                                    borderWidth: 1.5,
                                                  ),
                                                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        trainer.name!,
                                                        style: Styles.purpleTextStyle.copyWith(fontSize: 15),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ],
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
                                  Text(
                                    "( "+event!.joinedMembers.length.toString(),
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
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 0),
                              child:
                              brandClientsJoining.isEmpty ?
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
                                        physics: AlwaysScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: brandClientsJoining.length,
                                        itemBuilder: (context, int index) {
                                          var client = brandClientsJoining[index];
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(context, PageTransition(type: PageTransitionType.bottomToTop, child: ProfileViewUser(userID: client.id!)));
                                            },
                                            child: Padding(
                                              padding: !(index == 0) ? EdgeInsets.symmetric(horizontal: 8.0) : EdgeInsets.only(left: MediaQuery.of(context).size.width*0.06, right: 8.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  CircularImage(
                                                    size: MediaQuery.of(context).size.width*0.2,
                                                    image: client.imageUrl,
                                                    color: Theme.of(context).accentColor,
                                                    borderWidth: 1.5,
                                                  ),
                                                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        client.name!,
                                                        style: Styles.purpleTextStyle.copyWith(fontSize: 15),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ],
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
                            SizedBox(height: MediaQuery.of(context).size.height*0.12),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
            ),
          ),
        ],
      ),
      floatingActionButton: widget.canEdit ? Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          height: 50,
          width: 100,
          child: FloatingActionButton.extended(
            heroTag: null,
            onPressed: () {
              print("Edit");
            },
            backgroundColor: Colors.green,
            icon: Icon(Icons.edit, color: Colors.white,),
            label: Text(AppLocalizations.of(context)!.edit,
              style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),),
          ),
        ),
      ) : Container(),
    );
  }
}

/*
Row(
            mainAxisAlignment: MainAxisAlignment.center,
            //crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 25),
                child: FloatingActionButton.extended(
                  onPressed: () async {
                    // DeleteDialog
                    var result = await showDialog(
                        context: context,
                        builder: (_) {
                          return DeleteConfirmationDialog(text: AppLocalizations.of(context)!.deleteEventConfirmation);
                        }
                    );
                    if (result) {
                      setState(() {
                        isLoading = true;
                      });
                      await _accessDatabase.deleteEvent(widget.eventId);
                      Navigator.pop(context);
                    }

                  },
                  backgroundColor: Colors.red,
                  icon: Icon(Icons.delete_outline, color: Colors.white,),
                  label: Text(AppLocalizations.of(context)!.delete, style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width*0.05,),
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 25, left: 20, right: 20),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    print("Edit");
                  },
                  backgroundColor: Colors.green,
                  icon: Icon(Icons.edit, color: Colors.white,),
                  label: Text(AppLocalizations.of(context)!.edit,
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),),
                ),
              ),
            ],
          ),

  void _editEvent({Appointment? appointment, bool? updated, DateTime? dateTimeClicked}) {
    showModalBottomSheet<bool>(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))
        ),
        isScrollControlled: true,
        context: context,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        builder: (context) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height*0.88,
            ),
            padding: MediaQuery.of(context).viewInsets,
            child: AddEvent(
              oldData: widget.oldData,
              update: true,
              locale: Localizations.localeOf(context),
              initialDateTime: dateTimeClicked ?? null,
            ),
          );
        }
    );
  }

  */
/*

  Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height*0.80,
            ),
            child: Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Scaffold(
                      body: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  minHeight: MediaQuery.of(context).size.height*0.50,
                                ),
                                child: Form(
                                  key: formKeyInfo,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 25.0, right: 25.0),
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          descriptionController.text.isNotEmpty ? Padding(
                                              padding: EdgeInsets.only(top: 5.0),
                                              child: new Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  new Flexible(
                                                    child: new TextFormField(
                                                      keyboardType: TextInputType.visiblePassword,
                                                      controller: descriptionController,
                                                      readOnly: true,
                                                      minLines: 1,
                                                      maxLines: 5,
                                                      onChanged: (val) {
                                                        setState(() {
                                                          descriptionString = val;
                                                        });
                                                      },
                                                      style: Styles.purpleTextStyle,
                                                      decoration: InputDecoration(
                                                        labelStyle: Styles.purpleTextStyle,
                                                        hintText:AppLocalizations.of(context)!.descriptionError,
                                                        border: InputBorder.none,
                                                        focusedBorder: InputBorder.none,
                                                        enabledBorder: InputBorder.none,
                                                        errorBorder: InputBorder.none,
                                                        disabledBorder: InputBorder.none,
                                                      ),
                                                      textAlign: TextAlign.justify,
                                                    ),
                                                  ),
                                                ],
                                              )
                                          ) : Container(),
                                          Padding(
                                            padding: descriptionController.text.isNotEmpty ? EdgeInsets.only(top: 5.0) : EdgeInsets.only(top: 20.0),
                                            child: Container(
                                              height: MediaQuery.of(context).size.height * 0.15,
                                              width: MediaQuery.of(context).size.width * 0.90,
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context).backgroundColor,
                                                  borderRadius: BorderRadius.all(Radius.circular(15.0))
                                              ),
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(left:18, top: 10.0),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.max,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: <Widget>[
                                                        Icon(Icons.calendar_today_outlined, color: Theme.of(context).accentColor,),
                                                        Container(
                                                            padding: EdgeInsets.symmetric(horizontal: 20),
                                                            width: MediaQuery.of(context).size.width*0.70,
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.max,
                                                              children: <Widget>[
                                                                new Flexible(
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
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(left:18, top: 10.0),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.max,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: <Widget>[
                                                        Icon(Icons.timer, color: Theme.of(context).accentColor,),
                                                        Container(
                                                            padding: EdgeInsets.only(left: 20),
                                                            width: MediaQuery.of(context).size.width*0.30,
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.max,
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: <Widget>[
                                                                new Flexible(
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
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 5, bottom: 0),
                                            child: new Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Expanded(
                                                  child: TextFormField(
                                                    controller: ubicacionController,
                                                    validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.enterAddressError : null,
                                                    readOnly: true,
                                                    maxLines: 2,
                                                    onTap: null,
                                                    style: Styles.purpleTextStyle,
                                                    decoration: InputDecoration(
                                                      icon: Container(
                                                        width: 10,
                                                        height: 10,
                                                        child: Icon(
                                                          Icons.location_on_outlined,
                                                          color: Theme.of(context).accentColor,
                                                          size: 28,
                                                        ),
                                                      ),
                                                      hintText: AppLocalizations.of(context)!.enterAddress,
                                                      hintStyle: Styles.purpleTextStyle,
                                                      border: InputBorder.none,
                                                      contentPadding: EdgeInsets.only(left: 18.0, top: 18),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(width: MediaQuery.of(context).size.width*0.05,),
                                              FloatingActionButton(
                                                child: Icon(Icons.copy),
                                                elevation: 0,
                                                backgroundColor: Theme.of(context).accentColor,
                                                foregroundColor: Styles.white,
                                                onPressed: () async {
                                                  Clipboard.setData(new ClipboardData(text: ubicacionController.text)).then((_){
                                                    showTopSnackBar(
                                                      context,
                                                      CustomSnackBar.info(
                                                        icon: Container(),
                                                        iconRotationAngle: 0,
                                                        backgroundColor: Theme.of(context).primaryColor,
                                                        message: AppLocalizations.of(context)!.copyCorrectLocation,
                                                        textStyle: Styles.whiteTextStyle,
                                                      ),
                                                    );
                                                  });
                                                },
                                              ),
                                              Container(
                                                  height: 120,
                                                  child: Image.asset(Constants.locationImage)
                                              ),
                                            ],
                                          ),
                                        ]
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                      ),
                      resizeToAvoidBottomInset: false,
                    ),
                    Scaffold(
                      body: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  minHeight: MediaQuery.of(context).size.height*0.50,
                                ),
                                child: Padding(
                                    padding: EdgeInsets.only(left: 25.0, right: 25.0),
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.only(top: 20),
                                              child: new Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  new Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: <Widget>[
                                                      new Text(
                                                        AppLocalizations.of(context)!.designatedTrainers,
                                                        style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 15),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: MediaQuery.of(context).size.height*0.15,
                                                  width: MediaQuery.of(context).size.width*0.87,
                                                  child: ListView.builder(
                                                      shrinkWrap: true,
                                                      physics: AlwaysScrollableScrollPhysics(),
                                                      scrollDirection: Axis.horizontal,
                                                      itemCount: brandTrainersSelected.length,
                                                      itemBuilder: (context, int index) {
                                                        var trainer = brandTrainersSelected[index];
                                                        return Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              CircularImage(
                                                                size: MediaQuery.of(context).size.width*0.2,
                                                                image: trainer.imageUrl,
                                                                color: Theme.of(context).accentColor,
                                                                borderWidth: 1.5,
                                                              ),
                                                              SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Text(
                                                                    trainer.name!,
                                                                    style: Styles.purpleTextStyle.copyWith(fontSize: 15),
                                                                    textAlign: TextAlign.center,
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                              padding: EdgeInsets.only(top: 25),
                                              child: new Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  new Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: <Widget>[
                                                      new Text(
                                                        AppLocalizations.of(context)!.numberClientJoining,
                                                        style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 15),
                                            child:
                                            brandClientsJoining.isEmpty ?
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
                                                  width: MediaQuery.of(context).size.width*0.87,
                                                  child: ListView.builder(
                                                      shrinkWrap: true,
                                                      physics: AlwaysScrollableScrollPhysics(),
                                                      scrollDirection: Axis.horizontal,
                                                      itemCount: brandClientsJoining.length,
                                                      itemBuilder: (context, int index) {
                                                        var client = brandClientsJoining[index];
                                                        return Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              CircularImage(
                                                                size: MediaQuery.of(context).size.width*0.2,
                                                                image: client.imageUrl,
                                                                color: Theme.of(context).accentColor,
                                                                borderWidth: 1.5,
                                                              ),
                                                              SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Text(
                                                                    client.name!,
                                                                    style: Styles.purpleTextStyle.copyWith(fontSize: 15),
                                                                    textAlign: TextAlign.center,
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]
                                    )
                                ),
                              ),
                            ],
                          )
                      ),
                      resizeToAvoidBottomInset: false,
                    ),
                  ],
                )
            ),
          ),


 */
