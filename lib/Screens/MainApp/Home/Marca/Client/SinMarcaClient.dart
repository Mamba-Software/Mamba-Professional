import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';

class SinMarcaClient extends StatefulWidget {
  const SinMarcaClient({Key? key}) : super(key: key);

  @override
  _SinMarcaClientState createState() => _SinMarcaClientState();
}

class _SinMarcaClientState extends State<SinMarcaClient> {

  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  bool codigoClicked = false;
  bool isLoadingCodigo = false;
  // FormVariables
  var ubicacionController =  TextEditingController();
  var _codigoController = TextEditingController();
  var _codigo;
  bool codigoError = false;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  !codigoClicked ?
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        setState(() {
                          codigoClicked = !codigoClicked;
                        });
                      },
                      backgroundColor: Colors.green,
                      icon: Icon(
                        Icons.qr_code_outlined,
                        size: 40,
                        color: Colors.white,
                      ),
                      label: Text(AppLocalizations.of(context)!.addCode,
                        style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ) :
                  Padding(
                      padding: EdgeInsets.all(8),
                      child: new Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Flexible(
                            child: Material(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13)
                              ),
                              elevation: 5,
                              child: new TextFormField(
                                controller: _codigoController,
                                onChanged: (val) {
                                  setState(() {
                                    codigoError = false;
                                    _codigo = val;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.codigo,
                                  hintStyle: Styles.whiteTextStyle.copyWith(fontSize: 14, color: codigoError ? Colors.red: Colors.green),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: codigoError ? Colors.red: Colors.green, width: 1.0),
                                    borderRadius: BorderRadius.circular(13.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: codigoError ? Colors.red: Colors.green, width: 1.0),
                                    borderRadius: BorderRadius.circular(13.0),
                                  ),
                                ),
                                style: Styles.whiteTextStyle.copyWith(fontSize: 14, color: codigoError ? Colors.red: Colors.green),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          !isLoadingCodigo ?
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 15.0),
                                child: FloatingActionButton(
                                  child: Icon(Icons.login),
                                  backgroundColor: Colors.green,
                                  foregroundColor: Styles.white,
                                  onPressed: () async {
                                    if(_codigo == null || _codigo=="") {
                                      setState(() {
                                        codigoError = true;
                                      });
                                    } else {
                                      setState(() {
                                        isLoadingCodigo = true;
                                      });
                                      var result = await _accessDatabase.checkIfBrandExists(_codigo);
                                      if (!result) {
                                        setState(() {
                                          isLoadingCodigo = false;
                                          codigoError = true;
                                        });
                                      } else {
                                        await _accessDatabase.updateCurrentUserBrand(_codigo);
                                        Navigator.pushReplacement(
                                            context,
                                            CupertinoPageRoute<Null>(
                                              builder: (context) =>
                                                  SplashScreen(),
                                              settings: RouteSettings(
                                                  name: 'SplashScreen'),
                                            )
                                        );
                                      }
                                    }
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
                                      codigoError = false;
                                      _codigoController.text = "";
                                    });
                                  },
                                ),
                              ),
                            ],
                          )
                              :
                          SizedBox(
                            width: 130,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                FloatingActionButton(
                                    heroTag: null,
                                    child: SizedBox(
                                      width: 100,
                                      child: Padding(
                                        padding: const EdgeInsets.all(18.0),
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                    backgroundColor: Colors.orangeAccent,
                                    foregroundColor: Styles.white,
                                    onPressed: false ? () {} : null
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height*0.7,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                        "Cargando los entrenadors en tu zona...",
                        style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold)
                    ),
                    SizedBox(height: 20,),
                    LoadingViewPurple(),
                  ],
                ),
              ),
            )
          ],
        )
    );
  }
}
