import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/LibraryModels/lColor.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Condition.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Utils/MediaQuery/MediaQuery.dart';
import 'package:mamba_castelldefels/Globals/Widgets/TopSnackBar/TopSnackBar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../../../../Globals/Utils/Bonos/BonosUtils.dart';

class AddEditBono extends StatefulWidget {

  Brand brand;
  Bono bono;

  AddEditBono({Key? key, required this.brand, required this.bono}) : super(key: key);

  @override
  _AddEditBonoState createState() => _AddEditBonoState();
}

class _AddEditBonoState extends State<AddEditBono> with SingleTickerProviderStateMixin {
  // Acceso a Base de Datos
  var _brandDataService = new BrandDataService();

  //Utils MediaQuery
  var umq = new MediaQueryUtils();

  //TopSnackBar
  var _topsnackbar = new TopSnackBar();

  var _lColor = new lColor();

  // Boolean Loading
  bool isLoading = false;

  //Utils bonos
  final _bonosUtils = BonosUtils();

  // Boolean days bono selected
  List<bool> isSelectedDays = [true,false,false,false];

  // Boolean isUpdated
  bool isUpdated = false;

  // Tab Controller
  double addBonosTabValue = 0.25;
  double updateEventTabValue = 0.50;
  TabController? _tabController;
  int _selectedIndex = 0;
  List<bool> tabs = [true, false, false];

  // Title Controller
  var titleController = TextEditingController();
  String? titleString;

  var clasesController = TextEditingController();
  var priceController = TextEditingController();
  var expirationController = TextEditingController();
  var weeklyController = TextEditingController();
  var monthlyController = TextEditingController();
  var daysSelectorController = TextEditingController();

  // Description Controller
  String? descriptionString;
  final formKeyInfo = GlobalKey<FormState>();

  // Duration
  TextEditingController durationController = TextEditingController();

  final values = <bool?>[false, false, false, false, false, false, false];
  int _value = 1;
  String colorBono = " ";


  Bono bono = new Bono(
    color:  "1",
    isActive: true,
    classes: 0,
  );

  Condition condition = new Condition(
    expirationTime: 30,
  );

  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';

  List<Color> colors = [];

