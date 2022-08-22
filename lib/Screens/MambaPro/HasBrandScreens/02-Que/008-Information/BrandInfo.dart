import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectTimeDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Screens/MambaPro/HasBrandScreens/02-Que/012-Logo/Logo.dart';

// Tus Datos Widget.
class BrandInfo extends StatefulWidget {
  Locale? locale;
  int pageIndex;
  String brandId;
  BrandInfo({Key? key, this.locale, required this.pageIndex, required this.brandId}) : super(key: key);

  @override
  _BrandInfoState createState() => _BrandInfoState();
}

class _BrandInfoState extends State<BrandInfo> with SingleTickerProviderStateMixin {

  // DataBase Access
  final _brandDataService = BrandDataService();
  // Boolean isLoading
  bool isLoading = false;
  bool isUpdated = false;
  // Form To Validate
  final formKeyInfo = GlobalKey<FormState>();
  ScrollController? _scrollController;
  // Name Brand Controller
  // Logo Image
  var nameBrandController = TextEditingController();
  String nameBrandControllerTemp = "";
  // Description Controller
  var descriptionController = TextEditingController();
  String descriptionControllerTemp = "";
  // Max Members Brand
  TextEditingController membersController = TextEditingController();
  int members = 1;
  int membersMax = 30;
  bool errorMembers = false;
  // Time Picker Horari de Trabajo
  DateTime startTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 0);
  DateTime endTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 22, 0);
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  final List<double> _workShift = [];
  int? errorTime;
  // Descansos
  DateTime breakStartTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 13, 0);
  DateTime breakEndTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 14, 0);
  TimeOfDay _breakStartTime = const TimeOfDay(hour: 13, minute: 00);
  TimeOfDay _breakEndTime = const TimeOfDay(hour: 14, minute: 00);
  TextEditingController breakStartTimeController = TextEditingController();
  TextEditingController breakEndTimeController = TextEditingController();
  final List<TimeOfDay> _breakList = [];
  List<int> removedIndex = [];
  int breakLimit = 2;
  bool errorBreakTime = false;
  List<int> startBreaks = [];

  // App Bar and Scroll View
  bool appBarExpanded = false;
  bool get _isAppBarExpanded {
    return _scrollController!.hasClients && _scrollController!.offset > (MediaQuery.of(context).size.height*0.15 - kToolbarHeight);
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
    ..addListener(() => _isAppBarExpanded ?
      setState(() {
        appBarExpanded = true;
      }) :
      setState(() {
        appBarExpanded = false;
      }),
    );
    // Name Description
    nameBrandController.text = currentBrand.name!;
    descriptionController.text = currentBrand.description!;
    // Members Deprecated
    members = currentBrand.maxMembers!;
    membersController.text = currentBrand.maxMembers.toString();
    // Start Time
    var startHourWS = int.parse(currentBrand.workShift[0].toStringAsFixed(2).split(".")[0]);
    var startMinWS = int.parse(currentBrand.workShift[0].toStringAsFixed(2).split(".")[1]);
    startTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, startHourWS, startMinWS);
    startTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, startHourWS, startMinWS,));
    // End Time
    var endHourWS = int.parse(currentBrand.workShift[1].toStringAsFixed(2).split(".")[0]);
    var endMinWS = int.parse(currentBrand.workShift[1].toStringAsFixed(2).split(".")[1]);
    endTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, endHourWS, endMinWS);
    endTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, endHourWS, endMinWS,));
    // Break Time
    for (var i=2; i < currentBrand.workShift.length ; i+=2) {
      var start = currentBrand.workShift[i];
      int s = start.toInt();
      startBreaks.add(s);
      var startHour = int.parse(start.toStringAsFixed(2).split(".")[0]);
      var startMin = int.parse(start.toStringAsFixed(2).split(".")[1]);
      var end = currentBrand.workShift[i+1];
      int e = end.toInt();
      startBreaks.add(e);
      var endHour = int.parse(end.toStringAsFixed(2).split(".")[0]);
      var endMin = int.parse(end.toStringAsFixed(2).split(".")[1]);
      breakStartTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, startHour, startMin);
      _breakStartTime = TimeOfDay(hour: startHour, minute: startMin);
      breakEndTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, endHour, endMin);
      _breakEndTime = TimeOfDay(hour: endHour, minute: endMin);
      // Array of Breaks
      _breakList.add(_breakStartTime);
      _breakList.add(_breakEndTime);
    }
    breakStartTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 13, 0,));
    breakEndTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 14, 0,));

  }

  // Gets the user info from firebase.
  Future<void> getBrand() async {
    var basicData = await _brandDataService.getBrandDetails(widget.brandId);
    var userList = await _brandDataService.getBrandUsers(widget.brandId);
    setState(() {
      currentBrand.setBasicData = basicData;
      currentBrand.setUserList = userList;
      isLoading = false;
    });
  }

  Future<void> navigateToEditLogoScreen() async {
    await Navigator.push(
        context,
        CupertinoPageRoute<void>(
          builder: (context) => Logo(
              brandId: currentBrand.id!
          ),
        )
    ).whenComplete(() async {
      await getBrand();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      var startHourWS = int.parse(currentBrand.workShift[0].toStringAsFixed(2).split(".")[0]);
      var startMinWS = int.parse(currentBrand.workShift[0].toStringAsFixed(2).split(".")[1]);
      var endHourWS = int.parse(currentBrand.workShift[1].toStringAsFixed(2).split(".")[0]);
      var endMinWS = int.parse(currentBrand.workShift[1].toStringAsFixed(2).split(".")[1]);
      if (nameBrandControllerTemp.trim() != currentBrand.name! && nameBrandControllerTemp != "") {
        isUpdated = true;
      } else if (descriptionControllerTemp.trim() != currentBrand.description! && descriptionControllerTemp != "") {
        isUpdated = true;
      } else if (startTimeController.text != DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, startHourWS, startMinWS,)) || endTimeController.text != DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, endHourWS, endMinWS,))) {
        isUpdated = true;
      } else {
        isUpdated = false;
      }
    }

    return isLoading ?
    Scaffold(
      body: LoadingView(),
    )
        :
    Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      /*
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.information, style: Theme.of(context).appBarTheme.titleTextStyle,),
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext innerContext) => IconButton(
            icon: const Icon(Icons.menu),
              onPressed: () => mambaProScaffoldKey.currentState?.openDrawer()
          ),
        ),
        actions: [          
          Padding(
            padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.01),
            child: IconButton(
              icon: widget.pageIndex == 0 ? Container() :
              Icon(
                //iconStar ? Icons.push_pin : Icons.push_pin_outlined,
                Icons.push_pin,
                color: AppColors.red,
                //color: iconStar ? AppColors.red : Theme.of(context).primaryColor.withOpacity(0.5),
                size: MediaQuery.of(context).size.width*0.06,
              ),
              onPressed: () {
                /*
                setState(() {
                  iconStar = !iconStar;
                  if (iconStar == true) {
                    favourites.add(widget.pageIndex);
                  }
                  else {
                    favourites.remove(widget.pageIndex);
                  }
                  favourites.sort();
                  _userDataService.addFavouriteToUser(currentBrand.id!, currentUser.id!, favourites);
                }
                );
                 */
              },
            ),
          )
        ],
      ),
       */
      /*
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            expandedHeight: MediaQuery.of(context).size.height*0.15,
            elevation: 4,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Theme.of(context).backgroundColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.height*0.035 ),
                      child: Text(
                        AppLocalizations.of(context)!.information,
                        style: Theme.of(context).textTheme.headline1,
                      ),
                    )
                  ],
                ),
              ),
              titlePadding: EdgeInsets.zero,
              //centerTitle: true,
            ),
            title: appBarExpanded ? Text(AppLocalizations.of(context)!.information, style: Theme.of(context).appBarTheme.titleTextStyle,) : Container(),
            centerTitle: true,
            leading: Builder(
              builder: (BuildContext innerContext) => Padding(
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.02),
                child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      size: MediaQuery.of(context).size.height*0.04,
                    ),
                    onPressed: () => mambaProScaffoldKey.currentState?.openDrawer()
                ),
              ),
            ),
            bottom: PreferredSize(                       // Add this code
              preferredSize: const Size.fromHeight(1.0),      // Add this code
              child: Container(
                color: AppColors.grey,
                height: 1.0,
              ),                           // Add this code
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.01),
                child: IconButton(
                  icon: widget.pageIndex == 0 ? Container() :
                  Icon(
                    //iconStar ? Icons.push_pin : Icons.push_pin_outlined,
                    Icons.push_pin,
                    color: appBarExpanded ? Colors.red : Colors.blue,
                    //color: AppColors.red,
                    //color: iconStar ? AppColors.red : Theme.of(context).primaryColor.withOpacity(0.5),
                    size: MediaQuery.of(context).size.width*0.06,
                  ),
                  onPressed: () {
                    /*
                setState(() {
                  iconStar = !iconStar;
                  if (iconStar == true) {
                    favourites.add(widget.pageIndex);
                  }
                  else {
                    favourites.remove(widget.pageIndex);
                  }
                  favourites.sort();
                  _userDataService.addFavouriteToUser(currentBrand.id!, currentUser.id!, favourites);
                }
                );
                 */
                  },
                ),
              ),
            ],
          ),
        ],
        body: Builder(
          builder: (context) => CustomScrollView(
            shrinkWrap: true,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.width*0.07),
                    child: Form(
                      key: formKeyInfo,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.logo,
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.28,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: GestureDetector(
                                onTap: navigateToEditLogoScreen,
                                child: CircularImage(
                                  size: MediaQuery.of(context).size.height * 0.25,
                                  image: currentBrand.logoUrl!,
                                  borderWidth: 1,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.02),

                          Text(
                            AppLocalizations.of(context)!.nameBrand,
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Flexible(
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: nameBrandController,
                              onChanged: (value) {
                                setState(() {
                                  nameBrandControllerTemp = value;
                                });
                              },
                              validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.nameBrandError : null,
                              style: Theme.of(context).textTheme.headline1?.copyWith(fontWeight: FontWeight.normal),
                              textAlign: TextAlign.center,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                hintStyle: Theme.of(context).textTheme.caption,
                                hintText: AppLocalizations.of(context)!.nameBrandError,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.02),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!.createBrandDescDescription,
                                  style: Theme.of(context).textTheme.caption,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.02),
                          Text(
                            AppLocalizations.of(context)!.description,
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Flexible(
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: descriptionController,
                              onChanged: (value) {
                                setState(() {
                                  descriptionControllerTemp = value;
                                });
                              },
                              validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.descriptionError : null,
                              minLines: 1,
                              maxLines: 5,
                              maxLength: 250,
                              style: Theme.of(context).textTheme.bodyText2,
                              decoration: InputDecoration(
                                hintStyle: Theme.of(context).textTheme.caption,
                                hintText: AppLocalizations.of(context)!.descriptionError,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.04),
                          /*
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.maxNumberClientsError,
                              style: Theme.of(context).textTheme.caption,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.02),
                      Text(
                        AppLocalizations.of(context)!.maxNumberClients,
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      GestureDetector(
                          onTap: () {
                            selectSlot(context, 2, null);
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              new Flexible(
                                child: TextFormField(
                                  controller: membersController,
                                  minLines: 1,
                                  readOnly: true,
                                  enabled: false,
                                  style: Styles.purpleTextStyle,
                                  decoration: InputDecoration(
                                    hintStyle: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Colors.grey),
                                    hintText: AppLocalizations.of(context)!.maxNumberClientsError,
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
                      errorMembers ? Text(
                        AppLocalizations.of(context)!.maxNumberClientsError,
                        style: Styles.redTextStyle.copyWith(fontSize: 12),
                      ) : new Container(),
                      SizedBox(height: MediaQuery.of(context).size.height*0.03),
                      */
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!.createBrandWorkshiftDescription,
                                  style: Theme.of(context).textTheme.caption,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.02),
                          Text(
                            AppLocalizations.of(context)!.workingHours,
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.01),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              TextButton(
                                onPressed: () async {
                                  DateTime? pickedTimeTemp =  await showCupertinoModalPopup(
                                      context: context,
                                      builder: (_) => SelectTimeDialog(
                                        title: AppLocalizations.of(context)!.selectTime,
                                        startDate: startTime,
                                        onlyFuture: false,
                                      )
                                  );
                                  if (pickedTimeTemp != null) {
                                    setState(() {
                                      startTime = pickedTimeTemp;
                                      startTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, startTime.hour, startTime.minute,));
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                                    border: Border.all(color: Theme.of(context).primaryColor, width: 1.0),
                                    color: Colors.transparent,
                                  ),
                                  child: Text(
                                    startTimeController.text,
                                    style: Theme.of(context).textTheme.headline3,
                                  ),
                                ),
                              ),
                              Text("-",
                                  style: Theme.of(context).textTheme.headline3),
                              TextButton(
                                onPressed: () async {
                                  DateTime? pickedTimeTemp =  await showCupertinoModalPopup(
                                      context: context,
                                      builder: (_) => SelectTimeDialog(
                                        title: AppLocalizations.of(context)!.selectTime,
                                        startDate: endTime,
                                        onlyFuture: false,
                                      )
                                  );
                                  if (pickedTimeTemp != null) {
                                    setState(() {
                                      endTime = pickedTimeTemp;
                                      endTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, endTime.hour, endTime.minute,));
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(const Radius.circular(5)),
                                    border: Border.all(color: Theme.of(context).primaryColor, width: 1.0),
                                    color: Colors.transparent,
                                  ),
                                  child: Text(
                                      endTimeController.text,
                                      style: Theme.of(context).textTheme.headline3
                                  ),
                                ),
                              ),
                            ],
                          ),
                          errorTime != null ? Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10, top: 5.0, bottom: 0),
                            child: Text(
                              errorTime == 1 ? AppLocalizations.of(context)!.workingHoursError : AppLocalizations.of(context)!.workingHoursError1,
                              style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                              textAlign: TextAlign.center,
                            ),
                          ) : Container(),

                          /*
                      SizedBox(height: MediaQuery.of(context).size.height*0.04),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.createBrandBreakDescription,
                              style: Theme.of(context).textTheme.caption,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.02),
                      Text(
                        AppLocalizations.of(context)!.lunchBreak,
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * 0.43,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                TextButton(
                                  onPressed: _breakList.length < breakLimit ? () async {
                                    DateTime? pickedTimeTemp =  await showCupertinoModalPopup(
                                        context: context,
                                        builder: (_) => SelectTimeDialog(
                                          title: AppLocalizations.of(context)!.selectTime,
                                          startDate: breakStartTime,
                                          onlyFuture: false,
                                        )
                                    );
                                    if (pickedTimeTemp != null) {
                                      setState(() {
                                        breakStartTime = pickedTimeTemp;
                                        breakStartTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, breakStartTime.hour, breakStartTime.minute,));
                                      });
                                    }
                                  } : null,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(const Radius.circular(5)),
                                      border: Border.all(color: _breakList.length < breakLimit ? Theme.of(context).primaryColor : Colors.grey, width: 1.0),
                                      color: Colors.transparent,
                                    ),
                                    child: Text(
                                      breakStartTimeController.text,
                                      style: Theme.of(context).textTheme.headline3?.copyWith(color: _breakList.length < breakLimit ? Theme.of(context).primaryColor : Colors.grey),
                                    ),
                                  ),
                                ),
                                Text("-", style: Theme.of(context).textTheme.headline3?.copyWith(color: _breakList.length < breakLimit ? Theme.of(context).primaryColor : Colors.grey),),
                                TextButton(
                                  onPressed: _breakList.length < breakLimit ? () async {
                                    DateTime? pickedTimeTemp = await showCupertinoModalPopup(
                                        context: context,
                                        builder: (_) => SelectTimeDialog(
                                          title: AppLocalizations.of(context)!.selectTime,
                                          startDate: breakEndTime,
                                          onlyFuture: false,
                                        )
                                    );
                                    if (pickedTimeTemp != null) {
                                      setState(() {
                                        breakEndTime = pickedTimeTemp;
                                        breakEndTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, breakEndTime.hour, breakEndTime.minute,));
                                      });
                                    }
                                  } : null,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(const Radius.circular(5)),
                                      border: Border.all(color: _breakList.length < breakLimit ? Theme.of(context).primaryColor : Colors.grey, width: 1.0),
                                      color: Colors.transparent,
                                    ),
                                    child: Text(
                                      breakEndTimeController.text,
                                      style: Theme.of(context).textTheme.headline3?.copyWith(color: _breakList.length < breakLimit ? Theme.of(context).primaryColor : Colors.grey),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _breakList.length < breakLimit ? Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: OutlinedButton(
                              onPressed: () {
                                double toDouble(DateTime myTime) => myTime.hour + myTime.minute/60.0;
                                if (toDouble(DateFormat('HH:mm', widget.locale!.languageCode).parse(breakStartTimeController.text)) > toDouble(DateFormat('HH:mm', widget.locale!.languageCode).parse(breakEndTimeController.text))){
                                  setState(() {
                                    errorBreakTime = true;
                                  });
                                } else {
                                  DateTime start = DateFormat('HH:mm', widget.locale!.languageCode).parse(breakStartTimeController.text);
                                  DateTime end = DateFormat('HH:mm', widget.locale!.languageCode).parse(breakEndTimeController.text);
                                  _breakStartTime = TimeOfDay(hour: start.hour, minute: start.minute);
                                  _breakEndTime = TimeOfDay(hour: end.hour, minute: end.minute);
                                  setState(() {
                                    errorBreakTime = false ;
                                    _breakList.clear();
                                    _breakList.add(_breakStartTime);
                                    _breakList.add(_breakEndTime);
                                  });
                                }
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon( Icons.add, color: Colors.white, size: 30,),
                                ],
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.green,
                                elevation: 3,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(5),
                              ),
                            ),
                          ) : Container(),
                        ],
                      ),
                      errorBreakTime ? Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 5.0, bottom: 0),
                        child: Text(
                          AppLocalizations.of(context)!.workingHoursError1,
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                          textAlign: TextAlign.center,
                        ),
                      ) : Container(),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _breakList.length,
                        itemBuilder: (context, int index) {
                          if(index.isEven && !removedIndex.contains(index)) {
                            return Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.43,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      TextButton(
                                        onPressed: false ? () {
                                        } : null,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(const Radius.circular(5)),
                                            border: Border.all(color: Colors.green, width: 1.0),
                                            color: Colors.transparent,
                                          ),
                                          child: Text(
                                            '${_breakList[index].format(context)}',
                                            style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.green),
                                          ),
                                        ),
                                      ),
                                      Text("-", style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.green),),
                                      TextButton(
                                        onPressed: false ? () {
                                        } : null,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(const Radius.circular(5)),
                                            border: Border.all(color: Colors.green, width: 1.0),
                                            color: Colors.transparent,
                                          ),
                                          child: Text(
                                            '${_breakList[index+1].format(context)}',
                                            style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.green),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 0.0),
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        removedIndex.add(index);
                                        removedIndex.add(index+1);
                                        breakLimit += 2;
                                      });
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon( Icons.remove, color: Colors.white, size: 30,),
                                      ],
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      elevation: 3,
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(5),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(AppLocalizations.of(context)!.lunchBreakAdded, style: Theme.of(context).textTheme.bodyText2?.copyWith(fontStyle: FontStyle.italic), textAlign: TextAlign.center,),
                                ),
                              ],
                            );
                          } else {
                            return Container();
                          }
                        },
                        shrinkWrap: true,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      _breakList.length < breakLimit ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.createBrandAddDescription,
                              style: Theme.of(context).textTheme.bodyText2,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ) : Container(),
                       */
                          SizedBox(height: MediaQuery.of(context).size.height*0.10),
                        ],
                      ),
                    )
                ),
              ),
            ],
          ),
        ),


      ),
       */
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            expandedHeight: MediaQuery.of(context).size.height*0.15,
            elevation: 4,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Theme.of(context).backgroundColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: kToolbarHeight + MediaQuery.of(context).size.height*0.051),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                      child: Text(
                        AppLocalizations.of(context)!.information,
                        style: Theme.of(context).textTheme.headline1,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height*0.035,),
                    Container(
                      color: AppColors.grey,
                      height: 1.0,
                    ),
                  ],
                ),
              ),
              titlePadding: EdgeInsets.zero,
              //centerTitle: true,
            ),
            title: appBarExpanded ? Text(AppLocalizations.of(context)!.information, style: Theme.of(context).appBarTheme.titleTextStyle,) : Container(),
            centerTitle: true,
            leading: Builder(
              builder: (BuildContext innerContext) => Padding(
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.02),
                child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      size: MediaQuery.of(context).size.height*0.04,
                    ),
                    onPressed: () => mambaProScaffoldKey.currentState?.openDrawer()
                ),
              ),
            ),
            /*
            bottom: PreferredSize(                       // Add this code
              preferredSize: const Size.fromHeight(1.0),      // Add this code
              child: Container(
                color: AppColors.grey,
                height: 1.0,
              ),                           // Add this code
            ),
             */

            actions: [
              Padding(
                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.01),
                child: IconButton(
                  icon: widget.pageIndex == 0 ? Container() :
                  Icon(
                    //iconStar ? Icons.push_pin : Icons.push_pin_outlined,
                    Icons.push_pin,
                    color: appBarExpanded ? Colors.red : Colors.blue,
                    //color: AppColors.red,
                    //color: iconStar ? AppColors.red : Theme.of(context).primaryColor.withOpacity(0.5),
                    size: MediaQuery.of(context).size.width*0.06,
                  ),
                  onPressed: () {
                    /*
                setState(() {
                  iconStar = !iconStar;
                  if (iconStar == true) {
                    favourites.add(widget.pageIndex);
                  }
                  else {
                    favourites.remove(widget.pageIndex);
                  }
                  favourites.sort();
                  _userDataService.addFavouriteToUser(currentBrand.id!, currentUser.id!, favourites);
                }
                );
                 */
                  },
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.width*0.07),
                child: Form(
                  key: formKeyInfo,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.logo,
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.28,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: GestureDetector(
                            onTap: navigateToEditLogoScreen,
                            child: CircularImage(
                              size: MediaQuery.of(context).size.height * 0.25,
                              image: currentBrand.logoUrl!,
                              borderWidth: 1,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.02),

                      Text(
                        AppLocalizations.of(context)!.nameBrand,
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      Flexible(
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: nameBrandController,
                          onChanged: (value) {
                            setState(() {
                              nameBrandControllerTemp = value;
                            });
                          },
                          validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.nameBrandError : null,
                          style: Theme.of(context).textTheme.headline1?.copyWith(fontWeight: FontWeight.normal),
                          textAlign: TextAlign.center,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            hintStyle: Theme.of(context).textTheme.caption,
                            hintText: AppLocalizations.of(context)!.nameBrandError,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.02),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.createBrandDescDescription,
                              style: Theme.of(context).textTheme.caption,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.02),
                      Text(
                        AppLocalizations.of(context)!.description,
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      Flexible(
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: descriptionController,
                          onChanged: (value) {
                            setState(() {
                              descriptionControllerTemp = value;
                            });
                          },
                          validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.descriptionError : null,
                          minLines: 1,
                          maxLines: 5,
                          maxLength: 250,
                          style: Theme.of(context).textTheme.bodyText2,
                          decoration: InputDecoration(
                            hintStyle: Theme.of(context).textTheme.caption,
                            hintText: AppLocalizations.of(context)!.descriptionError,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.04),
                      /*
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.maxNumberClientsError,
                              style: Theme.of(context).textTheme.caption,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.02),
                      Text(
                        AppLocalizations.of(context)!.maxNumberClients,
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      GestureDetector(
                          onTap: () {
                            selectSlot(context, 2, null);
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              new Flexible(
                                child: TextFormField(
                                  controller: membersController,
                                  minLines: 1,
                                  readOnly: true,
                                  enabled: false,
                                  style: Styles.purpleTextStyle,
                                  decoration: InputDecoration(
                                    hintStyle: Styles.purpleTextStyle.copyWith(fontSize: 16, color: Colors.grey),
                                    hintText: AppLocalizations.of(context)!.maxNumberClientsError,
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
                      errorMembers ? Text(
                        AppLocalizations.of(context)!.maxNumberClientsError,
                        style: Styles.redTextStyle.copyWith(fontSize: 12),
                      ) : new Container(),
                      SizedBox(height: MediaQuery.of(context).size.height*0.03),
                      */
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.createBrandWorkshiftDescription,
                              style: Theme.of(context).textTheme.caption,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.02),
                      Text(
                        AppLocalizations.of(context)!.workingHours,
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          TextButton(
                            onPressed: () async {
                              DateTime? pickedTimeTemp =  await showCupertinoModalPopup(
                                  context: context,
                                  builder: (_) => SelectTimeDialog(
                                    title: AppLocalizations.of(context)!.selectTime,
                                    startDate: startTime,
                                    onlyFuture: false,
                                  )
                              );
                              if (pickedTimeTemp != null) {
                                setState(() {
                                  startTime = pickedTimeTemp;
                                  startTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, startTime.hour, startTime.minute,));
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(5)),
                                border: Border.all(color: Theme.of(context).primaryColor, width: 1.0),
                                color: Colors.transparent,
                              ),
                              child: Text(
                                startTimeController.text,
                                style: Theme.of(context).textTheme.headline3,
                              ),
                            ),
                          ),
                          Text("-",
                              style: Theme.of(context).textTheme.headline3),
                          TextButton(
                            onPressed: () async {
                              DateTime? pickedTimeTemp =  await showCupertinoModalPopup(
                                  context: context,
                                  builder: (_) => SelectTimeDialog(
                                    title: AppLocalizations.of(context)!.selectTime,
                                    startDate: endTime,
                                    onlyFuture: false,
                                  )
                              );
                              if (pickedTimeTemp != null) {
                                setState(() {
                                  endTime = pickedTimeTemp;
                                  endTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, endTime.hour, endTime.minute,));
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(const Radius.circular(5)),
                                border: Border.all(color: Theme.of(context).primaryColor, width: 1.0),
                                color: Colors.transparent,
                              ),
                              child: Text(
                                  endTimeController.text,
                                  style: Theme.of(context).textTheme.headline3
                              ),
                            ),
                          ),
                        ],
                      ),
                      errorTime != null ? Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 5.0, bottom: 0),
                        child: Text(
                          errorTime == 1 ? AppLocalizations.of(context)!.workingHoursError : AppLocalizations.of(context)!.workingHoursError1,
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                          textAlign: TextAlign.center,
                        ),
                      ) : Container(),

                      /*
                      SizedBox(height: MediaQuery.of(context).size.height*0.04),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.createBrandBreakDescription,
                              style: Theme.of(context).textTheme.caption,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.02),
                      Text(
                        AppLocalizations.of(context)!.lunchBreak,
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * 0.43,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                TextButton(
                                  onPressed: _breakList.length < breakLimit ? () async {
                                    DateTime? pickedTimeTemp =  await showCupertinoModalPopup(
                                        context: context,
                                        builder: (_) => SelectTimeDialog(
                                          title: AppLocalizations.of(context)!.selectTime,
                                          startDate: breakStartTime,
                                          onlyFuture: false,
                                        )
                                    );
                                    if (pickedTimeTemp != null) {
                                      setState(() {
                                        breakStartTime = pickedTimeTemp;
                                        breakStartTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, breakStartTime.hour, breakStartTime.minute,));
                                      });
                                    }
                                  } : null,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(const Radius.circular(5)),
                                      border: Border.all(color: _breakList.length < breakLimit ? Theme.of(context).primaryColor : Colors.grey, width: 1.0),
                                      color: Colors.transparent,
                                    ),
                                    child: Text(
                                      breakStartTimeController.text,
                                      style: Theme.of(context).textTheme.headline3?.copyWith(color: _breakList.length < breakLimit ? Theme.of(context).primaryColor : Colors.grey),
                                    ),
                                  ),
                                ),
                                Text("-", style: Theme.of(context).textTheme.headline3?.copyWith(color: _breakList.length < breakLimit ? Theme.of(context).primaryColor : Colors.grey),),
                                TextButton(
                                  onPressed: _breakList.length < breakLimit ? () async {
                                    DateTime? pickedTimeTemp = await showCupertinoModalPopup(
                                        context: context,
                                        builder: (_) => SelectTimeDialog(
                                          title: AppLocalizations.of(context)!.selectTime,
                                          startDate: breakEndTime,
                                          onlyFuture: false,
                                        )
                                    );
                                    if (pickedTimeTemp != null) {
                                      setState(() {
                                        breakEndTime = pickedTimeTemp;
                                        breakEndTimeController.text = DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, breakEndTime.hour, breakEndTime.minute,));
                                      });
                                    }
                                  } : null,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(const Radius.circular(5)),
                                      border: Border.all(color: _breakList.length < breakLimit ? Theme.of(context).primaryColor : Colors.grey, width: 1.0),
                                      color: Colors.transparent,
                                    ),
                                    child: Text(
                                      breakEndTimeController.text,
                                      style: Theme.of(context).textTheme.headline3?.copyWith(color: _breakList.length < breakLimit ? Theme.of(context).primaryColor : Colors.grey),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _breakList.length < breakLimit ? Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: OutlinedButton(
                              onPressed: () {
                                double toDouble(DateTime myTime) => myTime.hour + myTime.minute/60.0;
                                if (toDouble(DateFormat('HH:mm', widget.locale!.languageCode).parse(breakStartTimeController.text)) > toDouble(DateFormat('HH:mm', widget.locale!.languageCode).parse(breakEndTimeController.text))){
                                  setState(() {
                                    errorBreakTime = true;
                                  });
                                } else {
                                  DateTime start = DateFormat('HH:mm', widget.locale!.languageCode).parse(breakStartTimeController.text);
                                  DateTime end = DateFormat('HH:mm', widget.locale!.languageCode).parse(breakEndTimeController.text);
                                  _breakStartTime = TimeOfDay(hour: start.hour, minute: start.minute);
                                  _breakEndTime = TimeOfDay(hour: end.hour, minute: end.minute);
                                  setState(() {
                                    errorBreakTime = false ;
                                    _breakList.clear();
                                    _breakList.add(_breakStartTime);
                                    _breakList.add(_breakEndTime);
                                  });
                                }
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon( Icons.add, color: Colors.white, size: 30,),
                                ],
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.green,
                                elevation: 3,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(5),
                              ),
                            ),
                          ) : Container(),
                        ],
                      ),
                      errorBreakTime ? Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 5.0, bottom: 0),
                        child: Text(
                          AppLocalizations.of(context)!.workingHoursError1,
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                          textAlign: TextAlign.center,
                        ),
                      ) : Container(),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _breakList.length,
                        itemBuilder: (context, int index) {
                          if(index.isEven && !removedIndex.contains(index)) {
                            return Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.43,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      TextButton(
                                        onPressed: false ? () {
                                        } : null,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(const Radius.circular(5)),
                                            border: Border.all(color: Colors.green, width: 1.0),
                                            color: Colors.transparent,
                                          ),
                                          child: Text(
                                            '${_breakList[index].format(context)}',
                                            style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.green),
                                          ),
                                        ),
                                      ),
                                      Text("-", style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.green),),
                                      TextButton(
                                        onPressed: false ? () {
                                        } : null,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(const Radius.circular(5)),
                                            border: Border.all(color: Colors.green, width: 1.0),
                                            color: Colors.transparent,
                                          ),
                                          child: Text(
                                            '${_breakList[index+1].format(context)}',
                                            style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.green),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 0.0),
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        removedIndex.add(index);
                                        removedIndex.add(index+1);
                                        breakLimit += 2;
                                      });
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon( Icons.remove, color: Colors.white, size: 30,),
                                      ],
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      elevation: 3,
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(5),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(AppLocalizations.of(context)!.lunchBreakAdded, style: Theme.of(context).textTheme.bodyText2?.copyWith(fontStyle: FontStyle.italic), textAlign: TextAlign.center,),
                                ),
                              ],
                            );
                          } else {
                            return Container();
                          }
                        },
                        shrinkWrap: true,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      _breakList.length < breakLimit ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.createBrandAddDescription,
                              style: Theme.of(context).textTheme.bodyText2,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ) : Container(),
                       */
                      SizedBox(height: MediaQuery.of(context).size.height*0.10),
                    ],
                  ),
                )
            ),
          ),
        ],
      ),
      floatingActionButton: isUpdated ? Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
        child: FloatingActionButton.extended(
          heroTag: "81",
          onPressed: () async {
            if (validateInfo()) {
              setState(() {
                errorTime == null;
                errorBreakTime == false;
                isLoading = true;
              });
              DateTime start = DateFormat('HH:mm', widget.locale!.languageCode).parse(startTimeController.text);
              DateTime end = DateFormat('HH:mm', widget.locale!.languageCode).parse(endTimeController.text);
              double toDouble(DateTime myTime) => myTime.hour + myTime.minute/60.0;
              double toDouble2(TimeOfDay myTime) => myTime.hour + myTime.minute/60.0;
              // Reset Workshift
              _workShift.clear();
              _workShift.add(toDouble(start));
              _workShift.add(toDouble(end));
              for (var i=0; i < _breakList.length; i+=2) {
                if(!removedIndex.contains(i)) {
                  _workShift.add(toDouble2(_breakList[i]));
                  _workShift.add(toDouble2(_breakList[i+1]));
                }
              }
              await _brandDataService.updateBrandInfo(widget.brandId, nameBrandController.text, descriptionController.text, members, _workShift);
              await getBrand();
            }
          },
          backgroundColor: Colors.green,
          icon: Icon(Icons.save_rounded, color: Colors.white, size: MediaQuery.of(context).size.width*0.05,),
          label: Text(AppLocalizations.of(context)!.save,
            style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.white),),
        ),
      ) : Container(),
    );
  }

  bool validateInfo() {
    DateTime start = DateFormat('HH:mm', widget.locale!.languageCode).parse(startTimeController.text);
    DateTime end = DateFormat('HH:mm', widget.locale!.languageCode).parse(endTimeController.text);
    double toDouble(DateTime myTime) => myTime.hour + myTime.minute / 60.0;
    if (!formKeyInfo.currentState!.validate()) {
      return false;
    }
    if (membersController.text.isEmpty) {
      setState(() {
      errorMembers = true;
      });
      return false;
    }
    if (TimeOfDay(hour: start.hour, minute: start.minute) == const TimeOfDay(hour: 0, minute: 00) && TimeOfDay(hour: end.hour, minute: end.minute) == const TimeOfDay(hour: 23, minute: 00)) {
      setState(() {
        errorTime = 1;
      });
      return false;
    }
    if (toDouble(start) > toDouble(end)) {
      setState(() {
        errorTime = 2;
      });
      return false;
    }
    setState(() {
      errorTime == null;
      errorMembers = false;
    });
    return true;
  }


}

