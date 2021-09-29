import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingView.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingViewPurple.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'package:mamba_castelldefels/Screens/Authentication/SplashScreen.dart';
import 'package:mamba_castelldefels/Screens/MainApp/Home/Marca/Trainer/SinMarca/RegistrarMarca.dart';


class SinMarcaTrainer extends StatefulWidget {
  const SinMarcaTrainer({Key? key}) : super(key: key);

  @override
  _SinMarcaTrainerState createState() => _SinMarcaTrainerState();
}

class _SinMarcaTrainerState extends State<SinMarcaTrainer> {
  // Acceso a Base de Datos
  var _accessDatabase = new DatabaseAccess();
  // Boolean Loading
  bool isLoading = false;
  bool codigoClicked = false;
  bool isLoadingCodigo = false;
  // Model Usuario
  Usuario? user;
  // FormVariables
  var _codigoController = TextEditingController();
  var _codigo;
  bool codigoError = false;
  // Brand List
  List<Brand> brandList = [];

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
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: FloatingActionButton.extended(
                      heroTag: null,
                      onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute<Null>(
                              builder: (context) => RegistrarMarca(
                              ),
                              settings: RouteSettings(name: 'RegistrarMarca'),
                            )
                        );
                      },
                      icon: Icon(Icons.add_circle, size: 40,),
                      label: Text(AppLocalizations.of(context)!.createBrand, style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.bold),),
                    ),
                  ),
                  !codigoClicked ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        setState(() {
                          codigoClicked = !codigoClicked;
                        });
                      },
                      backgroundColor: Colors.green,
                      icon: Icon(Icons.qr_code_outlined, size: 40,),
                      label: Text(AppLocalizations.of(context)!.addCode,
                        style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ) : Padding(
                      padding: EdgeInsets.all(8),
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
                                          await _accessDatabase
                                              .updateCurrentUserBrand(
                                              _codigo);
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
                            ) :
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
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(AppLocalizations.of(context)!.trainersZone, style: Styles.purpleTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _accessDatabase.getAllBrands(),
                        builder: (context, snapshot) {
                          //if(snapshot == null || snapshot.data == null || snapshot.data.documents == null ) return EmptyView();
                          //else if(snapshot.hasError) return ErrorView();
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return LoadingView();
                          } else {
                            brandList = documentsToBrands(snapshot.data!.docs);
                            return ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                              scrollDirection: Axis.vertical,
                              itemCount: brandList.length,
                              itemBuilder: (context, int index) => BrandTile(brandList[index]),
                            );
                          }
                        }
                      ),
                    ),
                ),
              ),
              ],
          ),
        )
    );
  }

  List<Brand> documentsToBrands(List<DocumentSnapshot> documents) {
    List<Brand> brands = [];
    for(int i = 0; i < documents.length; i++) {
      brands.add(Brand.fromObject(documents[i], documents[i].id));
    }
    return brands;
  }

}

class BrandTile extends StatelessWidget{
  final Brand brand;
  BrandTile(this.brand);
  @override
  Widget build(BuildContext context) {
    return new Card(
      margin: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
      child: ListTile(
        leading: CircularImage(size: MediaQuery.of(context).size.width*0.15, image: brand.logoUrl, borderWidth: 0),
        title: Text(brand.name!,style: TextStyle(fontSize: 20.0),),
        subtitle: Text("Admin Tool"),
        onTap: () {

        },
      ),
    );
  }
}