  @override
  initState() {
    isLoading = false;
    var color;
    for (int i = 0; i < currentColors.length; ++i) {
      color = Color(int.parse(currentColors[i].hexa!));
      colors.add(color);
    }
    _tabController = TabController(length: 3, vsync: this);
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
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.transparent,
                      onTap: (index) {
                        _selectedIndex = index;
                      },
                      tabs: [
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info_outlined,
                                  color: tabs[0]
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context)
                                          .scaffoldBackgroundColor,
                                  size:
                                      MediaQuery.of(context).size.width * 0.06,
                                )
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
                                Icon(
                                  Icons.local_atm,
                                  color: tabs[1]
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context)
                                          .scaffoldBackgroundColor,
                                  size:
                                      MediaQuery.of(context).size.width * 0.06,
                                )
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
                                Icon(
                                  Icons.color_lens,
                                  color: tabs[2]
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context)
                                          .scaffoldBackgroundColor,
                                  size:
                                      MediaQuery.of(context).size.width * 0.06,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      width: 300,
                      height: 20,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: LinearProgressIndicator(
                          value: addBonosTabValue,
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                    )
                  ],
                )),
              ),
            ),
            body: LoadingView(),
          )
        : Scaffold(
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
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.transparent,
                      onTap: (index) {
                        _selectedIndex = index;
                      },
                      tabs: [
                        Tab(
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

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
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
                        width: MediaQuery.of(context).size.width * 0.80,
                        height: MediaQuery.of(context).size.height * 0.015,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: LinearProgressIndicator(
                            value: addBonosTabValue,
                            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                      )
                    ),
                  ],
                )),
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
                    timePage(),
                    othersPage(),
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
                                  });
                                } else if (_selectedIndex == 2) {
                                  setState(() {
                                    tabs[2] = false;
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
                              });
                            }
                          } else if (_selectedIndex == 1) {
                            _tabController!.animateTo(_selectedIndex += 1);
                            setState(() {
                              addBonosTabValue += 0.25;
                              tabs[2] = true;
                            });
                          } else
                            _addBono();
                        },
                        backgroundColor: _selectedIndex == 2
                            ? Colors.green
                            : Theme.of(context).colorScheme.secondary,
                        icon: Container(),
                        label: Text(
                          _selectedIndex == 2
                              ? 'Crear bono'
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
                                  AppLocalizations.of(context)!.title,
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
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            new Flexible(
                              child: new TextFormField(
                                controller: titleController,
                                validator: (val) => val!.isEmpty
                                    ? AppLocalizations.of(context)!.titleError
                                    : null,
                                onChanged: (val) {
                                  setState(() {
                                    bono.title = val;
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
                        child: new Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            new Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                new Text(
                                  AppLocalizations.of(context)!.description,
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
                        padding: EdgeInsets.only(top: 0.0),
                        child: new Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            new Flexible(
                              child: new TextFormField(
                                keyboardType: TextInputType.visiblePassword,
                                minLines: 1,
                                maxLines: 4,
                                onChanged: (val) {
                                  setState(() {
                                    bono.description = val;
                                  });
                                },
                                style: Theme.of(context).textTheme.bodyText2,
                                decoration: InputDecoration(
                                  hintStyle:
                                      Theme.of(context).textTheme.caption,
                                  hintText: AppLocalizations.of(context)!
                                      .descriptionError,
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        )),
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
                                  AppLocalizations.of(context)!.sessions,
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
                                controller: clasesController,
                                keyboardType: TextInputType.number,
                                validator: (val) => val!.isEmpty
                                    ? AppLocalizations.of(context)!.titleError
                                    : null,
                                onChanged: (val) {
                                  setState(() {
                                    bono.classes = int.parse(val);
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
                            top: MediaQuery.of(context).size.height * 0.03),
                        child: new Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            new Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                new Text(
                                  'Precio',
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
                                controller: priceController,
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  setState(() {
                                    bono.price = double.parse(val);
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

                  ]),
            ),
          ),
        ],
      )),
      resizeToAvoidBottomInset: true,
    );
  }

  Widget timePage() {
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
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.05,
                            bottom: MediaQuery.of(context).size.height * 0.02,
                        left: MediaQuery.of(context).size.height * 0.04),
                        child: Text(
                          'estilo del bono'.toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .headline1
                              ?.copyWith(fontWeight: FontWeight.normal),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    _selectedIndex == 1?  _bonosUtils.bonoObject(context, bono, widget.brand, _lColor) : Container(),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.05,
                            bottom: MediaQuery.of(context).size.height * 0.02,
                            left: MediaQuery.of(context).size.height * 0.04),
                        child: Text(
                          'Imagen'.toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .headline3
                              ?.copyWith(fontWeight: FontWeight.normal),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.05,
                            bottom: MediaQuery.of(context).size.height * 0.02,
                            left: MediaQuery.of(context).size.height * 0.04),
                        child: Text(
                          'Color solido'.toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .headline3
                              ?.copyWith(fontWeight: FontWeight.normal),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.005,
                            bottom: MediaQuery.of(context).size.height * 0.02,
                            left: MediaQuery.of(context).size.height * 0.04),
                        child: BlockPicker(
                          availableColors: colors,
                          pickerColor: Color(int.parse(_lColor.getlColor(bono.color!).hexa!)),
                          //default color
                          onColorChanged: (Color color) {
                            //on color picked
                            colorBono = getColorFromColorCode(color.toString());
                            setState(() {
                              bono.color = _lColor.getIdFromHexa(colorBono.toUpperCase());
                            });
                          },
                        ),
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

  Widget othersPage() {
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
                                  'Dias para expirar',
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
                        padding: EdgeInsets.only(top: umq.height(context, 0.02)),
                        child: new Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            daysSelectoWidget(0, '30', false),
                            SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                            daysSelectoWidget(1, '60', false),
                            SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                            daysSelectoWidget(2, '90', false),
                            SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                            daysSelectoWidget(3, '30', true),
                          ],
                        )),
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
                                  'Maximo numero de sesiones por semana',
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
                                //controller: weeklyController,
                                keyboardType: TextInputType.number,
                                initialValue: bono.classes!.toString(),
                                validator: (val) => val!.isEmpty
                                    ? AppLocalizations.of(context)!.titleError
                                    : null,
                                onChanged: (val) {
                                  setState(() {
                                    condition.weeklySessions = int.parse(val);
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

  String getColorFromColorCode(String code){
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

Widget daysSelectoWidget(int index, String numberDays, bool customized)
{
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
              color: isSelectedDays[index] == true? Styles.mainColor : Theme.of(context).primaryColor,
            ),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Align(
          alignment: Alignment.center,
          //padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06, vertical: MediaQuery.of(context).size.width * 0.02),
          child: customized? new TextFormField(
            controller: daysSelectorController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
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
              hintStyle:
              Theme.of(context).textTheme.caption,
              hintText:
              'Personaliza',
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
            enabled: true,
          ) : Text(
            numberDays,
            style: Theme.of(context).textTheme.button,
          ),
        ),
      ),
  );
}

  Future<void> _addBono() async {
    if(isSelectedDays[3] == true)
    {
      if(daysSelectorController.text.isNotEmpty) {
        condition.expirationTime = int.parse(daysSelectorController.text);
        setState(() {
          isLoading = true;
        });
        _brandDataService.addBonoToBrand(widget.brand.id!, bono, condition);
        Navigator.pop(context);
      }
      else {
        _topsnackbar.topsnackbar(context, 'Los dias para expirar deben tener un valor', Colors.red);
      }
    }
    else {
      setState(() {
        isLoading = true;
      });
      _brandDataService.addBonoToBrand(widget.brand.id!, bono, condition);
      Navigator.pop(context);
    }
  }
}
