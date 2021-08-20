// Flutter Libs
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// Internal App Resources
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Globals/Loading.dart';
// Authentication Service
import 'package:mamba_castelldefels/Data/AuthService.dart';

// Register Widget
class Register extends StatefulWidget {
  final Function toggleView;
  Register({ required this.toggleView });

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // Authentication Service
  final AuthenticationService _authenticationService = AuthenticationService();
  // Loading Screen Boolean
  bool loading = false;
  // Switch Trainer Client
  bool isTrainer = false;
  Color textColorClient = whiteColor;
  Color textColorTrainer = purpleColor;
  FontWeight fontWeightClient = FontWeight.bold;
  FontWeight fontWeightTrainer = FontWeight.normal;
  void toggleSwitch(bool value) {
    if(isTrainer == false) {
      setState(() {
        isTrainer = true;
        textColorTrainer = whiteColor;
        fontWeightTrainer = FontWeight.bold;
        textColorClient = purpleColor;
        fontWeightClient = FontWeight.normal;
      });
    } else {
      setState(() {
        isTrainer = false;
        textColorClient = whiteColor;
        fontWeightClient = FontWeight.bold;
        textColorTrainer = purpleColor;
        fontWeightTrainer = FontWeight.normal;
      });
    }
  }
  // FormVariables
  final _formKey = GlobalKey<FormState>();
  String error = '';
  String name = '';
  String email = '';
  String password1 = '';
  String password2 = '';

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() :Scaffold(
        backgroundColor: yellowColor,
        body: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(top: 16.0),
                      width: 200,
                      height: 100,
                      child: Image.asset(logoExtended)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Text(
                          'Cliente',
                          style: TextStyle(color: textColorClient, fontSize: 22, fontWeight: fontWeightClient),
                        ),
                      ),
                      Container(
                        child: Transform.scale( scale: 2.0,
                          child: new Switch(
                            onChanged: toggleSwitch,
                            value: isTrainer,
                            activeColor: purpleColor,
                            activeTrackColor: purpleLightColor,
                            inactiveThumbColor: purpleColor,
                            inactiveTrackColor: purpleLightColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Text(
                          'Entrenador',
                          style: TextStyle(color: textColorTrainer, fontSize: 22, fontWeight: fontWeightTrainer),
                        ),
                      )
                    ],
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 16.0, bottom: 0),
                      child: TextFormField(
                        validator: (val) => val!.isEmpty ? 'Escribe tu nombre' : null,
                        onChanged: (val) {
                          setState(() => name = val);
                        },
                        decoration: textFromInputDecoration.copyWith(labelText: 'Nombre completo')
                      )
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 16.0, bottom: 0),
                      child: TextFormField(
                        validator: (val) => val!.isEmpty ? 'Escribe tu email' : null,
                        onChanged: (val) {
                          setState(() => email = val);
                        },
                        decoration: textFromInputDecoration.copyWith(labelText: 'Email')
                      )
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 16.0, bottom: 0),
                      child: TextFormField(
                        validator: (val) => val!.length < 6 ? 'Introduzca una contraseña con 6 caracteres o más' : null,
                        onChanged: (val) {
                          setState(() => password1 = val);
                        },
                        obscureText: true,
                        decoration: textFromInputDecoration.copyWith(labelText: 'Contraseña')
                      )
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 16.0, bottom: 16.0),
                    child: TextFormField(
                        validator: (val) => val == password1 ? null : 'Contraseñas no coinciden',
                        onChanged: (val) {
                          setState(() => password2 = val);
                        },
                        obscureText: true,
                        decoration: textFromInputDecoration.copyWith(labelText: 'Repite tu contraseña')
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 250,
                    decoration: BoxDecoration(
                        color: purpleColor, borderRadius: BorderRadius.circular(20)),
                    child: TextButton(
                      onPressed: () async {
                        if(_formKey.currentState!.validate()){
                          setState(() {
                            loading = true;
                          });
                          dynamic result = await _authenticationService.signUp(
                              email: email,
                              password: password1,
                              name: name,
                              isTrainer: isTrainer,
                          );
                          if (result == null) {
                            setState(() {
                              error = 'Porfavor introduce un email válido.';
                              loading = false;
                            });
                          }
                        }
                      },
                      child: Text(
                        'Registrate',
                        style: whiteTextStyle.copyWith(fontSize: 28),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 16.0),
                    child: TextButton(
                        onPressed: () {
                          widget.toggleView();
                        },
                        child: Text(
                          'Tienes una cuenta? Inicia sesión',
                          style: whiteTextStyle,
                        )
                    ),
                  ),
                 Center(
                    child: Text(
                      error,
                      style: redTextStyle.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
            ),
          ),

          ),
        ),
    );
  }
}