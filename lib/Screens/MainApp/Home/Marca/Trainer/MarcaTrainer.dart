import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Marca/Trainer/RegistrarMarca.dart';


class MarcaTrainer extends StatefulWidget {
  const MarcaTrainer({Key? key}) : super(key: key);

  @override
  _MarcaTrainerState createState() => _MarcaTrainerState();
}

class _MarcaTrainerState extends State<MarcaTrainer> {
  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  // Boolean Loading
  bool isLoading = false;
  bool codigoClicked = false;
  // Model Usuario
  Usuario? user;
  // FormVariables
  final _formKey = GlobalKey<FormState>();
  var _codigoController = TextEditingController();
  var _codigo;

  // init Widget state. Loading user info.
  @override
  void initState() {
    super.initState();
    isLoading = true;
    getUser();
  }
  // Gets the user info from firebase.
  void getUser() async {
    user = await _accessDatabase.getCurrentUserDetails();
    setState(() {
      isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return isLoading ?
    LoadingView()
      :
    Container(
      child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxHeight: (MediaQuery.of(context).size.height*0.7889)*0.26,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text("¡Bienvenido a Mamba ${splitCommonName(user!.name!)}!", style: Styles.purpleTextStyle,textAlign: TextAlign.center,),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: FloatingActionButton.extended(
                        heroTag: null,
                        onPressed: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute<Null>(
                                builder: (context) => RegistrarMarca(),
                                settings: RouteSettings(name: 'RegistrarMarca'),
                              )
                          );
                        },
                        icon: Icon(Icons.add_circle, size: 40,),
                        label: Text("Crea tu Marca", style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.bold),),
                      ),
                    ),
                    !codigoClicked ? Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          setState(() {
                            codigoClicked = !codigoClicked;
                          });
                        },
                        backgroundColor: Colors.green,
                        icon: Icon(Icons.qr_code_outlined, size: 40,),
                        label: Text("Añadir Código",
                          style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ) : Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: new Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            new Flexible(
                              child: Material(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13)
                                ),
                                elevation: 5,
                                child: new TextFormField(
                                  controller: _codigoController,
                                  validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.codigo : null,
                                  onChanged: (val) {
                                    setState(() => _codigo = val);
                                  },
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!.codigo,
                                    hintStyle: Styles.whiteTextStyle.copyWith(fontSize: 14, color: Colors.green),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.green, width: 1.0),
                                      borderRadius: BorderRadius.circular(13.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.green, width: 1.0),
                                      borderRadius: BorderRadius.circular(13.0),
                                    ),
                                  ),
                                  style: Styles.whiteTextStyle.copyWith(fontSize: 14, color: Colors.green),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: FloatingActionButton(
                                child: Icon(Icons.login),
                                backgroundColor: Colors.green,
                                foregroundColor: Styles.white,
                                onPressed: () async {
                                  print("Afegir a Brand amb ID: $_codigo");
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: FloatingActionButton(
                                heroTag: null,
                                child: Icon(Icons.close),
                                backgroundColor: Colors.red,
                                foregroundColor: Styles.white,
                                onPressed: () async {
                                  setState(() {
                                    codigoClicked = !codigoClicked;
                                  });
                                },
                              ),
                            ),
                          ],
                        )
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 14.0),
                child: Text("Otros entrenadores en tu zona:", style: Styles.purpleTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),),
              ),
              Container(
                constraints: BoxConstraints(
                  maxHeight: (MediaQuery.of(context).size.height*0.7889)*0.63,
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            LoadingViewPurple(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Cargando...", style: Styles.purpleTextStyle),
                            ),
                          ],
                        ),
                  ),
                ),
                  ),
              ],
          ),
        )
    );
  }

  String splitCommonName(String name) {
    List<String> aux = name.split(" ");
    return aux[0];
  }
}
