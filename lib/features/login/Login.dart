import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'Register.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  static const backgroundColor = Color(0xFFF4AD1F);
  //static const backgroundColor = Color(0xFF200758);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 80.0),
              child: Container(
                  width: 180,
                  height: 135,
                  child: Image.asset('assets/images/mamba-logo.jpg')),
            ),
            Padding(
              padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 16.0, bottom: 0),
              child: TextField(
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF200758), width: 2.5),
                      borderRadius: BorderRadius.circular(13.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF200758), width: 2.5),
                      borderRadius: BorderRadius.circular(13.0),
                    ),
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Color(0xFF200758)),
                ),
              )
            ),
            Padding(
              padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 16.0, bottom: 0),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF200758), width: 2.5),
                    borderRadius: BorderRadius.circular(13.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF200758), width: 2.5),
                    borderRadius: BorderRadius.circular(13.0),
                  ),
                  labelText: 'Contraseña',
                  labelStyle: TextStyle(color: Color(0xFF200758)),
                ),
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
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => HomePage()));
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
                    Navigator.push(
                      context, MaterialPageRoute(builder: (_) => Register()));
                  },
                  child: Text(
                    'Nuevo usuario? Crea tu cuenta',
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  )
                ),
            ),
          ],
        ),
      )
    );
  }
}