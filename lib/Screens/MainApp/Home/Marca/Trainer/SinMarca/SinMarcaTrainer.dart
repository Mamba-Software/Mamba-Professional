import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Widgets/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/LoadingView.dart';
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
  // Boolean isLoading
  bool isLoading = false;
  // Brand List
  List<Brand> brandList = [];
  // Codigo
  var _codigo;
  bool codigoError = false;
  bool codigoClicked = false;
  bool isLoadingCodigo = false;
  var _codigoController = TextEditingController();

  // init Widget state. Loading user info.
  @override
  void initState() {
    isLoading = true;
    getAllBrands();
    super.initState();
  }

  Future<void> getAllBrands() async {
    brandList = await _accessDatabase.getAllBrands();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: MediaQuery.of(context).size.width*0.01,),
            Container(
                width: MediaQuery.of(context).size.width*0.30,
                child: Image.asset(Constants.logoExtendedYellow)
            ),
          ],
        ),
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_outlined, size: 35, color: !codigoClicked ? Theme.of(context).primaryColor : Colors.white,),
            onPressed: !codigoClicked ? () {
              setState(() {
                codigoClicked = true;
              });
            } : null,
          ),
          SizedBox(width: MediaQuery.of(context).size.width*0.03,),
          IconButton(
            icon: Icon(Icons.add_circle_outline, size: 35, color: Theme.of(context).primaryColor,),
            onPressed: () async {
              Navigator.push(
                  context,
                  CupertinoPageRoute<Null>(
                    builder: (context) => RegistrarMarca(
                      locale: Localizations.localeOf(context),
                    ),
                    settings: RouteSettings(name: 'RegistrarMarca'),
                  )
              );
            },
          ),
          SizedBox(width: MediaQuery.of(context).size.width*0.03,)
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            codigoClicked ? Container(
              height: MediaQuery.of(context).size.height*0.09,
              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.01),
              child: Column(
                children: [
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                      child: Row(
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
                                        Future.delayed(const Duration(milliseconds: 500), () {
                                          setState(() {
                                            isLoadingCodigo = false;
                                            codigoError = true;
                                          });
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
            ) : Container(),
            ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: brandList.length,
                itemBuilder: (context, int index) {
                  Brand brand = brandList[index];
                  return Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height*0.02),
                      Container(
                        height: MediaQuery.of(context).size.height*0.05,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircularImage(
                                size: MediaQuery.of(context).size.width*0.10,
                                image: brand.logoUrl,
                                color: Theme.of(context).accentColor,
                                borderWidth: 1.5,
                              ),
                              SizedBox(width: MediaQuery.of(context).size.width*0.03),
                              Expanded(
                                child: Text(
                                  brand.name!,
                                  style: Styles.purpleTextStyle.copyWith(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.35,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          image: new DecorationImage(
                            fit: BoxFit.cover,
                            image: Image.asset(Constants.mySessionsImage).image,
                          ),
                        ),
                        child: Center(),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      Row(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height*0.08,
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.calendar_today_outlined, size: 30, color: Theme.of(context).primaryColor),
                                        padding: EdgeInsets.all(0),
                                        onPressed: () {

                                        },
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!.calendar,
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 14),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.groups_outlined, size: 35, color: Theme.of(context).primaryColor),
                                        padding: EdgeInsets.all(0),
                                        onPressed: () {

                                        },
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!.members,
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 14),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.send_outlined, size: 35, color: Theme.of(context).primaryColor),
                                        padding: EdgeInsets.all(0),
                                        onPressed: () {

                                        },
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!.join,
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 14),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.question_answer_outlined, size: 35, color: Theme.of(context).primaryColor),
                                        padding: EdgeInsets.all(0),
                                        onPressed: () {

                                        },
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!.contact,
                                        style: Styles.purpleTextStyle.copyWith(fontSize: 14),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.02),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                        child: RichText(
                          text: TextSpan(
                            style: Styles.purpleTextStyle.copyWith(fontSize: 16),
                            children: [
                              TextSpan(text: '${brand.name!} ', style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),),
                              TextSpan(text: brand.description!),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.memberSince(brand.dateJoined!),
                                style: Styles.purpleTextStyle.copyWith(fontSize: 12, color: Colors.grey),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.02),
                    ],
                  );
                }
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.01),
          ],
        ),
      ),
    );
  }
}
