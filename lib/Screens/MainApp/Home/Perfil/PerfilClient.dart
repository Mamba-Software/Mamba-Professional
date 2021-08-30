// Flutter Libs
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// Internal Apop Tools
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Providers/AuthenticationProvider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Providers/UserProvider.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Perfil/PerfilModals/TusDatos.dart';
import 'package:provider/provider.dart';

class PerfilClient extends StatefulWidget {
  const PerfilClient({Key? key}) : super(key: key);

  @override
  _PerfilClientState createState() => _PerfilClientState();
}

class _PerfilClientState extends State<PerfilClient> {
  // List Bool Status
  List<bool> _statusButtons =  [false, false, false, false, false, false];
  final FocusNode myFocusNode = FocusNode();
  // Size of Icons
  final _iconSize = Size(85, 85);

  @override
  Widget build(BuildContext context) {
    final _authProvider = Provider.of<AuthenticationProvider>(context);
    final userFirebase = Provider.of<UserProvider>(context).usuario;
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
                return Container(
                  height: screenHeight*0.3,
                  padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
                  child: Text('Privacidad'),
                );
              case 2:
                return Container(
                  height: screenHeight*0.3,
                  padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
                  child: Text('Historial de Sesiones'),
                );
              case 3:
                return Container(
                  height: screenHeight*0.3,
                  padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
                  child: Text('Análisis y Seguimiento'),
                );
              case 4:
                return Container(
                  height: screenHeight*0.3,
                  padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
                  child: Text('FeedBack'),
                );
              case 5:
                return Container(
                  height: screenHeight*0.3,
                  padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
                  child: Text('Reporta un error'),
                );
              default:
                return Container(
                  height: screenHeight*0.3,
                  padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
                  child: Text('No ha Trobat'),
                );
            }
         }).whenComplete(() => _statusButtons[_buttonIndex] = !_statusButtons[_buttonIndex]);
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
                                      image: new DecorationImage(
                                        image: new ExactAssetImage(fotoPerfil),
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                                ],
                              ),
                              Positioned(
                                  top: 150,
                                  bottom: 0,
                                  left: 0,
                                  right: 100,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      new CircleAvatar(
                                        backgroundColor: yellowColor,
                                        radius: 20.0,
                                        child: new Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                        ),
                                      )
                                    ],
                                  )),
                              // Logos Flotants
                              // Perfil Adalt Esquerra
                              Positioned(
                                  top: 0,
                                  bottom: 250,
                                  left: 0,
                                  right: 230,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox.fromSize(
                                        size: _iconSize, // button width and height
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
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.face,
                                                    color: Colors.white,
                                                    size: 35.0,
                                                  ), // icon
                                                  Text(AppLocalizations.of(context)!.info, style: whiteTextStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),), // text
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                              // Contraseña Adalt Dreta
                              Positioned(
                                  top: 0,
                                  bottom: 250,
                                  left: 230,
                                  right: 0,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox.fromSize(
                                        size: _iconSize, // button width and height
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
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.settings,
                                                    color: Colors.white,
                                                    size: 35.0,
                                                  ), // icon
                                                  Text(AppLocalizations.of(context)!.settings, style: whiteTextStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),), // text
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                              // Entrenos Mig Esquerra
                              Positioned(
                                  top: 0,
                                  bottom: 0,
                                  left: 0,
                                  right: 300,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox.fromSize(
                                        size: _iconSize, // button width and height
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
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.event_note,
                                                    color: Colors.white,
                                                    size: 35.0,
                                                  ), // icon
                                                  Text(AppLocalizations.of(context)!.sessions, style: whiteTextStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),), // text
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                              // Analisis Mig Dreta
                              Positioned(
                                  top: 0,
                                  bottom: 0,
                                  left: 300,
                                  right: 0,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox.fromSize(
                                        size: _iconSize, // button width and height
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
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.leaderboard_outlined,
                                                    color: Colors.white,
                                                    size: 35.0,
                                                  ), // icon
                                                  Text(AppLocalizations.of(context)!.stats, style: whiteTextStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),), // text
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                              // Feedback Abaix Esquerra
                              Positioned(
                                  top: 250,
                                  bottom: 0,
                                  left: 0,
                                  right: 230,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox.fromSize(
                                        size: _iconSize, // button width and height
                                        child: ClipOval(
                                          child: Material(
                                            color: yellowColor, // button color
                                            child: InkWell(
                                              splashColor: Colors.white, // splash color
                                              onTap: () {
                                                setState(() {
                                                  _statusButtons[4] = !_statusButtons[4];
                                                  _showPerfiClientModals(4);
                                                });
                                              }, // button pressed
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.help_outline,
                                                    color: Colors.white,
                                                    size: 35.0,
                                                  ), // icon
                                                  Text(AppLocalizations.of(context)!.feedback, style: whiteTextStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),), // text
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                              // Bug Abaix Dreta
                              Positioned(
                                  top: 250,
                                  bottom: 0,
                                  left: 230,
                                  right: 0,
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox.fromSize(
                                        size: _iconSize, // button width and height
                                        child: ClipOval(
                                          child: Material(
                                            color: yellowColor, // button color
                                            child: InkWell(
                                              splashColor: Colors.white, // splash color
                                              onTap: () {
                                                setState(() {
                                                  _statusButtons[5] = !_statusButtons[5];
                                                  _showPerfiClientModals(5);
                                                });
                                              }, // button pressed
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.report_problem_outlined,
                                                    color: Colors.white,
                                                    size: 35.0,
                                                  ), // icon
                                                  Text(AppLocalizations.of(context)!.reporting, style: whiteTextStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),), // text
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
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
                      height: 40,
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
                          style: whiteTextStyle.copyWith(fontSize: 17.0),
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

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }
}
