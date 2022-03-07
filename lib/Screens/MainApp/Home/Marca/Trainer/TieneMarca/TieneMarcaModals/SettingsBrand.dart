import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/DataService/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/EventDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/RoomDataService.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/NotificationService/NotificationService.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Dialogs/ActionDialogs/ConfirmationDialog.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViews/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LocationAutoComplete/MyLocations.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/Providers/LanguageProvider.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Marca/Trainer/TieneMarca/TieneMarcaModals/AddBrandPics.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Idiomas/Idiomas.dart';
import 'EditBrandInfo.dart';
import 'EditLogoPage.dart';

class SettingsBrand extends StatefulWidget {
  const SettingsBrand({Key? key}) : super(key: key);
  @override
  _SettingsBrandState createState() => _SettingsBrandState();
}

class _SettingsBrandState extends State<SettingsBrand> {

  // Acceso a Base de Datos
  var _brandDataService = new BrandDataService();
  var _eventDataService = new EventDataService();
  var _roomDataService=  new RoomDataService();
  // Boolean Loading
  bool isLoading = false;
  bool firstBuild = true;
  // Type of Profile Widget value
  bool? _isPrivate = null;
  final _typeProfileKey = GlobalKey<_ProfileTypeWidgetState>();
  // Idioma Original
  bool idiomaChanged = false;
  final _idiomaChanged = GlobalKey<_LanguagePickerWidgetState>();
  // Boolean isUpdated
  bool isUpdated = false;
  // Boolean isSaved
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
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
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.settings, style: Theme.of(context).appBarTheme.titleTextStyle,),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width*0.06,),
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.width*0.07),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context)!.info,
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute<String>(
                                  builder: (context) => EditBrandInfo(
                                  locale: Localizations.localeOf(context),
                                ),
                              )
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.edit_outlined, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.05),
                            SizedBox(width: 10),
                            Text(
                              AppLocalizations.of(context)!.editBrandInfo,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute<String>(
                                builder: (context) => EditLogoPage(),
                              )
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.photo_camera_back, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.05),
                            SizedBox(width: 10),
                            Text(
                              AppLocalizations.of(context)!.editBrandLogo,
                             style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute<String>(
                              builder: (context) => MyLocations(
                                  brandId: currentBrand.id!,
                                ),
                              )
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on_outlined, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.05),
                            SizedBox(width: 10),
                            Text(
                              AppLocalizations.of(context)!.locations,
                             style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context)!.content,
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute<String>(
                                builder: (context) => AddBrandPics(),
                              )
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.photo_library_outlined, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.width*0.05),
                            SizedBox(width: 10),
                            Text(
                              AppLocalizations.of(context)!.addBrandPhotos,
                             style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                    ],
                  ),
                  currentUser.id != currentBrand.adminID ? TextButton(
                    onPressed: () async {
                      // Leaves Brand
                      var result = await showDialog(
                          context: context,
                          builder: (_) {
                            return ConfirmationDialog(text: AppLocalizations.of(context)!.exitBrandConfirm);
                          }
                      );
                      if (result) {
                        NotificationService().userLeavesBrand(currentUser.id!, currentBrand.id!);
                        await _eventDataService.deleteUserFromUpcomingEvents(currentUser.id!, currentUser.isTrainer!);
                        await _brandDataService.deleteUserFromBrand(currentUser.id!, currentBrand.id!);
                        Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute<Null>(
                              builder: (context) =>
                                  SplashScreen(),
                              settings: RouteSettings(
                                  name: 'SplashScreen'),
                            )
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.logout, color: Colors.red, size: MediaQuery.of(context).size.width*0.05),
                        SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)!.exitBrand,
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.red),
                        ),
                      ],
                    ),
                  ) : TextButton(
                    onPressed: () async {
                      var result = await showDialog(
                          context: context,
                          builder: (_) {
                            return DeleteBrandDialog();
                          }
                      );
                      if (result) {
                        setState(() {
                          isLoading = true;
                        });
                        // New DataBase
                        await _brandDataService.deleteBrand(currentBrand.id!);
                        await _roomDataService.deleteRoom(currentBrand.roomId!);
                        currentUser.setBrandList = [];
                        await Future.delayed(const Duration(seconds: 4));
                        Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute<Null>(
                              builder: (context) =>
                                  SplashScreen(),
                              settings: RouteSettings(
                                  name: 'SplashScreen'),
                            )
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red, size: MediaQuery.of(context).size.width*0.05),
                        SizedBox(width: 10),
                        Text(
                          AppLocalizations.of(context)!.deleteBrand,
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

class DeleteBrandDialog extends StatefulWidget {
  const DeleteBrandDialog({Key? key}) : super(key: key);

  @override
  _DeleteDialogState createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteBrandDialog> {

  // Delete Alert
  bool firstBuild = true;
  bool canDelete = false;
  bool wrongPassword = false;
  String deleteTemp = "";
  var deleteController;
  // Password Visible
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    if(firstBuild) {
      deleteTemp = "";
      firstBuild = false;
    }
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).scaffoldBackgroundColor
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 25, bottom: 10.0),
                  child: Text(AppLocalizations.of(context)!.deleteBrandConfirmation, style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                ),
                Flexible(
                  child: Text("${AppLocalizations.of(context)!.writeDeleteBrand} ", style: Theme.of(context).textTheme.bodyText2, textAlign: TextAlign.center,),
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                Flexible(
                  child: Text(currentBrand.name!, style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 15, right: 15),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new Flexible(
                        child: new TextFormField(
                          controller: deleteController,
                          onChanged: (val) {
                            setState(() => {
                              deleteTemp = val
                            });
                            if (deleteTemp != currentBrand.name) {
                              setState(() => {
                                canDelete = false
                              });
                            } else {
                              setState(() => {
                                canDelete = true
                              });
                            }
                          },
                          style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.red),
                          decoration: InputDecoration(
                            hintText: currentBrand.name,
                            hintStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.red.withOpacity(0.5)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red, width: 1),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red, width: 1),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton.extended(
                        heroTag: "32",
                        label: Text(AppLocalizations.of(context)!.delete, style: Theme.of(context).textTheme.bodyText2?.copyWith(color: AppColors.white),),
                        icon: Icon(Icons.delete_outline, size: MediaQuery.of(context).size.width*0.06,),
                        backgroundColor: canDelete ? Colors.red : Colors.red[200],
                        foregroundColor: AppColors.white,
                        onPressed: canDelete ? () async  {
                          Navigator.pop(context, true);
                        } : null,
                      ),
                      FloatingActionButton.extended(
                        heroTag: "33",
                        icon: Icon(Icons.cancel_outlined, size: MediaQuery.of(context).size.width*0.06,),
                        label: Text(AppLocalizations.of(context)!.cancel, style: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).primaryColorDark),),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Theme.of(context).primaryColorDark,
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
                top: -90,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox.fromSize(
                      size: Size(100, 100), // button width and height
                      child: ClipOval(
                        child: Material(
                          color: Colors.red, // button color
                          child: InkWell(
                            onTap: () async {
                              setState(() {});
                            },
                            child: Icon(Icons.delete_outline_outlined, color: Colors.white, size: 60,), // icon
                          ),
                        ),
                      ),
                    ),
                  ],
                )
            )
          ],
        ),
      ),
    );
  }

  String splitCommonName(String name) {
    List<String> aux = name.split(" ");
    return aux[0];
  }
}

