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
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectDaysDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/CupertinoSelect/SelectMembersDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/TopSnackBar/TopSnackBar.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/BonoCard.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Utils/MediaQuery/MediaQuery.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../../../../Data/LibraryModels/lDegradate.dart';
import '../../../../../Globals/Utils/Bonos/BonosUtils.dart';
import '../../../../../Globals/Widgets/Components/Images/RectangularImage.dart';
import '../../../../../Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/DeleteBonoDialog.dart';
import '../../03-Com/007-Contenido/SelectBrandImages.dart';

class AddEditBono extends StatefulWidget {
  Brand brand;
  Bono bono;
  bool edit;
  bool duplicate;
  bool delete;

  AddEditBono(
      {Key? key, required this.brand, required this.bono, required this.edit, required this.duplicate, required this.delete})
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

  bool noSessions = false;
  bool weekSessions = false;
  bool cancelTimeSessions = false;

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
  List<bool> isSelectedDays = [false, false, false, false];

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
  FocusNode focusNodetitleController = FocusNode();
  var descriptionController = TextEditingController();
  FocusNode focusNodeDescController = FocusNode();
  var sessionsController = TextEditingController();
  FocusNode focusNodeSessionsController = FocusNode();
  var priceController = TextEditingController();
  FocusNode focusNodePriceController = FocusNode();
  var freeCancellController = TextEditingController();
  var weeklyController = TextEditingController();
  var monthlyController = TextEditingController();
  var daysSelectorController = TextEditingController();

  // Description Controller
  String? descriptionString;
  final formKeyInfo = GlobalKey<FormState>();
  final formKeyPrice = GlobalKey<FormState>();
  final formKeyConditions = GlobalKey<FormState>();

  // Duration
  TextEditingController durationController = TextEditingController();

  final values = <bool?>[false, false, false, false, false, false, false];
  final int _value = 1;
  String colorBono = " ";
  String colorBono1 = " ";

