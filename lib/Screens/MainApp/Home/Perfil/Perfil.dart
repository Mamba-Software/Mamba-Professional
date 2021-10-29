import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Idiomas/Idiomas.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Providers/LanguageProvider.dart';
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
  final _globusSize = 20.0;
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
      LoadingViewPurple()
        :
      Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: new Container(
                    height: MediaQuery.of(context).size.height*0.40,
                    //padding: EdgeInsets.only(top: 25.0, bottom: 25.0, right: 25.0, left: 25.0),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height*0.40,
                          child: new Stack(
                              alignment: Alignment.center,
                              //fit: StackFit.,
                              children: <Widget>[
                                Positioned(
                                  top: 0,
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      GestureDetector(
                                        child: Container(
                                          child: Center(
                                            child: isLoading ?
                                            CircularProgressIndicator() :
                                            CircularImage(size: MediaQuery.of(context).size.height * 0.22, image: currentUser.imageUrl, file: _image, color: Theme.of(context).accentColor, borderWidth: 1.5,),
                                          ),
                                        ),
                                        onTap: () async {
                                          getImage();
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                // Logos Flotants
                                // Perfil Adalt Esquerra
                                Positioned(
                                    top: 0,
                                    bottom: MediaQuery.of(context).size.height*0.25,
                                    left: 0,
                                    right: MediaQuery.of(context).size.width*0.60,
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        OutlinedButton(
                                          onPressed: () {
                                            setState(() {
                                              _statusButtons[0] = !_statusButtons[0];
                                              _showPerfiClientModals(0);
                                            });
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon( Icons.person, color: Colors.white, size: _iconSize,),
                                            ],
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Theme.of(context).accentColor,
                                            //backgroundColor: !_statusButtons[0] ? Theme.of(context).primaryColor : Theme.of(context).primaryColorLight,
                                            elevation: 5,
                                            shape: CircleBorder(),
                                            padding: EdgeInsets.all(_globusSize),
                                          ),
                                        ),
                                      ],
                                    )),
                                // Ajustes Adalt Dreta
                                Positioned(
                                    top: 0,
                                    bottom: MediaQuery.of(context).size.height*0.25,
                                    left: MediaQuery.of(context).size.width*0.60,
                                    right: 0,
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        OutlinedButton(
                                          onPressed: () {
                                            setState(() {
                                              _statusButtons[1] = !_statusButtons[1];
                                              _showPerfiClientModals(1);
                                            });
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.settings, color: Colors.white, size: _iconSize,), // icon
                                            ],
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Theme.of(context).accentColor,
                                            //backgroundColor: !_statusButtons[0] ? Theme.of(context).primaryColor : Theme.of(context).primaryColorLight,
                                            elevation: 5,
                                            shape: CircleBorder(),
                                            padding: EdgeInsets.all(_globusSize),
                                          ),
                                        ),
                                      ],
                                    )),
                                // Feedback Abaix Esquerra
                                Positioned(
                                    top: MediaQuery.of(context).size.height*0.25,
                                    bottom: 0,
                                    left: 0,
                                    right: MediaQuery.of(context).size.width*0.60,
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        OutlinedButton(
                                          onPressed: () {
                                            setState(() {
                                              _statusButtons[2] = !_statusButtons[2];
                                              _showPerfiClientModals(2);
                                            });
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.help_outline, color: Colors.white, size: _iconSize,), // icon
                                            ],
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Theme.of(context).accentColor,
                                            //backgroundColor: !_statusButtons[0] ? Theme.of(context).primaryColor : Theme.of(context).primaryColorLight,
                                            elevation: 5,
                                            shape: CircleBorder(),
                                            padding: EdgeInsets.all(_globusSize),
                                          ),
                                        ),
                                      ],
                                    )),
                                // Bug Abaix Dreta
                                Positioned(
                                    top: MediaQuery.of(context).size.height*0.25,
                                    bottom: 0,
                                    left: MediaQuery.of(context).size.width*0.60,
                                    right: 0,
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        OutlinedButton(
                                          onPressed: () {
                                            setState(() {
                                              _statusButtons[3] = !_statusButtons[3];
                                              _showPerfiClientModals(3);
                                            });
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.report_problem_outlined, color: Colors.white, size: _iconSize,), // icon
                                            ],
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Theme.of(context).accentColor,
                                            //backgroundColor: !_statusButtons[0] ? Theme.of(context).primaryColor : Theme.of(context).primaryColorLight,
                                            elevation: 5,
                                            shape: CircleBorder(),
                                            padding: EdgeInsets.all(_globusSize),
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
                      Text("${currentUser.name}", style: Theme.of(context).textTheme.headline1!.copyWith(color: Theme.of(context).accentColor, fontWeight: FontWeight.bold, fontSize: 26), textAlign: TextAlign.center,),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: NumbersWidget(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:20.0, bottom: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(AppLocalizations.of(context)!.memberSince(currentUser.dateJoined!), style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 16)),
                          ],
                        ),
                      ),
                      currentUser.brandID != "null" ? Container(
                        padding: EdgeInsets.all(0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(currentUser.isTrainer! ? AppLocalizations.of(context)!.trainerOf : AppLocalizations.of(context)!.clientOf, style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 16)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: Text(currentBrand.name!, style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                            //CircularImage(size: MediaQuery.of(context).size.height * 0.07, image: currentBrand.logoUrl, borderWidth: 1.5, color: Theme.of(context).accentColor,),
                          ],
                        ),
                      ) : Container(
                        padding: EdgeInsets.all(0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(AppLocalizations.of(context)!.notInBrand, style: Styles.purpleTextStyle.copyWith(fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

  }

  @override
  void dispose() {
    super.dispose();
  }

}

class NumbersWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      buildButton(context, '4.8', 'Ranking'),
      buildDivider(context),
      buildButton(context, '35', 'Following'),
      buildDivider(context),
      buildButton(context, '50', 'Followers'),
    ],
  );

  Widget buildDivider(BuildContext context) => Container(
    height: 24,
    child: VerticalDivider(color: Theme.of(context).primaryColor,),
  );

  Widget buildButton(BuildContext context, String value, String text) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 2),
            Text(
              text,
              style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      );
}

