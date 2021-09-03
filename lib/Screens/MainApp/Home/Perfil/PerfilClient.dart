// Flutter Libs
import 'dart:io' as io;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
// Internal Apop Tools
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Providers/AuthenticationProvider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Providers/ClientProvider.dart';
import 'package:mamba_castelldefels/Providers/UserProvider.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Perfil/PerfilModals/FeedBack.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Perfil/PerfilModals/Settings.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Perfil/PerfilModals/TusDatos.dart';
import 'package:provider/provider.dart';

import 'PerfilModals/ReportBug.dart';

class PerfilClient extends StatefulWidget {
  const PerfilClient({Key? key}) : super(key: key);

  @override
  _PerfilClientState createState() => _PerfilClientState();
}

class _PerfilClientState extends State<PerfilClient> {
  // List Bool Status
  List<bool> _statusButtons =  [false, false, false, false, false];
  final FocusNode myFocusNode = FocusNode();
  // Size of Icons
  final _globusSize = Size(75, 75);
  final _iconSize = 45.0;
  // Image Picker
  final picker = ImagePicker();
  var _image = currentUser.imageURL == null ? null : io.File(currentUser.imageURL);

  @override
  Widget build(BuildContext context) {
    final _authProvider = Provider.of<AuthenticationProvider>(context);
    final userFirebase = Provider.of<UserProvider>(context).usuario;
    final client = Provider.of<ClientProvider>(context);
    
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

    return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: new Container(
                  height: screenHeight*0.5,
                  //padding: EdgeInsets.only(top: 25.0, bottom: 25.0, right: 25.0, left: 25.0),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: screenHeight*0.5,
                          child: new Stack(
                            alignment: Alignment.center,
                            fit: StackFit.expand,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: screenHeight*0.23,
                                    height: screenHeight*0.23,
                                    decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: yellowColor, width: 2.0),
                                      image: new DecorationImage(
                                        image: _image == null || currentUser.imageURL == null  ?
                                        new ExactAssetImage(fotoPerfil)
                                            :
                                        new Image.network(currentUser.imageURL).image,
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                                ],
                              ),
                              Positioned(
                                  top: screenHeight*0.20,
                                  bottom: 0,
                                  left: 0,
                                  right: screenWidth*0.23,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox.fromSize(
                                        size: Size(40, 40), // button width and height
                                        child: ClipOval(
                                          child: Material(
                                            color: yellowColor, // button color
                                            child: InkWell(
                                              onTap: () async {
                                                _image = await _openGallery(context);
                                                currentUser.imageURL = "";
                                                await client.uploadFileClientProfile(_image!);
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
                                  bottom: screenHeight*0.3,
                                  left: 0,
                                  right: screenWidth*0.55,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox.fromSize(
                                        size: _globusSize, // button width and height
                                        child: ClipOval(
                                          child: Material(
                                            color: !_statusButtons[0] ? yellowColor : yellowColorTrans, // button color
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
                                  bottom: screenHeight*0.3,
                                  left: screenWidth*0.55,
                                  right: 0,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox.fromSize(
                                        size: _globusSize, // button width and height
                                        child: ClipOval(
                                          child: Material(
                                            color: yellowColor, // button color
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
                                  top: screenHeight*0.3,
                                  bottom: 0,
                                  left: 0,
                                  right: screenWidth*0.55,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox.fromSize(
                                        size: _globusSize, // button width and height
                                        child: ClipOval(
                                          child: Material(
                                            color: yellowColor, // button color
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
                                  top: screenHeight*0.3,
                                  bottom: 0,
                                  left: screenWidth*0.55,
                                  right: 0,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox.fromSize(
                                        size: _globusSize, // button width and height
                                        child: ClipOval(
                                          child: Material(
                                            color: yellowColor, // button color
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
                    Text("${currentUser.name}", style: purpleTextStyle.copyWith(fontSize: 24, fontWeight: FontWeight.bold),),
                    Padding(
                      padding: const EdgeInsets.only(top:20.0, bottom: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(AppLocalizations.of(context)!.memberSince(userFirebase.dateJoined!), style: purpleTextStyle.copyWith(fontSize: 16)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:5.0, bottom: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(AppLocalizations.of(context)!.clientOf, style: purpleTextStyle.copyWith(fontSize: 16,)),
                          Text("Roldan Coach", style: purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 250,
                      decoration: BoxDecoration(
                          color: purpleColor, borderRadius: BorderRadius.circular(20)
                      ),
                      child: TextButton(
                        onPressed: () async {
                          await _authProvider.signOut();
                        },
                        child: Text(
                          AppLocalizations.of(context)!.closeSession,
                          style: whiteTextStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
  }

  Future<File> _openGallery(BuildContext context) async{
    XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        preferredCameraDevice: CameraDevice.front,
    );
    return io.File(pickedFile!.path);
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }
}