  double roundDouble(double value, int places) {
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  Bono bono = Bono(
    color: "0",
    isActive: true,
    sessions: 0,
    opacity: 1,
    imageUrl: '',
    isDegradate: false,
    id: 'newBono',
  );

  Condition condition = Condition(
    expirationTime: 30,
    cancelTime: 0,
    weeklySessions: 0,
  );

  List<Color> colors = [];
  List<Color> colorsDeg = [];

  // Check if Bono has Purchases
  bool hasPurchases = false;

  @override
  initState() {
    isLoading = false;
    _tabController = TabController(length: 5, vsync: this);
    var color;
    var degradate1, degradate2;
    if (widget.edit == true || widget.duplicate == true) {
      bono.id = widget.bono.id;
      bono.title = widget.bono.title;
      bono.description = widget.bono.description;
      bono.price = widget.bono.price;
      bono.sessions = widget.bono.sessions;
      if (bono.sessions! > 5000) {
        noSessions = true;
      }
      bono.isActive = widget.bono.isActive;
      bono.compras = widget.bono.compras;
      bono.color = widget.bono.color;
      bono.imageUrl = widget.bono.imageUrl;
      bono.isDegradate = widget.bono.isDegradate;
      bono.opacity = widget.bono.opacity;
      getCondition();
      if (widget.edit == true) {
        getPurchases();
      }
      mixpanel!.track('edit_bono_info');
    } else {
      isSelectedDays[1] = true;
      freeCancellController.text = '0';
      weeklyController.text = '0';
      mixpanel!.track('add_bono_info');
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
    if (widget.edit == true || widget.duplicate == true) {
      _currentSliderValue = bono.opacity! * 100;
      if (bono.imageUrl == '') {
        bonoImage = false;
      } else {
        eventImageUrl = bono.imageUrl;
        bonoImage = true;
      }
      if (bono.isDegradate!) {
        colorSelected = colorsDeg[int.parse(bono.color!)].value;
      }
      // Open Delete Dialog
      Future.delayed(Duration.zero, () {
        checkIfDeleteIsTrue();
      });
    } else {
      colorSelected = colors[int.parse(bono.color!)].value;
    }
  }

  void getCondition() async {
    condition = Condition(
      expirationTime: widget.bono.condition!.expirationTime,
      cancelTime: widget.bono.condition!.cancelTime,
      weeklySessions: widget.bono.condition!.weeklySessions,
    );
    isSelectedDays[0] = false;
    isSelectedDays[1] = false;
    isSelectedDays[2] = false;
    isSelectedDays[3] = false;
    if (condition.expirationTime == 0) {
      isSelectedDays[0] = true;
    } else if (condition.expirationTime == 30) {
      isSelectedDays[1] = true;
    } else if (condition.expirationTime == 60) {
      isSelectedDays[2] = true;
    } else {
      isSelectedDays[3] = true;
    }
    weeklyController.text = condition.weeklySessions.toString();
    freeCancellController.text = condition.cancelTime.toString();
  }

  Future<void> getPurchases() async {
    bool temp = await _brandDataService.checkIfBrandBonoHasPurchases(widget.brand.id!, widget.bono.id!);
    setState(() {
      hasPurchases = temp;
    });
  }

  Future<void> checkIfDeleteIsTrue() async {
    await getPurchases();
    // Open Delete Dialog
    if (widget.delete == true) {
      // DeleteDialog
      var result = await showDialog(
        context: context,
        builder: (_) {
          return DeleteBonoDialog(
            hasPurchases: hasPurchases,
          );
        }
      );
      if (result) {
        if (hasPurchases) {
          // Deactivate
          await _brandDataService.updateBonoActive(widget.brand.id!, bono.id!, !bono.isActive!);
          Navigator.pop(context);
        } else {
          // Delete Bono
          await _brandDataService.deleteBrandBono(widget.brand.id!, bono.id!);
          Navigator.pop(context);
        }
      }
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
                preferredSize: const Size.fromHeight(0),
                child: IgnorePointer(
                    child: Column(
                  children: [
                    Padding(
                        padding: EdgeInsets.symmetric(vertical:
                        MediaQuery.of(context).size.height * 0.01),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical:
                                  MediaQuery.of(context).size.height * 0.01), width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.015,
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
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
              toolbarHeight: MediaQuery.of(context).size.height*0.08,
              title: Text(
                widget.edit
                    ? AppLocalizations.of(context)!.editBono
                    : AppLocalizations.of(context)!.createBono,
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
              actions: [
                widget.edit == true ? IconButton(
                    onPressed: () async {
                      // DeleteDialog
                      var result = await showDialog(
                          context: context,
                          builder: (_) {
                            return DeleteBonoDialog(
                              hasPurchases: hasPurchases,
                            );
                          }
                      );
                      if (result) {
                        if (hasPurchases) {
                          // Deactivate
                          await _brandDataService.updateBonoActive(widget.brand.id!, bono.id!, !bono.isActive!);
                          Navigator.pop(context);
                        } else {
                          // Delete Bono
                          await _brandDataService.deleteBrandBono(widget.brand.id!, bono.id!);
                          Navigator.pop(context);
                        }
                      }
                    },
                    icon: SizedBox(
                      width: MediaQuery.of(context).size.width*0.15,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_outlined, color: AppColors.red, size: MediaQuery.of(context).size.width*0.07,),
                        ],
                      ),
                    )
                ) : Container(),
                SizedBox(width: MediaQuery.of(context).size.width*0.03)
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0),
                child: IgnorePointer(
                  child: Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.width*0.03),
                      LinearProgressIndicator(
                        value: addBonosTabValue,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                  ],
                )),
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
            resizeToAvoidBottomInset: true,
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
                  ),
                ),
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
                          child: SizedBox(
                            height: 50,
                            child: FloatingActionButton.extended(
                              heroTag: "4",
                              onPressed: () {
                                if (_selectedIndex == 1) {
                                  if (widget.edit) {
                                    mixpanel!.track('edit_bono_info');
                                  } else {
                                    mixpanel!.track('add_bono_info');
                                  }
                                  setState(() {
                                    tabs[1] = false;
                                    FocusManager.instance.primaryFocus?.unfocus();
                                  });
                                } else if (_selectedIndex == 2) {
                                  if (widget.edit) {
                                    mixpanel!.track('edit_bono_price');
                                  } else {
                                    mixpanel!.track('add_bono_price');
                                  }
                                  setState(() {
                                    tabs[2] = false;
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  });
                                } else if (_selectedIndex == 3) {
                                  if (widget.edit) {
                                    mixpanel!.track('edit_bono_conditions');
                                  } else {
                                    mixpanel!.track('add_bono_conditions');
                                  }
                                  setState(() {
                                    tabs[3] = false;
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  });
                                } else if (_selectedIndex == 4) {
                                  if (widget.edit) {
                                    mixpanel!.track('edit_bono_style');
                                  } else {
                                    mixpanel!.track('add_bono_style');
                                  }
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
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.01),
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
                              if (widget.edit) {
                                mixpanel!.track('edit_bono_price');
                              } else {
                                mixpanel!.track('add_bono_price');
                              }
                            } else {
                              if (widget.edit) {
                                mixpanel!.track('edit_bono_info_error');
                              } else {
                                mixpanel!.track('add_bono_info_error');
                              }
                            }
                          } else if (_selectedIndex == 1) {
                            if (formKeyPrice.currentState!.validate()) {
                              setState(() {
                                FocusManager.instance.primaryFocus?.unfocus();
                              });
                              Timer(const Duration(milliseconds: 100), test);
                              addBonosTabValue += 0.20;
                              tabs[2] = true;
                              priceController.text = bono.price!.toStringAsFixed(2);
                              if (widget.edit) {
                                mixpanel!.track('edit_bono_conditions');
                              } else {
                                mixpanel!.track('add_bono_conditions');
                              }
                            } else {
                              if (widget.edit) {
                                mixpanel!.track('edit_bono_price_error');
                              } else {
                                mixpanel!.track('add_bono_price_error');
                              }
                            }
                          } else if (_selectedIndex == 2) {
                            if (formKeyConditions.currentState!.validate()) {
                              _tabController!.animateTo(_selectedIndex += 1);
                              setState(() {
                                addBonosTabValue += 0.20;
                                tabs[3] = true;
                                FocusManager.instance.primaryFocus?.unfocus();
                              });
                              if (widget.edit) {
                                mixpanel!.track('edit_bono_style');
                              } else {
                                mixpanel!.track('add_bono_style');
                              }
                            } else {
                              if (weekSessions && !cancelTimeSessions) {
                                if (weeklyController.text.isNotEmpty) {
                                  _tabController!.animateTo(_selectedIndex += 1);
                                  setState(() {
                                    addBonosTabValue += 0.20;
                                    tabs[3] = true;
                                    FocusManager.instance.primaryFocus?.unfocus();
                                  });
                                  if (widget.edit) {
                                    mixpanel!.track('edit_bono_style');
                                  } else {
                                    mixpanel!.track('add_bono_style');
                                  }
                                }
                              }
                              if (!weekSessions && cancelTimeSessions) {
                                if (freeCancellController.text.isNotEmpty) {
                                  _tabController!.animateTo(_selectedIndex += 1);
                                  setState(() {
                                    addBonosTabValue += 0.20;
                                    tabs[3] = true;
                                    FocusManager.instance.primaryFocus?.unfocus();
                                  });
                                  if (widget.edit) {
                                    mixpanel!.track('edit_bono_style');
                                  } else {
                                    mixpanel!.track('add_bono_style');
                                  }
                                }
                              }
                            }
                          } else if (_selectedIndex == 3) {
                            _tabController!.animateTo(_selectedIndex += 1);
                            setState(() {
                              addBonosTabValue += 0.20;
                              tabs[4] = true;
                              FocusManager.instance.primaryFocus?.unfocus();
                            });
                            if (widget.edit) {
                              mixpanel!.track('edit_bono_preview');
                            } else {
                              mixpanel!.track('add_bono_preview');
                            }
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
                              ? widget.edit
                                  ? AppLocalizations.of(context)!.editBono
                                  : AppLocalizations.of(context)!.createBono
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
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
                          AppLocalizations.of(context)!.title,
                          "",
                          AppLocalizations.of(context)!.titleHint,
                          AppLocalizations.of(context)!.titleError,
                          true,
                          titleController,
                          focusNodetitleController,
                          false,
                          'title'),
                      optionTextWrite(
                          TextInputType.text,
                          AppLocalizations.of(context)!.description,
                          "",
                          AppLocalizations.of(context)!.descriptionHint,
                          AppLocalizations.of(context)!.descriptionError,
                          true,
                          descriptionController,
                          focusNodeDescController,
                          false,
                          'desc'),
                      optionTextWrite(
                          TextInputType.multiline,
                          bono.isActive! ? AppLocalizations.of(context)!.desactivarBono : AppLocalizations.of(context)!.activarBono,
                          AppLocalizations.of(context)!.activeBonoQuesDesc,
                          AppLocalizations.of(context)!.descriptionError,
                          AppLocalizations.of(context)!.descriptionError,
                          true,
                          null,
                          null,
                          true,
                          bono.isActive),
                    ]),
              ),
            ),
          ],
        )
      ),

    );
  }

  Widget pricePage() {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
          widget.edit == true ? hasPurchases ? Container(
              height: MediaQuery.of(context).size.height*0.15,
              width: MediaQuery.of(context).size.width*0.9,
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.04),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.2),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                border: Border.all(color: AppColors.red, width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outlined, color: AppColors.red, size:  MediaQuery.of(context).size.width*0.08,),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context)!.bonosPurchasedWarning,
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red, height: 1.3),
                    ),
                  ),
                ],
              ),
            ) : Container(
            height: MediaQuery.of(context).size.height*0.10,
            width: MediaQuery.of(context).size.width*0.9,
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.04),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outlined, color: Colors.green, size:  MediaQuery.of(context).size.width*0.08,),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    AppLocalizations.of(context)!.bonosCanPurchasedWarning,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.green, height: 1.3),
                  ),
                ),
              ],
            ),
          ) : Container(),
          Form(
            key: formKeyPrice,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    optionTextWrite(
                        TextInputType.number,
                        AppLocalizations.of(context)!.sessions,
                        AppLocalizations.of(context)!.sesionsBonoDesc,
                        AppLocalizations.of(context)!.sessionHint,
                        AppLocalizations.of(context)!.sessionPlease,
                        widget.edit && hasPurchases ? false : true,
                        sessionsController,
                        focusNodeSessionsController,
                        false,
                        'ses'),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    optionTextWrite(
                        const TextInputType.numberWithOptions(decimal: true),
                        AppLocalizations.of(context)!.price,
                        "",
                        AppLocalizations.of(context)!.priceHint,
                        AppLocalizations.of(context)!.pricePlease,
                        widget.edit && hasPurchases ? false : true,
                        priceController,
                        focusNodePriceController,
                        false,
                        'price'),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  ]
              ),
            ),
          ),
        ],
      )),
      resizeToAvoidBottomInset: true,
    );
  }

  Widget conditionsPage() {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            widget.edit == true ? hasPurchases ? Container(
              height: MediaQuery.of(context).size.height*0.15,
              width: MediaQuery.of(context).size.width*0.9,
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.04),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.2),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                border: Border.all(color: AppColors.red, width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outlined, color: AppColors.red, size:  MediaQuery.of(context).size.width*0.08,),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context)!.bonosPurchasedWarning,
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.red, height: 1.3),
                    ),
                  ),
                ],
              ),
            ) : Container(
              height: MediaQuery.of(context).size.height*0.10,
              width: MediaQuery.of(context).size.width*0.9,
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.04),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outlined, color: Colors.green, size:  MediaQuery.of(context).size.width*0.08,),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context)!.bonosCanPurchasedWarning,
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.green, height: 1.3),
                    ),
                  ),
                ],
              ),
            ) : Container(),
            Form(
              key: formKeyConditions,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      optionConditionsWrite(
                          TextInputType.text,
                          AppLocalizations.of(context)!.expireDate,
                          AppLocalizations.of(context)!.expiresAtDesc,
                          AppLocalizations.of(context)!.titleError,
                          AppLocalizations.of(context)!.titleError,
                          widget.edit && hasPurchases ? false : true,
                          titleController,
                          'exp'),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                      optionConditionsWrite(
                          TextInputType.number,
                          AppLocalizations.of(context)!.trainsPerWeek,
                          AppLocalizations.of(context)!.trainsPerWeekDesc,
                          AppLocalizations.of(context)!.sessionHint,
                          AppLocalizations.of(context)!.sessionPlease,
                          widget.edit && hasPurchases ? false : true,
                          weeklyController,
                          'maxw'),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                      !noSessions? optionConditionsWrite(
                          TextInputType.number,
                          AppLocalizations.of(context)!.freeCancel,
                          AppLocalizations.of(context)!.freeCancelDesc,
                          AppLocalizations.of(context)!.freeCancelHint,
                          AppLocalizations.of(context)!.freeCancelError,
                          widget.edit && hasPurchases ? false : true,
                          freeCancellController,
                          'canFree') : Container(),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.1),
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
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            BonoCard(
              height: MediaQuery.of(context).size.height * 0.22,
              width: MediaQuery.of(context).size.width * 0.84,
              bono: bono,
              brand: widget.brand,
              canExpand: false,
              onlyView: true,
              condition: condition,
            ),
          ]),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.08),
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
                                        .headline1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                    Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.02,
                            vertical:
                                MediaQuery.of(context).size.height * 0.03),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.95,
                              height: MediaQuery.of(context).size.height * 0.02,
                              child: Slider(
                                value: _currentSliderValue,
                                max: 100,
                                divisions: 9,
                                min: 10,
                                label: _currentSliderValue.round().toString(),
                                activeColor: Theme.of(context).primaryColor,
                                inactiveColor:
                                    Theme.of(context).backgroundColor,
                                onChanged: (double value) {
                                  setState(() {
                                    _currentSliderValue = value;
                                    bono.opacity = value / 100;
                                  });
                                },
                              ),
                            ),
                          ],
                        )),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.08,
                          right: MediaQuery.of(context).size.width * 0.08,
                          bottom: MediaQuery.of(context).size.height * 0.03),
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
                                      .headline1,
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
                        child: eventImageUrl != null
                            ? Stack(
                                children: [
                                  RectangularImage(
                                    height: MediaQuery.of(context).size.height *
                                        0.18,
                                    width: MediaQuery.of(context).size.height *
                                        0.9,
                                    borderRadius: 10,
                                    image: eventImageUrl,
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7.0),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.07,
                                        decoration: const BoxDecoration(
                                            color: AppColors.red,
                                            shape: BoxShape.circle),
                                        child: Center(
                                          child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                eventImageUrl = null;
                                                bonoImage = false;
                                                bono.imageUrl = '';
                                              });
                                            },
                                            icon: Icon(Icons.remove,
                                                color: AppColors.white,
                                                size: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.03),
                                            alignment: Alignment.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
                                          .headline1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      height: MediaQuery.of(context).size.height * 0.13,
                      width: MediaQuery.of(context).size.width * 0.84,
                      child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
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
                                colorBono =
                                    getColorFromColorCode(lcolor.toString());
                                bono.color = _lColor
                                    .getIdFromHexa(colorBono.toUpperCase());
                                setState(() {});
                              },
                              child: Padding(
                                padding: EdgeInsets.only(
                                    right: MediaQuery.of(context).size.width *
                                        0.025,
                                    left: MediaQuery.of(context).size.width *
                                        0.00),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.width * 0.1,
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                  decoration: BoxDecoration(
                                    color: Color(lcolor.value),
                                    border: colorSelected == lcolor.value
                                        ? Border.all(
                                            color:
                                                Theme.of(context).primaryColor,
                                          )
                                        : Border.all(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.09,
                            vertical:
                                MediaQuery.of(context).size.height * 0.03),
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
                                        .headline1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                    Container(
                      alignment: Alignment.centerLeft,
                      height: MediaQuery.of(context).size.height * 0.14,
                      width: MediaQuery.of(context).size.width * 0.84,
                      child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
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
                                colorBono = getColorFromColorCode(
                                    ldegradate1.toString());
                                colorBono1 = getColorFromColorCode(
                                    ldegradate2.toString());
                                bono.color = _lDegradate.getIdFromHexa(
                                    colorBono.toUpperCase(),
                                    colorBono1.toUpperCase());
                                setState(() {});
                              },
                              child: Padding(
                                padding: EdgeInsets.only(
                                    right: MediaQuery.of(context).size.width *
                                        0.025,
                                    left: MediaQuery.of(context).size.width *
                                        0.00),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.width * 0.1,
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
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
                                            ldegradate1.value
                                        ? Border.all(
                                            color:
                                                Theme.of(context).primaryColor,
                                          )
                                        : Border.all(
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.2,
                    ),
                  ]),
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
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.08),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context)!.preseeBono,
                      style: Theme.of(context)
                          .textTheme
                          .headline1,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BonoCard(
                  height: MediaQuery.of(context).size.height * 0.22,
                  width: MediaQuery.of(context).size.width * 0.84,
                  bono: bono,
                  brand: widget.brand,
                  canExpand: true,
                  isExpanded: true,
                  onlyView: true,
                  condition: condition,
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
            ),
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

  void setSeeSessions(bool? seeSes) {
    noSessions = seeSes!;
    if (noSessions) {
      freeCancellController.text = '0';
      condition.cancelTime = 0;
      sessionsController.text = '';
      bono.sessions = 10000;
    } else {
      sessionsController.text = '';
      bono.sessions = 0;
    }
    setState(() {});
  }

  void setWeekSessions(bool? seeSes) {
    weekSessions = seeSes!;
    if (weekSessions) {
      weeklyController.text = '';
    } else {
      weeklyController.text = '';
      condition.weeklySessions = 0;
    }
    setState(() {});
  }

  void setCancelHours(bool? seeSes) {
    cancelTimeSessions = seeSes!;
    if (cancelTimeSessions) {
      freeCancellController.text = '';
    } else {
      freeCancellController.text = '';
      condition.cancelTime = 0;
    }
    setState(() {});
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
        if(widget.edit == false) {
          isSelectedDays[0] = false;
          isSelectedDays[1] = false;
          isSelectedDays[2] = false;
          isSelectedDays[3] = false;
          isSelectedDays[index] = true;

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
          //bono.condition!.expirationTime = condition.expirationTime;

          setState(() {});
        }
      },
      child:
      customized == false? Container(
        height: MediaQuery.of(context).size.width * 0.15,
        width: MediaQuery.of(context).size.width * 0.2,
        decoration: BoxDecoration(
            border: Border.all(
              width: isSelectedDays[index] == true
                  ? 3 : 1,
              color: isSelectedDays[index] == true
                  ? Styles.mainColor
                  : widget.edit == false? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
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
                style: widget.edit == false? Theme.of(context).textTheme.button : Theme.of(context).textTheme.button!.copyWith(color: Theme.of(context).disabledColor),
              ),
              customized == false
                  ? Text(
                      AppLocalizations.of(context)!.days,
                      style: widget.edit == false? Theme.of(context).textTheme.button : Theme.of(context).textTheme.button!.copyWith(color: Theme.of(context).disabledColor),
                    )
                  : Container(),
            ],
          ),
        ),
      ) : !noSessions?
      Container(
        height: MediaQuery.of(context).size.width * 0.15,
        width: MediaQuery.of(context).size.width * 0.2,
        decoration: BoxDecoration(
            border: Border.all(
              width: isSelectedDays[index] == true ? 3 : 1,
              color: isSelectedDays[index] == true
                  ? Styles.mainColor
                  : widget.edit == false? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
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
                style: widget.edit == false? Theme.of(context).textTheme.button : Theme.of(context).textTheme.button!.copyWith(color: Theme.of(context).disabledColor),
              ),
              customized == false
                  ? Text(
                AppLocalizations.of(context)!.days,
                style: widget.edit == false? Theme.of(context).textTheme.button : Theme.of(context).textTheme.button!.copyWith(color: Theme.of(context).disabledColor),
              )
                  : Container(),
            ],
          ),
        ),
      ) : Container(),
    );
  }

  Future<void> _addBono() async {

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

   /* if(bono.sessions == 0) {
      bono.sessions = 10000;
    }

    */
    if (widget.edit == false) {
      _brandDataService.addBonoToBrand(widget.brand.id!, bono, condition);
      mixpanel!.track('add_bono_completed', properties: {
        'descriptionLength':bono.description!.length.toString(),
        'isActive':bono.isActive!,
        'sessions':bono.sessions!.toString(),
        'price':bono.price!.toString(),
        'expirationTime':condition.expirationTime!.toString(),
        'cancelTime':condition.cancelTime!.toString(),
        'weeklySessions':condition.weeklySessions!.toString(),
        'opacity':bono.opacity!.toString(),
        'hasImage':bono.imageUrl != null ? true : false,
        'isDegradate':bono.isDegradate!,
        'color':bono.color!,
      });
    } else {
      _brandDataService.updateBono(widget.brand.id!, bono, condition);
      mixpanel!.track('edit_bono_completed', properties: {
        'descriptionLength':bono.description!.length.toString(),
        'isActive':bono.isActive!,
        'sessions':bono.sessions!.toString(),
        'price':bono.price!.toString(),
        'expirationTime':condition.expirationTime!.toString(),
        'cancelTime':condition.cancelTime!.toString(),
        'weeklySessions':condition.weeklySessions!.toString(),
        'opacity':bono.opacity!.toString(),
        'hasImage':bono.imageUrl != null ? true : false,
        'isDegradate':bono.isDegradate!,
        'color':bono.color!,
      });
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
      var focusNode,
      bool checkBox,
      var variable) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              !checkBox && variable != 'ses'
                  ? Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            titleText,
                            style: Theme.of(context)
                                .textTheme
                                .headline1,
                          ),
                          subtitleText != ""
                              ?  Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                    subtitleText,
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                              )
                              :  Container(),
                        ],
                      ),
                    )
                  : variable != 'ses'
                      ? Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                  titleText,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline1
                              ),
                              subtitleText != ""
                                  ? Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                              subtitleText,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption,
                                          ),
                                        ),
                                        checkBox ? Container(
                                          margin: const EdgeInsets.only(left: 4.0),
                                          child: CupertinoSwitch(
                                            value: bono.isActive!,
                                            onChanged: setBonoActivation,
                                            trackColor: Theme.of(context).backgroundColor,
                                            thumbColor: bono.isActive! ? Theme.of(context).colorScheme.secondary : Theme.of(context).scaffoldBackgroundColor,
                                            activeColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                                          ),
                                        )
                                            : Container(),
                                      ],
                                    ), 
                                  )
                                  : Container(),
                            ],
                          ),
                        )
                      : Container(),

              variable == 'ses'
                  ? Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            titleText,
                            style: Theme.of(context)
                                .textTheme
                                .headline1,
                          ),
                          subtitleText != "" ?
                            variable != 'ses' ? Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                subtitleText,
                                style: Theme.of(context).textTheme.caption,
                              ),
                          ) :
                              isSelectedDays[0] == false ? Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    subtitleText,
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption,
                                  ),
                                ),
                                Container(
                                    margin: const EdgeInsets.only(left: 4.0),
                                    child: CupertinoSwitch(
                                      value: noSessions,
                                      onChanged: widget.edit == true && hasPurchases ? null : setSeeSessions,
                                      trackColor: Theme.of(context).backgroundColor,
                                      thumbColor: noSessions ? Theme.of(context).colorScheme.secondary : Theme.of(context).scaffoldBackgroundColor,
                                      activeColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                                    )
                                )
                              ],
                            ),
                          )
                            : Container()
                          : Container(),
                        ],
                      ),
                    )
                  : Container(),
            ],
          )
        ),
        !checkBox && variable != 'ses'
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.00),
                    child: Row(
                      children: [
                        Flexible(
                          child: TextFormField(
                            keyboardType: keyboard,
                            inputFormatters:
                                variable == 'ses' || variable == 'price'
                                    ? [
                                        FilteringTextInputFormatter.allow(
                                            RegExp('[0-9.,]')),
                                      ]
                                    : null,
                            initialValue: widget.edit == true || widget.duplicate == true
                                ? variable == 'title'
                                    ? bono.title
                                    : variable == 'desc'
                                        ? bono.description
                                        : variable == 'ses'
                                            ? bono.sessions.toString()
                                            : variable == 'price'
                                                ? bono.price.toString()
                                                : null
                                : null,
                            maxLines: variable == 'desc' ? 5 : null,
                            minLines: 1,
                            maxLength: variable == 'title'
                                ? 20
                                : variable == 'desc'
                                    ? 100
                                    : null,
                            autofocus: widget.edit == true || widget.duplicate == true ? false : variable == 'title' && titleController.text.isEmpty ? true : false,
                            controller: widget.edit == true || widget.duplicate == true ? null : controller,
                            focusNode: variable == 'title'
                                ? focusNodetitleController
                                : variable == 'desc'
                                ? focusNodeDescController
                                : variable == 'ses'
                                ? focusNodeSessionsController
                                : focusNodePriceController,
                            onEditingComplete: () {
                              if (variable == 'title' && descriptionController.text.isEmpty) {
                                focusNodeDescController.requestFocus();
                              } else if (variable == 'desc') {
                                focusNodeDescController.unfocus();
                              } else if (variable == 'ses') {
                                focusNodetitleController.unfocus();
                              } else {
                                focusNodetitleController.unfocus();
                              }
                            },
                            validator: (val) => val!.isEmpty ? errorText : null,
                            textCapitalization: variable == 'title'
                                ? TextCapitalization.words
                                : TextCapitalization.sentences,
                            onChanged: (val) {
                              setState(() {
                                if (variable == 'title') {
                                  bono.title = val;
                                } else if (variable == 'desc') {
                                  bono.description = val;
                                } else if (variable == 'ses') {
                                  bono.sessions = int.parse(val);
                                } else if (variable == 'price') {
                                  double price = double.parse(val.replaceAll(',', '.'));
                                  print(roundDouble(price, 2));
                                  bono.price = roundDouble(price, 2);
                                }
                              });
                            },
                            style: editable? Theme.of(context).textTheme.bodyText1 : Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).disabledColor),
                            decoration: InputDecoration(
                              suffixText: variable == 'ses' ? AppLocalizations.of(context)!.sessions.toLowerCase() : variable == 'price' ? "euros (€)" : "",
                              suffixStyle: Theme.of(context).textTheme.caption,
                              hintStyle: Theme.of(context).textTheme.caption,
                              hintText: hintText,
                              errorBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              disabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
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
                  variable == 'price' && priceController.text.isNotEmpty && priceController.text != "0" && sessionsController.text != "" && sessionsController.text != "0" && noSessions == false  ? Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
                    child: Text(
                      (bono.price! / bono.sessions!).toStringAsFixed(2) + " € / " + AppLocalizations.of(context)!.session,
                      style: Theme.of(context).textTheme.caption,
                      textAlign: TextAlign.left,
                    ),
                  ) : Container(),
                ],
              )
            : variable == 'ses' && !noSessions
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.00),
                          child: Row(
                            children: [
                              Flexible(
                                child: TextFormField(
                                  keyboardType: keyboard,
                                  inputFormatters:
                                  variable == 'ses' || variable == 'price'
                                      ? [
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[0-9.,]')),
                                  ]
                                      : null,
                                  initialValue: widget.edit == true || widget.duplicate == true
                                      ? variable == 'title'
                                      ? bono.title
                                      : variable == 'desc'
                                      ? bono.description
                                      : variable == 'ses'
                                      ? bono.sessions.toString()
                                      : variable == 'price'
                                      ? bono.price.toString()
                                      : null
                                      : null,
                                  maxLines: variable == 'desc' ? 5 : null,
                                  minLines: 1,
                                  maxLength: variable == 'title'
                                      ? 20
                                      : variable == 'desc'
                                      ? 100
                                      : null,
                                  autofocus: widget.edit == true || widget.duplicate == true ? false : variable == 'ses' && sessionsController.text.isEmpty && noSessions == false ? true : false,
                                  controller: widget.edit == true || widget.duplicate == true ? null : controller,
                                  validator: (val) =>
                                  val!.isEmpty ? errorText : null,
                                  textCapitalization: variable == 'title'
                                      ? TextCapitalization.words
                                      : TextCapitalization.sentences,
                                  onChanged: (val) {
                                    setState(() {
                                      if (variable == 'title') {
                                        bono.title = val;
                                      } else if (variable == 'desc') {
                                        bono.description = val;
                                      } else if (variable == 'ses') {
                                        bono.sessions = int.parse(val);
                                      } else if (variable == 'price') {
                                        double price = double.parse(val.replaceAll(',', '.'));
                                        print(roundDouble(price, 2));
                                        bono.price = roundDouble(price, 2);
                                      }
                                    });
                                  },
                                  style: editable? Theme.of(context).textTheme.bodyText1 : Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).disabledColor),
                                  decoration: InputDecoration(
                                    suffixText: variable == 'ses' ? AppLocalizations.of(context)!.sessions.toLowerCase() : variable == 'price' ? "euros (€)" : "",
                                    suffixStyle: Theme.of(context).textTheme.caption,
                                    hintStyle: Theme.of(context).textTheme.caption,
                                    hintText: hintText,
                                    //border: InputBorder.none,
                                    errorBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                    disabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide:
                                      BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide:
                                      BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                  enabled: editable,
                                ),
                              ),
                            ],
                          )
                      ),
                    ],
                  )
                : Container(),
      ],
    );
  }

  Future<int?> selectInteger(String text, int initial, int max) async {
    int? pickedMembers =  await showCupertinoModalPopup(
        context: context,
        builder: (_) => SelectDaysDialog(
          title: text,
          intialDays: initial,
          daysMax: max,
        )
    );
    return pickedMembers;
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
                      style: Theme.of(context).textTheme.headline1,
                    ),
                    variable == 'exp' ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        subtitleText,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ) :
                    variable == 'canFree' ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              subtitleText,
                              style: Theme.of(context)
                                  .textTheme
                                  .caption,
                            ),
                          ),
                          Container(
                              margin: const EdgeInsets.only(left: 4.0),
                              child: CupertinoSwitch(
                                value: cancelTimeSessions,
                                onChanged: widget.edit == true && hasPurchases ? null : setCancelHours,
                                trackColor: Theme.of(context).backgroundColor,
                                thumbColor: cancelTimeSessions ? Theme.of(context).colorScheme.secondary : Theme.of(context).scaffoldBackgroundColor,
                                activeColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                              )
                          )
                        ],
                      ),
                    ) :
                    variable == 'maxw' ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              subtitleText,
                              style: Theme.of(context)
                                  .textTheme
                                  .caption,
                            ),
                          ),
                          Container(
                              margin: const EdgeInsets.only(left: 4.0),
                              child: CupertinoSwitch(
                                value: weekSessions,
                                onChanged: widget.edit == true && hasPurchases ? null : setWeekSessions,
                                trackColor: Theme.of(context).backgroundColor,
                                thumbColor: weekSessions ? Theme.of(context).colorScheme.secondary : Theme.of(context).scaffoldBackgroundColor,
                                activeColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                              )
                          )
                        ],
                      ),
                    ) :
                    Container(),
                  ],
                ),
              ),
            ],
          )
        ),
        variable == 'exp' ?
        Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                daysSelectoWidget(0, 'No expira', true),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                daysSelectoWidget(1, '30', false),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                daysSelectoWidget(2, '60', false),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                daysSelectoWidget(3, '90', false),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              ],
            ))
        : variable == 'canFree' && cancelTimeSessions ?
        Row(
          children: <Widget>[
            Flexible(
              child: TextFormField(
                keyboardType: keyboard,
                controller: controller,
                maxLines: null,
                minLines: 1,
                validator: (val) => val!.isEmpty ? errorText : int.parse(val) > 7 ? errorText : null,
                onChanged: (val) {
                  setState(() {
                    if (variable == 'maxw') {
                      condition.weeklySessions = int.parse(val);
                    } else if (variable == 'canFree') {
                      condition.cancelTime = int.parse(val);
                    }
                  });
                },
                style: editable ? Theme.of(context).textTheme.bodyText1 : Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).disabledColor),
                decoration: InputDecoration(
                  suffixText: variable == 'maxw' ? AppLocalizations.of(context)!.trainsPerWeek.toLowerCase() : variable == 'canFree' ? AppLocalizations.of(context)!.hoursString.toLowerCase() : "",
                  suffixStyle: Theme.of(context).textTheme.caption,
                  hintStyle: Theme.of(context).textTheme.caption,
                  hintText: hintText,
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  disabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
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
        : variable == 'maxw' && weekSessions ?
        Row(
          children: <Widget>[
            Flexible(
              child: TextFormField(
                keyboardType: keyboard,
                controller: controller,
                maxLines: null,
                minLines: 1,
                validator: (val) => val!.isEmpty ? errorText : int.parse(val) > 7 ? errorText : null,
                onChanged: (val) {
                  setState(() {
                    condition.weeklySessions = int.parse(val);
                  });
                },
                style: editable ? Theme.of(context).textTheme.bodyText1 : Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).disabledColor),
                decoration: InputDecoration(
                  suffixText: variable == 'maxw' ? AppLocalizations.of(context)!.sessions.toLowerCase() : variable == 'canFree' ? AppLocalizations.of(context)!.hoursString.toLowerCase() : "",
                  suffixStyle: Theme.of(context).textTheme.caption,
                  hintStyle: Theme.of(context).textTheme.caption,
                  hintText: hintText,
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  disabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
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
        : Container(),
      ],
    );
  }

  void test() {
    _tabController!.animateTo(_selectedIndex += 1);
  }
}
