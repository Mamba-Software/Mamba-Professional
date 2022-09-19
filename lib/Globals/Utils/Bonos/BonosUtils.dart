import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/LibraryModels/lColor.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/BonoRequest.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../Data/LibraryModels/lDegradate.dart';
import '../../../Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/AddEditBono.dart';
import '../../Widgets/Components/Images/CircularImage.dart';

//BonosUtils Class is used to administrate all the bonos
class BonosUtils {

  var _lDegradate = new lDegradate();
  var _lColor = new lColor();

  //Function to transform documents to bonos
  List<Bono> documentsToBonos(
      List<DocumentSnapshot> documents, int ordenSelection) {
    List<Bono> bonos = [];
    for (int i = 0; i < documents.length; i++) {
      Bono bono = Bono.fromObjectAllData(documents[i].id, documents[i]);
      bonos.add(bono);
    }

    if(ordenSelection == 2) {
      bonos.sort((a, b) {
        if (b.isActive!) {
          return 1;
        }
        return -1;
      });
    }
    if(ordenSelection == 1) {
      bonos.sort((a, b) {
        if (b.isActive!) {
          return -1;
        }
        return 1;
      });
    }
    if(ordenSelection == 0) {
      bonos.sort((a, b) {
        return a.title.toString().toLowerCase().compareTo(b.title.toString().toLowerCase());
      });
    }
    if(ordenSelection == 3) {
      bonos.sort((a, b) {
        if (b.isActive!) {
          return -1;
        }
        return 1;
      });
    }


    return bonos;
  }

  //Function to transform documents to bonos request
  List<BonoRequest> documentsToBonosRequests(List<DocumentSnapshot> documents) {
    List<BonoRequest> bonosRequests = [];
    for (int i = 0; i < documents.length; i++) {
      BonoRequest bonoRequest = BonoRequest.fromObjectAllData(documents[i].id, documents[i]);
      bonosRequests.add(bonoRequest);
    }
    return bonosRequests;
  }

