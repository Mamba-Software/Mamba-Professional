import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mamba_castelldefels/Data/databaseAccess.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/Styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegistrarMarca extends StatefulWidget {
  const RegistrarMarca({Key? key}) : super(key: key);

  @override
  _RegistrarMarcaState createState() => _RegistrarMarcaState();
}

class _RegistrarMarcaState extends State<RegistrarMarca> {
  //DataBase Access
  var _accessDatabase = new DatabaseAccess();
  // Booleans
  bool basicInfo = false;

  // Form Values
  final _formBasicInfoKey = GlobalKey<FormState>();
  final _formBasicInfoKey2 = GlobalKey<FormState>();
  String nameBrand = "";
  String descriptionTemp = "";
  var nameBrandController;
  var descriptionController;
  // Image Picker
  var _image;

  // Selects image from Gallery and updates in firebase.
  Future getImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(image!.path);
    });
    retrieveLostData();
  }
  // Retrieve lost data of Gallery if it crashes becasue of Android.
  Future<void> retrieveLostData() async {
    final LostDataResponse response =
    await ImagePicker().retrieveLostData();
    if (response == null) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image = response.file;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crea tu Marca", style: Styles.whiteTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 22),),
        centerTitle: true,
        elevation: 10,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
      ),
      backgroundColor: Styles.white,
      body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                            child: new Text(
                              "Información Básica",
                              style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            height: MediaQuery.of(context).size.height * 0.2,
                            child: Center(
                              child: _image == null ?
                              RawMaterialButton(
                                onPressed: getImage,
                                child: new Icon(
                                  Icons.photo_library,
                                  color: Styles.accent,
                                  size: 35.0,
                                ),
                                shape: new CircleBorder(),
                                elevation: 4.0,
                                fillColor: Colors.white,
                                padding: EdgeInsets.all(50),
                              ):
                              GestureDetector(
                                onTap: getImage,
                                child: Stack(
                                  children: <Widget>[
                                    Center(
                                        child: Container(
                                            width: MediaQuery.of(context).size.width*0.35,
                                            decoration: new BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Styles.mainColor, width: 2.0),
                                              image: new DecorationImage(
                                                image: FileImage(_image),
                                                fit: BoxFit.fitWidth,
                                              ),
                                            )
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Form(
                            key: _formBasicInfoKey,
                            child: Expanded(
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: new Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          new Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              new Text(
                                                "Nombre",
                                                style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                  ),
                                  Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: new Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          new Flexible(
                                            child: new TextFormField(
                                              controller: nameBrandController,
                                              validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.nameCompletoError : null,
                                              onChanged: (val) {
                                                setState(() => {
                                                  nameBrand = val
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText: AppLocalizations.of(context)!.nameCompleto,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Form(
                              key: _formBasicInfoKey2,
                              child: Expanded(
                                child: new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        child: new Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            new Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                new Text(
                                                  "Descripción",
                                                  style: Styles.purpleTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                    ),
                                    Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                        child: new Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            new Flexible(
                                              child: new TextFormField(
                                                  controller: descriptionController,
                                                  validator: (val) => val!.isEmpty ? AppLocalizations.of(context)!.descriptionError : null,
                                                  onChanged: (val) {
                                                    setState(() => descriptionTemp = val);
                                                  },
                                                  maxLines: 6,
                                                  decoration: Styles.textFromInputDecoration.copyWith(hintText:AppLocalizations.of(context)!.descriptionHint)
                                              ),
                                            ),
                                          ],
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )
          ),
    );
  }
}
