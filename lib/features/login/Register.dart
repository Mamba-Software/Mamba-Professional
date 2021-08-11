import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/data/AuthService.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  static const backgroundColor = Color(0xFFF4AD1F);
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
  // Create New User
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController1 = TextEditingController();
  TextEditingController passwordController2 = TextEditingController();
  TextStyle nameStyle = TextStyle(color: Color(0xFF200758));
  TextStyle emailStyle = TextStyle(color: Color(0xFF200758));
  TextStyle password1Style = TextStyle(color: Color(0xFF200758));
  TextStyle password2Style = TextStyle(color: Color(0xFF200758));
  // Verification New User
  void fieldsNormalColors(){
    setState(() {
      nameStyle = TextStyle(color: Color(0xFF200758));
      emailStyle = TextStyle(color: Color(0xFF200758));
      password1Style = TextStyle(color: Color(0xFF200758));
      password2Style = TextStyle(color: Color(0xFF200758));
    });
  }
  bool isFieldEmpty() {
    bool aux = false;
    if(nameController.text == "") {
      aux = true;
      setState(() {
        nameStyle = TextStyle(color: Colors.red);
      });
    }
    if(emailController.text == "") {
      aux = true;
      setState(() {
        emailStyle = TextStyle(color: Colors.red);
      });
    }
    if(passwordController1.text == "") {
      aux = true;
      setState(() {
        password1Style = TextStyle(color: Colors.red);
      });
    }
    if(passwordController2.text == "") {
      aux = true;
      setState(() {
        password2Style = TextStyle(color: Colors.red);
      });
    }
    return aux;
  }
  bool isPasswordDiferent(String s1, String s2) {
    print("isPasswordDiferent:");
    if(s1 == s2) {
      print("NO");
      return false;
    }
    setState(() {
      password1Style = TextStyle(color: Colors.red);
      password2Style = TextStyle(color: Colors.red);
    });
    passwordController1.clear();
    passwordController2.clear();
    print("YES");
    return true;

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
                      controller: nameController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF200758), width: 2.5),
                          borderRadius: BorderRadius.circular(13.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF200758), width: 2.5),
                          borderRadius: BorderRadius.circular(13.0),
                        ),
                        labelText: 'Nombre completo',
                        labelStyle: nameStyle,
                      ),
                    )
                ),
                Padding(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 16.0, bottom: 0),
                    child: TextField(
                      controller: emailController,
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
                        labelStyle: emailStyle,
                      ),
                    )
                ),
                Padding(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 16.0, bottom: 0),
                    child: TextField(
                      controller: passwordController1,
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
                        labelStyle: password1Style,
                      ),
                    )
                ),
                Padding(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 16.0, bottom: 16.0),
                    child: TextField(
                      controller: passwordController2,
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
                        labelStyle: password2Style
                      ),
                    ),
                  ),
                Container(
                  height: 50,
                  width: 250,
                  decoration: BoxDecoration(
                      color: Color(0xFF200758), borderRadius: BorderRadius.circular(20)),
                  child: TextButton(
                    onPressed: () {
                      if (isFieldEmpty() == false) {
                        fieldsNormalColors();
                        if (isPasswordDiferent(passwordController1.text.trim(),passwordController2.text.trim())) {
                          context.read<AuthenticationService>().signUp(
                            email: emailController.text.trim(),
                            password: passwordController1.text.trim(),
                          );
                        }
                      }
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