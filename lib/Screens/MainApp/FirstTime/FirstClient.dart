import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/AuthService.dart';
import 'package:mamba_castelldefels/Data/Database.dart';
import 'package:mamba_castelldefels/Globals/Globals.dart';
import 'package:mamba_castelldefels/Globals/Loading.dart';

class FirstClient extends StatefulWidget {
  const FirstClient({Key? key}) : super(key: key);

  @override
  _FirstClientState createState() => _FirstClientState();
}

class _FirstClientState extends State<FirstClient> {
  // Authentication Service
  final AuthenticationService _authenticationService = AuthenticationService();
  final DatabaseService _databaseService = DatabaseService();
  // Loading Screen Boolean
  late bool loading = false;
  // Codigo Widget Boolean
  bool codigo = false;
  // FormVariables
  final _formKey = GlobalKey<FormState>();
  String key = "";
  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
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
                    padding: const EdgeInsets.all(16.0),
                    child: Text("¡ Bienvenido ${currentClient.name} !",
                      style: purpleTextStyle.copyWith(fontSize: 23, fontWeight:FontWeight.bold),
                      textAlign: TextAlign.center,),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0, bottom: 4.0),
                    child: Text("¿Formas parte de una marca de entreno personal?",
                      style: purpleTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 24.0),
                        child: FloatingActionButton(
                          child: Text("Sí", style: whiteTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              codigo = true;
                            });

                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0, bottom: 24.0),
                        child: FloatingActionButton(
                          child: Text("No", style: whiteTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          onPressed: () async {
                            setState(() {
                              loading = true;
                            });
                            await _databaseService.updateUsersData(userUID, userIsTrainer, false);
                          },
                        ),
                      ),
                    ],
                  ),
                  codigo ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
                        child: Text("! Perfecto !",
                          style: purpleTextStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 45.0, right: 45.0, top: 4.0, bottom: 0),
                        child: TextFormField(
                            validator: (val) => val!.isEmpty ? 'Introduzca su código' : null,
                            onChanged: (val) {
                              setState(() => key = val);
                            },
                            decoration: textFromInputDecoration.copyWith(labelText: 'Introduzca su código')
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FloatingActionButton.extended(
                          icon: Icon(Icons.qr_code),
                          label: Text("Vamos", style: purpleTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),),
                          backgroundColor: whiteColor,
                          foregroundColor: purpleColor,
                          onPressed: () async {
                            // TODO: validació del codi per entrar directament a formar part del grup de entrenadors.
                            //if(_formKey.currentState!.validate()){}
                            setState(() {
                              loading = true;
                            });
                            await _databaseService.updateUsersData(userUID, userIsTrainer, false);
                          },
                        ),
                      ),
                    ],
                  ) : Container(),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
