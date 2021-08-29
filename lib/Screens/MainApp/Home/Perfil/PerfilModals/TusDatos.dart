import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Providers/ClientProvider.dart';
import 'package:provider/provider.dart';

class TusDatos extends StatefulWidget {
  const TusDatos({Key? key}) : super(key: key);

  @override
  _TusDatosState createState() => _TusDatosState();
}

class _TusDatosState extends State<TusDatos> {
  bool _editStatus = false;
  // Form Values
  final _formKey = GlobalKey<FormState>();
  String nombreCompletoTemp = "";
  String emailTemp = "";
  final nombreCompletoController = TextEditingController(text: currentUser.name);
  final emailController = TextEditingController(text: currentUser.email);

  @override
  Widget build(BuildContext context) {
    return Container(
      //height: screenHeight+100,
      padding: MediaQuery.of(context).viewInsets,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: purpleColor),
                  onPressed: () => {Navigator.of(context).pop()},
                ),
                Text('Tus Datos', style: purpleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
                !_editStatus ? IconButton(
                    icon: Icon(Icons.edit, color: purpleColor),
                    onPressed: () => {
                      setState(() => _editStatus = !_editStatus)
                    }
                ) :
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.save, color: Colors.green),
                      onPressed: () => {
                        setState(() {
                          if(_formKey.currentState!.validate()){
                            if (!nombreCompletoTemp.isEmpty) currentUser.name = nombreCompletoTemp;
                            if (!emailTemp.isEmpty) currentUser.email = emailTemp;
                            Provider.of<ClientProvider>(context, listen: false).updateClientFirebase(currentUser);
                            _editStatus = !_editStatus;
                            FocusScope.of(context).requestFocus(new FocusNode());
                          }
                        })
                      },
                    ),
                    SizedBox.fromSize(
                      size: Size(10, 0),
                    ),
                    IconButton(
                      icon: Icon(Icons.highlight_off, color: Colors.red),
                      onPressed: () => {
                        setState(() {
                          nombreCompletoController.text = currentUser.name;
                          emailController.text = currentUser.email;
                          _editStatus = !_editStatus;
                          FocusScope.of(context).requestFocus(new FocusNode());
                        })
                      },
                    )
                  ],
                ),
              ],
            ),
            new Container(
              child: Padding(
                padding: EdgeInsets.only(bottom: 25.0),
                child: Form(
                  key: _formKey,
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
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
                                  enabled: _editStatus,
                                  autofocus: _editStatus,
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
                                  enabled: _editStatus,
                                  autofocus: _editStatus,
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

/*
   */

// !_editStatus ? _getActionButtons() : new Container(),

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
                    /*setState(() {
                      if(_formKey.currentState!.validate()){
                        if (!nombreCompletoTemp.isEmpty) currentUser.name = nombreCompletoTemp;
                        if (!emailTemp.isEmpty) currentUser.email = emailTemp;
                        Provider.of<ClientProvider>(context, listen: false).updateClientFirebase(currentUser);
                        _status = true;
                        FocusScope.of(context).requestFocus(new FocusNode());
                      }
                    });
                     */
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
                  },
                )),
          ),
          flex: 2,
        ),
      ],
    ),
  );
}
