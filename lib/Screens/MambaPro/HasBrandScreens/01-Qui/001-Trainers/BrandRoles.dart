import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/Payments/PaymentDataService.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:mamba_castelldefels/Data/Models/BonoRequest.dart';
import 'package:mamba_castelldefels/Globals/Constants.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/GroupOfComponents/Bonos/BonoRequestObject.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../Data/Models/Bono.dart';
import '../../../../../../Data/Models/Usuario.dart';
import '../../../../../../Globals/Utils/Bonos/BonosUtils.dart';
import '../../../../../../Globals/Widgets/Components/Images/CircularImage.dart';
import '../../../../../Data/Models/Purchase.dart';
import '../../../../../Globals/Widgets/GroupOfComponents/Dialogs/ActionDialogs/RequestBonoConfirmationDialog.dart';
import '../../../../../../Globals/Widgets/GroupOfComponents/LoadingViews/LoadingView.dart';


class BrandRoles extends StatefulWidget {
  String brandId;
  List<Usuario> trainers = [];

  BrandRoles({Key? key, required this.brandId, required List<Usuario> trainers}) : super(key: key);

  @override
  _BrandRolesState createState() => _BrandRolesState();
}

class _BrandRolesState extends State<BrandRoles> {
  // Acceso a Base de Datos
  final _brandDataService = BrandDataService();
  // Trainers Roles
  List<Usuario> allTrainers = [];

  @override
  initState() {
    allTrainers = widget.trainers;
    super.initState();
  }

  String getUsersFullName(Usuario user) {
    return "${user.firstName} ${user.lastName}";
  }

  String returnBrandRoleString(Usuario user) {
    switch (user.brandRole) {
      case 1:
        return AppLocalizations.of(context)!.owner;
      case 2:
        return AppLocalizations.of(context)!.administrador;
      case 3:
        return AppLocalizations.of(context)!.trainer;
      default:
        return AppLocalizations.of(context)!.trainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.bonoBuys,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: MediaQuery.of(context).size.width * 0.06,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: allTrainers.length,
          itemBuilder: (context, index) {
            Usuario user = allTrainers[index];
            return ListTile(
              leading: CircularImage(
                size: MediaQuery.of(context).size.width*0.15,
                image: user.imageUrl,
                color: Theme.of(context).primaryColor,
                borderWidth: 1.0,
              ),
              title: Text(
                getUsersFullName(user),
                style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    returnBrandRoleString(user),
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor, size: MediaQuery.of(context).size.height*0.03,),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(0),
                onPressed: false ? () {
                } : null,
              ),
              onTap: null,
            );
          }
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
