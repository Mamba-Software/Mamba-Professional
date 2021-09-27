import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingView.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Screens/Authentication/Login.dart';

class TieneMarcaTrainer extends StatefulWidget {
  const TieneMarcaTrainer({Key? key}) : super(key: key);

  @override
  _TieneMarcaTrainerState createState() => _TieneMarcaTrainerState();
}

class _TieneMarcaTrainerState extends State<TieneMarcaTrainer> {
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

  // Get current BrandDetails
  void getCurrentBrandDetails() async {
    currentBrand = await _accessDatabase.getCurrentBrandDetails(currentBrand.id!);
    print(currentBrand);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    isLoading = true;
    getCurrentBrandDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Calls a Modal Bottom Sheet every time an Icon is Tapped. It updates the page after closing only if there have been changes
    // inside the modal. Some set the isLoading to true (TusDatos, as the name needs to be updated in the UI), others don´t as it
    // can happen in the background (Settings)
    /*
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
     */

    return isLoading ?
    LoadingView()
        :
    SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: new Container(
              height: MediaQuery.of(context).size.height*0.5,
              //padding: EdgeInsets.only(top: 25.0, bottom: 25.0, right: 25.0, left: 25.0),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height*0.5,
                    child: new Stack(
                        alignment: Alignment.topCenter,
                        fit: StackFit.expand,
                        children: <Widget>[
                          // Logo Brand
                          Positioned(
                              top: MediaQuery.of(context).size.height*0.07,
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.3,
                                    child: Center(
                                      child: isLoading ?
                                      CircularProgressIndicator() :
                                      CircularImage(size: MediaQuery.of(context).size.height * 0.20, image: currentBrand.logoUrl, file: _image,),
                                    ),
                                  ),
                                ],
                              ),
                          ),
                          // Titol Brand
                          Positioned(
                            top: MediaQuery.of(context).size.height*0.33,
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Text("${currentBrand.name}", style: Styles.purpleTextStyle.copyWith(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center,)
                          ),
                          // Logos Flotants
                          // Perfil Adalt Esquerra
                          Positioned(
                              top: 0,
                              bottom: MediaQuery.of(context).size.height*0.35,
                              left: 0,
                              right: MediaQuery.of(context).size.width*0.45,
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
                                              //_showPerfiClientModals(0);
                                            });
                                            //_showSettingsPanel();
                                          }, // button pressed
                                          child: Icon( Icons.group_add, color: Colors.white, size: _iconSize,), // icon
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
                              left: MediaQuery.of(context).size.width*0.45,
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
                                              //_showPerfiClientModals(1);
                                            });
                                          }, // button pressed
                                          child: Icon(Icons.groups, color: Colors.white, size: _iconSize,), // icon
                                        ),
                                      ),
                                    ),
                                  ),

                                ],
                              )),
                          // Ajustes Mig Esquerra
                          Positioned(
                              top: 0,
                              bottom: 0,
                              left: 0,
                              right:  MediaQuery.of(context).size.width*0.70,
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
                                              //_showPerfiClientModals(1);
                                            });
                                          }, // button pressed
                                          child: Icon(Icons.today, color: Colors.white, size: _iconSize,), // icon
                                        ),
                                      ),
                                    ),
                                  ),

                                ],
                              )),
                          // Ajustes Mig Dreta
                          Positioned(
                              top: 0,
                              bottom: 0,
                              left: MediaQuery.of(context).size.width*0.70,
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
                                              //_showPerfiClientModals(1);
                                            });
                                          }, // button pressed
                                          child: Icon(Icons.checklist, color: Colors.white, size: _iconSize,), // icon
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
                              right: MediaQuery.of(context).size.width*0.45,
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
                                              //_showPerfiClientModals(2);
                                            });
                                          }, // button pressed
                                          child: Icon(Icons.payment, color: Colors.white, size: _iconSize,), // icon
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
                              left: MediaQuery.of(context).size.width*0.45,
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
                                              //_showPerfiClientModals(3);
                                            });
                                          }, // button pressed
                                          child: Icon(
                                            Icons.settings,
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
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Container(
              child: new Column(
                children: [
                  Text("Eventos de Hoy", style: Styles.purpleTextStyle.copyWith(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