  Widget bonoObject(var context, Bono _bono, Brand brand, var _lColor) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width * 0.0,
          horizontal: MediaQuery.of(context).size.width * 0.065),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: MediaQuery.of(context).size.width * 0.50,
            width: MediaQuery.of(context).size.width * 0.85,
            decoration:  _bono.isDegradate! ?  BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(int.parse(_lDegradate.getlDegradate(_bono.color!).hexa1!)).withOpacity(_bono.opacity!),
                    Color(int.parse(_lDegradate.getlDegradate(_bono.color!).hexa2!)).withOpacity(_bono.opacity!),
                  ],
                ),

                 image: _bono.imageUrl != null && _bono.imageUrl != ''? DecorationImage(
                  opacity: 225,

                  image:  NetworkImage(_bono.imageUrl!),
                  fit: BoxFit.cover,
                ) : null,


                //color: Color(int.parse(_lColor.getlColor(_bono.color!).hexa!)),
                borderRadius:
                    const BorderRadius.all(const Radius.circular(15))) : BoxDecoration(
                image: _bono.imageUrl != null && _bono.imageUrl != ''? DecorationImage(
                  opacity: 225,

                  image:  NetworkImage(_bono.imageUrl!),
                  fit: BoxFit.cover,
                ) : null,
                color: Color(int.parse(_lColor.getlColor(_bono.color!).hexa!)).withOpacity(_bono.opacity!),
                borderRadius:
                const BorderRadius.all(const Radius.circular(15))),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.015,
                left: MediaQuery.of(context).size.height * 0.03),
            child: Align(
              alignment: Alignment.topLeft,
              child: CircularImage(
                size: MediaQuery.of(context).size.width * 0.10,
                image: brand.logoUrl,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.02,
                right: MediaQuery.of(context).size.height * 0.03),
            child: Align(
              alignment: Alignment.topRight,
              child: Text(
                brand.name!.toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .headline3
                    ?.copyWith(fontWeight: FontWeight.normal, color: Colors.white),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.15,
                left: MediaQuery.of(context).size.height * 0.005),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.width * 0.05,
                    horizontal: MediaQuery.of(context).size.width * 0.005),
                child: ListTile(
                    title: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.01,
                          left: MediaQuery.of(context).size.height * 0.01),
                      child: Text(
                        _bono.title!.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .headline1
                            ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.01,
                          left: MediaQuery.of(context).size.height * 0.01),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                right: MediaQuery.of(context).size.height * 0.02),
                            child: Text(
                              _bono.price!.toString().toUpperCase() + '€',
                              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Text(
                            _bono.classes!.toString().toUpperCase() +
                                ' ' +
                                AppLocalizations.of(context)!
                                    .sessions
                                    .toUpperCase(),
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bonoObjectSmall(var context, Bono bono, Brand brand) {
    return SizedBox(
      height:  MediaQuery.of(context).size.width * 0.10,
      width: MediaQuery.of(context).size.width * 0.30,
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.width * 0.0,
            horizontal: MediaQuery.of(context).size.width * 0.065),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              height:  MediaQuery.of(context).size.width * 0.50,
              width: MediaQuery.of(context).size.width * 0.85,
              decoration:  bono.isDegradate! ?  BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(int.parse(_lDegradate.getlDegradate(bono.color!).hexa1!)).withOpacity(bono.opacity!),
                      Color(int.parse(_lDegradate.getlDegradate(bono.color!).hexa2!)).withOpacity(bono.opacity!),
                    ],
                  ),

                  image: bono.imageUrl != null && bono.imageUrl != ''? DecorationImage(
                    opacity: 225,

                    image:  NetworkImage(bono.imageUrl!),
                    fit: BoxFit.cover,
                  ) : null,


                  //color: Color(int.parse(_lColor.getlColor(bono.color!).hexa!)),
                  borderRadius:
                  const BorderRadius.all(const Radius.circular(5))) : BoxDecoration(
                  image: bono.imageUrl != null && bono.imageUrl != ''? DecorationImage(
                    opacity: 225,

                    image:  NetworkImage(bono.imageUrl!),
                    fit: BoxFit.cover,
                  ) : null,
                  color: Color(int.parse(_lColor.getlColor(bono.color!).hexa!)).withOpacity(bono.opacity!),
                  borderRadius:
                  const BorderRadius.all(const Radius.circular(5))),
            ),

            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.015,
                  left: MediaQuery.of(context).size.height * 0.03),
              child: Align(
                alignment: Alignment.topLeft,
                child: CircularImage(
                  size: MediaQuery.of(context).size.width * 0.10,
                  image: brand.logoUrl,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02,
                  right: MediaQuery.of(context).size.height * 0.03),
              child: Align(
                alignment: Alignment.topRight,
                child: Text(
                  brand.name!.toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .headline3
                      ?.copyWith(fontWeight: FontWeight.normal, color: Colors.white),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.13,
                  left: MediaQuery.of(context).size.height * 0.005),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.width * 0.01,
                      horizontal: MediaQuery.of(context).size.width * 0.005),
                  child: ListTile(
                      title: Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.01,
                            left: MediaQuery.of(context).size.height * 0.01),
                        child: Text(
                          bono.title!.toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .headline1
                              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.01,
                            left: MediaQuery.of(context).size.height * 0.01),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  right: MediaQuery.of(context).size.height * 0.02),
                              child: Text(
                                bono.price!.toString().toUpperCase() + '€',
                                style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Text(
                              bono.classes!.toString().toUpperCase() +
                                  ' ' +
                                  AppLocalizations.of(context)!
                                      .sessions
                                      .toUpperCase(),
                              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width * 0.27),
                            Icon(
                              Icons.more_horiz_outlined,
                              size: MediaQuery.of(context).size.width * 0.07,
                            ),
                          ],
                        ),
                      )),

                ),
              ),
            ),


          ],
        ),
      ),
    );
  }

  Widget bonoObjectDesactivated(var context, Bono _bono, Brand brand, var _lColor, var _brandDataService) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width * 0.01,
          horizontal: MediaQuery.of(context).size.width * 0.065),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
              height: MediaQuery.of(context).size.width * 0.60,
              width: MediaQuery.of(context).size.width * 0.85,
              decoration:  _bono.isDegradate! ?  BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(int.parse(_lDegradate.getlDegradate(_bono.color!).hexa1!)).withOpacity(_bono.opacity!),
                      Color(int.parse(_lDegradate.getlDegradate(_bono.color!).hexa2!)).withOpacity(_bono.opacity!),
                    ],
                  ),

                  image: _bono.imageUrl != null && _bono.imageUrl != '' ? DecorationImage(
                    opacity: 225,

                    image:  NetworkImage(_bono.imageUrl!),
                    fit: BoxFit.cover,
                  ) : null,


                  //color: Color(int.parse(_lColor.getlColor(_bono.color!).hexa!)),
                  borderRadius:
                  const BorderRadius.all(const Radius.circular(15))) : BoxDecoration(
                  image: _bono.imageUrl != null && _bono.imageUrl != ''? DecorationImage(
                    opacity: 225,

                    image:  NetworkImage(_bono.imageUrl!),
                    fit: BoxFit.cover,
                  ) : null,
                  color: Color(int.parse(_lColor.getlColor(_bono.color!).hexa!)).withOpacity(_bono.opacity!),
                  borderRadius:
                  const BorderRadius.all(const Radius.circular(15)))
          ),
          Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.015,
                left: MediaQuery.of(context).size.height * 0.03),
            child: Align(
              alignment: Alignment.topLeft,
              child: CircularImage(
                size: MediaQuery.of(context).size.width * 0.10,
                image: brand.logoUrl,
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.02,
                right: MediaQuery.of(context).size.height * 0.03),
            child: Align(
              alignment: Alignment.topRight,
              child: Text(
                brand.name!.toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .headline3
                    ?.copyWith(fontWeight: FontWeight.normal, color: Colors.white),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.15,
                left: MediaQuery.of(context).size.height * 0.005),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.width * 0.05,
                    horizontal: MediaQuery.of(context).size.width * 0.005),
                child: ListTile(
                    title: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.01,
                          left: MediaQuery.of(context).size.height * 0.01),
                      child: Text(
                        _bono.title!.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .headline1
                            ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.01,
                          left: MediaQuery.of(context).size.height * 0.01),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                right: MediaQuery.of(context).size.height * 0.02),
                            child: Text(
                              _bono.price!.toString().toUpperCase() + '€',
                              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Text(
                            _bono.classes!.toString().toUpperCase() +
                                ' ' +
                                AppLocalizations.of(context)!
                                    .sessions
                                    .toUpperCase(),
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    )),
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.width * 0.60,
            width: MediaQuery.of(context).size.width * 0.85,
            decoration:  BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius:
                BorderRadius.all(Radius.circular(15))),
            child:  GestureDetector(
                onTap: () {
                  _bono.isActive = !_bono.isActive!;
                  _brandDataService.updateBonoActive(brand.id!, _bono.id!, _bono.isActive!);
                },
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: MediaQuery.of(context).size.width * 0.1,
                    width: MediaQuery.of(context).size.width * 0.32,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                        ),
                        borderRadius:
                        const BorderRadius.all(const Radius.circular(20))),
                    child: Align(
                      alignment: Alignment.center,
                      //padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06, vertical: MediaQuery.of(context).size.width * 0.02),
                      child: Text(
                        _bono.isActive!? 'Desactivar'.toUpperCase() : 'Activar'.toUpperCase(),
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),// 0: Light, 1: Dark

          ),

        ],
      ),
    );
  }

  Widget bonoObjectOpen(var context, Bono _bono, Brand brand, var _lColor, var _brandDataService) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width * 0.01,
          horizontal: MediaQuery.of(context).size.width * 0.065),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: MediaQuery.of(context).size.width * 1.5,
            width: MediaQuery.of(context).size.width * 0.85,
              decoration:  _bono.isDegradate! ?  BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(int.parse(_lDegradate.getlDegradate(_bono.color!).hexa1!)).withOpacity(_bono.opacity!),
                      Color(int.parse(_lDegradate.getlDegradate(_bono.color!).hexa2!)).withOpacity(_bono.opacity!),
                    ],
                  ),

                  image: _bono.imageUrl != null && _bono.imageUrl != '' ? DecorationImage(
                    opacity: 225,

                    image:  NetworkImage(_bono.imageUrl!),
                    fit: BoxFit.cover,
                  ) : null,


                  //color: Color(int.parse(_lColor.getlColor(_bono.color!).hexa!)),
                  borderRadius:
                  const BorderRadius.all(const Radius.circular(15))) : BoxDecoration(
                  image: _bono.imageUrl != null && _bono.imageUrl != ''? DecorationImage(
                    opacity: 225,

                    image:  NetworkImage(_bono.imageUrl!),
                    fit: BoxFit.cover,
                  ) : null,
                  color: Color(int.parse(_lColor.getlColor(_bono.color!).hexa!)).withOpacity(_bono.opacity!),
                  borderRadius:
                  const BorderRadius.all(const Radius.circular(15)))
          ),
          Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.015,
                left: MediaQuery.of(context).size.height * 0.03),
            child: Align(
              alignment: Alignment.topLeft,
              child: CircularImage(
                size: MediaQuery.of(context).size.width * 0.10,
                image: brand.logoUrl,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.02,
                right: MediaQuery.of(context).size.height * 0.03),
            child: Align(
              alignment: Alignment.topRight,
              child: Text(
                brand.name!.toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .headline3
                    ?.copyWith(fontWeight: FontWeight.normal, color: Colors.white),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.15,
                left: MediaQuery.of(context).size.height * 0.005),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.width * 0.05,
                    horizontal: MediaQuery.of(context).size.width * 0.005),
                child: ListTile(
                    title: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.01,
                          left: MediaQuery.of(context).size.height * 0.01),
                      child: Text(
                        _bono.title!.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .headline1
                            ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.01,
                          left: MediaQuery.of(context).size.height * 0.01),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                right: MediaQuery.of(context).size.height * 0.02),
                            child: Text(
                              _bono.price!.toString().toUpperCase() + '€',
                              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Text(
                            _bono.classes!.toString().toUpperCase() +
                                ' ' +
                                AppLocalizations.of(context)!
                                    .sessions
                                    .toUpperCase(),
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    )),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.30,
                    left: MediaQuery.of(context).size.height * 0.035,
                right: MediaQuery.of(context).size.height * 0.04),
                child: Text(
                  _bono.description!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2?.copyWith(color: Colors.white),
                  textAlign: TextAlign.left,
                  maxLines: 4,
                  overflow: TextOverflow.visible,

                ),
              ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.60,
                  right: MediaQuery.of(context).size.height * 0.01),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      if(_brandDataService is !String) {
                        navigateToAddBonosScreen(context, _bono, brand);
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.03,
                          horizontal: MediaQuery.of(context).size.height * 0.01),
                      child: Container(
                        height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.32,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                            ),
                            borderRadius:
                            const BorderRadius.all(const Radius.circular(20))),
                        child: Align(
                          alignment: Alignment.center,
                          //padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06, vertical: MediaQuery.of(context).size.width * 0.02),
                          child: Text(
                            AppLocalizations.of(context)!
                                .edit.toUpperCase(),
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if(_brandDataService is !String) {
                        _bono.isActive = !_bono.isActive!;
                        _brandDataService.updateBonoActive(
                            brand.id!, _bono.id!, _bono.isActive!);
                      }
                      },
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.03,
                          right: MediaQuery.of(context).size.height * 0.02),

                      child: Container(
                        height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.32,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                            ),
                            borderRadius:
                            const BorderRadius.all(const Radius.circular(20))),
                        child: Align(
                          alignment: Alignment.center,
                          //padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06, vertical: MediaQuery.of(context).size.width * 0.02),
                          child: Text(
                            _bono.isActive!? 'Desactivar'.toUpperCase() : 'Activar'.toUpperCase(),
                            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Navigate to Add Bonos
  void navigateToAddBonosScreen(Bono bono, var context, Brand brand) {
    Navigator.push(
        context,
        CupertinoPageRoute<Null>(
          builder: (context) => AddEditBono(
            brand: brand, bono: bono, edit: true,
          ),
        ));
  }
}
