// Flutter Libs
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// Internal Apop Tools
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Models/Trainer.dart';
import 'package:mamba_castelldefels/Providers/AuthenticationProvider.dart';
import 'package:mamba_castelldefels/Providers/TrainerProvider.dart';
import 'package:provider/provider.dart';

class PerfilTrainer extends StatefulWidget {
  const PerfilTrainer({Key? key}) : super(key: key);

  @override
  _PerfilTrainerState createState() => _PerfilTrainerState();
}

class _PerfilTrainerState extends State<PerfilTrainer> {
  // List Bool Status
  bool _status = true;
  List<bool> _statusButtons =  [false, false, false, false, false, false];
  final FocusNode myFocusNode = FocusNode();
  // Form Values
  final _formKey = GlobalKey<FormState>();
  String nombreCompletoTemp = "";
  String emailTemp = "";
  final nombreCompletoController = TextEditingController(text: currentUser.name);
  final emailController = TextEditingController(text: currentUser.email);

  @override
  Widget build(BuildContext context) {
    final _authProvider = Provider.of<AuthenticationProvider>(context);
    void _showPerfiClientModals(int _buttonIndex) {
      showModalBottomSheet(context: context, builder: (context) {
        switch (_buttonIndex) {
          case 0:
            return Container(
              height: screenHeight*0.5,
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
              child: Text('Tus Datos', style: purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24),),
            );
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
            return Container();
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
                                    size: Size(80, 80), // button width and height
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
                                              Text("Datos", style: whiteTextStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),), // text
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
                                    size: Size(80, 80), // button width and height
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
                                                Icons.lock_outline,
                                                color: Colors.white,
                                                size: 35.0,
                                              ), // icon
                                              Text("Privacidad", style: whiteTextStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),), // text
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
                                    size: Size(80, 80), // button width and height
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
                                              Text("Sesiones", style: whiteTextStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),), // text
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
                                    size: Size(80, 80), // button width and height
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
                                              Text("Análisis", style: whiteTextStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),), // text
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
                                    size: Size(80, 80), // button width and height
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
                                              Text("Feedback", style: whiteTextStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),), // text
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
                                    size: Size(80, 80), // button width and height
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
                                              Text("Errores", style: whiteTextStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),), // text
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
                      Text("Miembro desde:", style: purpleTextStyle),
                      Text(" 29/08/2021", style: purpleTextStyle.copyWith(fontStyle: FontStyle.italic),),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top:5.0, bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Entrenador de: ", style: purpleTextStyle),
                      Text("Roldan Coach", style: purpleTextStyle.copyWith(fontWeight: FontWeight.bold),),
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
                      'Cerrar Sesión',
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

  /* Informacion Personal Form
  new Container(
                    color: whiteColor,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 25.0),
                      child: Form(
                        key: _formKey,
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                                child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    new Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        new Text(
                                          'Información Personal',
                                          style: purpleTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: new Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    new Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        new Text(
                                          'Nombre Completo',
                                          style: purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 2.0),
                                child: new Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    new Flexible(
                                      child: new TextFormField(
                                        controller: nombreCompletoController,
                                        validator: (val) => val!.isEmpty ? 'Escribe tu nombre completo' : null,
                                        onChanged: (val) {
                                          setState(() => nombreCompletoTemp = val);
                                        },
                                        decoration: const InputDecoration(
                                          hintText: "Nombre Completo",
                                        ),
                                        enabled: !_status,
                                        autofocus: !_status,
                                      ),
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 25.0),
                                child: new Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    new Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        new Text(
                                          'Email',
                                          style: purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0, right: 25.0, top: 2.0),
                                child: new Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    new Flexible(
                                      child: new TextFormField(
                                        controller: emailController,
                                        validator: (val) => val!.isEmpty ? 'Escribe tu email' : null,
                                        onChanged: (val) {
                                          setState(() => emailTemp = val);
                                        },
                                        decoration: const InputDecoration(
                                          hintText: "Email",
                                        ),
                                        enabled: !_status,
                                        autofocus: !_status,
                                      ),
                                    ),
                                  ],
                                )),
                            !_status ? _getActionButtons() : new Container(),
                          ],
                        ),
                      ),
                    ),
                  )
   */

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                  child: new ElevatedButton(
                    child: new Text("Guardar", style: whiteTextStyle,),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20.0)),
                    ),
                    onPressed: () {
                      setState(() {
                        if(_formKey.currentState!.validate()){
                          if (!nombreCompletoTemp.isEmpty) currentUser.name = nombreCompletoTemp;
                          if (!emailTemp.isEmpty) currentUser.email = emailTemp;
                          Provider.of<TrainerProvider>(context, listen: false).updateTrainerFirebase(currentUser);
                          _status = true;
                          FocusScope.of(context).requestFocus(new FocusNode());
                        }
                      });
                    },
                  )),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Container(
                  child: new ElevatedButton(
                    child: new Text("Cancelar", style: whiteTextStyle,),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20.0)),
                    ),
                    onPressed: () {
                      setState(() {
                        nombreCompletoController.text = currentUser.name;
                        emailController.text = currentUser.email;
                        _status = true;
                        FocusScope.of(context).requestFocus(new FocusNode());
                      });
                    },
                  )),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

}
