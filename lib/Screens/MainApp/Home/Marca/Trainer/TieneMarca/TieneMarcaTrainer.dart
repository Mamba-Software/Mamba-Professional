import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingView.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Marca/Trainer/TieneMarca/TieneMarcaModals/AjustesMarca.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Marca/Trainer/TieneMarca/TieneMarcaModals/AnadirMiembro.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Marca/Trainer/TieneMarca/TieneMarcaModals/Calendario.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Marca/Trainer/TieneMarca/TieneMarcaModals/HistorialSesiones.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Marca/Trainer/TieneMarca/TieneMarcaModals/Subscripciones.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Marca/Trainer/TieneMarca/TieneMarcaModals/TodosMiembros.dart';

class TieneMarcaTrainer extends StatefulWidget {
  const TieneMarcaTrainer({Key? key}) : super(key: key);

  @override
  _TieneMarcaTrainerState createState() => _TieneMarcaTrainerState();
}

class _TieneMarcaTrainerState extends State<TieneMarcaTrainer> {
  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  // List Bool Status
  List<bool> _statusButtons =  [false, false, false, false, false, false];
  // Size of Icons
  final _globusSize = 20.0;
  final _iconSize = 40.0;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Calls a Modal Bottom Sheet every time an Icon is Tapped. It updates the page after closing only if there have been changes
    // inside the modal. Some set the isLoading to true (TusDatos, as the name needs to be updated in the UI), others don´t as it
    // can happen in the background (Settings)
    void _showPerfiClientModals(int _buttonIndex) async {
      switch (_buttonIndex) {
        case 0:
          showModalBottomSheet<bool>(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return AnadirMiembro();
              }
          ).whenComplete(() =>{
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
                return TodosMiembros();
              }
          ).whenComplete(() =>{
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
                return Calendario();
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
                return HistorialSesiones();
              }).whenComplete(() => {
            setState(() {
              _statusButtons[3] = !_statusButtons[3];
            })
          });
          break;
        case 4:
          showModalBottomSheet(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return Subscripciones();
              }).whenComplete(() => {
            setState(() {
              _statusButtons[4] = !_statusButtons[4];
            })
          });
          break;
        case 5:
          showModalBottomSheet(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return AjustesMarca();
              }).whenComplete(() => {
            setState(() {
              _statusButtons[5] = !_statusButtons[5];
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

    return SingleChildScrollView(
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
                                      child: CircularImage(size: MediaQuery.of(context).size.height * 0.20, image: currentBrand.logoUrl),
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
                            child: Text("${currentBrand.name}", style: Styles.purpleTextStyle.copyWith(fontSize: 23, fontWeight: FontWeight.bold), textAlign: TextAlign.center,)
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
                                        Icon(Icons.group_add, color: Colors.white, size: _iconSize,), // icon
                                      ],
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: !_statusButtons[0] ? Styles.mainColor : Styles.mainColorTrans,
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
                              bottom: MediaQuery.of(context).size.height*0.35,
                              left: MediaQuery.of(context).size.width*0.45,
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
                                        Icon(Icons.groups, color: Colors.white, size: _iconSize,), // icon
                                      ],
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: !_statusButtons[1] ? Styles.mainColor : Styles.mainColorTrans,
                                      elevation: 5,
                                      shape: CircleBorder(),
                                      padding: EdgeInsets.all(_globusSize),
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
                                        Icon(Icons.today, color: Colors.white, size: _iconSize,), // icon
                                      ],
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: !_statusButtons[2] ? Styles.mainColor : Styles.mainColorTrans,
                                      elevation: 5,
                                      shape: CircleBorder(),
                                      padding: EdgeInsets.all(_globusSize),
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
                                        Icon(Icons.checklist, color: Colors.white, size: _iconSize,), // icon
                                      ],
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: !_statusButtons[3] ? Styles.mainColor : Styles.mainColorTrans,
                                      elevation: 5,
                                      shape: CircleBorder(),
                                      padding: EdgeInsets.all(_globusSize),
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
                                  OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _statusButtons[4] = !_statusButtons[4];
                                        _showPerfiClientModals(4);
                                      });
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.payment, color: Colors.white, size: _iconSize,), // icon
                                      ],
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: !_statusButtons[4] ? Styles.mainColor : Styles.mainColorTrans,
                                      elevation: 5,
                                      shape: CircleBorder(),
                                      padding: EdgeInsets.all(_globusSize),
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
                                  OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _statusButtons[5] = !_statusButtons[5];
                                        _showPerfiClientModals(5);
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
                                      backgroundColor: !_statusButtons[5] ? Styles.mainColor : Styles.mainColorTrans,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              child: new Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Eventos de Hoy", style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

