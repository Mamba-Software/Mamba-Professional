import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Location/LocationDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Promotions/PromotionsDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Subscription.dart';
import 'package:mamba_castelldefels/Notifications/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/app/style/AppColors.dart';
import 'package:mamba_castelldefels/commons/utils/Images/ImageUtils.dart';
import 'package:mamba_castelldefels/commons/widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/commons/widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:mamba_castelldefels/Data/Models/Location.dart';
import 'package:google_place/google_place.dart' as googlePlace;
import 'package:mamba_castelldefels/commons/constants/GlobalVars.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/commons/widgets/GroupOfComponents/LocationAutoComplete/AddressSearch.dart';
import 'package:mamba_castelldefels/commons/widgets/GroupOfComponents/LocationAutoComplete/LocationPlacesSearch.dart';
import 'package:mamba_castelldefels/Auth/views/mobile/SplashScreen.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

class RegistrarMarca extends StatefulWidget {
  Locale? locale;
  RegistrarMarca({super.key, this.locale});

  @override
  _RegistrarMarcaState createState() => _RegistrarMarcaState();
}

class _RegistrarMarcaState extends State<RegistrarMarca>
    with SingleTickerProviderStateMixin {
  // DataBase Access
  final _brandDataService = BrandDataService();
  final _locationDataService = LocationDataService();
  // Boolean isLoading
  bool isLoading = false;
  // Tab Controller
  final PageController _pageControllerData = PageController(initialPage: 0);
  double addEventTabValue = 0.25;
  // Logo Image
  var _image;
  // Name Brand Controller
  var nameBrandController = TextEditingController();
  bool nameCanGoNext = false;
  // Description Controller
  var descriptionController = TextEditingController();
  FocusNode focusNodeDescription = FocusNode();
  bool maxChars = false;
  // Max Members Brand
  TextEditingController membersController = TextEditingController();
  int members = 1;
  int membersMax = 100;
  // Google APIS
  googlePlace.GooglePlace? gPlace;
  googlePlace.DetailsResult? detailsResult;
  // Ubicación
  Location location = Location();
  var ubicacionController = TextEditingController();
  bool hasLocation = false;
  bool errorLocation = false;

  Subscription subscritionPromo = Subscription();
  final _promotionDataService = PromotionsDataService();

  // 4th TAB: Time
  // Time Picker Horari de Trabajo
  DateTime startTime = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 0);
  DateTime endTime = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 22, 0);
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  final List<double> _workShift = [];
  int? errorTime;
  // Descansos
  TextEditingController breakStartTimeController = TextEditingController();
  TextEditingController breakEndTimeController = TextEditingController();
  final List<TimeOfDay> _breakList = [];
  List<int> removedIndex = [];
  int breakLimit = 2;
  bool errorBreakTime = false;
  // Booking Window
  int bookingWindow = 3;
  int minBookingWindow = 1;

  // Selects image from Gallery and updates in firebase.
  Future getImage() async {
    File? temp = await ImageUtils().pickImage();
    setState(() {
      _image = temp;
    });
  }

  Future<void> registerBrand() async {
    mixpanel!.track('register_brand_completed');
    // Get Data About The Times Of The Brand
    DateTime start = DateFormat('HH:mm', widget.locale!.languageCode)
        .parse(startTimeController.text);
    DateTime end = DateFormat('HH:mm', widget.locale!.languageCode)
        .parse(endTimeController.text);
    double toDouble(DateTime myTime) => myTime.hour + myTime.minute / 100.0;
    double toDouble2(TimeOfDay myTime) => myTime.hour + myTime.minute / 100.0;
    _workShift.add(toDouble(start));
    _workShift.add(toDouble(end));
    for (var i = 0; i < _breakList.length; i += 2) {
      if (!removedIndex.contains(i)) {
        _workShift.add(toDouble2(_breakList[i]));
        _workShift.add(toDouble2(_breakList[i + 1]));
      }
    }
    if (descriptionController.text.isEmpty) {
      descriptionController.text = "";
    }
    // Create Brand
    var result = await _brandDataService.addBrand(
        nameBrandController.text.trim(),
        _image,
        descriptionController.text.trim(),
        _workShift,
        membersMax,
        bookingWindow,
        minBookingWindow);
    // Add Location
    String baseLocation = await _locationDataService.addLocation(
        result,
        true,
        location.placeId!,
        location.description!,
        location.street!,
        location.streetNumber!,
        location.city!,
        location.zipCode!,
        location.latitude!,
        location.longitude!);
    await _brandDataService.updateBrandBaseLocation(result, baseLocation);
    // Add User To Brand
    // New Database
    await _brandDataService.addUserToBrand(currentUser.id!, result, 1);
    // Update Current User Brand
    NotificationService().userCreatesBrand(currentUser.id!, result);
    // Create Group Chat
    String logoUrl = await _brandDataService.getBrandLogoUrl(result);
    final room = await FirebaseChatCore.instance.createGroupRoom(
        imageUrl: logoUrl,
        metadata: {
          "trainer${currentUser.id!}": currentUser.isTrainer,
          "active${currentUser.id!}": false,
        },
        name: nameBrandController.text.trim(),
        users: []);
    await _brandDataService.updateBrandRoom(result, room.id);
    subscritionPromo =
        await _promotionDataService.getValidSubscription('7DAYSTRIAL', result);
    await _brandDataService.updateBrandPay(result, subscritionPromo.duration!,
        subscritionPromo.id!, subscritionPromo.title!, DateTime.now(), false);
    brandIsActive = false;
    // Pushing to Splash Screen
    await Future.delayed(const Duration(seconds: 2)); // Ensure listener fires
    Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute<void>(
        builder: (context) => const SplashScreen(),
        settings: const RouteSettings(name: 'SplashScreen'),
      ),
      (_) => false,
    );
  }

  @override
  void initState() {
    mixpanel!.track('register_brand_cover');
    gPlace = googlePlace.GooglePlace(Platform.isAndroid
        ? dotenv.env['PLACES_API_ANDROID']!
        : dotenv.env['PLACES_API_IOS']!);
    startTimeController.text =
        DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      8,
      0,
    ));
    endTimeController.text =
        DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      22,
      0,
    ));
    breakStartTimeController.text =
        DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      13,
      0,
    ));
    breakEndTimeController.text =
        DateFormat('HH:mm', widget.locale!.languageCode).format(DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      14,
      0,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.01),
          child: Text(AppLocalizations.of(context)!.createBrand,
              style: Theme.of(context).textTheme.displaySmall),
        ),
        centerTitle: false,
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.background,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.01),
            child: IconButton(
              icon: Icon(
                Icons.close,
                size: MediaQuery.of(context).size.width * 0.06,
              ),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LinearPercentIndicator(
                  width: MediaQuery.of(context).size.width * 0.94,
                  lineHeight: 5,
                  percent: addEventTabValue,
                  animation: false,
                  animationDuration: 250,
                  barRadius: const Radius.circular(10),
                  progressColor: Theme.of(context).primaryColor,
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.2),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Expanded(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageControllerData,
                onPageChanged: (int page) {
                  setState(() {
                    addEventTabValue += 0.25;
                  });
                },
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.1),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.addBrandLogo,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(fontSize: 30),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02),
                                Text(
                                  AppLocalizations.of(context)!
                                      .createBrandPortada,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.05),
                                Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.15,
                                    color: Colors.transparent,
                                    child: _image == null
                                        ? Center(
                                            child: OutlinedButton(
                                              onPressed: getImage,
                                              style: OutlinedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.lightGrey,
                                                elevation: 4,
                                                shape: const CircleBorder(),
                                                padding:
                                                    const EdgeInsets.all(40),
                                              ),
                                              child: Icon(
                                                Icons.add,
                                                color: AppColors.grey,
                                                size: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.08,
                                              ),
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: getImage,
                                            child: Stack(
                                              children: <Widget>[
                                                const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                            color: AppColors
                                                                .black)),
                                                Center(
                                                    child: CircularImage(
                                                  size: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.15,
                                                  file: _image,
                                                  borderWidth: 1,
                                                  color: AppColors.grey,
                                                )),
                                              ],
                                            ),
                                          )),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.10,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.04,
                                vertical:
                                    MediaQuery.of(context).size.width * 0.03),
                            child: Row(
                              children: [
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.01),
                                Icon(
                                  Icons.visibility,
                                  color: Theme.of(context).primaryColor,
                                  size:
                                      MediaQuery.of(context).size.width * 0.06,
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.04),
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!.changeLater,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: _image == null
                                      ? null
                                      : () {
                                          _pageControllerData.nextPage(
                                            duration: const Duration(
                                                milliseconds: 500),
                                            curve: Curves.ease,
                                          );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: _image != null
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.1),
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(15),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: _image != null
                                        ? Theme.of(context).primaryColorDark
                                        : Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.2),
                                    size: MediaQuery.of(context).size.width *
                                        0.06,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.1),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.nameBrand,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(fontSize: 30),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02),
                                Text(
                                  AppLocalizations.of(context)!
                                      .createBrandPortada,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.05),
                                Material(
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          autofocus: true,
                                          controller: nameBrandController,
                                          keyboardType: TextInputType.name,
                                          onChanged: (val) {
                                            if (nameBrandController
                                                .text.isNotEmpty) {
                                              setState(() {
                                                nameCanGoNext = true;
                                              });
                                            } else {
                                              setState(() {
                                                nameCanGoNext = false;
                                              });
                                            }
                                          },
                                          onFieldSubmitted: (val) {
                                            focusNodeDescription.requestFocus();
                                          },
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall
                                              ?.copyWith(
                                                  fontWeight: FontWeight.normal,
                                                  color: AppColors.black),
                                          textCapitalization:
                                              TextCapitalization.words,
                                          decoration: InputDecoration(
                                              filled: true,
                                              fillColor: AppColors.white,
                                              hintText:
                                                  AppLocalizations.of(context)!
                                                      .nameBrandError,
                                              hintStyle: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall
                                                  ?.copyWith(
                                                      color: AppColors.grey,
                                                      fontWeight:
                                                          FontWeight.normal),
                                              errorStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                      color: AppColors.red),
                                              border: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.transparent,
                                                    width: 1.5),
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.transparent,
                                                    width: 1.5),
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.transparent,
                                                    width: 1.5),
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.transparent,
                                                    width: 1.5),
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.fromLTRB(
                                                      12, 8, 12, 8)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02),
                                Material(
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          focusNode: focusNodeDescription,
                                          controller: descriptionController,
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          minLines: 3,
                                          maxLines: 5,
                                          onChanged: (val) {
                                            if (descriptionController
                                                    .text.length ==
                                                250) {
                                              setState(() {
                                                maxChars = true;
                                              });
                                            } else {
                                              setState(() {
                                                maxChars = false;
                                              });
                                            }
                                          },
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall
                                              ?.copyWith(
                                                  fontWeight: FontWeight.normal,
                                                  color: AppColors.black),
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(
                                                250), // for mobile
                                          ],
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: AppColors.white,
                                            hintText:
                                                "${AppLocalizations.of(context)!.descriptionError}. Max. 250 ${AppLocalizations.of(context)!.chars.toLowerCase()} (${AppLocalizations.of(context)!.optional.toLowerCase()})",
                                            hintStyle: Theme.of(context)
                                                .textTheme
                                                .displaySmall
                                                ?.copyWith(
                                                    color: AppColors.grey,
                                                    fontWeight:
                                                        FontWeight.normal),
                                            errorStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                    color: AppColors.red),
                                            border: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.transparent,
                                                  width: 1.5),
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.transparent,
                                                  width: 1.5),
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.transparent,
                                                  width: 1.5),
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.transparent,
                                                  width: 1.5),
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.fromLTRB(
                                                    12, 12, 12, 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                maxChars
                                    ? Container(
                                        padding: const EdgeInsets.all(8),
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        decoration: const BoxDecoration(
                                          color: AppColors.red,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                "Max. 250 ${AppLocalizations.of(context)!.chars.toLowerCase()}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                        color: AppColors.white),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.10,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.04,
                                vertical:
                                    MediaQuery.of(context).size.width * 0.03),
                            child: Row(
                              children: [
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.01),
                                Icon(
                                  Icons.visibility,
                                  color: Theme.of(context).primaryColor,
                                  size:
                                      MediaQuery.of(context).size.width * 0.06,
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.04),
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!.changeLater,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: nameCanGoNext == false
                                      ? null
                                      : () {
                                          FocusScopeNode currentFocus =
                                              FocusScope.of(context);
                                          if (!currentFocus.hasPrimaryFocus) {
                                            currentFocus.unfocus();
                                          }
                                          _pageControllerData.nextPage(
                                            duration: const Duration(
                                                milliseconds: 500),
                                            curve: Curves.ease,
                                          );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: nameCanGoNext
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.1),
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(15),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: nameCanGoNext
                                        ? Theme.of(context).primaryColorDark
                                        : Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.2),
                                    size: MediaQuery.of(context).size.width *
                                        0.06,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.1),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${AppLocalizations.of(context)!.add} ${AppLocalizations.of(context)!.baseLocation.toLowerCase()}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(fontSize: 30),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02),
                                Text(
                                  AppLocalizations.of(context)!
                                      .createBrandLocation,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.05),
                                Material(
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: ListTile(
                                    onTap: () async {
                                      // Generate a new token here
                                      final sessionToken = const Uuid().v4();
                                      final language = currentUser.idioma;
                                      final Suggestion? result =
                                          await showSearch(
                                        context: context,
                                        delegate: AddressSearch(
                                            sessionToken, language!),
                                      );
                                      // We have a result for our locations search
                                      if (result != null) {
                                        location.placeId = result.placeId;
                                        final placeDetails =
                                            await LocationPlacesSearch(
                                                    sessionToken, language)
                                                .getPlaceDetailFromId(
                                                    location.placeId!);
                                        // Get the information on Strings
                                        if (placeDetails.street != null) {
                                          location.street =
                                              placeDetails.street!;
                                        } else {
                                          location.street = "N/A";
                                        }
                                        if (placeDetails.streetNumber != null) {
                                          location.streetNumber =
                                              placeDetails.streetNumber!;
                                        } else {
                                          location.streetNumber = "N/A";
                                        }
                                        if (placeDetails.city != null) {
                                          location.city = placeDetails.city!;
                                        } else {
                                          location.city = "N/A";
                                        }
                                        if (placeDetails.zipCode != null) {
                                          location.zipCode =
                                              placeDetails.zipCode!;
                                        } else {
                                          location.zipCode = "N/A";
                                        }
                                        //if(placeDetails.fullAddress!=null) location.description = placeDetails.fullAddress!;
                                        // Build Correct Description
                                        location.description =
                                            "${location.street} ${location.streetNumber}, ${location.city}, ${location.zipCode}";
                                        // Get Latitude/Longitude
                                        var temp = await gPlace!.details
                                            .get(location.placeId!);
                                        if (temp != null &&
                                            temp.result != null &&
                                            mounted) {
                                          detailsResult = temp.result;
                                          location.latitude = detailsResult!
                                              .geometry!.location!.lat!;
                                          location.longitude = detailsResult!
                                              .geometry!.location!.lng!;
                                        }
                                        setState(() {
                                          hasLocation = true;
                                          errorLocation = false;
                                        });
                                      } else {
                                        setState(() {
                                          hasLocation = false;
                                        });
                                      }
                                    },
                                    title: hasLocation
                                        ? Text(
                                            location.description!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                    color: AppColors.black),
                                          )
                                        : Text(
                                            AppLocalizations.of(context)!
                                                .enterAddressError,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                    color: AppColors.black),
                                          ),
                                    minLeadingWidth:
                                        MediaQuery.of(context).size.width *
                                            0.04,
                                    leading: Icon(
                                      hasLocation
                                          ? Icons.edit_location
                                          : Icons.add_location,
                                      color: AppColors.black,
                                    ),
                                    tileColor: AppColors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.03),
                                hasLocation
                                    ? Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .streetName,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                              Text(
                                                location.street!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.01),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .streetNumber,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                              Text(
                                                location.streetNumber!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.01),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .city,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                              Text(
                                                location.city!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.01),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .zipCode,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                              Text(
                                                location.zipCode!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.01),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${AppLocalizations.of(context)!.latitude}: ",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                              Text(
                                                location.latitude!.toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.01),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${AppLocalizations.of(context)!.longitud}: ",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                              Text(
                                                location.longitude!.toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              )
                                            ],
                                          ),
                                        ],
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.10,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.04,
                                vertical:
                                    MediaQuery.of(context).size.width * 0.03),
                            child: Row(
                              children: [
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.01),
                                Icon(
                                  Icons.visibility,
                                  color: Theme.of(context).primaryColor,
                                  size:
                                      MediaQuery.of(context).size.width * 0.06,
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.04),
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!.changeLater,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: hasLocation == false
                                      ? null
                                      : () async {
                                          _pageControllerData.nextPage(
                                            duration: const Duration(
                                                milliseconds: 500),
                                            curve: Curves.ease,
                                          );
                                          registerBrand();
                                        },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: _image != null
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.1),
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(15),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: _image != null
                                        ? Theme.of(context).primaryColorDark
                                        : Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.2),
                                    size: MediaQuery.of(context).size.width *
                                        0.06,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LoadingView(
                          color: Theme.of(context).primaryColor,
                          hasLogo: false,
                          isSmall: true,
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        Text(
                          "${AppLocalizations.of(context)!.creating} ${AppLocalizations.of(context)!.yourBrand.toLowerCase()} ...",
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(fontSize: 30),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    /*
    Scaffold(
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height*0.13,
          title: getTitle(),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: IgnorePointer(
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.transparent,
                      tabs: [
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_outlined, color: tabs[0] ? Theme.of(context).colorScheme.secondary : Colors.grey, size: MediaQuery.of(context).size.width*0.06,)
                              ],
                            ),
                          ),
                        ),
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.info_outlined, color: tabs[1] ? Theme.of(context).colorScheme.secondary : Colors.grey.withOpacity(0.2), size: MediaQuery.of(context).size.width*0.06,)
                              ],
                            ),
                          ),
                        ),
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_on_outlined, color: tabs[2] ? Theme.of(context).colorScheme.secondary : Colors.grey.withOpacity(0.2), size: MediaQuery.of(context).size.width*0.06,)
                              ],
                            ),
                          ),
                        ),
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.calendar_today_outlined, color: tabs[3] ? Theme.of(context).colorScheme.secondary : Colors.grey.withOpacity(0.2), size: MediaQuery.of(context).size.width*0.06,)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    LinearProgressIndicator(
                      value: addEventTabValue,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                )
            ),
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Scaffold(
                      resizeToAvoidBottomInset: true,
                      body: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.width*0.07),
                            child: Form(
                              key: formKeyInfo,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          AppLocalizations.of(context)!.createBrandCoverDescription,
                                          style: Theme.of(context).textTheme.caption,
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height*0.04),
                                  Text(
                                    AppLocalizations.of(context)!.logo,
                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.30,
                                    child: Center(
                                      child: _image == null ?
                                      OutlinedButton(
                                        onPressed: getImage,
                                        child: Column(
                                          //mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.photo_library_outlined,
                                              color: Theme.of(context).primaryColor,
                                              size: MediaQuery.of(context).size.width * 0.08,
                                            ),
                                          ],
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                              color: Theme.of(context).primaryColor,
                                              width: 1.5
                                          ),
                                          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                          elevation: 10,
                                          shape: const CircleBorder(),
                                          padding: EdgeInsets.only(left: MediaQuery.of(context).size.height * 0.11, right: MediaQuery.of(context).size.height * 0.11, top: MediaQuery.of(context).size.height * 0.13),
                                        ),
                                      )
                                          :
                                      GestureDetector(
                                        onTap: getImage,
                                        child: CircularImage(
                                          size: MediaQuery.of(context).size.height * 0.25,
                                          file: _image,
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
                                      controller: nameBrandController,
                                      validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.nameBrandError : null,
                                      style: Theme.of(context).textTheme.headline1,
                                      textAlign: TextAlign.center,
                                      textCapitalization: TextCapitalization.words,
                                      decoration: InputDecoration(
                                        hintStyle: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.grey),
                                        hintText: AppLocalizations.of(context)!.nameBrandError,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height*0.1),
                                ],
                              ),
                            )
                        ),
                      ),
                    ),
                    Scaffold(
                      resizeToAvoidBottomInset: false,
                      body: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.width*0.07),
                            child: Form(
                              key: formKeyMembers,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
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
                                  SizedBox(height: MediaQuery.of(context).size.height*0.04),
                                  Text(
                                    AppLocalizations.of(context)!.description,
                                    style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                  Flexible(
                                    child: TextFormField(
                                        keyboardType: TextInputType.text,
                                        controller: descriptionController,
                                        textCapitalization: TextCapitalization.sentences,
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
                                  SizedBox(height: MediaQuery.of(context).size.height*0.02),
                                ],
                              ),
                            )
                        ),
                      ),
                    ),
                    Scaffold(
                      resizeToAvoidBottomInset: false,
                      body: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.width*0.07),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        AppLocalizations.of(context)!.createBrandLocationDescription,
                                        style: Theme.of(context).textTheme.caption,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height*0.03),
                                Text(
                                  AppLocalizations.of(context)!.createBrandBaseLocation,
                                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                ListTile(
                                  onTap: () async {
                                    // Generate a new token here
                                    final sessionToken = const Uuid().v4();
                                    final language = currentUser.idioma;
                                    final Suggestion? result = await showSearch(
                                      context: context,
                                      delegate: AddressSearch(sessionToken, language!),
                                    );
                                    // We have a result for our locations search
                                    if (result != null) {
                                      location.placeId = result.placeId;
                                      final placeDetails = await LocationPlacesSearch(sessionToken, language).getPlaceDetailFromId(location.placeId!);
                                      // Get the information on Strings
                                      if(placeDetails.street!=null) {
                                        location.street = placeDetails.street!;
                                      } else {
                                        location.street="N/A";
                                      }
                                      if(placeDetails.streetNumber!=null) {
                                        location.streetNumber = placeDetails.streetNumber!;
                                      } else {
                                        location.streetNumber="N/A";
                                      }
                                      if(placeDetails.city!=null) {
                                        location.city = placeDetails.city!;
                                      } else {
                                        location.city="N/A";
                                      }
                                      if(placeDetails.zipCode!=null) {
                                        location.zipCode = placeDetails.zipCode!;
                                      } else {
                                        location.zipCode="N/A";
                                      }
                                      //if(placeDetails.fullAddress!=null) location.description = placeDetails.fullAddress!;
                                      // Build Correct Description
                                      location.description = "${location.street} ${location.streetNumber}, ${location.city}, ${location.zipCode}";
                                      // Get Latitude/Longitude
                                      var temp = await gPlace!.details.get(location.placeId!);
                                      if (temp != null && temp.result != null && mounted) {
                                        detailsResult = temp.result;
                                        location.latitude = detailsResult!.geometry!.location!.lat!;
                                        location.longitude = detailsResult!.geometry!.location!.lng!;
                                      }
                                      setState(() {
                                        hasLocation = true;
                                        errorLocation = false;
                                      });
                                    } else {
                                      setState(() {
                                        hasLocation = false;
                                      });
                                    }
                                  },
                                  title: hasLocation ? Text(
                                    location.description!,
                                    style: Theme.of(context).textTheme.bodyText2,
                                  ) : Text(
                                    AppLocalizations.of(context)!.enterAddressError,
                                    style: Theme.of(context).textTheme.bodyText2,
                                  ),
                                  leading: Icon(
                                    Icons.add_location,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                errorLocation ? Padding(
                                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01),
                                  child: Text(
                                    AppLocalizations.of(context)!.enterAddressError,
                                    style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                  ),
                                ) : Container(),
                                SizedBox(height: MediaQuery.of(context).size.height*0.02),
                                hasLocation ? Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.streetName,
                                          style: Theme.of(context).textTheme.caption,
                                        ),
                                        Text(location.street!, style: Theme.of(context).textTheme.bodyText2,)
                                      ],
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.streetNumber,
                                          style: Theme.of(context).textTheme.caption,
                                        ),
                                        Text(location.streetNumber!, style: Theme.of(context).textTheme.bodyText2,)
                                      ],
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.city,
                                          style: Theme.of(context).textTheme.caption,
                                        ),
                                        Text(location.city!, style: Theme.of(context).textTheme.bodyText2,)
                                      ],
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.zipCode,
                                          style: Theme.of(context).textTheme.caption,
                                        ),
                                        Text(location.zipCode!, style: Theme.of(context).textTheme.bodyText2,)
                                      ],
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${AppLocalizations.of(context)!.latitude}: ",
                                          style: Theme.of(context).textTheme.caption,
                                        ),
                                        Text(location.latitude!.toString(), style: Theme.of(context).textTheme.bodyText2,)
                                      ],
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${AppLocalizations.of(context)!.longitud}: ",
                                          style: Theme.of(context).textTheme.caption,
                                        ),
                                        Text(location.longitude!.toString(), style: Theme.of(context).textTheme.bodyText2,)
                                      ],
                                    ),
                                  ],
                                ) : Container(),
                              ],
                            )
                        ),
                      ),
                    ),
                    Scaffold(
                      resizeToAvoidBottomInset: false,
                      body: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.width*0.07),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                                          borderRadius: const BorderRadius.all(Radius.circular(5)),
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
                                SizedBox(height: MediaQuery.of(context).size.height*0.04),
                                /*
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
                                            onPressed: _breakList.length < breakLimit ? () {
                                              selectSlot(context, 4, true);
                                            } : null,
                                            child: Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(5)),
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
                                            onPressed: _breakList.length < breakLimit ? () {
                                              selectSlot(context, 4, false);
                                            } : null,
                                            child: Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(5)),
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
                                              _breakList.add(_breakStartTime);
                                              _breakList.add(_breakEndTime);
                                            });
                                          }
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon( Icons.add, color: Colors.white, size: 30,),
                                          ],
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          elevation: 3,
                                          shape: CircleBorder(),
                                          padding: EdgeInsets.all(5),
                                        ),
                                      ),
                                    ) : Container(),
                                  ],
                                ),
                                errorBreakTime ? Padding(
                                  padding: EdgeInsets.only(left: 10, right: 10, top: 5.0, bottom: 0),
                                  child: Text(
                                    AppLocalizations.of(context)!.workingHoursError1,
                                    style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                ) : Container(),
                                SizedBox(height: MediaQuery.of(context).size.height*0.01),
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
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
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.all(Radius.circular(5)),
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
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.all(Radius.circular(5)),
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
                                                  Icon( Icons.remove, color: Colors.white, size: 30,),
                                                ],
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                elevation: 3,
                                                shape: CircleBorder(),
                                                padding: EdgeInsets.all(5),
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        AppLocalizations.of(context)!.bookingWindowDescription,
                                        style: Theme.of(context).textTheme.caption,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height*0.02),
                                Text(
                                  AppLocalizations.of(context)!.bookingWindow,
                                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height*0.02),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: GestureDetector(
                                    onTap: () {
                                      selectNumberOfDays();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                                        border: Border.all(color: Theme.of(context).primaryColor, width: 1.0),
                                        color: Colors.transparent,
                                      ),
                                      height: MediaQuery.of(context).size.width*0.1,
                                      width: MediaQuery.of(context).size.width*0.2,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            bookingWindow.toString()+" "+AppLocalizations.of(context)!.days.toLowerCase(),
                                            style: Theme.of(context).textTheme.headline3,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                        ),
                      ),
                    ),
                  ],
                )
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width*0.01),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _selectedIndex != 0 ? Padding(
                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.01, left: MediaQuery.of(context).size.width*0.09),
                child: Container(
                  height: 50,
                  child: FloatingActionButton.extended(
                  shape: const StadiumBorder(),(
                  shape: const StadiumBorder(),(
                    heroTag: "72",
                    onPressed: () {
                      if (_selectedIndex == 1) {
                        mixpanel!.track('register_brand_cover');
                        setState(() {
                          tabs[1] = false;
                        });
                      } else if (_selectedIndex == 2) {
                        mixpanel!.track('register_brand_info');
                        setState(() {
                          tabs[2] = false;
                        });
                      } else if (_selectedIndex == 3) {
                        mixpanel!.track('register_brand_location');
                        setState(() {
                          tabs[3] = false;
                        });
                      }
                      _tabController!.animateTo(_selectedIndex -= 1);
                      setState(() {
                        addEventTabValue -= 0.25;
                      });
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    icon: Container(),
                    label: Text(
                      AppLocalizations.of(context)!.back,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).primaryColorDark),),
                  ),
                ),
              ) :  Padding(
                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.01, left: MediaQuery.of(context).size.width*0.09),
                child: Container(
                  height: 50,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.01),
                child: Container(
                  height: 50,
                  child: FloatingActionButton.extended(
                  shape: const StadiumBorder(),(
                    heroTag: "27",
                    onPressed: () async {
                      if (_selectedIndex == 0) {
                        if (validatePortada()) {
                          _tabController!.animateTo(_selectedIndex += 1);
                          setState(() {
                            errorImage = false;
                            addEventTabValue += 0.25;
                            tabs[1] = true;
                          });
                          mixpanel!.track('register_brand_info');
                        }
                      } else if (_selectedIndex == 1) {
                        if (validateInfo()) {
                          _tabController!.animateTo(_selectedIndex += 1);
                          setState(() {
                            addEventTabValue += 0.25;
                            tabs[2] = true;
                          });
                          mixpanel!.track('register_brand_location');
                        }
                      } else if (_selectedIndex == 2) {
                        if (validateLocation()) {
                          _tabController!.animateTo(_selectedIndex += 1);
                          setState(() {
                            errorLocation = false;
                            addEventTabValue += 0.25;
                            tabs[3] = true;
                          });
                          mixpanel!.track('register_brand_workday');
                        }
                      } else if (_selectedIndex == 3) {
                        if (validateTime()) {
                          setState(() {
                            isLoading = true;
                          });
                          await registerBrand();
                        }
                      }
                    },
                    backgroundColor: _selectedIndex == 3 ? Colors.green : Theme.of(context).colorScheme.secondary,
                    icon: Container(),
                    label: Text(
                      _selectedIndex == 3 ? AppLocalizations.of(context)!.createBrand : AppLocalizations.of(context)!.next,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.white),),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
     */
  }
}
