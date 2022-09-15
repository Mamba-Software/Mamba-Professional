import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Payments/PaymentDataService.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/BonoRequest.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Utils/Bonos/BonosUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Bonos/BonoObject.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Images/CircularImage.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Events/SelectEventUsers/BonosDEL%C3%87.dart';

import '../../../../Data/LibraryModels/lColor.dart';
import '../../../../Data/LibraryModels/lDegradate.dart';
import '../../../../Screens/MambaPro/HasBrandScreens/02-Que/005-Bonos/AddEditBono.dart';
import '../../GroupOfComponents/Dialogs/ActionDialogs/RequestBonoConfirmationDialog.dart';

class BonoRequestObject extends StatefulWidget {
  Bono bono;
  Usuario user;
  BonoRequest bonoRequest;
  String brandId;

  BonoRequestObject({Key? key, required this.bono,required this.user,required this.bonoRequest, required this.brandId }) : super(key: key);

  @override
  bonoRequestObjectState createState() => new bonoRequestObjectState();
}

class bonoRequestObjectState extends State<BonoRequestObject> {

  var _lDegradate = new lDegradate();
  var _lColor = new lColor();
  Bono bono = new Bono();
  Usuario user = Usuario();
  BonoRequest bonoRequest = BonoRequest();
  Brand brand = Brand();
  final _brandDataService = BrandDataService();

  var _bonoUtils = new BonosUtils();
  String bonoSee = 'nadie';

  var _paymentDataService = new PaymentDataService();

  @override
  void initState() {
    bono = widget.bono;
    user = widget.user;
    bonoRequest = widget.bonoRequest;

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return  GestureDetector(

      onTap: () async {
        Purchase purchase = new Purchase();
        int? paymentMethod = await showDialog(
            context: context,
            builder: (_) {
              return RequestBonoConfirmationDialog(
                text: 'Si aceptas se le otorgaran ' + bonoRequest.classes! + ' sesiones',
                userId: user.id!,
              );
            }
        );

        if(paymentMethod != null) {
          if (paymentMethod >= 0) {
            print('create');
            purchase.purchasedAt = Timestamp.now();
            purchase.brandId = widget.brandId;
            purchase.bonoId = bonoRequest.bonoId;
            purchase.price = double.parse(bonoRequest.price!);
            purchase.userId = bonoRequest.userId!;
            purchase.paymentMethod = paymentMethod;

            _paymentDataService.addPurchaseToPayments(purchase);
            //await _brandDataService.addUserToBrand( _bonoRequest.userId!, widget.brandId, 0);
            //_userDataService.addBonoToUser(widget.brandId, _bonoRequest.userId!, _bonoRequest.bonoId!, int.parse(_bonoRequest.classes!), Timestamp.now());
            //_userDataService.deleteUserBonoRequest(_bonoRequest.userId!, widget.brandId, _bonoRequest.bonoId!);
            _brandDataService.deleteBrandBonoRequest( widget.brandId, bonoRequest.bonoId!);
            _brandDataService.updateBonoCompras(widget.brandId, bonoRequest.bonoId!);
          }
          else if (paymentMethod == -1) {
            _brandDataService.deleteBrandBonoRequest( widget.brandId, bonoRequest.bonoId!);
          }
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05, vertical: MediaQuery.of(context).size.width*0.04),
        child: Column(
          children: [
            ListTile(
                leading: CircularImage(
                  size: MediaQuery.of(context).size.width*0.15,
                  image: user.imageUrl!,
                  color: Theme.of(context).primaryColor,
                  borderWidth: 1,
                ),
                title: Text(
                  user.name!,
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                ),
                trailing: _bonoUtils.bonoObjectSmall(context, bono, currentBrand),
            ),
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.width*0.04),
              child: Divider(
                thickness: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}