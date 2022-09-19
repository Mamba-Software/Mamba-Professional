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
import 'package:mamba_castelldefels/Globals/Utils/Date/DateTimeUtils.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Bonos/BonoCard.dart';
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
  Brand brand;

  BonoRequestObject({Key? key, required this.bono,required this.user,required this.bonoRequest, required this.brand }) : super(key: key);

  @override
  bonoRequestObjectState createState() => bonoRequestObjectState();
}

class bonoRequestObjectState extends State<BonoRequestObject> {

  Bono bono = Bono();
  Usuario user = Usuario();
  BonoRequest bonoRequest = BonoRequest();
  Brand brand = Brand();
  final _brandDataService = BrandDataService();

  final _bonoUtils = BonosUtils();

  final _paymentDataService = PaymentDataService();

  @override
  void initState() {
    bono = widget.bono;
    user = widget.user;
    brand = widget.brand;
    bonoRequest = widget.bonoRequest;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.all(MediaQuery.of(context).size.width*0.05),
      minLeadingWidth: MediaQuery.of(context).size.width*0.15,
      leading: CircularImage(
        size: MediaQuery.of(context).size.width*0.15,
        image: user.imageUrl,
        color: Theme.of(context).primaryColor,
        borderWidth: 1.0,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            user.name!,
            style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.requestSent(DateTimeUtils().formatDateTimeToStringDDMMYYYY(bonoRequest.timeRequested!.toDate(), Localizations.localeOf(context).languageCode)),
            style: Theme.of(context).textTheme.caption,
            textAlign: TextAlign.left,
          ),
        ],
      ),
      trailing: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: MediaQuery.of(context).size.width*0.17,
          child: BonoCard(
            height: MediaQuery.of(context).size.height*0.05,
            width: MediaQuery.of(context).size.width*0.17,
            bono: bono,
            brand: brand,
            canExpand: false,
            onlyView: true,
          ),
        ),
      ),
      onTap: () async {
        Purchase purchase = Purchase();
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
            purchase.brandId = widget.brand.id!;
            purchase.bonoId = bonoRequest.bonoId;
            purchase.price = double.parse(bonoRequest.price!);
            purchase.userId = bonoRequest.userId!;
            purchase.paymentMethod = paymentMethod;

            _paymentDataService.addPurchaseToPayments(purchase);
            //await _brandDataService.addUserToBrand( _bonoRequest.userId!, widget.brandId, 0);
            //_userDataService.addBonoToUser(widget.brandId, _bonoRequest.userId!, _bonoRequest.bonoId!, int.parse(_bonoRequest.classes!), Timestamp.now());
            //_userDataService.deleteUserBonoRequest(_bonoRequest.userId!, widget.brandId, _bonoRequest.bonoId!);
            _brandDataService.deleteBrandBonoRequest(widget.brand.id!, bonoRequest.bonoId!);
            _brandDataService.updateBonoCompras(widget.brand.id!, bonoRequest.bonoId!);
          }
          else if (paymentMethod == -1) {
            _brandDataService.deleteBrandBonoRequest(widget.brand.id!, bonoRequest.bonoId!);
          }
        }
      },
    );
  }
}