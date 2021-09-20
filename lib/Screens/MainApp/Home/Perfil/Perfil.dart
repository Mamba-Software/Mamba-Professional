import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Idiomas/Idiomas.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Providers/LanguageProvider.dart';
import 'package:mamba_castelldefels/Screens/Authentication/Login.dart';
import 'package:provider/provider.dart';
import 'PerfilModals/FeedBack.dart';
import 'PerfilModals/ReportBug.dart';
import 'PerfilModals/Settings.dart';
import 'PerfilModals/TusDatos.dart';

// Profile page for each user.
class Perfil extends StatefulWidget {
  const Perfil({Key? key}) : super(key: key);

  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  // Boolean Loading
  bool isLoading = false;
  // List Bool Status
  List<bool> _statusButtons =  [false, false, false, false];
  // Size of Icons
  final _globusSize = Size(80, 80);
  final _iconSize = 45.0;
  // Image Picker
  var _image;
  // IdiomaChanged Settings Modal
  var _isSaved;
  var _isUpdated;

  // init Widget state. Loading user info.
  @override
  void initState() {
    super.initState();
  }
  // Gets the user info from firebase.
  void getUser() async {
    currentUser = await _accessDatabase.getCurrentUserDetails();
    setState(() {
      isLoading = false;
    });
  }
  // Selects image from Gallery and updates in firebase.
  Future getImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(image!.path);
    });
    retrieveLostData();
    await _accessDatabase.updateCurrentUserPhoto(_image);
    getUser();
  }
  // Retrieve lost data of Gallery if it crashes becasue of Android.
  Future<void> retrieveLostData() async {
    final LostDataResponse response =
    await ImagePicker().retrieveLostData();
    if (response == null) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image = response.file;
      });
    }
  }

  Widget build(BuildContext context) {
    // Calls a Modal Bottom Sheet every time an Icon is Tapped. It updates the page after closing only if there have been changes
    // inside the modal. Some set the isLoading to true (TusDatos, as the name needs to be updated in the UI), others don´t as it
    // can happen in the background (Settings)
    void _showPerfiClientModals(int _buttonIndex) async {
      _isSaved = false;
      _isUpdated = false;
      switch (_buttonIndex) {
        case 0:
          showModalBottomSheet<bool>(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return TusDatos(
                isUpdated: (bool) {
                  _isUpdated = bool!;
                }
              );
            }
          ).whenComplete(() =>{
            if(_isUpdated){
              setState(() {
                isLoading = true;
                getUser();
              }),
            },
            setState(() {
            _statusButtons[0] = !_statusButtons[0];
            })
          });
          break;
        case 1:
          showModalBottomSheet<bool>(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return Settings(
                  isSaved: (bool) {
                    _isSaved = bool!;
                  },
                  isUpdated: (bool) {
                   _isUpdated = bool!;
                  }
                );
              }
          ).whenComplete(() =>{
            if(_isUpdated){
              setState(() {
                isLoading = true;
                getUser();
              }),
            },
            if(!_isSaved){
              Provider.of<LanguageProvider>(context, listen: false).setLocale(Idiomas.getLocaleFromString(currentUser.idioma!)),
            },
            setState(() {
              _statusButtons[1] = !_statusButtons[1];
            }),
          });
          break;
        case 2:
          showModalBottomSheet(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return FeedBack();
              }).whenComplete(() => {
                setState(() {
                  _statusButtons[2] = !_statusButtons[2];
                })
              });
          break;
        case 3:
          showModalBottomSheet(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return ReportBug();
              }).whenComplete(() => {
                setState(() {
                  _statusButtons[3] = !_statusButtons[3];
                })
              });
          break;
        default:
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container();
              });
      }
    }

    return isLoading ?
      LoadingView()
        :
      Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: new Container(
                    height: MediaQuery.of(context).size.height*0.5,
                    //padding: EdgeInsets.only(top: 25.0, bottom: 25.0, right: 25.0, left: 25.0),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height*0.5,
                          child: new Stack(
                              alignment: Alignment.center,
                              fit: StackFit.expand,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      height: MediaQuery.of(context).size.height * 0.4,
                                      child: Center(
                                        child: isLoading ?
                                        CircularProgressIndicator() :
                                        CircularImage(size: MediaQuery.of(context).size.height * 0.3, image: currentUser.imageUrl, file: _image,),
                                      ),
                                    ),
                                  ],
                                ),
                                Positioned(
                                    top: MediaQuery.of(context).size.height*0.25,
                                    bottom: 0,
                                    left: 0,
                                    right: MediaQuery.of(context).size.width*0.23,
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox.fromSize(
                                          size: Size(50, 50), // button width and height
                                          child: ClipOval(
                                            child: Material(
                                              color: Styles.mainColor, // button color
                                              child: InkWell(
                                                onTap: () async {
                                                  getImage();
                                                  setState(() {});
                                                },
                                                child: Icon(Icons.collections_outlined, color: Colors.white, size: 30,), // icon
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                ),
                                // Logos Flotants
                                // Perfil Adalt Esquerra
                                Positioned(
                                    top: 0,
                                    bottom: MediaQuery.of(context).size.height*0.35,
                                    left: 0,
                                    right: MediaQuery.of(context).size.width*0.60,
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox.fromSize(
                                          size: _globusSize, // button width and height
                                          child: ClipOval(
                                            child: Material(
                                              color: !_statusButtons[0] ? Styles.mainColor : Styles.mainColorTrans, // button color
                                              child: InkWell(
                                                // splash color
                                                onTap: () {
                                                  setState(() {
                                                    _statusButtons[0] = !_statusButtons[0];
                                                    _showPerfiClientModals(0);
                                                  });
                                                  //_showSettingsPanel();
                                                }, // button pressed
                                                child: Icon( Icons.person, color: Colors.white, size: _iconSize,), // icon
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                                // Ajustes Adalt Dreta
                                Positioned(
                                    top: 0,
                                    bottom: MediaQuery.of(context).size.height*0.35,
                                    left: MediaQuery.of(context).size.width*0.60,
                                    right: 0,
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox.fromSize(
                                          size: _globusSize, // button width and height
                                          child: ClipOval(
                                            child: Material(
                                              color: !_statusButtons[1] ? Styles.mainColor : Styles.mainColorTrans, // button color
                                              child: InkWell(
                                                splashColor: Colors.white, // splash color
                                                onTap: () {
                                                  setState(() {
                                                    _statusButtons[1] = !_statusButtons[1];
                                                    _showPerfiClientModals(1);
                                                  });
                                                }, // button pressed
                                                child: Icon(Icons.settings, color: Colors.white, size: _iconSize,), // icon
                                              ),
                                            ),
                                          ),
                                        ),

                                      ],
                                    )),
                                // Feedback Abaix Esquerra
                                Positioned(
                                    top: MediaQuery.of(context).size.height*0.35,
                                    bottom: 0,
                                    left: 0,
                                    right: MediaQuery.of(context).size.width*0.60,
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox.fromSize(
                                          size: _globusSize, // button width and height
                                          child: ClipOval(
                                            child: Material(
                                              color: !_statusButtons[2] ? Styles.mainColor : Styles.mainColorTrans, // button color
                                              child: InkWell(
                                                splashColor: Colors.white, // splash color
                                                onTap: () {
                                                  setState(() {
                                                    _statusButtons[2] = !_statusButtons[2];
                                                    _showPerfiClientModals(2);
                                                  });
                                                }, // button pressed
                                                child: Icon(Icons.help_outline, color: Colors.white, size: _iconSize,), // icon
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                                // Bug Abaix Dreta
                                Positioned(
                                    top: MediaQuery.of(context).size.height*0.35,
                                    bottom: 0,
                                    left: MediaQuery.of(context).size.width*0.60,
                                    right: 0,
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox.fromSize(
                                          size: _globusSize, // button width and height
                                          child: ClipOval(
                                            child: Material(
                                              color: !_statusButtons[3] ? Styles.mainColor : Styles.mainColorTrans, // button color
                                              child: InkWell(
                                                splashColor: Colors.white, // splash color
                                                onTap: () {
                                                  setState(() {
                                                    _statusButtons[3] = !_statusButtons[3];
                                                    _showPerfiClientModals(3);
                                                  });
                                                }, // button pressed
                                                child: Icon(
                                                  Icons.report_problem_outlined,
                                                  color: Colors.white,
                                                  size: _iconSize,
                                                ), // icon
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                              ]),
                        ),
                      ],
                    ),
                  ),
                ),
                new Container(
                  //padding: EdgeInsets.only(top: 25.0, bottom: 25.0, right: 25.0, left: 25.0),
                  child: new Column(
                    children: [
                      Text("${currentUser.name}", style: Styles.purpleTextStyle.copyWith(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                      Padding(
                        padding: const EdgeInsets.only(top:20.0, bottom: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(AppLocalizations.of(context)!.memberSince(currentUser.dateJoined!), style: Styles.purpleTextStyle.copyWith(fontSize: 16)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:5.0, bottom: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(currentUser.isTrainer! ? AppLocalizations.of(context)!.trainerOf : AppLocalizations.of(context)!.clientOf, style: Styles.purpleTextStyle.copyWith(fontSize: 16,)),
                            Text("Roldan Coach", style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 250,
                        decoration: BoxDecoration(
                            color: Styles.accent, borderRadius: BorderRadius.circular(20)
                        ),
                        child: TextButton(
                          onPressed: () async {
                            _accessDatabase.signOut().then((value) =>
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  CupertinoPageRoute<Null>(
                                    builder: (context) => Login(),
                                    settings: RouteSettings(name: 'Login'),
                                  ),
                                      (_) => false,
                                )
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout_outlined, color: Styles.white),
                              SizedBox(width: 10),
                              Text(
                                AppLocalizations.of(context)!.closeSession,
                                style: Styles.whiteTextStyle,
                              ),
                            ],
                          ),
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

  @override
  void dispose() {
    super.dispose();
  }

}
