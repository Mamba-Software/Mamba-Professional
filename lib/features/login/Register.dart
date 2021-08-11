import 'package:flutter/material.dart';
import 'HomePage.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  static const backgroundColor = Color(0xFFF4AD1F);
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
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
                        labelText: 'Nombre Completo',
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
                Padding(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 16.0, bottom: 16.0),
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
                        labelText: 'Repite tu contraseña',
                        labelStyle: TextStyle(color: Color(0xFF200758)),
                      ),
                    )
                ),
                Container(
                  height: 50,
                  width: 250,
                  decoration: BoxDecoration(
                      color: Color(0xFF200758), borderRadius: BorderRadius.circular(20)),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (_) => HomePage()));
                    },
                    child: Text(
                      'Registrate',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}