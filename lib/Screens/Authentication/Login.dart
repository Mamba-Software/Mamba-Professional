// Flutter Libs
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// Internal App Resources
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Globals/Loading.dart';
// Authentication Service
import 'package:mamba_castelldefels/Data/AuthService.dart';

// Login Widget
class Login extends StatefulWidget {

  final Function toggleView;
  Login({ required this.toggleView });

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Authentication Service
  final AuthenticationService _authenticationService = AuthenticationService();
  // Loading Screen Boolean
  bool loading = false;
  // FormVariables
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';

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
                Padding(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 13.0, bottom: 0.0),
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
                        setState(() => password = val);
                      },
                      obscureText: true,
                        decoration: textFromInputDecoration.copyWith(labelText: 'Contraseña')
                    )
                ),
                TextButton(
                  onPressed: (){
                    //TODO: FORGOT PASSWORD SCREEN GOES HERE
                  },
                  child: Text(
                    'Has olvidado tu contraseña?',
                    style: whiteTextStyle,
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
                      if(_formKey.currentState!.validate()){
                        setState(() {
                          loading = true;
                          error = '';
                        });
                        dynamic result = await _authenticationService.signIn(
                            email: email,
                            password: password
                        );
                        if (result == null) {
                          setState(() {
                            error = 'No encontramos este usuario.\n Porfavor prueba otra vez';
                            loading = false;
                          });
                        }
                      }
                    },
                    child: Text(
                      'Login',
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
                        'Nuevo usuario? Crea tu cuenta',
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