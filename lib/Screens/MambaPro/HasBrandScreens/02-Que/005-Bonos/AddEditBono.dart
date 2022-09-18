import 'dart:async';
import 'dart:math';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/services.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/LibraryModels/lColor.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Condition.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Styles/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Bonos/BonoCard.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Utils/MediaQuery/MediaQuery.dart';
import 'package:mamba_castelldefels/Globals/Widgets/TopSnackBar/TopSnackBar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
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
  final _brandDataService = BrandDataService();

  //Utils MediaQuery
  var umq = MediaQueryUtils();

  double _currentSliderValue = 100;

  // Event Image
  bool isRandomImage = true;
  bool imageError = true;
  String? eventImageUrl;

  bool bonoImage = false;

  var colorSelected = 0;
  var colorSelectedDeg = 0;

  //TopSnackBar
  final _topsnackbar = TopSnackBar();

  final _lColor = lColor();
  final _lDegradate = lDegradate();

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
  double addBonosTabValue = 0.20;
  double updateEventTabValue = 0.50;
  TabController? _tabController;
  int _selectedIndex = 0;
  List<bool> tabs = [true, false, false, false, false];

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
  final int _value = 1;
  String colorBono = " ";
  String colorBono1 = " ";

  double roundDouble(double value, int places){
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  Bono bono = Bono(
    color: "0",
    isActive: true,
    classes: 0,
    opacity: 1,
    imageUrl: '',
    isDegradate: false,
    id: 'newBono',
  );

  Condition condition = Condition(
    expirationTime: 30,
  );

  final String _selectedDate = '';
  final String _dateCount = '';
  final String _range = '';
  final String _rangeCount = '';

  List<Color> colors = [];
  List<Color> colorsDeg = [];

  @override
  initState() {
    isLoading = false;
    _tabController = TabController(length: 5, vsync: this);
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
      weeklyController.text = condition.weeklySessions.toString();
    }
    else {
      condition.cancelTime = 6;
      condition.expirationTime = 30;
      isSelectedDays[0] = true;
      condition.weeklySessions = 10;
    }
    for (int i = 0; i < currentColors.length; ++i) {
      color = Color(int.parse(currentColors[i].hexa!));
      colors.add(color);
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
      if(bono.isDegradate!) {
        colorSelected = colorsDeg[int.parse(bono.color!)].value;
      }
      }
      else {
        colorSelected = colors[int.parse(bono.color!)].value;
      }

    }

  void getCondition() async
  {
    condition =  await _brandDataService.getConditionInfo(widget.brand.id!, bono.id!);
    condition.cancelTime = 6;
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
    return isLoading ? Scaffold(
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
                preferredSize: const Size.fromHeight(0),
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
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
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
          ) : Scaffold(
            appBar: AppBar(
              toolbarHeight: MediaQuery.of(context).size.height*0.12,
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
                preferredSize: const Size.fromHeight(0),
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
                                    Icon(Icons.info_outlined, color: tabs[0] ? Theme.of(context).colorScheme.secondary : Theme.of(context).scaffoldBackgroundColor, size: MediaQuery.of(context).size.width*0.06,)
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
                                    Icon(Icons.euro, color: tabs[1] ? Theme.of(context).colorScheme.secondary : Theme.of(context).scaffoldBackgroundColor, size: MediaQuery.of(context).size.width*0.06,)
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
                                    Icon(Icons.format_list_numbered, color: tabs[2] ? Theme.of(context).colorScheme.secondary : Theme.of(context).scaffoldBackgroundColor, size: MediaQuery.of(context).size.width*0.06,)
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
                                    Icon(Icons.palette_outlined, color: tabs[3] ? Theme.of(context).colorScheme.secondary : Theme.of(context).scaffoldBackgroundColor, size: MediaQuery.of(context).size.width*0.06,)
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
                                    Icon(Icons.playlist_add_check, color: tabs[4] ? Theme.of(context).colorScheme.secondary : Theme.of(context).scaffoldBackgroundColor, size: MediaQuery.of(context).size.width*0.06,)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        LinearProgressIndicator(
                          value: addBonosTabValue,
                          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ],
                    )
                ),
              ),
              /*
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0),
                child: IgnorePointer(
                    child: LinearProgressIndicator(
                    value: addBonosTabValue,
                    valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary),
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    ),
                ),
              ),
               */
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
                      informationPage(),
                      pricePage(),
                      conditionsPage(),
                      stylePage(),
                      confirmationPage(),
                    ],
                  )
                ),
              ],
            ),
            floatingActionButton: Padding(
              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _selectedIndex != 0
                      ? Padding(
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.01,
                              left: MediaQuery.of(context).size.width * 0.09),
                          child: SizedBox(
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
                                } else if (_selectedIndex == 4) {
                                  setState(() {
                                    tabs[4] = false;
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  });
                                }
                                _tabController!.animateTo(_selectedIndex -= 1);
                                setState(() {
                                  addBonosTabValue -= 0.20;
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
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.01),
                    child: SizedBox(
                      height: 50,
                      child: FloatingActionButton.extended(
                        heroTag: "5",
                        onPressed: () {
                          if (_selectedIndex == 0) {
                            if (formKeyInfo.currentState!.validate()) {
                              _tabController!.animateTo(_selectedIndex += 1);
                              setState(() {
                                addBonosTabValue += 0.20;
                                tabs[1] = true;
                                FocusManager.instance.primaryFocus?.unfocus();
                              });
                            }
                          } else if (_selectedIndex == 1) {
                            if (formKePrice.currentState!.validate()) {
                              setState(() {
                                FocusManager.instance.primaryFocus?.unfocus();
                              });
                              Timer(const Duration(milliseconds: 100), test);
                              addBonosTabValue += 0.20;
                              tabs[2] = true;
                              priceController.text = bono.price!.toStringAsFixed(2);
                            }
                          } else if (_selectedIndex == 2) {
                            _tabController!.animateTo(_selectedIndex += 1);
                            setState(() {
                              addBonosTabValue += 0.20;
                              tabs[3] = true;
                              FocusManager.instance.primaryFocus?.unfocus();
                            });
                          } else if (_selectedIndex == 3) {
                            _tabController!.animateTo(_selectedIndex += 1);
                            setState(() {
                              addBonosTabValue += 0.20;
                              tabs[4] = true;
                              FocusManager.instance.primaryFocus?.unfocus();
                            });
                          } else {
                            _addBono();
                          }
                        },
                        backgroundColor: _selectedIndex == 4
                            ? Colors.green
                            : Theme.of(context).colorScheme.secondary,
                        icon: Container(),
                        label: Text(
                          _selectedIndex == 4
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
                        "",
                        AppLocalizations.of(context)!.titleHint,
                        AppLocalizations.of(context)!.titleError,
                        widget.edit ? false : true,
                        titleController,
                        false,
                        'title'),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    optionTextWrite(
                        TextInputType.text,
                        AppLocalizations.of(context)!.descriptionBono,
                        "",
                        AppLocalizations.of(context)!.descriptionError,
                        AppLocalizations.of(context)!.descriptionError,
                        true,
                        descriptionController,
                        false,
                        'desc'),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    optionTextWrite(
                        TextInputType.multiline,
                        AppLocalizations.of(context)!.activeBono,
                        "En caso de estar activado, este bono estará disponible para los clientes en el momento del a creación. Siempre puedes activar o desactivar tu bono una vez este ha sido creado.",
                        AppLocalizations.of(context)!.descriptionError,
                        AppLocalizations.of(context)!.descriptionError,
                        true,
                        descriptionController,
                        true,
                        bono.isActive),
                  ]),
            ),
          ),
          ],
        )
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
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        optionTextWrite(
                            TextInputType.number,
                            AppLocalizations.of(context)!.sesionsBono,
                            "",
                            0.toString(),
                            'Añade las sesiones porfavor',
                            widget.edit ? false : true,
                            clasesController,
                            false,
                            'ses'),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                        optionTextWrite(
                            const TextInputType.numberWithOptions(decimal: true),
                            AppLocalizations.of(context)!.priceBono,
                            "",
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
        )
      ),
      resizeToAvoidBottomInset: true,
    );
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
                          'Fecha de expiración',
                          "Indica el número de días hasta el vencimiento de este bono",
                          AppLocalizations.of(context)!.titleHint,
                          AppLocalizations.of(context)!.titleError,
                          widget.edit ? false : true,
                          titleController,
                          'exp'),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                      optionConditionsWrite(
                          TextInputType.number,
                          'Cancelación gratuita',
                          "Introduce el número de horas mínimo para cancelar la asistencia a una sessión de manera gratuïta.",
                          AppLocalizations.of(context)!.titleHint,
                          AppLocalizations.of(context)!.titleError,
                          true,
                          titleController,
                          'ses'),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                      optionConditionsWrite( TextInputType.number,
                          'Sesiones por semana',
                          "Introduce el número máximo de sesiones que pueden realizar tus clientes en una misma semana (Lunes a Domingo).",
                          AppLocalizations.of(context)!.titleHint,
                          AppLocalizations.of(context)!.titleError,
                          true,
                          titleController,
                          'maxw'),
                    ]),
              ),
            ),
          ],
        )
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  Widget stylePage() {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height*0.03,),
          BonoCard(
            height: MediaQuery.of(context).size.height*0.22,
            width: MediaQuery.of(context).size.width*0.84,
            bono: bono,
            brand: widget.brand,
            canExpand: false,
            onlyView: true,
            condition: condition,
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.02,),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.08),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  "Opacidad",
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
                      )
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02, vertical: MediaQuery.of(context).size.height * 0.03),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width*0.95,
                            height: MediaQuery.of(context).size.height * 0.02,
                            child: Slider(
                              value: _currentSliderValue,
                              max: 100,
                              divisions: 9,
                              min: 10,
                              label: _currentSliderValue.round().toString(),
                              activeColor: Theme.of(context).primaryColor,
                              inactiveColor: Theme.of(context).backgroundColor,
                              onChanged: (double value) {
                                setState(() {
                                  _currentSliderValue = value;
                                  bono.opacity = value/100;
                                });
                              },
                            ),
                          ),
                        ],
                      )),
                  SizedBox(height: MediaQuery.of(context).size.height*0.01,),

                  Padding(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.08, right: MediaQuery.of(context).size.width * 0.08, bottom: MediaQuery.of(context).size.height * 0.03),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      ],
                    ),
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
                      child: eventImageUrl != null ? Stack(
                        children: [
                          RectangularImage(
                            height:
                            MediaQuery.of(context).size.height * 0.18,
                            width: MediaQuery.of(context).size.height * 0.9,
                            borderRadius: 10,
                            image: eventImageUrl,
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 7.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width*0.07,
                                decoration: const BoxDecoration(
                                    color: AppColors.red,
                                    shape: BoxShape.circle
                                ),
                                child: Center(
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        eventImageUrl = null;
                                        bonoImage = false;
                                        bono.imageUrl = '';
                                      });

                                    },
                                    icon: Icon(
                                        Icons.remove,
                                        color: AppColors.white,
                                        size: MediaQuery.of(context).size.width*0.03
                                    ),
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                        :
                      DottedBorder(
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
                  Container(
                    alignment: Alignment.centerLeft,
                    height: MediaQuery.of(context).size.height*0.13,
                    width: MediaQuery.of(context).size.width*0.84,
                    child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          crossAxisSpacing: 5.0,
                          mainAxisSpacing: 5.0,
                        ),
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
                              setState(() {});
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.025, left: MediaQuery.of(context).size.width * 0.00),
                              child: Container(
                                height: MediaQuery.of(context).size.width * 0.1,
                                width: MediaQuery.of(context).size.width * 0.1,
                                decoration: BoxDecoration(
                                  color: Color(lcolor.value),
                                  border: colorSelected == lcolor.value? Border.all(
                                    color:  Theme.of(context).primaryColor,
                                  ) : Border.all(
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          );
                        }
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.09, vertical: MediaQuery.of(context).size.height * 0.03),
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
                    )
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    height: MediaQuery.of(context).size.height*0.14,
                    width: MediaQuery.of(context).size.width*0.84,
                    child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          crossAxisSpacing: 5.0,
                          mainAxisSpacing: 5.0,
                        ),
                        itemCount: currentDegradates.length,
                        itemBuilder: (context, int index) {
                          int index1 = index * 2;
                          int index2 = index1 + 1;

                          var ldegradate1 = colorsDeg[index1];
                          var ldegradate2 = colorsDeg[index2];
                          return GestureDetector(
                            onTap: () {
                              bono.isDegradate = true;
                              colorSelectedDeg = ldegradate1.value;
                              colorSelected = 0;
                              colorBono = getColorFromColorCode(ldegradate1.toString());
                              colorBono1 = getColorFromColorCode(ldegradate2.toString());
                              bono.color = _lDegradate.getIdFromHexa(colorBono.toUpperCase(), colorBono1.toUpperCase());
                              setState(() {});
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: MediaQuery.of(context).size.width * 0.025,
                                  left: MediaQuery.of(context).size.width * 0.00
                              ),
                              child: Container(
                                height: MediaQuery.of(context).size.width * 0.1,
                                width: MediaQuery.of(context).size.width * 0.1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                    colors: [
                                      Color(ldegradate1.value),
                                      Color(ldegradate2.value),
                                    ],
                                  ),
                                  border: colorSelectedDeg == ldegradate1.value ? Border.all(color: Theme.of(context).primaryColor,
                                  ) : Border.all(color: Theme.of(context).primaryColorDark,),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          );
                        }
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height*0.2,),
                ]
              ),
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  Widget confirmationPage() {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*0.03,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.08),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      "Previsualiza tu bono",
                      style: Theme.of(context).textTheme.headline1?.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.04,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BonoCard(
                  height: MediaQuery.of(context).size.height*0.22,
                  width: MediaQuery.of(context).size.width*0.84,
                  bono: bono,
                  brand: widget.brand,
                  canExpand: true,
                  isExpanded: true,
                  onlyView: true,
                  condition: condition,
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.2,),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }


  String getColorFromColorCode(String code) {
    return code.substring(6, 16);
  }

  void setBonoActivation(bool? activation) {
    setState(() {
      bono.isActive = activation;
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
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        child: Align(
          alignment: Alignment.center,
          //padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06, vertical: MediaQuery.of(context).size.width * 0.02),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                 customized == false ? numberDays : "No expira",
                  style: Theme.of(context).textTheme.button,
              ),
              customized == false ? Text(
                AppLocalizations.of(context)!.days,
                style: Theme.of(context).textTheme.button,
              ) : Container(),
            ],
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
        condition.expirationTime = 0;
      }
      if (isSelectedDays[1]) {
        condition.expirationTime = 30;
      }
      if (isSelectedDays[2]) {
        condition.expirationTime = 60;
      }
      if (isSelectedDays[3]) {
        condition.expirationTime = 90;
      }
    }

      if(widget.edit == false ) {
        _brandDataService.addBonoToBrand(widget.brand.id!, bono, condition);
      } else {
        _brandDataService.updateBono(widget.brand.id!, bono, condition);
      }
      Navigator.pop(context);
    }


  Widget optionTextWrite(
      var keyboard,
      var titleText,
      var subtitleText,
      var hintText,
      var errorText,
      bool editable,
      var controller,
      bool checkBox,
      var variable) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              !checkBox? Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      titleText,
                      style: Theme.of(context).textTheme.headline1?.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    subtitleText != "" ? Text(
                      subtitleText,
                      style: Theme.of(context).textTheme.caption,
                    ) : Container(),
                  ],
                ),
              ) : !widget.edit? Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      titleText,
                      style: Theme.of(context).textTheme.headline1?.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    subtitleText != "" ? Text(
                      subtitleText,
                      style: Theme.of(context).textTheme.caption,
                    ) : Container(),
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
          )
        ),
        !checkBox? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.00),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Flexible(
                      child: TextFormField(
                        keyboardType: keyboard,
                        inputFormatters: variable == 'ses' || variable == 'price' ? [FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),] : null,
                        initialValue: widget.edit == true? variable == 'title'? bono.title : variable == 'desc'? bono.description : variable == 'ses'? bono.classes.toString() : variable == 'price'? bono.price.toString() : null : null,
                        maxLines: variable == 'desc'? 5 : null,
                        minLines: 1,
                        maxLength: variable == 'title' ? 20 : variable == 'desc'? 100 : null,
                        controller:  widget.edit == true ? null : controller,
                        validator: (val) => val!.isEmpty ? errorText : null,
                        textCapitalization: variable == 'title' ? TextCapitalization.words : TextCapitalization.sentences,
                        onChanged: (val) {
                          setState(() {
                            if (variable == 'title') {
                              bono.title = val;
                            } else if (variable == 'desc') {
                              bono.description = val;
                            } else if (variable == 'ses') {
                              bono.classes = int.parse(val);
                              weeklyController.text = condition.weeklySessions.toString();
                            } else if (variable == 'price') {
                              double price = double.parse(val.replaceAll(',','.'));
                              print(roundDouble(price, 2));
                              bono.price = roundDouble(price, 2);
                            }
                          });
                        },
                        style: Theme.of(context).textTheme.bodyText1,
                        decoration: InputDecoration(
                          suffixText: variable == 'ses' ? "sesiones" : variable == 'price' ?  "euros (€)" : "",
                          hintStyle: Theme.of(context).textTheme.caption,
                          hintText: hintText,
                          //border: InputBorder.none,
                          errorBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          disabledBorder: InputBorder.none,
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                        enabled: editable,
                      ),
                    ),
                  ],
                )
              ),
          ],
        ) : Container()
      ],
    );
  }

  Widget optionConditionsWrite(
      var keyboard,
      var titleText,
      var subtitleText,
      var hintText,
      var errorText,
      bool editable,
      var controller,
      var variable) {
    return Column(
      children: [
        Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                 Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        titleText,
                        style: Theme.of(context).textTheme.headline1?.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                      subtitleText != "" ? Text(
                        subtitleText,
                        style: Theme.of(context).textTheme.caption,
                      ) : Container(),
                    ],
                  ),
                ),
              ],
            )),
          variable == 'exp'? Padding(
              padding:
              EdgeInsets.only(top: umq.height(context, 0.02)),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  daysSelectoWidget(0, 'No expira', true),
                  SizedBox(
                      width:
                      MediaQuery.of(context).size.width * 0.02),
                  daysSelectoWidget(1, '30', false),
                  SizedBox(
                      width:
                      MediaQuery.of(context).size.width * 0.02),
                  daysSelectoWidget(2, '60', false),
                  SizedBox(
                      width:
                      MediaQuery.of(context).size.width * 0.02),
                  daysSelectoWidget(3, '90', false),
                  SizedBox(
                      width:
                      MediaQuery.of(context).size.width * 0.02),
                ],
              )) : variable == 'maxw' || variable == 'ses'?
          Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.00),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Flexible(
                    child: TextFormField(
                      keyboardType: keyboard,
                      initialValue: widget.edit ? variable == 'maxw'? condition.weeklySessions.toString() : null : null,
                      maxLines: null,
                      minLines: 1,
                      maxLength: variable == 'title'? 20 : variable == 'desc'? 100 : null,
                      //controller:  widget.edit == true ? null : controller,
                      validator: (val) => val!.isEmpty ? errorText : null,
                      onChanged: (val) {
                        setState(() {
                          if (variable == 'maxw') {
                            condition.weeklySessions = int.parse(val);
                          }  else if (variable == 'ses') {
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
                        suffixText: variable == 'maxw' ? "sesiones por semana" : variable == 'ses' ? "horas de antelacion" : "",
                        errorBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        disabledBorder: InputBorder.none,
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
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