class ProfileTypeWidget extends StatefulWidget {
  final ValueChanged<bool> selectedProfileTypeChanged;
  final Usuario? user;
  ProfileTypeWidget({required Key key, required this.selectedProfileTypeChanged, required this.user}) : super(key: key);

  @override
  _ProfileTypeWidgetState createState() => _ProfileTypeWidgetState();
}

class _ProfileTypeWidgetState extends State<ProfileTypeWidget> {
  bool firstBuild = true;
  var isPrivate;
  @override
  resetProfileType() => isPrivate = widget.user!.isPrivate!;
  Widget build(BuildContext context) {
    if (firstBuild) {
      isPrivate = widget.user!.isPrivate!;
      firstBuild = false;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _icon(true, text: AppLocalizations.of(context)!.typeProfilePrivate, icon: Icons.visibility_off_outlined),
        SizedBox(width: MediaQuery.of(context).size.width*0.10),
        _icon(false, text: AppLocalizations.of(context)!.typeProfilePublic, icon: Icons.visibility_outlined),
      ],
    );
  }
  Widget _icon(bool index, {required String text, required IconData icon}) {
    return SizedBox.fromSize(
          size: Size(85, 85), // button width and height
          child: ClipOval(
            child: Material(
              color: isPrivate == index ? Theme.of(context).accentColor : Theme.of(context).scaffoldBackgroundColor,
              child: InkWell(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).primaryColor)),
                    ),
                  ],
                ),
                onTap: () => {
                  setState(() {
                    isPrivate = index;
                    widget.selectedProfileTypeChanged(isPrivate);
                  }),
                },
              ),
            ),
          ),
        );
  }
}

class LanguagePickerWidget extends StatefulWidget {
  ValueChanged<bool?> idiomaChanged;
  LanguagePickerWidget({Key? key, required this.idiomaChanged}) : super(key: key);
  @override
  _LanguagePickerWidgetState createState() => _LanguagePickerWidgetState();
}

class _LanguagePickerWidgetState extends State<LanguagePickerWidget> {
  Locale? _locale;
  var allLocales;
  bool idiomaChanged = false;
  @override
  resetIdiomaChanged() => {
    idiomaChanged = false
  };
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    _locale = languageProvider.idioma;
    allLocales = Idiomas.all;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _iconLocale(allLocales[0], context),
        SizedBox(width: MediaQuery.of(context).size.width*0.10),
        _iconLocale(allLocales[1], context),
      ],
    );
  }
  Widget _iconLocale(Locale locale, BuildContext context ) {
    return SizedBox.fromSize(
          size: Size(85, 85), // button width and height
          child: ClipOval(
            child: Material(
              color: _locale == locale ? Theme.of(context).accentColor : Theme.of(context).scaffoldBackgroundColor, // button color
              child: InkWell(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                          locale.languageCode.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Theme.of(context).primaryColor)
                      ),
                    ),
                  ],
                ),
                onTap: () => {
                  setState(() {
                    _locale = locale;
                    if (_locale!.languageCode != currentUser.idioma!) {
                      idiomaChanged = true;
                    } else {
                      idiomaChanged = false;
                    }
                    Provider.of<LanguageProvider>(context, listen: false).setLocale(_locale!);
                    widget.idiomaChanged(idiomaChanged);
                  }),
                }
              ),
            ),
          ),
      );
  }
}
