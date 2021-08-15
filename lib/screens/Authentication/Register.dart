import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/data/AuthService.dart';
import 'package:mamba_castelldefels/globals/Constants.dart';
import 'package:mamba_castelldefels/globals/Loading.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  Register({ required this.toggleView });

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthenticationService _authenticationService = AuthenticationService();
  static const backgroundColor = Color(0xFFF4AD1F);
  bool loading = false;
  // Switch Trainer Client
  bool isTrainer = false;
  Color textColorClient = Colors.white;
  Color textColorTrainer = Color(0xFF200758);
  FontWeight fontWeightClient = FontWeight.bold;
  FontWeight fontWeightTrainer = FontWeight.normal;
  void toggleSwitch(bool value) {
    if(isTrainer == false) {
      setState(() {
        isTrainer = true;
        textColorTrainer = Colors.white;
        fontWeightTrainer = FontWeight.bold;
        textColorClient = Color(0xFF200758);
        fontWeightClient = FontWeight.normal;
      });
    } else {
      setState(() {
        isTrainer = false;
        textColorClient = Colors.white;
        fontWeightClient = FontWeight.bold;
        textColorTrainer = Color(0xFF200758);
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
        backgroundColor: backgroundColor,
        body: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(top: 16.0),
                      width: 180,
                      height: 135,
                      child: Image.asset('assets/images/mamba-logo.jpg')),
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
                            activeColor: Color(0xFF200758),
                            activeTrackColor: Color(0x8F190763),
                            inactiveThumbColor: Color(0xFF200758),
                            inactiveTrackColor: Color(0xA6190763),
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
                        color: Color(0xFF200758), borderRadius: BorderRadius.circular(20)),
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
                        style: TextStyle(color: Colors.white, fontSize: 25),
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
                          style: TextStyle(color: Colors.white, fontSize: 17),
                        )
                    ),
                  ),
                 Center(
                    child: Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 17, fontWeight: FontWeight.bold),
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