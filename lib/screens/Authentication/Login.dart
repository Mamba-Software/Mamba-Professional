import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/data/AuthService.dart';
import 'package:mamba_castelldefels/globals/Constants.dart';
import 'package:mamba_castelldefels/globals/Loading.dart';

class Login extends StatefulWidget {

  final Function toggleView;
  Login({ required this.toggleView });

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Authentication Service
  final AuthenticationService _authenticationService = AuthenticationService();
  // Global Constant
  static const backgroundColor = Color(0xFFF4AD1F);
  bool loading = false;
  // FormVariables
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';

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
                    width: 180,
                    height: 135,
                    child: Image.asset('assets/images/mamba-logo.jpg')),
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
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                ),
                Container(
                  height: 50,
                  width: 250,
                  decoration: BoxDecoration(
                      color: Color(0xFF200758), borderRadius: BorderRadius.circular(20)
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
                        'Nuevo usuario? Crea tu cuenta',
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