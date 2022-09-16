import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/LibraryModels/lColor.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Condition.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Bonos/BonoObject.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Utils/MediaQuery/MediaQuery.dart';
import 'package:mamba_castelldefels/Globals/Widgets/TopSnackBar/TopSnackBar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../../../../Data/LibraryModels/lDegradate.dart';
import '../../../../../Globals/Utils/Bonos/BonosUtils.dart';
import '../../../../../Globals/Widgets/Components/Images/RectangularImage.dart';
import '../../03-Com/007-Contenido/SelectBrandImages.dart';

class AddEditBono extends StatefulWidget {
  Brand brand;
  Bono bono;
  bool edit;

  AddEditBono(
      {Key? key, required this.brand, required this.bono, required this.edit})
      : super(key: key);

  @override
  _AddEditBonoState createState() => _AddEditBonoState();
}

class _AddEditBonoState extends State<AddEditBono>
    with SingleTickerProviderStateMixin {
  // Acceso a Base de Datos
  var _brandDataService = new BrandDataService();

  //Utils MediaQuery
  var umq = new MediaQueryUtils();

  double _currentSliderValue = 100;

  // Event Image
  bool isRandomImage = true;
  bool imageError = true;
  String? eventImageUrl;

  bool bonoImage = false;
  bool mostraBono = false;

  var colorSelected = 0;
  var colorSelectedDeg = 0;

  //TopSnackBar
  var _topsnackbar = new TopSnackBar();

  var _lColor = new lColor();
  var _lDegradate = new lDegradate();

  // Boolean Loading
  bool isLoading = false;
  bool openBono = false;

  TextEditingController startDateController = TextEditingController();

  //Utils bonos
  final _bonosUtils = BonosUtils();

  // Boolean days bono selected
  List<bool> isSelectedDays = [true, false, false, false];

  // Boolean isUpdated
  bool isUpdated = false;

  // Tab Controller
  double addBonosTabValue = 0.25;
  double updateEventTabValue = 0.50;
  TabController? _tabController;
  int _selectedIndex = 0;
  List<bool> tabs = [true, false, false, false];

  // Title Controller
  var titleController = TextEditingController();
  String? titleString;

  var descriptionController = TextEditingController();
  var clasesController = TextEditingController();
  var priceController = TextEditingController();
  var expirationController = TextEditingController();
  var weeklyController = TextEditingController();
  var monthlyController = TextEditingController();
  var daysSelectorController = TextEditingController();

  // Description Controller
  String? descriptionString;
  final formKeyInfo = GlobalKey<FormState>();
  final formKePrice = GlobalKey<FormState>();

  // Duration
  TextEditingController durationController = TextEditingController();

  final values = <bool?>[false, false, false, false, false, false, false];
  int _value = 1;
  String colorBono = " ";
  String colorBono1 = " ";


  Widget returnBono(Bono _bono) {
    return  BonoObject(bono: _bono, view: true, brand: widget.brand, clientView: true);

  }


  Bono bono = new Bono(
    color: "0",
    isActive: true,
    classes: 0,
    opacity: 1,
    imageUrl: '',
    isDegradate: false,
    id: 'newBono',
  );

  Condition condition = new Condition(
    expirationTime: 30,
    infiniteSessions: false,
  );

  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';

  List<Color> colors = [];
  List<Color> colorsDeg = [];

  @override
  initState() {
    isLoading = false;
    _tabController = TabController(length: 4, vsync: this);
    var color;
    var degradate1, degradate2;
    if(widget.edit == true) {
      bono.id = widget.bono.id;
      bono.title = widget.bono.title;
      bono.description = widget.bono.description;
      bono.price = widget.bono.price;
      bono.classes = widget.bono.classes;
      bono.isActive = widget.bono.isActive;
      bono.compras = widget.bono.compras;
      bono.color = widget.bono.color;
      bono.imageUrl = widget.bono.imageUrl;
      bono.isDegradate = widget.bono.isDegradate;
      bono.opacity = widget.bono.opacity;

    }

    if(widget.edit == true) {
      getCondition();
    }
    for (int i = 0; i < currentColors.length; ++i) {
      color = Color(int.parse(currentColors[i].hexa!));
      colors.add(color);
      print(color);
    }
    for (int i = 0; i < currentDegradates.length; ++i) {
      degradate1 = Color(int.parse(currentDegradates[i].hexa1!));
      degradate2 = Color(int.parse(currentDegradates[i].hexa2!));
      colorsDeg.add(degradate1);
      colorsDeg.add(degradate2);
    }
    colorSelected = colors[0].value;
    if(widget.edit == true) {
      _currentSliderValue = bono.opacity! * 100;
      if(bono.imageUrl == '') {
        bonoImage = false;
      }
      else {
        eventImageUrl = bono.imageUrl;
        bonoImage = true;
      }
      if(bono.isDegradate!)
        colorSelected = colorsDeg[int.parse(bono.color!)].value;
      }
      else {
        colorSelected = colors[int.parse(bono.color!)].value;
      }

    }

    void getCondition() async
    {
      condition =  await _brandDataService.getConditionInfo(widget.brand.id!, bono.id!);
      condition.infiniteSessions = false;
      condition.cancelTime = 6.5;
      isSelectedDays[0] = false;
      isSelectedDays[1] = false;
      isSelectedDays[2] = false;
      isSelectedDays[3] = false;
      if(condition.expirationTime == 30) {
        isSelectedDays[0] = true;
      }
      else if(condition.expirationTime == 60) {
        isSelectedDays[1] = true;
      }
      else if(condition.expirationTime == 90) {
        isSelectedDays[2] = true;
      }
      else {
        isSelectedDays[3] = true;
        daysSelectorController.text = condition.expirationTime.toString();

      }

    }




  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            appBar: AppBar(
              toolbarHeight: MediaQuery.of(context).size.height * 0.14,
              title: Text(
                AppLocalizations.of(context)!.bonos,
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: MediaQuery.of(context).size.width * 0.06,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(0),
                child: IgnorePointer(
                    child: Column(
                  children: [
                    Padding(
                        padding: EdgeInsets.symmetric(
                            vertical:
                                MediaQuery.of(context).size.height * 0.01),
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.01),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.015,
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            child: LinearProgressIndicator(
                              value: addBonosTabValue,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.secondary),
                              backgroundColor: Colors.grey.shade100,
                            ),
                          ),
                        )),
                  ],
                )),
              ),
            ),
            body: LoadingView(),
          )
        : Scaffold(
            appBar: AppBar(
              toolbarHeight: MediaQuery.of(context).size.height * 0.10,
              title: Text(
                widget.edit? AppLocalizations.of(context)!.editBono : AppLocalizations.of(context)!.createBono,
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: MediaQuery.of(context).size.width * 0.06,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(0),
                child: IgnorePointer(
                    child: LinearProgressIndicator(
                    value: addBonosTabValue,
                    valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary),
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    ),
                ),
              ),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            resizeToAvoidBottomInset: true,
            body: Column(
              children: [
                Expanded(
                    child: TabBarView(
                  controller: _tabController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    informationPage(),
                    pricePage(),
                    stylePage(),
                    conditionsPage(),
                  ],
                )),
              ],
            ),
            floatingActionButton: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.width * 0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _selectedIndex != 0
                      ? Padding(
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.01,
                              left: MediaQuery.of(context).size.width * 0.09),
                          child: Container(
                            height: 50,
                            child: FloatingActionButton.extended(
                              heroTag: "4",
                              onPressed: () {
                                if (_selectedIndex == 1) {
                                  setState(() {
                                    tabs[1] = false;
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  });
                                } else if (_selectedIndex == 2) {
                                  setState(() {
                                    tabs[2] = false;
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  });
                                } else if (_selectedIndex == 3) {
                                  setState(() {
                                    tabs[3] = false;
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  });
                                }
                                _tabController!.animateTo(_selectedIndex -= 1);
                                setState(() {
                                  addBonosTabValue -= 0.25;
                                });
                              },
                              backgroundColor: Theme.of(context).primaryColor,
                              icon: Container(),
                              label: Text(
                                AppLocalizations.of(context)!.back,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                        color:
                                            Theme.of(context).primaryColorDark),
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.01,
                              left: MediaQuery.of(context).size.width * 0.09),
                          child: Container(
                            height: 50,
                          ),
                        ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.01),
                    child: Container(
                      height: 50,
                      child: FloatingActionButton.extended(
                        heroTag: "5",
                        onPressed: () {
                          if (_selectedIndex == 0) {
                            if (formKeyInfo.currentState!.validate()) {
                              _tabController!.animateTo(_selectedIndex += 1);
                              setState(() {
                                addBonosTabValue += 0.25;
                                tabs[1] = true;
                                FocusManager.instance.primaryFocus?.unfocus();
                              });
                            }
                          } else if (_selectedIndex == 1) {
                            if (formKePrice.currentState!.validate()) {
                              setState(() {
                                mostraBono = true;
                                FocusManager.instance.primaryFocus?.unfocus();
                              });
                              Timer(Duration(milliseconds: 100), test);
                              addBonosTabValue += 0.25;
                              tabs[2] = true;

                            }
                          } else if (_selectedIndex == 2) {
                            _tabController!.animateTo(_selectedIndex += 1);
                            setState(() {
                              addBonosTabValue += 0.25;
                              tabs[3] = true;
                              FocusManager.instance.primaryFocus?.unfocus();
                            });
                          }  else
                            _addBono();
                        },
                        backgroundColor: _selectedIndex == 3
                            ? Colors.green
                            : Theme.of(context).colorScheme.secondary,
                        icon: Container(),
                        label: Text(
                          _selectedIndex == 3
                              ? widget.edit? AppLocalizations.of(context)!.editBono : AppLocalizations.of(context)!.createBono
                              : AppLocalizations.of(context)!.next,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(color: AppColors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget informationPage() {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
        children: [
          Form(
            key: formKeyInfo,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    optionTextWrite(
                        TextInputType.text,
                        AppLocalizations.of(context)!.nameBono,
                        AppLocalizations.of(context)!.titleHint,
                        AppLocalizations.of(context)!.titleError,
                        widget.edit ? false : true,
                        titleController,
                        false,
                        'title'),
                    optionTextWrite(
                        TextInputType.multiline,
                        AppLocalizations.of(context)!.descriptionBono,
                        AppLocalizations.of(context)!.descriptionError,
                        AppLocalizations.of(context)!.descriptionError,
                        true,
                        descriptionController,
                        false,
                        'desc'),
                    optionTextWrite(
                        TextInputType.multiline,
                        AppLocalizations.of(context)!.activeBono,
                        AppLocalizations.of(context)!.descriptionError,
                        AppLocalizations.of(context)!.descriptionError,
                        true,
                        descriptionController,
                        true,
                        bono.isActive),
                    /*
                    Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.01),
                        child: new Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            new Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                new Text(
                                  'Bono actiu',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            new Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                new Checkbox(value: bono.isActive, onChanged:  setBonoActivation, checkColor: Theme.of(context).primaryColor, activeColor: Styles.mainColor,)
                              ],
                            ),
                          ],
                        )),
                    Padding(
                        padding: EdgeInsets.only(top: umq.height(context, 0.05)),
                        child: new Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            new Flexible(
                              child: Container(
                                height: MediaQuery.of(context).size.width * 0.1,
                                width: MediaQuery.of(context).size.width * 0.30,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: new ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Color(int.parse(_lColor.getlColor(bono.color!).hexa!))),
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Escull un color'),
                                            content: SingleChildScrollView(
                                              child: BlockPicker(
                                                availableColors: colors,
                                                pickerColor: Color(int.parse(_lColor.getlColor(bono.color!).hexa!)),
                                                //default color
                                                onColorChanged: (Color color) {
                                                  //on color picked

                                                  colorBono = getColorFromColorCode(color.toString());
                                                },
                                              ),
                                            ),
                                            actions: <Widget>[
                                              ElevatedButton(
                                                child: const Text('Fet'),
                                                onPressed: () {
                                                  setState(() {
                                                    bono.color = _lColor.getIdFromHexa(colorBono.toUpperCase());
                                                  });
                                                  Navigator.of(context)
                                                      .pop(); //dismiss the color picker
                                                },
                                              ),
                                            ],
                                          );
                                        });
                                  },
                                  child: Text("Escull un color"),
                                ),
                              ),
                            ),
                          ],
                        )),

                     */
                  ]),
            ),
          ),
        ],
      )),
      resizeToAvoidBottomInset: true,
    );
  }

  Widget stylePage() {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ClipRect(
              child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.09,
                            vertical: MediaQuery.of(context).size.height * 0.03),
                        child: Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.00),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Flexible(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        AppLocalizations.of(context)!.styleBono,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1
                                            ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                      ),
                      mostraBono == true
                          ? returnBono(bono)
                          : Container(),
                    ]),

            ),
          ),
          Expanded(
            child: SingleChildScrollView(
                child: Column(
              children: [
                Form(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.00),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.height * 0.01),
                              child: Container(
                                margin: EdgeInsets.only(
                                    top:
                                        MediaQuery.of(context).size.height * 0.01),
                                width: MediaQuery.of(context).size.width * 0.85,
                                height: MediaQuery.of(context).size.height * 0.015,
                                child: Slider(
                                  value: _currentSliderValue,
                                  max: 100,
                                  divisions: 9,
                                  min: 10,
                                  label: _currentSliderValue.round().toString(),
                                  activeColor: Colors.white,
                                  onChanged: (double value) {
                                    setState(() {
                                      _currentSliderValue = value;
                                      bono.opacity = value/100;
                                    });
                                  },
                                ),
                              )),
                          Padding(
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.09,
                                right: MediaQuery.of(context).size.width * 0.09,
                                bottom: MediaQuery.of(context).size.height * 0.03),
                            child: Padding(
                                padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.height * 0.00),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Flexible(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            AppLocalizations.of(context)!.photo,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline1
                                                ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 25),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Checkbox(
                                          value: bonoImage,
                                          onChanged: setImage,
                                          checkColor: Theme.of(context).primaryColor,
                                          activeColor: Styles.mainColor,
                                        )
                                      ],
                                    ),
                                  ],
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.09,
                                right: MediaQuery.of(context).size.width * 0.09,
                                bottom: MediaQuery.of(context).size.height * 0.005),
                            child: GestureDetector(
                              onTap: () async {
                                var result = await showModalBottomSheet<String?>(
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
                                      heightFactor: 0.85,
                                      child: SelectBrandImages(
                                        brandId: currentBrand.id!,
                                      ),
                                    );
                                  },
                                );
                                if (result != null) {
                                  eventImageUrl = result;
                                  bonoImage = true;
                                  if (bonoImage) {
                                    bono.imageUrl = result;
                                  } else {
                                    bono.imageUrl = '';
                                  }
                                  setState(() {});
                                }
                              },
                              child: eventImageUrl != null
                                  ? RectangularImage(
                                      height:
                                          MediaQuery.of(context).size.height * 0.18,
                                      width: MediaQuery.of(context).size.height * 0.9,
                                      borderRadius: 10,
                                      image: eventImageUrl,
                                    )
                                  : DottedBorder(
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(10),
                                      dashPattern: const [10, 10],
                                      color: imageError
                                          ? AppColors.grey
                                          : AppColors.grey.withOpacity(0.5),
                                      strokeWidth: 2,
                                      child: Container(
                                          height: MediaQuery.of(context).size.height *
                                              0.15,
                                          width: MediaQuery.of(context).size.height *
                                              0.9,
                                          color: Colors.transparent,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.add,
                                                      color: imageError
                                                          ? AppColors.grey
                                                          : AppColors.grey
                                                              .withOpacity(0.5),
                                                      size: MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.1),
                                                  Text(
                                                    AppLocalizations.of(context)!
                                                            .select +
                                                        " " +
                                                        AppLocalizations.of(context)!
                                                            .photo
                                                            .toLowerCase(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .caption
                                                        ?.copyWith(
                                                          color: imageError
                                                              ? AppColors.grey
                                                              : AppColors.grey
                                                                  .withOpacity(0.5),
                                                        ),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ))),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: MediaQuery.of(context).size.width * 0.09,
                                vertical: MediaQuery.of(context).size.height * 0.03),
                            child: Padding(
                                padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.height * 0.00),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Flexible(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            AppLocalizations.of(context)!.colorSolid,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline1
                                                ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 25),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                right:
                                MediaQuery.of(context).size.width * 0.025,
                                left:
                                MediaQuery.of(context).size.width * 0.0),
                            child:  Container(
                                alignment: Alignment.centerLeft,
                                height: MediaQuery.of(context).size.height*0.05,
                                width: MediaQuery.of(context).size.width*0.80,
                                child:
                                ListView.builder(
                                    shrinkWrap: true,
                                    //physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: colors.length,
                                    itemBuilder: (context, int index) {
                                      var lcolor = colors[index];
                                      return GestureDetector(
                                        onTap: () {
                                          bono.isDegradate = false;
                                          colorSelected = lcolor.value;
                                          colorSelectedDeg = 0;
                                          colorBono = getColorFromColorCode(lcolor.toString());
                                          bono.color = _lColor.getIdFromHexa(colorBono.toUpperCase());
                                          setState(() {

                                          });
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              right:
                                                  MediaQuery.of(context).size.width * 0.025,
                                              left:
                                                  MediaQuery.of(context).size.width * 0.00),
                                          child: Container(
                                            height: MediaQuery.of(context).size.width * 0.1,
                                            width: MediaQuery.of(context).size.width * 0.1,
                                            decoration: BoxDecoration(
                                                color: Color(lcolor.value), //0x00D2B19C
                                                border: colorSelected == lcolor.value? Border.all(
                                                  color:  Theme.of(context).primaryColor,
                                                ) : Border.all(
                                                    color:  Theme.of(context).primaryColorDark,
                                                ),
                                                borderRadius: const BorderRadius.all(
                                                    const Radius.circular(20))),
                                          ),
                                        ),
                                      );
                                    }),
                              ),

                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: MediaQuery.of(context).size.width * 0.09,
                                vertical: MediaQuery.of(context).size.height * 0.03),
                            child: Padding(
                                padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.height * 0.00),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Flexible(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            AppLocalizations.of(context)!
                                                .degradateSolid,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline1
                                                ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 25),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                right:
                                MediaQuery.of(context).size.width * 0.025,
                                left:
                                MediaQuery.of(context).size.width * 0.0),
                            child:  Container(
                              alignment: Alignment.centerLeft,
                              height: MediaQuery.of(context).size.height*0.05,
                              width: MediaQuery.of(context).size.width*0.80,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  //physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: colorsDeg.length,
                                  itemBuilder: (context, int index) {
                                    if(index == 0 || index%2 == 0) {
                                      var ldegradate1 = colorsDeg[index];
                                      var ldegradate2 = colorsDeg[index + 1];
                                      return GestureDetector(
                                        onTap: () {
                                          bono.isDegradate = true;
                                          colorSelectedDeg = ldegradate1.value;
                                          colorSelected = 0;
                                          colorBono = getColorFromColorCode(
                                              ldegradate1.toString());
                                          colorBono1 = getColorFromColorCode(
                                              ldegradate2.toString());
                                          bono.color = _lDegradate.getIdFromHexa(
                                              colorBono.toUpperCase(), colorBono1.toUpperCase());
                                          print(bono.color);
                                          //bono.color = _lColor.getIdFromHexa(lcolor.value.toString());
                                          setState(() {

                                          });
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              right:
                                              MediaQuery
                                                  .of(context)
                                                  .size
                                                  .width * 0.025,
                                              left:
                                              MediaQuery
                                                  .of(context)
                                                  .size
                                                  .width * 0.00),
                                          child: Container(
                                            height: MediaQuery
                                                .of(context)
                                                .size
                                                .width * 0.1,
                                            width: MediaQuery
                                                .of(context)
                                                .size
                                                .width * 0.1,
                                            decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topRight,
                                                  end: Alignment.bottomLeft,
                                                  colors: [
                                                    Color(ldegradate1.value),
                                                    Color(ldegradate2.value),
                                                  ],
                                                ),
                                                border: colorSelectedDeg ==
                                                    ldegradate1.value ? Border.all(
                                                  color: Theme
                                                      .of(context)
                                                      .primaryColor,
                                                ) : Border.all(
                                                  color: Theme
                                                      .of(context)
                                                      .primaryColorDark,
                                                ),
                                                borderRadius: const BorderRadius.all(
                                                    const Radius.circular(20))),
                                          ),
                                        ),
                                      );
                                    }
                                    else return Container();
                                  }),
                            ),

                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: MediaQuery.of(context).size.width * 0.09,
                                vertical: MediaQuery.of(context).size.height * 0.03),
                            child: Padding(
                                padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.height * 0.00),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Flexible(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            AppLocalizations.of(context)!.metalized,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline1
                                                ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 25),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ]),
                  ),
                ),
              ],
            )),
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  Widget pricePage() {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
        children: [
          Form(
            key: formKePrice,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    optionTextWrite(
                        TextInputType.number,
                        AppLocalizations.of(context)!.sesionsBono,
                        0.toString(),
                        'Añade las sesiones porfavor',
                        widget.edit ? false : true,
                        clasesController,
                        false,
                        'ses'),
                    optionTextWrite(
                        TextInputType.number,
                        AppLocalizations.of(context)!.priceBono,
                        0.toString(),
                        'Añade el precio porfavor',
                        widget.edit ? false : true,
                        priceController,
                        false,
                        'price'),
                  ]),
            ),
          ),
        ],
      )),
      resizeToAvoidBottomInset: true,
    );
  }

  Future<void> selectSlot(ctx, type) {
    // Initial Vars
    var startDate = DateTime.now();
    var title;
    var widgetPicker;
    // Different types of pickers
    Widget dateTimePicker = CupertinoTheme(
      data: CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
            dateTimePickerTextStyle: Theme.of(context).textTheme.bodyText1,
          )
      ),
      child: Column(
        children: [
          CupertinoTimerPicker(
            mode: CupertinoTimerPickerMode.hm,
            onTimerDurationChanged: (value) {

            },
          ),
        ],
      ),
    );
    if (type == 0) {
      title = AppLocalizations.of(context)!.selectDateOfBirth;
      widgetPicker = dateTimePicker;
    }
    showCupertinoModalPopup(
        context: ctx,
        builder: (_) => Material(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height*0.40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        child: Text(title,
                          style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,)
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.01),
                    child: widgetPicker,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: TextButton(
                          child: Text(AppLocalizations.of(context)!.entendido,
                              style: Theme.of(context).textTheme.headline3?.copyWith(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          }
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.02),
              ],
            ),
          ),
        )
    );
    return Future.value("");
  }

  Widget conditionsPage() {

    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
        children: [
          Form(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    optionConditionsWrite( TextInputType.text,
                  'Dias para expirar',
                  AppLocalizations.of(context)!.titleHint,
                  AppLocalizations.of(context)!.titleError,
                  widget.edit ? false : true,
                  titleController,
                  'exp'),
                    optionConditionsWrite( TextInputType.number,
                        'Maximo numero de sesiones por semana',
                        AppLocalizations.of(context)!.titleHint,
                        AppLocalizations.of(context)!.titleError,
                        true,
                        titleController,
                        'maxw'),
                    optionConditionsWrite( TextInputType.number,
                        'Maximo numero de sesiones por mes',
                        AppLocalizations.of(context)!.titleHint,
                        AppLocalizations.of(context)!.titleError,
                        true,
                        titleController,
                        'maxm'),
                    optionConditionsWrite( TextInputType.number,
                        'Classes infinitas',
                        AppLocalizations.of(context)!.titleHint,
                        AppLocalizations.of(context)!.titleError,
                        true,
                        titleController,
                        'inf'),



                    Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.03),
                        child: new Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            new Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                new Text(
                                  'Maximo numero de classes por mes',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        )),
                    Padding(
                        padding: EdgeInsets.only(top: 0),
                        child: new Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            new Flexible(
                              child: new TextFormField(
                                //controller: monthlyController,
                                keyboardType: TextInputType.number,
                                initialValue: bono.classes.toString(),
                                onChanged: (val) {
                                  setState(() {
                                    condition.monthlySessions = int.parse(val);
                                  });
                                },
                                style: Theme.of(context).textTheme.bodyText2,
                                decoration: InputDecoration(
                                  hintStyle:
                                      Theme.of(context).textTheme.caption,
                                  hintText:
                                      AppLocalizations.of(context)!.titleHint,
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                ),
                                enabled: true,
                              ),
                            ),
                          ],
                        )),
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.01),
                      child: GestureDetector(
                          onTap: () {
                            selectSlot(context, 0);
                            FocusScopeNode currentFocus = FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                               Flexible(
                                child: TextFormField(
                                  controller: startDateController,
                                  readOnly: true,
                                  enabled: false,
                                  style:  Theme.of(context).textTheme.headline1!.copyWith(color: Theme.of(context).primaryColor, fontSize: 18, fontWeight: FontWeight.w300),
                                  decoration: const InputDecoration(
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
                    ),
                  ]),
            ),
          ),
        ],
      )),
      resizeToAvoidBottomInset: true,
    );
  }

  bool validateDateAndTime(DateTime startTime, double duration) {
    // Calculating the Time to check
    var hour = duration.toString().split(".")[0];
    var min = duration.toStringAsFixed(2).split(".")[1];
    var endTime = startTime
        .add(Duration(hours: int.parse(hour), minutes: int.parse(min)));
    // Computing the workshift
    var workshift1 = currentBrand.workShift[0];
    var workshift2 = currentBrand.workShift[1];
    var startWorkHour = workshift1.toStringAsFixed(2).split(".")[0];
    var startWorkMin = workshift1.toStringAsFixed(2).split(".")[1];
    var endWorkHour = workshift2.toStringAsFixed(2).split(".")[0];
    var endWorkMin = workshift2.toStringAsFixed(2).split(".")[1];
    var startWorkDay = DateTime(startTime.year, startTime.month, startTime.day,
        int.parse(startWorkHour), int.parse(startWorkMin));
    var endWorkDay = DateTime(startTime.year, startTime.month, startTime.day,
        int.parse(endWorkHour), int.parse(endWorkMin));
    if ( // Can´t create event in the past
        startTime.isBefore(DateTime.now()) ||
            startTime.isAtSameMomentAs(DateTime.now()) ||
            endTime.isBefore(DateTime.now()) ||
            endTime.isAtSameMomentAs(DateTime.now())
            // Can´t create event outside of working hours
            ||
            startTime.isBefore(startWorkDay) ||
            endTime.isBefore(startWorkDay) ||
            startTime.isAfter(endWorkDay) ||
            endTime.isAfter(endWorkDay)) {
      return false;
    } else {
      // Can´t create event in break period of working hours
      for (var i = 2; i < currentBrand.workShift.length; i += 2) {
        // Breaks
        var break1 = currentBrand.workShift[i];
        var break2 = currentBrand.workShift[i + 1];
        // Take the minute and the hour
        var startBreakHour = break1.toStringAsFixed(2).split(".")[0];
        var startBreakMin = break1.toStringAsFixed(2).split(".")[1];
        var endBreakHour = break2.toStringAsFixed(2).split(".")[0];
        var endBreakMin = break2.toStringAsFixed(2).split(".")[1];
        // Date Time formatted
        var startBreak = DateTime(startTime.year, startTime.month,
            startTime.day, int.parse(startBreakHour), int.parse(startBreakMin));
        var endBreak = DateTime(startTime.year, startTime.month, startTime.day,
            int.parse(endBreakHour), int.parse(endBreakMin));
        // Condition check
        if (((startTime.isAfter(startBreak) ||
                    startTime.isAtSameMomentAs(startBreak)) &&
                (startTime.isBefore(endBreak))) ||
            ((endTime.isAfter(startBreak)) &&
                (endTime.isBefore(endBreak) ||
                    endTime.isAtSameMomentAs(endBreak)))) {
          return false;
        }
      }
      return true;
    }
  }

  String getColorFromColorCode(String code) {
    return code.substring(6, 16);
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    /// The argument value will return the changed date as [DateTime] when the
    /// widget [SfDateRangeSelectionMode] set as single.
    ///
    /// The argument value will return the changed dates as [List<DateTime>]
    /// when the widget [SfDateRangeSelectionMode] set as multiple.
    ///
    /// The argument value will return the changed range as [PickerDateRange]
    /// when the widget [SfDateRangeSelectionMode] set as range.
    ///
    /// The argument value will return the changed ranges as
    /// [List<PickerDateRange] when the widget [SfDateRangeSelectionMode] set as
    /// multi range.
  }

  void setBonoActivation(bool? activation) {
    setState(() {
      bono.isActive = activation;
    });
  }

  void setInfinitClasses(bool? infinit) {
    setState(() {
      condition.infiniteSessions = infinit;
    });
  }

  void setImage(bool? image) {
    setState(() {
      bonoImage = image!;
      if (image == false) {
        bono.imageUrl = '';
      } else {
        bono.imageUrl = eventImageUrl;
      }
    });
  }

  Widget daysSelectoWidget(int index, String numberDays, bool customized) {
    return GestureDetector(
      onTap: () {
        setState(() {
          condition.expirationTime = int.parse(numberDays);
          isSelectedDays[0] = false;
          isSelectedDays[1] = false;
          isSelectedDays[2] = false;
          isSelectedDays[3] = false;
          isSelectedDays[index] = true;
        });
      },
      child: Container(
        height: MediaQuery.of(context).size.width * 0.15,
        width: MediaQuery.of(context).size.width * 0.2,
        decoration: BoxDecoration(
            border: Border.all(
              color: isSelectedDays[index] == true
                  ? Styles.mainColor
                  : Theme.of(context).primaryColor,
            ),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Align(
          alignment: Alignment.center,
          //padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06, vertical: MediaQuery.of(context).size.width * 0.02),
          child: customized
              ? new TextFormField(
                  controller: daysSelectorController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  //initialValue: isSelectedDays[3]? condition.expirationTime.toString() : null,
                  onTap: () {
                    setState(() {
                      isSelectedDays[0] = false;
                      isSelectedDays[1] = false;
                      isSelectedDays[2] = false;
                      isSelectedDays[3] = false;
                      isSelectedDays[index] = true;
                    });
                  },
                  style: Theme.of(context).textTheme.bodyText2,
                  decoration: InputDecoration(
                    hintStyle: Theme.of(context).textTheme.caption,
                    hintText: 'Personaliza',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                  enabled: true,
                )
              : Text(
                  numberDays,
                  style: Theme.of(context).textTheme.button,
                ),
        ),
      ),
    );
  }

  Future<void> _addBono() async {
    if (isSelectedDays[3] == true) {
      if (daysSelectorController.text.isNotEmpty) {
        condition.expirationTime = int.parse(daysSelectorController.text);
        /*setState(() {
          isLoading = true;
        });
        _brandDataService.addBonoToBrand(widget.brand.id!, bono, condition);
        Navigator.pop(context);*/
      } else {
        _topsnackbar.topsnackbar(
            context, 'Los dias para expirar deben tener un valor', Colors.red);
      }
    } else {
      if (isSelectedDays[0]) {
        condition.expirationTime = 30;
      }
      if (isSelectedDays[1]) {
        condition.expirationTime = 60;
      }
      if (isSelectedDays[2]) {
        condition.expirationTime = 90;
      }
    }

      if(widget.edit == false )_brandDataService.addBonoToBrand(widget.brand.id!, bono, condition);
      else _brandDataService.updateBono(widget.brand.id!, bono, condition);
      Navigator.pop(context);
    }


  Widget optionTextWrite(
      var keyboard,
      var titleText,
      var hintText,
      var errorText,
      bool editable,
      var controller,
      bool checkBox,
      var variable) {
    return Column(
      children: [
        Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                !checkBox? Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        titleText,
                        style: Theme.of(context).textTheme.headline1?.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                    ],
                  ),
                ) :  !widget.edit? Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        titleText,
                        style: Theme.of(context).textTheme.headline1?.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                    ],
                  ),
                ) : Container(),
                checkBox && widget.edit != true
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Checkbox(
                            value: bono.isActive,
                            onChanged: setBonoActivation,
                            checkColor: Theme.of(context).primaryColor,
                            activeColor: Styles.mainColor,
                          )
                        ],
                      )
                    : Container(),
              ],
            )),
        !checkBox? Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.00),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Flexible(
                  child: TextFormField(
                    keyboardType: keyboard,
                    initialValue: widget.edit == true? variable == 'title'? bono.title : variable == 'desc'? bono.description : variable == 'ses'? bono.classes.toString() : variable == 'price'? bono.price.toString() : null : null,
                    maxLines: variable == 'desc'? 5 : null,
                    minLines: 1,
                    maxLength: variable == 'title'? 20 : variable == 'desc'? 100 : null,
                    controller:  widget.edit == true? null : controller,
                    validator: (val) => val!.isEmpty ? errorText : null,
                    onChanged: (val) {
                      setState(() {
                        if (variable == 'title') {
                          bono.title = val;
                        } else if (variable == 'desc') {
                          bono.description = val;
                        } else if (variable == 'ses') {
                          bono.classes = int.parse(val);
                        } else if (variable == 'price') {
                          bono.price = double.parse(val);
                        }
                      });
                    },
                    style: Theme.of(context).textTheme.bodyText1,
                    decoration: InputDecoration(
                      hintStyle: Theme.of(context).textTheme.caption,
                      hintText: hintText,
                      //border: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    enabled: editable,
                  ),
                ),
              ],
            )) : Container()

      ],
    );
  }

  Widget optionConditionsWrite(
      var keyboard,
      var titleText,
      var hintText,
      var errorText,
      bool editable,
      var controller,
      var variable) {
    return Column(
      children: [
        Padding(
            padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                 Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        titleText,
                        style: Theme.of(context).textTheme.headline1?.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                    ],
                  ),
                ),
                variable == 'inf'
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Checkbox(
                      value: condition.infiniteSessions,
                      onChanged: setInfinitClasses,
                      checkColor: Theme.of(context).primaryColor,
                      activeColor: Styles.mainColor,
                    )
                  ],
                )
                    : Container(),
              ],
            )),
          variable == 'exp'? Padding(
              padding:
              EdgeInsets.only(top: umq.height(context, 0.02)),
              child: new Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  daysSelectoWidget(0, '30', false),
                  SizedBox(
                      width:
                      MediaQuery.of(context).size.width * 0.02),
                  daysSelectoWidget(1, '60', false),
                  SizedBox(
                      width:
                      MediaQuery.of(context).size.width * 0.02),
                  daysSelectoWidget(2, '90', false),
                  SizedBox(
                      width:
                      MediaQuery.of(context).size.width * 0.02),
                  daysSelectoWidget(3, '30', true),
                ],
              )) : variable == 'maxw' || variable == 'maxm'?
          Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.00),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Flexible(
                    child: TextFormField(
                      keyboardType: keyboard,
                      initialValue: widget.edit ? variable == 'maxw'? condition.weeklySessions.toString() : condition.monthlySessions.toString() : bono.classes!.toString(),
                      maxLines: null,
                      minLines: 1,
                      maxLength: variable == 'title'? 20 : variable == 'desc'? 100 : null,
                      //controller:  widget.edit == true ? null : controller,
                      validator: (val) => val!.isEmpty ? errorText : null,
                      onChanged: (val) {
                        setState(() {
                          if (variable == 'maxw') {
                            condition.weeklySessions = int.parse(val);
                          } else if (variable == 'maxm') {
                            condition.monthlySessions = int.parse(val);
                          } else if (variable == 'ses') {
                            bono.classes = int.parse(val);
                          } else if (variable == 'price') {
                            bono.price = double.parse(val);
                          }
                        });
                      },
                      style: Theme.of(context).textTheme.bodyText1,
                      decoration: InputDecoration(
                        hintStyle: Theme.of(context).textTheme.caption,
                        hintText: hintText,
                        //border: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      enabled: editable,
                    ),
                  ),
                ],
              )) : Container(),
      ],
    );
  }

  void test()  {
    _tabController!.animateTo(_selectedIndex += 1);
  }
}
