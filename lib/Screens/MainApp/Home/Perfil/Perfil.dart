import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:mamba_castelldefels/Screens/Authentication/Login.dart';

import 'PerfilModals/FeedBack.dart';
import 'PerfilModals/ReportBug.dart';
import 'PerfilModals/Settings.dart';
import 'PerfilModals/TusDatos.dart';

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
  // Model Usuario
  Usuario? user;
  // List Bool Status
  List<bool> _statusButtons =  [false, false, false, false];
  final FocusNode myFocusNode = FocusNode();
  // Size of Icons
  final _globusSize = Size(75, 75);
  final _iconSize = 45.0;
  // Image Picker
  var _image;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    getUser();
  }

  void getUser() async {
    user = await _accessDatabase.getCurrentUserDetails();
    setState(() {
      isLoading = false;
    });
  }

  Future getImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(image!.path);
    });
    retrieveLostData();
    _accessDatabase.updateCurrentUserPhoto(_image);
    getUser();
    print(user!.imageUrl);
  }

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
    void _showPerfiClientModals(int _buttonIndex) {
      showModalBottomSheet(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
          isScrollControlled: true,
          context: context,
          builder: (context) {
            switch (_buttonIndex) {
              case 0:
                return TusDatos();
              case 1:
                return Settings();
              case 2:
                return FeedBack();
              case 3:
                return ReportBug();
              default:
                return Container();
            }
          }).whenComplete(() =>
      _statusButtons[_buttonIndex] = !_statusButtons[_buttonIndex]
      );
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
                                      width: MediaQuery.of(context).size.width*0.5,
                                      height: MediaQuery.of(context).size.height*0.5,
                                      decoration: new BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Styles.mainColor, width: 4.0),
                                        image: new DecorationImage(
                                          image: _image == null ? Image.network(user!.imageUrl!).image : FileImage(_image),
                                          fit: BoxFit.fitWidth,
                                        ),
                                      )),
                                ],
                              ),
                              Positioned(
                                  top: MediaQuery.of(context).size.height*0.20,
                                  bottom: 0,
                                  left: 0,
                                  right: MediaQuery.of(context).size.width*0.23,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox.fromSize(
                                        size: Size(40, 40), // button width and height
                                        child: ClipOval(
                                          child: Material(
                                            color: Styles.mainColor, // button color
                                            child: InkWell(
                                              onTap: () async {
                                                getImage();
                                                setState(() {});
                                              },
                                              child: Icon(Icons.collections_outlined, color: Colors.white, size: 25,), // icon
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                              // Logos Flotants
                              // Perfil Adalt Esquerra
                              Positioned(
                                  top: 0,
                                  bottom: MediaQuery.of(context).size.height*0.3,
                                  left: 0,
                                  right: MediaQuery.of(context).size.width*0.55,
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
                                              child: Icon( Icons.face, color: Colors.white, size: _iconSize,), // icon
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                              // Ajustes Adalt Dreta
                              Positioned(
                                  top: 0,
                                  bottom: MediaQuery.of(context).size.height*0.3,
                                  left: MediaQuery.of(context).size.width*0.55,
                                  right: 0,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox.fromSize(
                                        size: _globusSize, // button width and height
                                        child: ClipOval(
                                          child: Material(
                                            color: Styles.mainColor, // button color
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
                                  top: MediaQuery.of(context).size.height*0.3,
                                  bottom: 0,
                                  left: 0,
                                  right: MediaQuery.of(context).size.width*0.55,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox.fromSize(
                                        size: _globusSize, // button width and height
                                        child: ClipOval(
                                          child: Material(
                                            color: Styles.mainColor, // button color
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
                                  top: MediaQuery.of(context).size.height*0.3,
                                  bottom: 0,
                                  left: MediaQuery.of(context).size.width*0.55,
                                  right: 0,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox.fromSize(
                                        size: _globusSize, // button width and height
                                        child: ClipOval(
                                          child: Material(
                                            color: Styles.mainColor, // button color
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
                    Text("${user!.name}", style: Styles.purpleTextStyle.copyWith(fontSize: 24, fontWeight: FontWeight.bold),),
                    Padding(
                      padding: const EdgeInsets.only(top:20.0, bottom: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(AppLocalizations.of(context)!.memberSince(user!.dateJoined!), style: Styles.purpleTextStyle.copyWith(fontSize: 16)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:5.0, bottom: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(AppLocalizations.of(context)!.clientOf, style: Styles.purpleTextStyle.copyWith(fontSize: 16,)),
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
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }

}
