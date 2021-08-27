// Flutter Libs
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// Internal Apop Tools
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Providers/TrainerProvider.dart';
import 'package:provider/provider.dart';

class PerfilTrainer extends StatefulWidget {
  const PerfilTrainer({Key? key}) : super(key: key);

  @override
  _PerfilTrainerState createState() => _PerfilTrainerState();
}

class _PerfilTrainerState extends State<PerfilTrainer> {
  // Form Status
  bool _status = true;
  final FocusNode myFocusNode = FocusNode();
  // Form Values
  final _formKey = GlobalKey<FormState>();
  String nombreCompletoTemp = "";
  String emailTemp = "";
  final nombreCompletoController = TextEditingController(text: currentUser.name);
  final emailController = TextEditingController(text: currentUser.email);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: new ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              new Container(
                padding: EdgeInsets.all(15.0),
                color: Colors.white,
                child: new Column(
                  children: <Widget>[
                    new Stack(
                        fit: StackFit.loose,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  width: 140.0,
                                  height: 140.0,
                                  decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                      image: new ExactAssetImage(fotoPerfil),
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                            ],
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: 90.0, right: 100.0),
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  new CircleAvatar(
                                    backgroundColor: Colors.red,
                                    radius: 20.0,
                                    child: new Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              )),
                        ]),
                  ],
                ),
              ),
              new Container(
                color: whiteColor,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new GestureDetector(
                          child: new CircleAvatar(
                            backgroundColor: yellowColor,
                            radius: 25.0,
                            child: new Icon(
                              Icons.help_outline,
                              color: Colors.white,
                              size: 35.0,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              print("FEEBACK PAGE");
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new GestureDetector(
                          child: new CircleAvatar(
                            backgroundColor: yellowColor,
                            radius: 25.0,
                            child: new Icon(
                              Icons.report_problem_outlined,
                              color: Colors.white,
                              size: 35.0,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              print("REPORT A BUG");
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new GestureDetector(
                          child: new CircleAvatar(
                            backgroundColor: yellowColor,
                            radius: 25.0,
                            child: new Icon(
                              Icons.lock_outline,
                              color: Colors.white,
                              size: 35.0,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              print("CAMBIAR CONTRASEÑA");
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new GestureDetector(
                          child: new CircleAvatar(
                            backgroundColor: _status ? yellowColor : Color(0x66F4AD1F),
                            radius: 25.0,
                            child: new Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 35.0,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              !_status ? _status = true : _status = false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
            ],
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
